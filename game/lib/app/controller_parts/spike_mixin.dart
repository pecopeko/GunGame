part of '../game_controller.dart';

mixin SpikeMixin on ChangeNotifier {
  GameController get _controller => this as GameController;

  /// Check if selected unit can plant the spike
  bool get canPlant {
    final unit = _controller.selectedUnit;
    if (unit == null) return false;
    if (unit.team != TeamId.attacker) return false;
    
    // Check if this unit carries the spike
    final state = _controller.state;
    if (state.spike.state != SpikeStateType.carried) return false;
    if (state.spike.carrierUnitId != unit.unitId) return false;

    // Check if on a site (A or B)
    final tileMap = {for (final t in state.map.tiles) t.id: t};
    final tile = tileMap[unit.posTileId];
    if (tile == null) return false;

    return tile.type == TileType.siteA || tile.type == TileType.siteB;
  }

  /// Check if selected unit can defuse the spike
  bool get canDefuse {
    final unit = _controller.selectedUnit;
    if (unit == null) return false;
    if (unit.team != TeamId.defender) return false;

    // Spike must be planted
    final state = _controller.state;
    if (state.spike.state != SpikeStateType.planted) return false;

    // Unit must be on the spike tile
    return unit.posTileId == state.spike.plantedTileId;
  }

  /// Plant the spike
  void plantSpike() {
    final unit = _controller.selectedUnit;
    if (unit == null || !canPlant) return;

    final state = _controller.state;
    final tileMap = {for (final t in state.map.tiles) t.id: t};
    final tile = tileMap[unit.posTileId];
    if (tile == null) return;

    final site = tile.type == TileType.siteA ? PlantSite.siteA : PlantSite.siteB;

    // Update spike state
    final newSpike = SpikeState(
      state: SpikeStateType.planted,
      plantedSite: site,
      plantedTileId: unit.posTileId,
      explosionInRounds: 4, // Explodes after 4 rounds
      defuseProgress: 0,
    );

    var newState = state.copyWith(spike: newSpike);
    _controller._turnManager.updateState(newState);

    // Advance turn
    newState = _controller._turnManager.advanceTurn(unit.unitId);
    _controller._state = newState;

    // Clear selection
    _controller.deselectUnit();
  }

  /// Start or continue defusing the spike
  void defuseSpike() {
    final unit = _controller.selectedUnit;
    if (unit == null || !canDefuse) return;

    final state = _controller.state;
    final currentProgress = state.spike.defuseProgress ?? 0;
    final newProgress = currentProgress + 1;

    var newState = state;

    if (newProgress >= 2) {
      // Defuse complete!
      final newSpike = SpikeState(
        state: SpikeStateType.defused,
        plantedSite: state.spike.plantedSite,
        plantedTileId: state.spike.plantedTileId,
      );

      newState = state.copyWith(spike: newSpike);
      _controller._winCondition = WinCondition(
        winner: TeamId.defender,
        reason: 'Spike defused!',
      );
      newState = newState.copyWith(phase: 'GameOver');
    } else {
      // Defuse in progress
      final newSpike = SpikeState(
        state: SpikeStateType.planted,
        plantedSite: state.spike.plantedSite,
        plantedTileId: state.spike.plantedTileId,
        explosionInRounds: state.spike.explosionInRounds,
        defuseProgress: newProgress,
        defusingUnitId: unit.unitId,
      );

      newState = state.copyWith(spike: newSpike);
    }

    _controller._turnManager.updateState(newState);

    // Advance turn
    newState = _controller._turnManager.advanceTurn(unit.unitId);
    _controller._state = newState;

    // Clear selection
    _controller.deselectUnit();
  }

  /// Check spike explosion at end of round (called from TurnManager)
  void checkSpikeExplosion() {
    final state = _controller.state;
    if (state.spike.state != SpikeStateType.planted) return;

    final remaining = (state.spike.explosionInRounds ?? 0) - 1;

    var newState = state;

    if (remaining <= 0) {
      // BOOM!
      final newSpike = SpikeState(
        state: SpikeStateType.exploded,
        plantedSite: state.spike.plantedSite,
        plantedTileId: state.spike.plantedTileId,
      );

      newState = state.copyWith(spike: newSpike);
      _controller._winCondition = WinCondition(
        winner: TeamId.attacker,
        reason: 'Spike exploded!',
      );
      newState = newState.copyWith(phase: 'GameOver');
    } else {
      // Update countdown
      final newSpike = SpikeState(
        state: SpikeStateType.planted,
        plantedSite: state.spike.plantedSite,
        plantedTileId: state.spike.plantedTileId,
        explosionInRounds: remaining,
        defuseProgress: state.spike.defuseProgress,
      );

      newState = state.copyWith(spike: newSpike);
    }

    _controller._state = newState;
    _controller._turnManager.updateState(newState);
    notifyListeners();
  }

  /// Get spike status for UI display
  String get spikeStatusText {
    switch (_controller.state.spike.state) {
      case SpikeStateType.unplanted:
        return 'Spike not deployed';
      case SpikeStateType.carried:
        return 'Spike being carried';
      case SpikeStateType.planted:
        final rounds = _controller.state.spike.explosionInRounds ?? 0;
        final progress = _controller.state.spike.defuseProgress ?? 0;
        if (progress > 0) {
          return 'Defusing... ($progress/2)';
        }
        return 'Spike planted! $rounds rounds left';
      case SpikeStateType.defused:
        return 'Spike defused';
      case SpikeStateType.exploded:
        return 'Spike exploded';
    }
  }
}
