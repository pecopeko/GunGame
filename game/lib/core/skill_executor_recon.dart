part of 'skill_executor.dart';

// ===== RECON (INITIATOR) SKILLS =====

/// Drone: Deploy adjacent, then move 1 tile per use (up to 10 per round)
SkillResult _executeDroneTag(
  GameState state,
  UnitState caster,
  String? targetTileId,
  VisionSystem visionSystem,
) {
  if (targetTileId == null) {
    return SkillResult(
      success: false,
      updatedState: state,
      description: 'Select target tile for Drone',
    );
  }

  final tileMap = {for (final t in state.map.tiles) t.id: t};
  final casterTile = tileMap[caster.posTileId];
  if (casterTile == null) {
    return SkillResult(success: false, updatedState: state, description: 'Invalid target');
  }

  final enemyTeam = caster.team == TeamId.attacker ? TeamId.defender : TeamId.attacker;
  final affectedUnits = <String>[];

  var updatedUnits = List<UnitState>.from(state.units);

  final targetTile = tileMap[targetTileId];
  if (targetTile == null || !targetTile.walkable) {
    return SkillResult(success: false, updatedState: state, description: 'Invalid target');
  }

  final existingDrone = state.effects.firstWhere(
    (e) => e.type == EffectType.drone && e.ownerUnitId == caster.unitId,
    orElse: () => const EffectInstance(
      id: '',
      type: EffectType.drone,
      ownerUnitId: '',
      team: TeamId.attacker,
      tileId: '',
      remainingTurns: 0,
    ),
  );

  final hasDrone = existingDrone.id.isNotEmpty;
  final currentDroneTile = hasDrone ? tileMap[existingDrone.tileId] : casterTile;
  if (currentDroneTile == null) {
    return SkillResult(success: false, updatedState: state, description: 'Invalid drone origin');
  }

  final occupiedAllies = state.units
      .where((u) => u.alive && u.team == caster.team && u.posTileId.isNotEmpty)
      .map((u) => u.posTileId)
      .toSet();
  final reachable = const Pathing().reachableTiles(
    state.map,
    currentDroneTile.id,
    1,
    occupiedAllies,
    includeOccupied: true,
  );
  if (!reachable.contains(targetTileId)) {
    return SkillResult(success: false, updatedState: state, description: 'Drone target out of range');
  }

  final remainingMoves = hasDrone ? (existingDrone.movesRemaining ?? 0) : 10;
  if (remainingMoves <= 0) {
    return SkillResult(success: false, updatedState: state, description: 'Drone out of moves');
  }

  for (var i = 0; i < updatedUnits.length; i++) {
    final unit = updatedUnits[i];
    if (!unit.alive || unit.team != enemyTeam) continue;
    final unitTile = tileMap[unit.posTileId];
    if (unitTile == null) continue;

    final dist =
        (unitTile.row - targetTile.row).abs() + (unitTile.col - targetTile.col).abs();
    final inRange = dist <= caster.card.attackRange;
    if (inRange &&
        visionSystem.hasLineOfSight(targetTile, unitTile, state.map, tileMap, state: state)) {
      updatedUnits[i] = _addStatus(unit, StatusType.revealed, 4);
      affectedUnits.add(unit.unitId);
    }
  }

  final shouldDestroy = affectedUnits.isNotEmpty;
  final nextMoves = remainingMoves - 1;

  final updatedEffects = <EffectInstance>[
    for (final effect in state.effects)
      if (effect.type != EffectType.drone || effect.ownerUnitId != caster.unitId) effect,
    if (!shouldDestroy && nextMoves > 0)
      EffectInstance(
        id: hasDrone ? existingDrone.id : 'drone_${DateTime.now().millisecondsSinceEpoch}',
        type: EffectType.drone,
        ownerUnitId: caster.unitId,
        team: caster.team,
        tileId: targetTileId!,
        remainingTurns: hasDrone ? existingDrone.remainingTurns : 2,
        totalTurns: hasDrone ? existingDrone.totalTurns : 2,
        movesRemaining: nextMoves,
        totalMoves: 10,
      ),
  ];

  if (!hasDrone) {
    final casterIndex = updatedUnits.indexWhere((u) => u.unitId == caster.unitId);
    if (casterIndex >= 0) {
      updatedUnits[casterIndex] = _consumeSkill(updatedUnits[casterIndex], SkillSlot.skill1);
    }
  }

  final finalState = state.copyWith(
    units: updatedUnits,
    effects: updatedEffects,
  );

  return SkillResult(
    success: true,
    updatedState: finalState,
    description: affectedUnits.isEmpty
        ? 'Drone: Scouting...'
        : 'Drone: Enemy revealed!',
    affectedUnitIds: affectedUnits,
    affectedTileIds: [targetTileId!],
    consumeTurn: shouldDestroy || nextMoves <= 0,
  );
}

