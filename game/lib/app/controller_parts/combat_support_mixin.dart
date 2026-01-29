part of '../game_controller.dart';

mixin CombatSupportMixin on ChangeNotifier {
  GameController get _controller => this as GameController;

  void _enterBonusMove(String unitId, GameState state) {
    _controller._bonusMovePending = true;
    _controller._bonusMoveUnitId = unitId;
    _controller._selectedUnitId = unitId;
    _controller._isSkillMode = false;
    _controller._activeSkillSlot = null;
    _controller._skillTargetTiles = {};
    _controller._isAttackMode = false;

    final activeUnit = state.units.firstWhere((u) => u.unitId == unitId);
    final occupiedTiles = state.units
        .where((u) =>
            u.alive &&
            u.team == activeUnit.team &&
            u.unitId != unitId &&
            u.posTileId.isNotEmpty)
        .map((u) => u.posTileId)
        .toSet();

    _controller._highlightedTiles = _controller.pathing.reachableTiles(
      state.map,
      activeUnit.posTileId,
      2,
      occupiedTiles,
    );
  }

  TrapTriggerResult _applyTrapTrigger(GameState state, String activeUnitId) {
    final activeUnit = state.units.cast<UnitState?>().firstWhere(
          (u) => u?.unitId == activeUnitId,
          orElse: () => null,
        );
    if (activeUnit == null || !activeUnit.alive) {
      return TrapTriggerResult(state: state, triggered: false);
    }

    final trap = state.effects.cast<EffectInstance?>().firstWhere(
          (e) =>
              e != null &&
              e.type == EffectType.trap &&
              !e.id.startsWith('trap_trigger_') &&
              e.tileId == activeUnit.posTileId &&
              e.team != activeUnit.team,
          orElse: () => null,
        );

    if (trap == null) {
      return TrapTriggerResult(state: state, triggered: false);
    }

    final updatedUnits = state.units.map((unit) {
      if (unit.unitId == activeUnitId) {
        var updated = _applyStatus(unit, StatusType.trapped, 1);
        updated = _applyStatus(updated, StatusType.revealed, 2);
        return updated;
      }
      return unit;
    }).toList();

    final updatedEffects = [
      for (final effect in state.effects)
        if (effect.id != trap.id) effect,
      EffectInstance(
        id: 'trap_trigger_${DateTime.now().millisecondsSinceEpoch}',
        type: EffectType.trap,
        ownerUnitId: trap.ownerUnitId,
        team: trap.team,
        tileId: activeUnit.posTileId,
        remainingTurns: 2,
        totalTurns: 2,
      ),
    ];

    return TrapTriggerResult(
      state: state.copyWith(units: updatedUnits, effects: updatedEffects),
      triggered: true,
    );
  }

  GameState _applyCameraTriggers(GameState state) {
    final tileMap = {for (final t in state.map.tiles) t.id: t};
    final updatedUnits = List<UnitState>.from(state.units);
    final updatedEffects = <EffectInstance>[];

    for (final effect in state.effects) {
      if (effect.type != EffectType.camera) {
        updatedEffects.add(effect);
        continue;
      }
      if (effect.id.startsWith('camera_trigger_')) {
        updatedEffects.add(effect);
        continue;
      }

      final cameraTile = tileMap[effect.tileId];
      if (cameraTile == null) {
        continue;
      }

      final enemyTeam = effect.team == TeamId.attacker ? TeamId.defender : TeamId.attacker;
      UnitState? detectedEnemy;

      for (final unit in updatedUnits) {
        if (!unit.alive || unit.team != enemyTeam) continue;
        final unitTile = tileMap[unit.posTileId];
        if (unitTile == null) continue;

        if (_controller.visionSystem.hasLineOfSight(
          cameraTile,
          unitTile,
          state.map,
          tileMap,
          state: state,
        )) {
          detectedEnemy = unit;
          break;
        }
      }

      if (detectedEnemy != null) {
        final idx = updatedUnits.indexWhere((u) => u.unitId == detectedEnemy!.unitId);
        if (idx >= 0) {
          updatedUnits[idx] = _applyStatus(updatedUnits[idx], StatusType.revealed, 2);
        }

        updatedEffects.add(EffectInstance(
          id: 'camera_trigger_${DateTime.now().millisecondsSinceEpoch}',
          type: EffectType.camera,
          ownerUnitId: effect.ownerUnitId,
          team: effect.team,
          tileId: detectedEnemy!.posTileId,
          remainingTurns: 2,
          totalTurns: 2,
        ));
      } else {
        updatedEffects.add(effect);
      }
    }

    return state.copyWith(units: updatedUnits, effects: updatedEffects);
  }

  GameState _applySmokeExpirationTrades(GameState before, GameState after) {
    final expiredSmokeTiles = before.effects
        .where((e) => e.type == EffectType.smoke)
        .where((e) => after.effects.every((next) => next.id != e.id))
        .map((e) => e.tileId)
        .toSet();

    if (expiredSmokeTiles.isEmpty) {
      return after;
    }

    final attackers = after.units.where((u) => u.alive && u.team == TeamId.attacker);
    final defenders = after.units.where((u) => u.alive && u.team == TeamId.defender);
    final toKill = <String>{};

    for (final attacker in attackers) {
      for (final defender in defenders) {
        if (toKill.contains(attacker.unitId) || toKill.contains(defender.unitId)) {
          continue;
        }

        final attackerRange = _effectiveAttackRange(attacker);
        final defenderRange = _effectiveAttackRange(defender);
        if (attackerRange == 0 || defenderRange == 0) continue;

        final dist = _controller.pathing.manhattanDistance(
          attacker.posTileId,
          defender.posTileId,
          after.map,
        );
        if (dist > attackerRange || dist > defenderRange) continue;

        final attackerSees = _canUnitSeeEnemy(attacker, defender, after);
        final defenderSees = _canUnitSeeEnemy(defender, attacker, after);
        if (!attackerSees || !defenderSees) continue;

        final lineTiles = _controller.visionSystem.tilesOnLine(
          attacker.posTileId,
          defender.posTileId,
          after,
        );
        final betweenTiles = lineTiles.length > 2
            ? lineTiles.sublist(1, lineTiles.length - 1)
            : const <String>[];
        final hadSmokeBetween = betweenTiles.any(expiredSmokeTiles.contains) ||
            expiredSmokeTiles.contains(attacker.posTileId) ||
            expiredSmokeTiles.contains(defender.posTileId);
        if (hadSmokeBetween) {
          toKill.add(attacker.unitId);
          toKill.add(defender.unitId);
        }
      }
    }

    if (toKill.isEmpty) {
      return after;
    }

    final updatedUnits = after.units.map((unit) {
      if (toKill.contains(unit.unitId)) {
        return UnitState(
          unitId: unit.unitId,
          team: unit.team,
          card: unit.card,
          hp: 0,
          posTileId: unit.posTileId,
          alive: false,
          activatedThisRound: unit.activatedThisRound,
          statuses: unit.statuses,
          cooldowns: unit.cooldowns,
          charges: unit.charges,
        );
      }
      return unit;
    }).toList();

    return after.copyWith(units: updatedUnits);
  }

  bool _canUnitSeeEnemy(UnitState viewer, UnitState target, GameState state) {
    if (_hasStatus(viewer, StatusType.blinded)) {
      return false;
    }
    return _controller.visionSystem.canUnitSeeTile(viewer, target.posTileId, state);
  }

  int _effectiveAttackRange(UnitState unit) {
    if (_hasStatus(unit, StatusType.blinded)) {
      return 0;
    }
    if (_hasStatus(unit, StatusType.stunned)) {
      return 1;
    }
    return unit.card.attackRange;
  }

  int _effectiveMoveRange(UnitState unit, int baseMoveRange) {
    if (_hasStatus(unit, StatusType.stunned)) {
      return 1;
    }
    return baseMoveRange;
  }

  bool _hasStatus(UnitState unit, StatusType type) {
    return unit.statuses.any((s) => s.type == type && s.remainingTurns > 0);
  }

  UnitState _applyStatus(UnitState unit, StatusType type, int turns) {
    final statuses = List<StatusInstance>.from(unit.statuses)
      ..removeWhere((s) => s.type == type)
      ..add(StatusInstance(type: type, remainingTurns: turns));

    return UnitState(
      unitId: unit.unitId,
      team: unit.team,
      card: unit.card,
      hp: unit.hp,
      posTileId: unit.posTileId,
      alive: unit.alive,
      activatedThisRound: unit.activatedThisRound,
      statuses: statuses,
      cooldowns: unit.cooldowns,
      charges: unit.charges,
    );
  }

  GameState _resolveGlobalEncounters(GameState state) {
    var currentState = state;
    final units = List<UnitState>.from(state.units);

    for (var i = 0; i < units.length; i++) {
      final unitA = units[i];
      if (!unitA.alive) continue;
      for (var j = i + 1; j < units.length; j++) {
        final unitB = units[j];
        if (!unitB.alive) continue;
        if (unitA.team == unitB.team) continue;

        final canA = _canUnitAttack(unitA, unitB, currentState);
        final canB = _canUnitAttack(unitB, unitA, currentState);
        if (!canA && !canB) continue;

        UnitState attacker;
        UnitState target;
        if (canA && !canB) {
          attacker = unitA;
          target = unitB;
        } else if (canB && !canA) {
          attacker = unitB;
          target = unitA;
        } else {
          final turnTeam = currentState.turnTeam;
          if (unitA.team == turnTeam) {
            attacker = unitA;
            target = unitB;
          } else if (unitB.team == turnTeam) {
            attacker = unitB;
            target = unitA;
          } else {
            attacker = unitA;
            target = unitB;
          }
        }

        final resolution = _controller.rulesEngine.resolveCombat(
          currentState,
          attacker,
          target,
          _controller.visionSystem,
        );
        currentState = _controller.rulesEngine.applyCombatResult(
          currentState,
          attacker.unitId,
          target.unitId,
          resolution.result,
        );
      }
    }

    return currentState;
  }

  bool _canUnitAttack(UnitState attacker, UnitState target, GameState state) {
    if (!_canUnitSeeEnemy(attacker, target, state)) {
      return false;
    }
    final dist = _controller.pathing.manhattanDistance(
      attacker.posTileId,
      target.posTileId,
      state.map,
    );
    return dist <= _effectiveAttackRange(attacker);
  }
}

class EncounterOutcome {
  EncounterOutcome({required this.state, required this.activeUnitScoredKill});

  final GameState state;
  final bool activeUnitScoredKill;
}

class TrapTriggerResult {
  TrapTriggerResult({required this.state, required this.triggered});

  final GameState state;
  final bool triggered;
}
