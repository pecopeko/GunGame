part of '../game_controller.dart';

mixin CombatMixin on ChangeNotifier, CombatSupportMixin {
  GameController get _controller => this as GameController;

  /// Select a unit (Gameplay)
  void selectUnit(String unitId) {
    if (_controller._bonusMovePending && unitId != _controller._bonusMoveUnitId) {
      return;
    }
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

    // Gameplay selection (standard checks)
    // Removed activatedThisRound check per user request for unlimited actions
    if (unit.team != _controller.state.turnTeam || !unit.alive) {
      return;
    }

    _controller._selectedUnitId = unitId;

    // Calculate movement highlights
    final occupiedTiles = _controller.state.units
        .where((u) =>
            u.alive &&
            u.team == unit.team &&
            u.unitId != unitId &&
            u.posTileId.isNotEmpty)
        .map((u) => u.posTileId)
        .toSet();

    final baseMoveRange = _controller._bonusMovePending ? 2 : unit.card.moveRange;
    final moveRange = _effectiveMoveRange(unit, baseMoveRange);
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
    if (_controller._bonusMovePending) {
      return;
    }
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
          .where((u) =>
              u.alive &&
              u.team == unit.team &&
              u.unitId != unit.unitId &&
              u.posTileId.isNotEmpty)
          .map((u) => u.posTileId)
          .toSet();

      final baseMoveRange = _controller._bonusMovePending ? 2 : unit.card.moveRange;
      final moveRange = _effectiveMoveRange(unit, baseMoveRange);
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
    if (_controller.selectedUnitId == null) return;
    if (!_controller.highlightedTiles.contains(targetTileId)) return;

    final state = _controller.state;
    final activeUnitId = _controller.selectedUnitId!;
    final isBonusMove =
        _controller._bonusMovePending && _controller._bonusMoveUnitId == activeUnitId;

    final updatedUnits = state.units.map((unit) {
      if (unit.unitId == activeUnitId) {
        return UnitState(
          unitId: unit.unitId,
          team: unit.team,
          card: unit.card,
          hp: unit.hp,
          posTileId: targetTileId,
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

    final activeUnit = state.units.firstWhere((unit) => unit.unitId == activeUnitId);
    final enemyOnTarget = state.units.any(
      (u) => u.alive && u.team != activeUnit.team && u.posTileId == targetTileId,
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

    final canBonus = !isBonusMove &&
        !trapResult.triggered &&
        updatedActiveUnit != null &&
        updatedActiveUnit.alive &&
        updatedActiveUnit.card.role == Role.entry &&
        encounter.activeUnitScoredKill;

    if (canBonus) {
      _enterBonusMove(activeUnitId, newState);
      _controller._state = newState;
      notifyListeners();
      return;
    }

    _controller._bonusMovePending = false;
    _controller._bonusMoveUnitId = null;

    final preAdvanceState = newState;
    newState = _controller._turnManager.advanceTurn(activeUnitId);
    newState = _applySmokeExpirationTrades(preAdvanceState, newState);
    newState = _resolveGlobalEncounters(newState);
    _controller._state = newState;

    _controller._winCondition = _controller.rulesEngine.checkWinCondition(newState);
    if (_controller.winCondition != null) {
      _controller._state = newState.copyWith(phase: 'GameOver');
    }

    _controller._selectedUnitId = null;
    _controller._highlightedTiles = {};

    notifyListeners();
  }

  /// Resolve combat encounters for a specific unit after action.
  EncounterOutcome _resolveEncountersWithOutcome(GameState state, String activeUnitId) {
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
      final activeRange = _effectiveAttackRange(activeUnit);
      final enemyRange = _effectiveAttackRange(enemy);

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
      } else if (!activeIsAttacker && resolution.result == CombatResult.defenderWins) {
        activeUnitScoredKill = true;
      }
    }

    return EncounterOutcome(
      state: currentState,
      activeUnitScoredKill: activeUnitScoredKill,
    );
  }

  /// Check if a skill can be used
  bool canUseSkill(SkillSlot slot) {
    final unit = _controller.selectedUnit;
    if (unit == null) return false;

    // Check charges
    final charges = unit.charges[slot] ?? 0;
    if (charges > 0) return true;

    // Check cooldown
    final cooldown = unit.cooldowns[slot] ?? 0;
    return cooldown == 0;
  }

  /// Get skill info for display
  String getSkillStatus(SkillSlot slot) {
    final unit = _controller.selectedUnit;
    if (unit == null) return 'N/A';

    final charges = unit.charges[slot] ?? 0;
    if (charges > 0) return '$charges LEFT';

    final cooldown = unit.cooldowns[slot] ?? 0;
    if (cooldown > 0) return 'CD $cooldown';

    return 'READY';
  }

  /// Enter skill targeting mode
  void enterSkillMode(SkillSlot slot) {
    if (_controller._bonusMovePending) return;
    if (_controller.selectedUnitId == null) return;
    final unit = _controller.selectedUnit;
    if (unit == null) return;

    if (!canUseSkill(slot)) return;

    _controller._isSkillMode = true;
    _controller._isAttackMode = false;
    _controller._activeSkillSlot = slot;
    _controller._highlightedTiles = {};
    _controller._attackableUnitIds = {};
    _controller._skillTargetTiles = _controller.skillExecutor.getValidTargets(_controller.state, unit, slot);
    notifyListeners();
  }

  /// Execute skill on target tile
  void executeSkill(String targetTileId) {
    if (!_controller.isSkillMode || _controller.activeSkillSlot == null) return;
    final unit = _controller.selectedUnit;
    if (unit == null) return;

    if (!_controller.skillTargetTiles.contains(targetTileId)) return;

    final priorUnit = unit;
    final result = _controller.skillExecutor.executeSkill(
      _controller.state,
      unit,
      _controller.activeSkillSlot!,
      targetTileId,
      _controller.visionSystem,
    );

    if (result.success) {
      var newState = result.updatedState;
      final activeUnitId = priorUnit.unitId;

      final movedUnit = newState.units.cast<UnitState?>().firstWhere(
            (u) => u?.unitId == activeUnitId,
            orElse: () => null,
          );

      var trapTriggered = false;
      if (movedUnit != null && movedUnit.posTileId != priorUnit.posTileId) {
        final trapResult = _applyTrapTrigger(newState, activeUnitId);
        newState = trapResult.state;
        trapTriggered = trapResult.triggered;
      }

      newState = _applyCameraTriggers(newState);
      _controller._state = newState;
      _controller._turnManager.updateState(newState);

      EncounterOutcome? encounter;
      if (movedUnit != null && movedUnit.posTileId != priorUnit.posTileId) {
        encounter = _resolveEncountersWithOutcome(newState, activeUnitId);
        newState = encounter.state;
        _controller._turnManager.updateState(newState);
      }
      
      final activeUnit = newState.units.cast<UnitState?>().firstWhere(
            (u) => u?.unitId == activeUnitId,
            orElse: () => null,
          );

      final canBonus = !trapTriggered &&
          activeUnit != null &&
          activeUnit.alive &&
          activeUnit.card.role == Role.entry &&
          encounter != null &&
          encounter.activeUnitScoredKill;

      if (canBonus) {
        _enterBonusMove(activeUnitId, newState);
        _controller._state = newState;
        deselectUnit();
        notifyListeners();
        return;
      }

      _controller._bonusMovePending = false;
      _controller._bonusMoveUnitId = null;

      final preAdvanceState = newState;
      newState = _controller._turnManager.advanceTurn(activeUnitId);
      newState = _applySmokeExpirationTrades(preAdvanceState, newState);
      newState = _resolveGlobalEncounters(newState);
      _controller._turnManager.updateState(newState);
      _controller._state = newState;

      // Check win condition
      _controller._winCondition = _controller.rulesEngine.checkWinCondition(newState);
      if (_controller.winCondition != null) {
        _controller._state = newState.copyWith(phase: 'GameOver');
      }
    }

    // Clear selection
    deselectUnit();
  }

  /// Cancel skill mode
  void cancelSkillMode() {
    _controller._isSkillMode = false;
    _controller._activeSkillSlot = null;
    _controller._skillTargetTiles = {};
    notifyListeners();
  }
  
  // Method stubs for now-removed attack properties to prevent binding errors if any remain
  bool get canAttack => false;
  void enterAttackMode() {}
}