/// Flash: Blind units in cross (2 tiles) around target (within 5 tiles)
SkillResult _executeFlash(
  GameState state,
  UnitState caster,
  String? targetTileId,
  VisionSystem visionSystem,
) {
  if (targetTileId == null) {
    return SkillResult(
      success: false,
      updatedState: state,
      description: 'Select direction for Flash',
    );
  }

  final tileMap = {for (final t in state.map.tiles) t.id: t};
  final casterTile = tileMap[caster.posTileId];
  final targetTile = tileMap[targetTileId];
  if (casterTile == null || targetTile == null) {
    return SkillResult(success: false, updatedState: state, description: 'Invalid target');
  }
  final allyOnTarget = state.units.any(
    (u) => u.alive && u.team == caster.team && u.posTileId == targetTileId,
  );
  if (allyOnTarget) {
    return SkillResult(success: false, updatedState: state, description: 'Tile is occupied');
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
    caster.card.skill2.range ?? 5,
    occupiedTiles,
    includeOccupied: true,
  );
  if (!reachable.contains(targetTileId)) {
    return SkillResult(success: false, updatedState: state, description: 'Target out of range');
  }

  final affectedUnits = <String>[];
  var updatedUnits = List<UnitState>.from(state.units);

  final affectedTileIds = <String>{};
  for (final tile in state.map.tiles) {
    final dist =
        (tile.row - targetTile.row).abs() + (tile.col - targetTile.col).abs();
    final isCross = tile.row == targetTile.row || tile.col == targetTile.col;
    if (dist <= 2 && isCross) {
      affectedTileIds.add(tile.id);
    }
  }

  for (var i = 0; i < updatedUnits.length; i++) {
    final unit = updatedUnits[i];
    if (!unit.alive) continue;
    if (affectedTileIds.contains(unit.posTileId)) {
      updatedUnits[i] = _addStatus(unit, StatusType.blinded, 3);
      affectedUnits.add(unit.unitId);
    }
  }

  final casterIndex = updatedUnits.indexWhere((u) => u.unitId == caster.unitId);
  if (casterIndex >= 0) {
    updatedUnits[casterIndex] = _consumeSkill(updatedUnits[casterIndex], SkillSlot.skill2);
  }

  final flashEffect = EffectInstance(
    id: 'flash_${DateTime.now().millisecondsSinceEpoch}',
    type: EffectType.flash,
    ownerUnitId: caster.unitId,
    team: caster.team,
    tileId: targetTileId,
    remainingTurns: 2,
    totalTurns: 2,
  );

  final updatedEffects = [...state.effects, flashEffect];

  return SkillResult(
    success: true,
    updatedState: state.copyWith(units: updatedUnits, effects: updatedEffects),
    description: affectedUnits.isNotEmpty ? 'Flash: Blinded ${affectedUnits.length}!' : 'Flash: No one hit',
    affectedUnitIds: affectedUnits,
    affectedTileIds: affectedTileIds.toList(),
  );
}
