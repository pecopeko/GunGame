part of '../game_controller.dart';

mixin SetupMixin on ChangeNotifier {
  GameController get _controller => this as GameController;

  /// Select a role to spawn (Setup Phase)
  void selectRoleToSpawn(Role role) {
    // Always set, never toggle off
    _controller._selectedRoleToSpawn = role;
    _controller._selectedUnitId = null;
    _controller._highlightedTiles = _getPlacementZones();
    notifyListeners();
  }

  // Helper for placement zones
  Set<String> _getPlacementZones() {
    final state = _controller.state;
    final isAttacker = state.phase == 'SetupAttacker';
    // Attacker: Bottom rows (10-14), Defender: Top rows (0-4)
    final minRow = isAttacker ? 10 : 0;
    final maxRow = isAttacker ? 14 : 4;

    return state.map.tiles
        .where((t) => t.row >= minRow && t.row <= maxRow && t.type != TileType.wall && t.walkable)
        .map((t) => t.id)
        .toSet();
  }

  Set<String> getPlacementZones() {
    return _getPlacementZones();
  }

  /// Spawn unit of selected role on tile
  void spawnUnit(String tileId) {
    if (_controller.selectedRoleToSpawn == null) return;
    if (!_controller.highlightedTiles.contains(tileId)) return;

    final state = _controller.state;
    final currentTeam = state.phase == 'SetupAttacker' ? TeamId.attacker : TeamId.defender;
    final teamUnits = state.units.where((u) => u.team == currentTeam).toList();
    
    // Check 5 unit limit
    if (teamUnits.length >= 5) {
      if (kDebugMode) print('Team limit reached (5 units)');
      return;
    }

    // Check if tile is occupied
    final isOccupied = state.units.any((u) => u.posTileId == tileId);
    if (isOccupied) return;

    // Generate ID
    final idSuffix = DateTime.now().millisecondsSinceEpoch; // Simple unique ID
    final unitId = '${currentTeam == TeamId.attacker ? "atk" : "def"}_$idSuffix';

    final newUnit = _controller.unitFactory.createUnit(
      id: unitId,
      team: currentTeam,
      role: _controller.selectedRoleToSpawn!,
      posTileId: tileId,
    );

    var newState = state.copyWith(units: [...state.units, newUnit]);
    
    // Spike carrier is selected after setup confirmation.
    
    _controller._state = newState;
    notifyListeners();
  }

  /// Remove unit (during setup)
  void removeUnit(String unitId) {
    final state = _controller._state;
    if (!state.phase.startsWith('Setup')) return;
    
    final unit = state.units.cast<UnitState?>().firstWhere((u) => u!.unitId == unitId, orElse: () => null);
    if (unit == null) return;

    // Check ownership
    if (state.phase == 'SetupAttacker' && unit.team != TeamId.attacker) return;
    if (state.phase == 'SetupDefender' && unit.team != TeamId.defender) return;

    // Remove
    final updatedUnits = state.units.where((u) => u.unitId != unitId).toList();
    
    // Handle Spike
    var newSpike = state.spike;
    if (unit.team == TeamId.attacker && state.spike.carrierUnitId == unitId) {
       // Pass spike to another attacker if available
       final nextAttacker = updatedUnits.cast<UnitState?>().firstWhere(
            (u) => u!.team == TeamId.attacker, 
            orElse: () => null
       );
       
       if (nextAttacker == null) {
         // No attackers left
         newSpike = const SpikeState(state: SpikeStateType.unplanted);
       } else {
         newSpike = SpikeState(state: SpikeStateType.carried, carrierUnitId: nextAttacker.unitId);
       }
    }

    _controller._state = state.copyWith(units: updatedUnits, spike: newSpike);
    _controller.deselectUnit();
  }

  /// Remove unit (during setup)
  void undoLastPlacement() {
    final state = _controller.state;
    if (!state.phase.startsWith('Setup')) return;

    final currentTeam = state.phase == 'SetupAttacker' ? TeamId.attacker : TeamId.defender;
    // Find the last added unit for this team (assuming order is preserved, which it is for lists)
    final teamUnits = state.units.where((u) => u.team == currentTeam).toList();
    if (teamUnits.isEmpty) return;

    final lastUnitId = teamUnits.last.unitId;
    removeUnit(lastUnitId);
  }

  /// Confirm placement and proceed phase
  void confirmPlacement() {
    final state = _controller.state;
    // Check if all units for current team are placed (Not strict anymore, but maybe we enforce min 1?)
    // User logic implies we can have any number up to 5. Let's assume > 0 is good.
    final currentTeam = state.phase == 'SetupAttacker' ? TeamId.attacker : TeamId.defender;
    final teamUnits = state.units.where((u) => u.team == currentTeam).toList();

    if (teamUnits.isEmpty) return; // Require at least 1 unit?

    var newState = state;

    if (state.phase == 'SetupAttacker') {
      newState = state.copyWith(
        phase: 'SelectSpikeCarrier',
        turnTeam: TeamId.attacker,
        spike: const SpikeState(state: SpikeStateType.unplanted),
      );
      _controller._turnManager.updateState(newState);
    } else if (state.phase == 'SetupDefender') {
      newState = state.copyWith(
        phase: 'Playing',
        turnTeam: TeamId.attacker,
      );
      _controller._turnManager.updateState(newState);
    }
    
    // Update state
    _controller._state = newState;
    
    // Clear ALL selections and highlights
    _controller._selectedUnitId = null;
    _controller._selectedRoleToSpawn = null;
    _controller._highlightedTiles = {};
    
    notifyListeners();
  }
  
  /// Check if placement is complete (for UI enable/disable)
  bool get isPlacementComplete {
    return true; // With dynamic placement, always allow confirm if we have units?
    // Let's refine: Attacker needs > 0 units.
    final state = _controller.state;
    final currentTeam = state.phase == 'SetupAttacker' ? TeamId.attacker : TeamId.defender;
    return state.units.any((u) => u.team == currentTeam);
  }
}
