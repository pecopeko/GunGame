part of 'skill_executor.dart';

// ===== RECON (INITIATOR) SKILLS =====

/// Drone: Deploy adjacent, then move up to 10 tiles in one use (one-round control)
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
  final originTile = casterTile;
  if (originTile == null) {
    return SkillResult(success: false, updatedState: state, description: 'Invalid drone origin');
  }

  final targetTile = tileMap[targetTileId];
  if (targetTile == null || !targetTile.walkable) {
    return SkillResult(success: false, updatedState: state, description: 'Invalid target');
  }
  final occupied = state.units.any(
    (u) => u.alive && u.team == caster.team && u.posTileId == targetTileId,
  );
  if (occupied) {
    return SkillResult(success: false, updatedState: state, description: 'Tile is occupied');
  }

  final distance = (originTile.row - targetTile.row).abs() +
      (originTile.col - targetTile.col).abs();
  if (distance == 0 || distance > 1) {
    return SkillResult(
      success: false,
      updatedState: state,
      description: 'Drone target out of range (max 1 tile)',
    );
  }

  final path = _buildDronePath(originTile, targetTile, tileMap);
  if (path == null) {
    return SkillResult(
      success: false,
      updatedState: state,
      description: 'Drone path blocked',
    );
  }

  for (final stepTile in path) {
    for (var i = 0; i < updatedUnits.length; i++) {
      final unit = updatedUnits[i];
      if (!unit.alive || unit.team != enemyTeam) continue;
      final unitTile = tileMap[unit.posTileId];
      if (unitTile == null) continue;

      final dist =
          (unitTile.row - stepTile.row).abs() + (unitTile.col - stepTile.col).abs();
      final inRange = dist <= caster.card.attackRange;
      if (inRange &&
          visionSystem.hasLineOfSight(stepTile, unitTile, state.map, tileMap, state: state)) {
        updatedUnits[i] = _addStatus(unit, StatusType.revealed, 4);
        affectedUnits.add(unit.unitId);
      }
    }
    if (affectedUnits.isNotEmpty) {
      break;
    }
  }

  final casterIndex = updatedUnits.indexWhere((u) => u.unitId == caster.unitId);
  if (casterIndex >= 0) {
    updatedUnits[casterIndex] = _consumeSkill(updatedUnits[casterIndex], SkillSlot.skill1);
  }

  final updatedEffects = <EffectInstance>[
    for (final effect in state.effects)
      if (effect.type != EffectType.drone) effect,
    EffectInstance(
      id: 'drone_${DateTime.now().millisecondsSinceEpoch}',
      type: EffectType.drone,
      ownerUnitId: caster.unitId,
      team: caster.team,
      tileId: targetTileId!,
      remainingTurns: 1,
      totalTurns: 1,
    ),
  ];

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
      updatedUnits[i] = _addStatus(unit, StatusType.blinded, 2);
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

List<Tile>? _buildDronePath(
  Tile from,
  Tile to,
  Map<String, Tile> tileMap,
) {
  final queue = <_DroneNode>[];
  final visited = <String>{};
  final parents = <String, String>{};

  queue.add(_DroneNode(from.id, 0));
  visited.add(from.id);

  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    if (current.id == to.id) {
      return _reconstructDronePath(from.id, to.id, parents, tileMap);
    }
    if (current.distance >= 10) continue;

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
      queue.add(_DroneNode(neighborId, current.distance + 1));
    }
  }

  return null;
}

List<Tile> _reconstructDronePath(
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

class _DroneNode {
  _DroneNode(this.id, this.distance);

  final String id;
  final int distance;
}
