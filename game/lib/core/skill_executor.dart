import 'entities.dart';
import 'pathing.dart';
import 'vision_system.dart';

part 'skill_executor_entry.dart';
part 'skill_executor_recon.dart';
part 'skill_executor_smoke.dart';
part 'skill_executor_sentinel.dart';

/// Result of a skill execution
class SkillResult {
  const SkillResult({
    required this.success,
    required this.updatedState,
    required this.description,
    this.affectedUnitIds = const [],
    this.affectedTileIds = const [],
  });

  final bool success;
  final GameState updatedState;
  final String description;
  final List<String> affectedUnitIds;
  final List<String> affectedTileIds;
}

/// Handles execution of all skills
class SkillExecutor {
  const SkillExecutor();

  /// Execute a skill
  SkillResult executeSkill(
    GameState state,
    UnitState caster,
    SkillSlot slot,
    String? targetTileId,
    VisionSystem visionSystem,
  ) {
    final skill = slot == SkillSlot.skill1 ? caster.card.skill1 : caster.card.skill2;

    // Check if skill is available (cooldowns/charges)
    if (!_canUseSkill(caster, slot)) {
      return SkillResult(
        success: false,
        updatedState: state,
        description: '${skill.name} is not available',
      );
    }

    // Execute based on role and skill
    switch (caster.card.role) {
      case Role.entry:
        return slot == SkillSlot.skill1
            ? _executeBreachPulse(state, caster, targetTileId, visionSystem)
            : _executeDash(state, caster, targetTileId, visionSystem);
      case Role.recon:
        return slot == SkillSlot.skill1
            ? _executeDroneTag(state, caster, targetTileId, visionSystem)
            : _executeFlash(state, caster, targetTileId, visionSystem);
      case Role.smoke:
        if (slot == SkillSlot.skill1) {
          return _executeSmoke(state, caster, targetTileId);
        }
        return SkillResult(
          success: false,
          updatedState: state,
          description: 'No logic for Skill 2',
        );
      case Role.sentinel:
        return slot == SkillSlot.skill1
            ? _executeTrap(state, caster, targetTileId)
            : _executeCamera(state, caster, targetTileId);
    }
  }

  bool _canUseSkill(UnitState unit, SkillSlot slot) {
    // Check charges
    final charges = unit.charges[slot] ?? 0;
    if (charges > 0) return true;

    // Check cooldown
    final cooldown = unit.cooldowns[slot] ?? 0;
    return cooldown == 0;
  }

