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

class GameController extends ChangeNotifier
    with SetupMixin, CombatSupportMixin, CombatMixin, SpikeMixin {
  GameController({
    required GameState state,
    RulesEngine? rulesEngine,
    VisionSystem? visionSystem,
    UnitFactory? unitFactory,
  })  : _state = state,
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

  // Duelist bonus move state
  bool _bonusMovePending = false;
  String? _bonusMoveUnitId;

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
    return visionSystem.visibleTilesForTeam(_state, _state.turnTeam);
  }

  /// Get visible enemy units for current turn team
  List<UnitState> get visibleEnemies {
    // In setup phase, enemies are invisible
    if (_state.phase == 'SetupAttacker' || _state.phase == 'SetupDefender') {
      return [];
    }
    return visionSystem.getVisibleEnemies(_state, _state.turnTeam);
  }

  /// Check if a tile is visible to current team
  bool isTileVisible(String tileId) {
    return visibleTilesForCurrentTeam.contains(tileId);
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

    if (_bonusMovePending) {
      if (_selectedUnitId == _bonusMoveUnitId && _highlightedTiles.contains(tileId)) {
        moveUnit(tileId);
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
    // Setup Phase
    if (_state.phase.startsWith('Setup')) {
       final unit = _state.units.cast<UnitState?>().firstWhere((u) => u!.unitId == unitId, orElse: () => null);
       if (unit == null) return;

       final isOwnTeam = (_state.phase == 'SetupAttacker' && unit.team == TeamId.attacker) ||
                         (_state.phase == 'SetupDefender' && unit.team == TeamId.defender);
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
      _selectedUnitId = unitId;
      notifyListeners();
      return;
    }

    // Standard Gameplay
    if (_bonusMovePending && unitId != _bonusMoveUnitId) {
      return;
    }

    if (_selectedUnitId == unitId) {
      deselectUnit();
    } else {
      selectUnit(unitId);
    }
  }
}
