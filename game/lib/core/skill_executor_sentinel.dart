// Sentinelロールのスキル処理を実装する。
part of 'skill_executor.dart';

// ===== SENTINEL SKILLS =====

/// Trap: Place trap that triggers on enemy movement (ends their turn, reveals position, breaks)
SkillResult _executeTrap(GameState state, UnitState caster, String? targetTileId) {
  if (targetTileId == null) {
    return SkillResult(
      success: false,
      updatedState: state,
      description: 'Select tile for Trap',
    );
  }

  final tileMap = {for (final t in state.map.tiles) t.id: t};
  final casterTile = tileMap[caster.posTileId];
  final targetTile = tileMap[targetTileId];
  if (casterTile == null || targetTile == null || !targetTile.walkable) {
    return SkillResult(success: false, updatedState: state, description: 'Invalid target');
  }
  final alreadyTrapped = state.effects.any(
    (e) => e.type == EffectType.trap && e.tileId == targetTileId,
  );
  if (alreadyTrapped) {
    return SkillResult(success: false, updatedState: state, description: 'Trap already placed');
  }

  // Check range using movement rules (BFS, 1 step)
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
    2,
    occupiedTiles,
  );
  if (!reachable.contains(targetTileId)) {
    return SkillResult(success: false, updatedState: state, description: 'Must place adjacent');
  }

  final List<UnitState> updatedUnits = state.units.map((unit) {
    if (unit.unitId == caster.unitId) {
      return _consumeSkill(unit, SkillSlot.skill1);
    }
    return unit;
  }).toList();

  // Create trap effect (persistent until triggered)
  final trapEffect = EffectInstance(
    id: 'trap_${DateTime.now().millisecondsSinceEpoch}',
    type: EffectType.trap,
    ownerUnitId: caster.unitId,
    team: caster.team,
    tileId: targetTileId,
    remainingTurns: 999, // Persistent until triggered
    totalTurns: 999,
  );

  final updatedEffects = [...state.effects, trapEffect];

  return SkillResult(
    success: true,
    updatedState: state.copyWith(units: updatedUnits, effects: updatedEffects),
    description: 'Trap placed at $targetTileId',
    affectedTileIds: [targetTileId],
  );
}

/// Check if unit stepped on trap and trigger it
/// When triggered: enemy's turn ends immediately, position is revealed, trap breaks
/// Returns: (updated state, whether trap was triggered, trapped unit id)
({GameState state, bool triggered, String? trappedUnitId}) checkTrapTrigger(
  GameState state,
  UnitState movingUnit,
) {
  // Find trap at unit's position
  final trap = state.effects.firstWhere(
    (e) => e.type == EffectType.trap && 
           e.tileId == movingUnit.posTileId &&
           e.team != movingUnit.team,
    orElse: () => EffectInstance(
      id: '',
      type: EffectType.trap,
      ownerUnitId: '',
      team: TeamId.attacker,
      tileId: '',
      remainingTurns: 0,
    ),
  );

  if (trap.id.isEmpty) {
    return (state: state, triggered: false, trappedUnitId: null);
  }

  // Trap triggered - update unit with trapped status and reveal
  var updatedUnits = List<UnitState>.from(state.units);
  for (var i = 0; i < updatedUnits.length; i++) {
    final unit = updatedUnits[i];
    if (unit.unitId == movingUnit.unitId) {
      // Add trapped status (reveals position) and mark turn as ended
      var updated = _addStatus(unit, StatusType.trapped, 1);
      updated = _addStatus(updated, StatusType.revealed, 2);
      // Mark as activated to end their turn
      updatedUnits[i] = UnitState(
        unitId: updated.unitId,
        team: updated.team,
        card: updated.card,
        hp: updated.hp,
        posTileId: updated.posTileId,
        alive: updated.alive,
        activatedThisRound: true, // Turn ends immediately
        statuses: updated.statuses,
        cooldowns: updated.cooldowns,
        charges: updated.charges,
      );
      break;
    }
  }

  // Remove trap after trigger
  final updatedEffects = state.effects.where((e) => e.id != trap.id).toList();

  return (
    state: state.copyWith(units: updatedUnits, effects: updatedEffects),
    triggered: true,
    trappedUnitId: movingUnit.unitId,
  );
}

