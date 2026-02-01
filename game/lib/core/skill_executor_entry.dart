part of 'skill_executor.dart';

// ===== ENTRY (DUELIST) SKILLS =====

/// Stun: Stun enemy on target tile (3 tiles away, cardinal)
SkillResult _executeBreachPulse(
  GameState state,
  UnitState caster,
  String? targetTileId,
  VisionSystem visionSystem,
) {
  if (targetTileId == null) {
    return SkillResult(
      success: false,
      updatedState: state,
      description: 'Select target tile for Breach Pulse',
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

  // Check range using movement rules (BFS, 3 steps)
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
    3,
    occupiedTiles,
    includeOccupied: true,
  );
  if (!reachable.contains(targetTileId)) {
    return SkillResult(success: false, updatedState: state, description: 'Target out of range');
  }

  final affectedUnits = <String>[];
  final enemyTeam = caster.team == TeamId.attacker ? TeamId.defender : TeamId.attacker;

  var updatedUnits = List<UnitState>.from(state.units);
  for (var i = 0; i < updatedUnits.length; i++) {
    final unit = updatedUnits[i];
    if (unit.team != enemyTeam || !unit.alive) continue;
    if (unit.posTileId != targetTileId) continue;

    updatedUnits[i] = _addStatus(unit, StatusType.stunned, 3);
    affectedUnits.add(unit.unitId);
  }

  // Consume skill
  final casterIndex = updatedUnits.indexWhere((u) => u.unitId == caster.unitId);
  if (casterIndex >= 0) {
    updatedUnits[casterIndex] = _consumeSkill(updatedUnits[casterIndex], SkillSlot.skill1);
  }

  final stunEffects = [
    EffectInstance(
      id: 'stun_${DateTime.now().millisecondsSinceEpoch}_$targetTileId',
      type: EffectType.stun,
      ownerUnitId: caster.unitId,
      team: caster.team,
      tileId: targetTileId,
      remainingTurns: 2,
      totalTurns: 2,
    ),
  ];

  return SkillResult(
    success: true,
    updatedState: state.copyWith(units: updatedUnits, effects: [...state.effects, ...stunEffects]),
    description: affectedUnits.isEmpty
        ? 'Stun: No enemy on tile'
        : 'Stun: Enemy disabled!',
    affectedUnitIds: affectedUnits,
    affectedTileIds: [targetTileId],
  );
}

/// Dash: Create smoke at target tile (4 away) and move there
SkillResult _executeDash(
  GameState state,
  UnitState caster,
  String? targetTileId,
  VisionSystem visionSystem,
) {
  if (targetTileId == null) {
    return SkillResult(
      success: false,
      updatedState: state,
      description: 'Select target tile for Dash',
    );
  }

  final tileMap = {for (final t in state.map.tiles) t.id: t};
  final casterTile = tileMap[caster.posTileId];
  final targetTile = tileMap[targetTileId];
  if (casterTile == null || targetTile == null || !targetTile.walkable) {
    return SkillResult(success: false, updatedState: state, description: 'Invalid target');
  }

  // Check range using movement rules (BFS, 5 steps)
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
    5,
    occupiedTiles,
  );
  if (!reachable.contains(targetTileId)) {
    return SkillResult(success: false, updatedState: state, description: 'Target out of range');
  }

  // Check if tile is occupied by ally
  final isOccupied = state.units.any(
    (u) => u.alive && u.team == caster.team && u.posTileId == targetTileId,
  );
  if (isOccupied) {
    return SkillResult(success: false, updatedState: state, description: 'Tile is occupied');
  }

  // Reveal enemies seen during dash (from each step along the path)
  final enemyTeam = caster.team == TeamId.attacker ? TeamId.defender : TeamId.attacker;
  var updatedUnits = List<UnitState>.from(state.units);
  final path = _buildDashPath(casterTile, targetTile, tileMap, 5);

  for (var i = 0; i < updatedUnits.length; i++) {
    final unit = updatedUnits[i];
    if (!unit.alive || unit.team != enemyTeam) continue;

    final unitTile = tileMap[unit.posTileId];
    if (unitTile == null) continue;

    var seen = false;
    for (final stepTile in path) {
      final dist =
          (unitTile.row - stepTile.row).abs() + (unitTile.col - stepTile.col).abs();
      if (dist > caster.card.attackRange) {
        continue;
      }
      final stepUnit = UnitState(
        unitId: caster.unitId,
        team: caster.team,
        card: caster.card,
        hp: caster.hp,
        posTileId: stepTile.id,
        alive: caster.alive,
        activatedThisRound: caster.activatedThisRound,
        statuses: caster.statuses,
        cooldowns: caster.cooldowns,
        charges: caster.charges,
      );
      if (visionSystem.canUnitSeeTile(stepUnit, unit.posTileId, state)) {
        seen = true;
        break;
      }
    }

    if (seen) {
      updatedUnits[i] = _addStatus(unit, StatusType.revealed, 4);
    }
  }

  final enemyOnTarget = state.units.any(
    (u) => u.alive && u.team != caster.team && u.posTileId == targetTileId,
  );

  // Move caster and consume skill
  for (var i = 0; i < updatedUnits.length; i++) {
    final unit = updatedUnits[i];
    if (unit.unitId == caster.unitId) {
      final updated = UnitState(
        unitId: unit.unitId,
        team: unit.team,
        card: unit.card,
        hp: unit.hp,
        posTileId: targetTileId,
        alive: enemyOnTarget ? false : unit.alive,
        activatedThisRound: unit.activatedThisRound,
        statuses: unit.statuses,
        cooldowns: unit.cooldowns,
        charges: unit.charges,
      );
      updatedUnits[i] = _consumeSkill(updated, SkillSlot.skill2);
    }
  }

  final movedCaster = updatedUnits.firstWhere((u) => u.unitId == caster.unitId);
  var newSpike = state.spike;
  if (movedCaster.alive && state.spike.state == SpikeStateType.dropped) {
    final dropTileId = state.spike.droppedTileId;
    if (dropTileId != null) {
      final pathTileIds = <String>[
        caster.posTileId,
        for (final tile in path) tile.id,
      ];
      if (pathTileIds.contains(dropTileId)) {
        newSpike = SpikeState(
          state: SpikeStateType.carried,
          carrierUnitId: caster.unitId,
        );
      }
    }
  }

  final dashEffect = EffectInstance(
    id: 'dash_${DateTime.now().millisecondsSinceEpoch}',
    type: EffectType.dash,
    ownerUnitId: caster.unitId,
    team: caster.team,
    tileId: caster.posTileId,
    targetTileId: targetTileId,
    remainingTurns: 2,
    totalTurns: 2,
  );

  final smokeEffect = EffectInstance(
    id: 'smoke_dash_${DateTime.now().millisecondsSinceEpoch}',
    type: EffectType.smoke,
    ownerUnitId: caster.unitId,
    team: caster.team,
    tileId: targetTileId,
    remainingTurns: 3,
    totalTurns: 3,
  );

  final updatedEffects = [...state.effects, dashEffect, smokeEffect];

  return SkillResult(
    success: true,
    updatedState: state.copyWith(
      units: updatedUnits,
      effects: updatedEffects,
      spike: newSpike,
    ),
    description: 'Dash: Moved to ${targetTileId}!',
    affectedTileIds: [targetTileId],
  );
}