  /// Get valid target tiles for a skill
  Set<String> getValidTargets(
    GameState state,
    UnitState caster,
    SkillSlot slot,
  ) {
    final skill = slot == SkillSlot.skill1 ? caster.card.skill1 : caster.card.skill2;
    final tileMap = {for (final t in state.map.tiles) t.id: t};
    final casterTile = tileMap[caster.posTileId];
    if (casterTile == null) return {};

    final occupiedTiles = state.units
        .where((u) => u.alive && u.posTileId.isNotEmpty)
        .map((u) => u.posTileId)
        .toSet();
    final occupiedAllies = state.units
        .where((u) =>
            u.alive &&
            u.team == caster.team &&
            u.posTileId.isNotEmpty)
        .map((u) => u.posTileId)
        .toSet();

    if (caster.card.role == Role.entry && slot == SkillSlot.skill1) {
      return const Pathing().reachableTiles(
        state.map,
        caster.posTileId,
        3,
        occupiedAllies,
        includeOccupied: true,
      );
    }

    if (caster.card.role == Role.entry && slot == SkillSlot.skill2) {
      return const Pathing().reachableTiles(
        state.map,
        caster.posTileId,
        5,
        occupiedAllies,
      );
    }

    if (caster.card.role == Role.recon && slot == SkillSlot.skill1) {
      final drone = state.effects.firstWhere(
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
      if (drone.id.isNotEmpty && (drone.movesRemaining ?? 0) <= 0) {
        return {};
      }
      final startTileId = drone.id.isNotEmpty ? drone.tileId : caster.posTileId;
      return const Pathing().reachableTiles(
        state.map,
        startTileId,
        1,
        occupiedAllies,
        includeOccupied: true,
      );
    }

    if (caster.card.role == Role.recon && slot == SkillSlot.skill2) {
      return const Pathing().reachableTiles(
        state.map,
        caster.posTileId,
        skill.range ?? 5,
        occupiedAllies,
        includeOccupied: true,
      );
    }

    if (caster.card.role == Role.smoke && slot == SkillSlot.skill1) {
      return const Pathing().reachableTiles(
        state.map,
        caster.posTileId,
        10,
        occupiedAllies,
        includeOccupied: true,
      );
    }

    if (caster.card.role == Role.sentinel && slot == SkillSlot.skill1) {
      return const Pathing().reachableTiles(
        state.map,
        caster.posTileId,
        1,
        occupiedAllies,
        includeOccupied: true,
      );
    }

    if (caster.card.role == Role.sentinel && slot == SkillSlot.skill2) {
      return const Pathing().reachableTiles(
        state.map,
        caster.posTileId,
        2,
        occupiedAllies,
        includeOccupied: true,
      );
    }

    final validTiles = <String>{};

    bool isCardinalTarget(Tile tile, int distance) {
      if (distance <= 0) return false;
      return casterTile.row == tile.row || casterTile.col == tile.col;
    }

    for (final tile in state.map.tiles) {
      final distance =
          (casterTile.row - tile.row).abs() + (casterTile.col - tile.col).abs();
      final occupied = occupiedTiles.contains(tile.id);

      switch (caster.card.role) {
        case Role.entry:
          if (slot == SkillSlot.skill2) {
            if (tile.walkable &&
                !state.units.any((u) => u.alive && u.posTileId == tile.id)) {
              validTiles.add(tile.id);
            }
          }
          break;
        case Role.recon:
          if (slot == SkillSlot.skill2) {
            if (distance > 0 && distance <= 5) {
              validTiles.add(tile.id);
            }
          }
          break;
        case Role.smoke:
          if (slot == SkillSlot.skill1) {
            if (tile.walkable) {
              validTiles.add(tile.id);
            }
          }
          break;
        case Role.sentinel:
          if (slot == SkillSlot.skill1) {
            if (distance == 1) {
              validTiles.add(tile.id);
            }
          } else {
            if (distance == 2 && isCardinalTarget(tile, distance)) {
              validTiles.add(tile.id);
            }
          }
          break;
      }
    }

    // Fallback for any future skills using range
    if (validTiles.isEmpty && skill.range != null) {
      for (final tile in state.map.tiles) {
        final distance =
            (casterTile.row - tile.row).abs() + (casterTile.col - tile.col).abs();
        if (distance > 0 && distance <= skill.range!) {
          validTiles.add(tile.id);
        }
      }
    }

    return validTiles;
  }
}

/// Consume skill charge or start cooldown
UnitState _consumeSkill(UnitState unit, SkillSlot slot) {
  final skill = slot == SkillSlot.skill1 ? unit.card.skill1 : unit.card.skill2;
  final newCooldowns = Map<SkillSlot, int>.from(unit.cooldowns);
  final newCharges = Map<SkillSlot, int>.from(unit.charges);

  final currentCharges = newCharges[slot] ?? 0;
  if (currentCharges > 0) {
    newCharges[slot] = currentCharges - 1;
  } else if (skill.cooldownTurns != null) {
    newCooldowns[slot] = skill.cooldownTurns!;
  }

  return UnitState(
    unitId: unit.unitId,
    team: unit.team,
    card: unit.card,
    hp: unit.hp,
    posTileId: unit.posTileId,
    alive: unit.alive,
    activatedThisRound: unit.activatedThisRound,
    statuses: unit.statuses,
    cooldowns: newCooldowns,
    charges: newCharges,
  );
}

/// Add status to a unit
UnitState _addStatus(UnitState unit, StatusType type, int turns) {
  final newStatuses = List<StatusInstance>.from(unit.statuses);
  // Remove existing status of same type
  newStatuses.removeWhere((s) => s.type == type);
  newStatuses.add(StatusInstance(type: type, remainingTurns: turns));

  return UnitState(
    unitId: unit.unitId,
    team: unit.team,
    card: unit.card,
    hp: unit.hp,
    posTileId: unit.posTileId,
    alive: unit.alive,
    activatedThisRound: unit.activatedThisRound,
    statuses: newStatuses,
    cooldowns: unit.cooldowns,
    charges: unit.charges,
  );
}