/// Camera: Place camera that reveals area (breaks when enemy detected, 1 turn reveal)
SkillResult _executeCamera(GameState state, UnitState caster, String? targetTileId) {
  if (targetTileId == null) {
    return SkillResult(
      success: false,
      updatedState: state,
      description: 'Select tile for Camera',
    );
  }

  final tileMap = {for (final t in state.map.tiles) t.id: t};
  final casterTile = tileMap[caster.posTileId];
  final targetTile = tileMap[targetTileId];
  if (casterTile == null || targetTile == null) {
    return SkillResult(success: false, updatedState: state, description: 'Invalid target');
  }
  final alreadyCamera = state.effects.any(
    (e) => e.type == EffectType.camera && e.tileId == targetTileId,
  );
  if (alreadyCamera) {
    return SkillResult(success: false, updatedState: state, description: 'Camera already placed');
  }

  // Check range using movement rules (BFS, 2 steps)
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
    2,
    occupiedTiles,
  );
  if (!reachable.contains(targetTileId)) {
    return SkillResult(success: false, updatedState: state, description: 'Target out of range');
  }

  final List<UnitState> updatedUnits = state.units.map((unit) {
    if (unit.unitId == caster.unitId) {
      return _consumeSkill(unit, SkillSlot.skill2);
    }
    return unit;
  }).toList();

  // Create camera effect (persistent until triggered)
  final cameraEffect = EffectInstance(
    id: 'cam_${DateTime.now().millisecondsSinceEpoch}',
    type: EffectType.camera,
    ownerUnitId: caster.unitId,
    team: caster.team,
    tileId: targetTileId,
    remainingTurns: 999, // Persistent until enemy detected
    totalTurns: 999,
    range: caster.card.attackRange,
  );

  final updatedEffects = [...state.effects, cameraEffect];

  return SkillResult(
    success: true,
    updatedState: state.copyWith(units: updatedUnits, effects: updatedEffects),
    description: 'Camera placed at $targetTileId',
    affectedTileIds: [targetTileId],
  );
}

/// Check if camera detects enemy and trigger reveal (called from game loop)
/// Returns updated state with camera removed and enemy revealed for 1 turn
SkillResult checkCameraDetection(
  GameState state,
  EffectInstance camera,
  VisionSystem visionSystem,
) {
  final tileMap = {for (final t in state.map.tiles) t.id: t};
  final cameraTile = tileMap[camera.tileId];
  if (cameraTile == null) {
    return SkillResult(success: false, updatedState: state, description: 'Invalid camera');
  }

  final enemyTeam = camera.team == TeamId.attacker ? TeamId.defender : TeamId.attacker;
  final affectedUnits = <String>[];
  var updatedUnits = List<UnitState>.from(state.units);

  // Check for enemies in camera LoS (no distance limit)
  for (var i = 0; i < updatedUnits.length; i++) {
    final unit = updatedUnits[i];
    if (!unit.alive || unit.team != enemyTeam) continue;

    final unitTile = tileMap[unit.posTileId];
    if (unitTile == null) continue;

    if (visionSystem.hasLineOfSight(cameraTile, unitTile, state.map, tileMap, state: state)) {
      // Reveal enemy for 2 turns (green indicator)
      updatedUnits[i] = _addStatus(unit, StatusType.revealed, 2);
      affectedUnits.add(unit.unitId);
    }
  }

  if (affectedUnits.isEmpty) {
    return SkillResult(success: false, updatedState: state, description: 'No enemy detected');
  }

  // Remove camera after detection
  final updatedEffects = state.effects.where((e) => e.id != camera.id).toList();

  return SkillResult(
    success: true,
    updatedState: state.copyWith(units: updatedUnits, effects: updatedEffects),
    description: 'Camera detected enemy! (${affectedUnits.length} revealed)',
    affectedUnitIds: affectedUnits,
    affectedTileIds: [camera.tileId],
  );
}