List<Tile> _buildDashPath(
  Tile from,
  Tile to,
  Map<String, Tile> tileMap,
  int maxSteps,
) {
  final queue = <_DashNode>[];
  final visited = <String>{};
  final parents = <String, String>{};

  queue.add(_DashNode(from.id, 0));
  visited.add(from.id);

  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    if (current.id == to.id) {
      return _reconstructDashPath(from.id, to.id, parents, tileMap);
    }
    if (current.distance >= maxSteps) continue;

    final tile = tileMap[current.id];
    if (tile == null) continue;

    final neighbors = [
      'r${tile.row - 1}c${tile.col}',
      'r${tile.row + 1}c${tile.col}',
      'r${tile.row}c${tile.col - 1}',
      'r${tile.row}c${tile.col + 1}',
    ];

    for (final neighborId in neighbors) {
      final neighbor = tileMap[neighborId];
      if (neighbor == null || !neighbor.walkable) continue;
      if (visited.contains(neighborId)) continue;
      visited.add(neighborId);
      parents[neighborId] = current.id;
      queue.add(_DashNode(neighborId, current.distance + 1));
    }
  }

  return [to];
}

List<Tile> _reconstructDashPath(
  String startId,
  String endId,
  Map<String, String> parents,
  Map<String, Tile> tileMap,
) {
  final path = <Tile>[];
  var currentId = endId;
  while (currentId != startId) {
    final tile = tileMap[currentId];
    if (tile != null) {
      path.add(tile);
    }
    final parent = parents[currentId];
    if (parent == null) break;
    currentId = parent;
  }
  return path.reversed.toList();
}

class _DashNode {
  _DashNode(this.id, this.distance);

  final String id;
  final int distance;
}
