part of 'skill_executor.dart';

// ===== SMOKE SKILLS =====

/// Smoke: Place smoke that blocks vision
SkillResult _executeSmoke(GameState state, UnitState caster, String? targetTileId) {
  if (targetTileId == null) {
    return SkillResult(
      success: false,
      updatedState: state,
      description: 'Select tile for Smoke',
    );
  }

  final tileMap = {for (final t in state.map.tiles) t.id: t};
  final targetTile = tileMap[targetTileId];
  if (targetTile == null || !targetTile.walkable) {
    return SkillResult(success: false, updatedState: state, description: 'Invalid target');
  }
  final occupiedTiles = state.units
      .where((u) =>
          u.alive &&
          u.team == caster.team &&
          u.posTileId.isNotEmpty)
      .map((u) => u.posTileId)
      .toSet();
  final reachable = const Pathing().reachableTiles(
    state.map,
    caster.posTileId,
    10,
    occupiedTiles,
  );
  if (!reachable.contains(targetTileId)) {
    return SkillResult(success: false, updatedState: state, description: 'Target out of range');
  }

  final List<UnitState> updatedUnits = state.units.map((unit) {
    if (unit.unitId == caster.unitId) {
      return _consumeSkill(unit, SkillSlot.skill1);
    }
    return unit;
  }).toList();

  // Create smoke effect
  final smokeEffect = EffectInstance(
    id: 'smoke_${DateTime.now().millisecondsSinceEpoch}',
    type: EffectType.smoke,
    ownerUnitId: caster.unitId,
    team: caster.team,
    tileId: targetTileId,
    remainingTurns: 10,
    totalTurns: 10,
  );

  final updatedEffects = [...state.effects, smokeEffect];

  return SkillResult(
    success: true,
    updatedState: state.copyWith(units: updatedUnits, effects: updatedEffects),
    description: 'Smoke placed at $targetTileId (10 turns)',
    affectedTileIds: [targetTileId],
  );
}
