import 'package:flutter/foundation.dart';

import '../core/entities.dart';
import '../core/map_loader.dart';
import '../core/pathing.dart';
import '../core/rules_engine.dart';
import '../core/skill_executor.dart';
import '../core/turn_manager.dart';
import '../core/vision_system.dart';
import '../core/unit_factory.dart';

part 'controller_parts/setup_mixin.dart';
part 'controller_parts/combat_mixin.dart';
part 'controller_parts/combat_support_mixin.dart';
part 'controller_parts/spike_mixin.dart';
part 'controller_parts/turn_control_mixin.dart';

class GameController extends ChangeNotifier
    with
        SetupMixin,
        CombatSupportMixin,
        CombatMixin,
        SpikeMixin,
        TurnControlMixin {
  GameController({
    required GameState state,
    RulesEngine? rulesEngine,
    VisionSystem? visionSystem,
    UnitFactory? unitFactory,
  }) : _state = state,
       rulesEngine = rulesEngine ?? const RulesEngine(),
       visionSystem = visionSystem ?? const VisionSystem(),
       pathing = const Pathing(),
       skillExecutor = const SkillExecutor(),
       unitFactory = unitFactory ?? const UnitFactory(),
       _turnManager = TurnManager(state);

  GameState _state;
  final RulesEngine rulesEngine;
  final VisionSystem visionSystem;
  final Pathing pathing;
  final SkillExecutor skillExecutor;
  final UnitFactory unitFactory;
  final TurnManager _turnManager;
  TeamId? _viewTeamOverride;
  TeamId? _onlineLocalTeam;

  // Selection state
  String? _selectedUnitId;
  Role? _selectedRoleToSpawn; // For setup phase
  Set<String> _highlightedTiles = {};
  bool _isAttackMode = false;
  Set<String> _attackableUnitIds = {};
  WinCondition? _winCondition;

  // Skill mode state
  bool _isSkillMode = false;
  SkillSlot? _activeSkillSlot;
  Set<String> _skillTargetTiles = {};

  GameState get state => _state;
  String? get selectedUnitId => _selectedUnitId;
  Role? get selectedRoleToSpawn => _selectedRoleToSpawn;
  Set<String> get highlightedTiles => _highlightedTiles;
  bool get isAttackMode => _isAttackMode;
  Set<String> get attackableUnitIds => _attackableUnitIds;
  WinCondition? get winCondition => _winCondition;
  bool get isSkillMode => _isSkillMode;
  SkillSlot? get activeSkillSlot => _activeSkillSlot;
  Set<String> get skillTargetTiles => _skillTargetTiles;
  TeamId get viewTeam => _viewTeamOverride ?? _state.turnTeam;
  TeamId? get onlineLocalTeam => _onlineLocalTeam;

  void applyExternalWinCondition(WinCondition condition) {
    _winCondition = condition;
    _state = _state.copyWith(phase: 'GameOver');
    notifyListeners();
  }

  bool get canLocalPlayerActNow {
    if (_state.phase == 'GameOver') return false;
    if (_onlineLocalTeam == null) return true;

    if (_state.phase == 'SetupAttacker')
      return _onlineLocalTeam == TeamId.attacker;
    if (_state.phase == 'SetupDefender')
      return _onlineLocalTeam == TeamId.defender;
    if (_state.phase == 'SelectSpikeCarrier')
      return _onlineLocalTeam == TeamId.attacker;
    if (_state.phase == 'Playing') return _state.turnTeam == _onlineLocalTeam;
    return true;
  }

  void setViewTeam(TeamId? team) {
    if (_viewTeamOverride == team) return;
    _viewTeamOverride = team;
    notifyListeners();
  }

  void setOnlineLocalTeam(TeamId? team) {
    if (_onlineLocalTeam == team) return;
    _onlineLocalTeam = team;
    notifyListeners();
  }

  bool get isBotOpponentActive {
    if (_viewTeamOverride == null) return false;
    return _state.phase == 'SelectSpikeCarrier' &&
        _viewTeamOverride != TeamId.attacker;
  }

  bool get isBotSetupPhase {
    if (_viewTeamOverride == null) return false;
    if (_state.phase == 'SetupAttacker') {
      return _viewTeamOverride != TeamId.attacker;
    }
    if (_state.phase == 'SetupDefender') {
      return _viewTeamOverride != TeamId.defender;
    }
    return false;
  }

  UnitState? get selectedUnit {
    if (_selectedUnitId == null) return null;
    return _state.units.cast<UnitState?>().firstWhere(
      (u) => u?.unitId == _selectedUnitId,
      orElse: () => null,
    );
  }

  /// Get visible tiles for current turn team
  Set<String> get visibleTilesForCurrentTeam {
    // In setup phase, full map is visible (but enemies are handled separately)
    if (_state.phase == 'SetupAttacker' || _state.phase == 'SetupDefender') {
      return _state.map.tiles.map((t) => t.id).toSet();
    }
    if (_state.phase == 'GameOver') {
      return _state.map.tiles.map((t) => t.id).toSet();
    }
    return visionSystem.visibleTilesForTeam(_state, viewTeam);
  }

  /// Get visible enemy units for current turn team
  List<UnitState> get visibleEnemies {
    // In setup phase, enemies are invisible
    if (_state.phase == 'SetupAttacker' || _state.phase == 'SetupDefender') {
      return [];
    }
    if (_state.phase == 'GameOver') {
      final enemyTeam = viewTeam == TeamId.attacker
          ? TeamId.defender
          : TeamId.attacker;
      return _state.units.where((u) => u.team == enemyTeam && u.alive).toList();
    }
    return visionSystem.getVisibleEnemies(_state, viewTeam);
  }

  /// Check if a tile is visible to current team
  bool isTileVisible(String tileId) {
    return visibleTilesForCurrentTeam.contains(tileId);
  }

  /// Replace game state from an external source (e.g., online sync).
  void hydrateFromExternal(GameState newState, {bool resetSelections = true}) {
    _state = newState;
    _turnManager.updateState(newState);
    _winCondition = rulesEngine.checkWinCondition(newState);

    if (resetSelections) {
      _selectedUnitId = null;
      _selectedRoleToSpawn = null;
      _highlightedTiles = {};
      _isAttackMode = false;
      _attackableUnitIds = {};
      _isSkillMode = false;
      _activeSkillSlot = null;
      _skillTargetTiles = {};
    }
    notifyListeners();
  }

  /// Initialize game with map and units
  Future<void> initializeGame() async {
    const loader = MapLoader();
    final map = await loader.loadFromAsset('assets/maps/ascent.json');

    // Start with 0 units
    final units = <UnitState>[];

    _state = _state.copyWith(
      map: map,
      units: units,
      phase: 'SetupAttacker', // Start with Attacker Setup
      turnTeam: TeamId.attacker,
      spike: const SpikeState(state: SpikeStateType.unplanted),
    );
    notifyListeners();
  }

  /// Handle tile tap
  void onTileTap(String tileId) {
    if (!canLocalPlayerActNow) return;

    // Setup Phase
    if (_state.phase.startsWith('Setup')) {
      // Check if there is a unit on this tile
      final unitOnTile = _state.units.cast<UnitState?>().firstWhere(
        (u) => u?.posTileId == tileId && u?.alive == true,
        orElse: () => null,
      );

      if (unitOnTile != null) {
        onUnitTap(unitOnTile.unitId);
        return;
      }

      // If a role is selected, try to spawn
      if (_selectedRoleToSpawn != null) {
        spawnUnit(tileId);
      }
      return;
    }

    if (_state.phase == 'SelectSpikeCarrier') {
      final unitOnTile = _state.units.cast<UnitState?>().firstWhere(
        (u) => u?.posTileId == tileId && u?.alive == true,
        orElse: () => null,
      );
      if (unitOnTile != null) {
        onUnitTap(unitOnTile.unitId);
      }
      return;
    }

    // Standard Gameplay
    // Skill mode - execute skill on target tile
    if (_isSkillMode && _skillTargetTiles.contains(tileId)) {
      executeSkill(tileId);
      return;
    }

    // Skill mode - cancel if tapping outside
    if (_isSkillMode) {
      cancelSkillMode();
      return;
    }

    if (_isAttackMode) {
      // In attack mode, tapping tile cancels attack mode
      _isAttackMode = false;
      _attackableUnitIds = {};
      notifyListeners();
      return;
    }

    // Check if there is a visible unit on this tile
    final unitOnTile = _state.units.cast<UnitState?>().firstWhere(
      (u) => u?.posTileId == tileId && u?.alive == true,
      orElse: () => null,
    );

    // If unit found and it's visible to current team (or is own unit), handle selection logic
    // We rely on visual representation, but logic-wise:
    if (unitOnTile != null) {
      if (isTileVisible(tileId)) {
        onUnitTap(unitOnTile.unitId);
        return;
      }
    }

    if (_selectedUnitId != null && _highlightedTiles.contains(tileId)) {
      moveUnit(tileId);
    }
  }

  /// Handle unit tap
  void onUnitTap(String unitId) {
    if (!canLocalPlayerActNow) return;

    // Setup Phase
    if (_state.phase.startsWith('Setup')) {
      final unit = _state.units.cast<UnitState?>().firstWhere(
        (u) => u!.unitId == unitId,
        orElse: () => null,
      );
      if (unit == null) return;

      final isOwnTeam =
          (_state.phase == 'SetupAttacker' && unit.team == TeamId.attacker) ||
          (_state.phase == 'SetupDefender' && unit.team == TeamId.defender);
      if (_onlineLocalTeam != null && unit.team != _onlineLocalTeam) {
        return;
      }
      if (isOwnTeam) {
        // User requested to disable tap-to-remove. Doing nothing.
        // removeUnit(unitId);
      }
      return;
    }

    if (_state.phase == 'SelectSpikeCarrier') {
      final unit = _state.units.cast<UnitState?>().firstWhere(
        (u) => u?.unitId == unitId,
        orElse: () => null,
      );
      if (unit == null || unit.team != TeamId.attacker) return;
      if (_onlineLocalTeam != null && unit.team != _onlineLocalTeam) return;
      _selectedUnitId = unitId;
      notifyListeners();
      return;
    }

    // Standard Gameplay
    if (_selectedUnitId == unitId) {
      deselectUnit();
    } else {
      selectUnit(unitId);
    }
  }
}
