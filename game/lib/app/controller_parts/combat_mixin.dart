// ターン制戦闘の主要操作を扱う。
part of '../game_controller.dart';

mixin CombatMixin on ChangeNotifier, CombatSupportMixin {
  GameController get _controller => this as GameController;

  /// Select a unit (Gameplay)
  void selectUnit(String unitId) {
    if (!_controller.canLocalPlayerActNow) return;
    if (_controller._state.phase.startsWith('Setup')) {
      // Should be handled by setup logic wrapper or separate call,
      // but if called directly:
      // In new setup (5v5), selecting a unit means removing it?
      // or we just don't support 'selectUnit' for setup in this mixin.
      return;
    }

    final unit = _controller.state.units.cast<UnitState?>().firstWhere(
      (u) => u?.unitId == unitId,
      orElse: () => null,
    );

    if (unit == null) return;
    if (_controller._onlineLocalTeam != null &&
        unit.team != _controller._onlineLocalTeam) {
      return;
    }

    // Gameplay selection (standard checks)
    // Removed activatedThisRound check per user request for unlimited actions
    if (unit.team != _controller.state.turnTeam || !unit.alive) {
      return;
    }

    _controller._selectedUnitId = unitId;

    // Calculate movement highlights
    final occupiedTiles = _controller.state.units
        .where(
          (u) =>
              u.alive &&
              u.team == unit.team &&
              u.unitId != unitId &&
              u.posTileId.isNotEmpty,
        )
        .map((u) => u.posTileId)
        .toSet();

    final moveRange = _effectiveMoveRange(unit, unit.card.moveRange);
    _controller._highlightedTiles = _controller.pathing.reachableTiles(
      _controller.state.map,
      unit.posTileId,
      moveRange,
      occupiedTiles,
    );

    notifyListeners();
  }

  /// Deselect current unit
  void deselectUnit() {
    _controller._selectedUnitId = null;
    _controller._selectedRoleToSpawn = null;
    resetActionModes();
  }

  /// Reset attack/skill modes and return to movement mode
  void resetActionModes() {
    _controller._isAttackMode = false;
    _controller._attackableUnitIds = {};
    _controller._isSkillMode = false;
    _controller._activeSkillSlot = null;
    _controller._skillTargetTiles = {};

    // Recalculate movement highlights if unit selected
    final unit = _controller.selectedUnit;
    if (unit != null) {
      final occupiedTiles = _controller.state.units
          .where(
            (u) =>
                u.alive &&
                u.team == unit.team &&
                u.unitId != unit.unitId &&
                u.posTileId.isNotEmpty,
          )
          .map((u) => u.posTileId)
          .toSet();

      final moveRange = _effectiveMoveRange(unit, unit.card.moveRange);
      _controller._highlightedTiles = _controller.pathing.reachableTiles(
        _controller.state.map,
        unit.posTileId,
        moveRange,
        occupiedTiles,
      );
    } else {
      _controller._highlightedTiles = {};
    }

    notifyListeners();
  }

  /// Move selected unit to target tile
  void moveUnit(String targetTileId) {
    if (!_controller.canLocalPlayerActNow) return;
    if (_controller.selectedUnitId == null) return;
    if (!_controller.highlightedTiles.contains(targetTileId)) return;

    final state = _controller.state;
    final activeUnitId = _controller.selectedUnitId!;
    final activeUnit = state.units.firstWhere(
      (unit) => unit.unitId == activeUnitId,
    );

    final occupiedAllies = state.units
        .where(
          (u) =>
              u.alive &&
              u.team == activeUnit.team &&
              u.unitId != activeUnitId &&
              u.posTileId.isNotEmpty,
        )
        .map((u) => u.posTileId)
        .toSet();
    final path = _controller.pathing.shortestPath(
      state.map,
      activeUnit.posTileId,
      targetTileId,
      occupiedAllies,
    );

    var stopTileId = targetTileId;
    if (path.isNotEmpty) {
      for (final stepId in path.skip(1)) {
        final hasTrap = state.effects.any(
          (e) =>
              e.type == EffectType.trap &&
              e.tileId == stepId &&
              e.team != activeUnit.team,
        );
        if (hasTrap) {
          stopTileId = stepId;
          break;
        }
      }
    }
    final pathToStop = <String>[if (path.isNotEmpty) ...path];
    if (pathToStop.isNotEmpty) {
      final stopIndex = pathToStop.indexOf(stopTileId);
      if (stopIndex != -1) {
        pathToStop.removeRange(stopIndex + 1, pathToStop.length);
      }
    } else {
      pathToStop.addAll([activeUnit.posTileId, stopTileId]);
    }

    final updatedUnits = state.units.map((unit) {
      if (unit.unitId == activeUnitId) {
        return UnitState(
          unitId: unit.unitId,
          team: unit.team,
          card: unit.card,
          hp: unit.hp,
          posTileId: stopTileId,
          alive: unit.alive,
          activatedThisRound: unit.activatedThisRound,
          statuses: unit.statuses,
          cooldowns: unit.cooldowns,
          charges: unit.charges,
        );
      }
      return unit;
    }).toList();

    var newState = state.copyWith(units: updatedUnits);

    final enemyOnTarget = state.units.any(
      (u) => u.alive && u.team != activeUnit.team && u.posTileId == stopTileId,
    );
    if (enemyOnTarget) {
      final killedUnits = newState.units.map((unit) {
        if (unit.unitId == activeUnitId) {
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
      newState = newState.copyWith(units: killedUnits);
    }

    final activeAfterMove = newState.units.cast<UnitState?>().firstWhere(
      (u) => u?.unitId == activeUnitId,
      orElse: () => null,
    );
    if (activeAfterMove != null && activeAfterMove.alive) {
      newState = _controller.pickupSpikeIfPassed(
        newState,
        activeAfterMove,
        pathToStop,
      );
    }

    final trapResult = _applyTrapTrigger(newState, activeUnitId);
    newState = trapResult.state;

    newState = _applyCameraTriggers(newState);
    _controller._state = newState;

    final encounter = _resolveEncountersWithOutcome(newState, activeUnitId);
    newState = encounter.state;
    _controller._turnManager.updateState(newState);

    final updatedActiveUnit = newState.units.cast<UnitState?>().firstWhere(
      (u) => u?.unitId == activeUnitId,
      orElse: () => null,
    );

    final preAdvanceState = newState;
    newState = _controller._turnManager.advanceTurn(activeUnitId);
    newState = _applySmokeExpirationTrades(preAdvanceState, newState);
    newState = _resolveGlobalEncounters(newState);
    newState = _controller.dropSpikeIfCarrierDead(newState);
    _controller._state = newState;
    _controller.checkSpikeExplosion();
    newState = _controller.state;

    if (_controller.winCondition == null) {
      if (_controller.winCondition == null) {
        _controller._winCondition = _controller.rulesEngine.checkWinCondition(
          newState,
        );
        if (_controller.winCondition != null) {
          _controller._state = newState.copyWith(phase: 'GameOver');
        }
      }
    }

    _controller._selectedUnitId = null;
    _controller._highlightedTiles = {};

    notifyListeners();
  }

  /// Resolve combat encounters for a specific unit after action.
  EncounterOutcome _resolveEncountersWithOutcome(
    GameState state,
    String activeUnitId,
  ) {
    var currentState = state;
    var activeUnitScoredKill = false;

    var activeUnit = currentState.units.cast<UnitState?>().firstWhere(
      (u) => u?.unitId == activeUnitId,
      orElse: () => null,
    );
    if (activeUnit == null || !activeUnit.alive) {
      return EncounterOutcome(state: currentState, activeUnitScoredKill: false);
    }

    final enemies = currentState.units
        .where((u) => u.team != activeUnit!.team && u.alive)
        .toList();

    for (final enemy in enemies) {
      activeUnit = currentState.units.cast<UnitState?>().firstWhere(
        (u) => u?.unitId == activeUnitId,
        orElse: () => null,
      );
      if (activeUnit == null || !activeUnit.alive) break;

      final activeSeesEnemy = _canUnitSeeEnemy(activeUnit, enemy, currentState);
      final enemySeesActive = _canUnitSeeEnemy(enemy, activeUnit, currentState);

      final dist = _controller.pathing.manhattanDistance(
        activeUnit.posTileId,
        enemy.posTileId,
        currentState.map,
      );
      final activeRange = _effectiveAttackRangeAgainst(activeUnit, enemy);
      final enemyRange = _effectiveAttackRangeAgainst(enemy, activeUnit);

      final activeInRange = dist <= activeRange;
      final enemyInRange = dist <= enemyRange;

      final activeCanAttack = activeSeesEnemy && activeInRange;
      final enemyCanAttack = enemySeesActive && enemyInRange;

      if (!activeCanAttack && !enemyCanAttack) {
        continue;
      }

      final activeIsAttacker = activeCanAttack || !enemyCanAttack;
      final attacker = activeIsAttacker ? activeUnit : enemy;
      final target = activeIsAttacker ? enemy : activeUnit;

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

      if (activeIsAttacker && resolution.result == CombatResult.attackerWins) {
        activeUnitScoredKill = true;
      } else if (!activeIsAttacker &&
          resolution.result == CombatResult.defenderWins) {
        activeUnitScoredKill = true;
      }
    }

    return EncounterOutcome(
      state: currentState,
      activeUnitScoredKill: activeUnitScoredKill,
    );
  }

}
