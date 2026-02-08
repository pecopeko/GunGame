// スキル使用に関する戦闘操作をまとめる。
part of '../game_controller.dart';

mixin CombatSkillMixin on ChangeNotifier, CombatSupportMixin, CombatMixin {
  GameController get _controller => this as GameController;

  /// Check if a skill can be used
  bool canUseSkill(SkillSlot slot) {
    final unit = _controller.selectedUnit;
    if (unit == null) return false;

    final skill = slot == SkillSlot.skill1
        ? unit.card.skill1
        : unit.card.skill2;
    if (_isEmptySkill(skill)) return false;

    // Skills with charges must have charges to be used.
    final maxCharges = skill.maxCharges ?? 0;
    if (maxCharges > 0) {
      final charges = unit.charges[slot] ?? 0;
      return charges > 0;
    }

    // No-charge skills use cooldown only.
    final cooldown = unit.cooldowns[slot] ?? 0;
    return cooldown == 0 && maxCharges == 0;
  }

  /// Get skill info for display
  String getSkillStatus(SkillSlot slot) {
    final unit = _controller.selectedUnit;
    if (unit == null) return 'N/A';

    final skill = slot == SkillSlot.skill1
        ? unit.card.skill1
        : unit.card.skill2;
    if (_isEmptySkill(skill)) return 'N/A';
    final maxCharges = skill.maxCharges ?? 0;
    final charges = unit.charges[slot] ?? 0;
    if (maxCharges > 0) {
      return charges > 0 ? '$charges LEFT' : 'EMPTY';
    }

    final cooldown = unit.cooldowns[slot] ?? 0;
    if (cooldown > 0) return 'CD $cooldown';

    return 'READY';
  }

  bool shouldShowSkill(SkillSlot slot) {
    final unit = _controller.selectedUnit;
    if (unit == null) return false;
    final skill = slot == SkillSlot.skill1
        ? unit.card.skill1
        : unit.card.skill2;
    if (_isEmptySkill(skill)) return false;
    final maxCharges = skill.maxCharges ?? 0;
    if (maxCharges <= 0) return true;
    final charges = unit.charges[slot] ?? 0;
    return charges > 0;
  }

  bool _isEmptySkill(SkillDef skill) {
    return skill.name == 'Empty' &&
        skill.description.toLowerCase().contains('no second');
  }

  /// Enter skill targeting mode
  void enterSkillMode(SkillSlot slot) {
    if (!_controller.canLocalPlayerActNow) return;
    if (_controller.selectedUnitId == null) return;
    final unit = _controller.selectedUnit;
    if (unit == null) return;

    if (!canUseSkill(slot)) return;

    _controller._isSkillMode = true;
    _controller._isAttackMode = false;
    _controller._activeSkillSlot = slot;
    _controller._highlightedTiles = {};
    _controller._attackableUnitIds = {};
    _controller._skillTargetTiles = _controller.skillExecutor.getValidTargets(
      _controller.state,
      unit,
      slot,
    );
    notifyListeners();
  }

  /// Execute skill on target tile
  void executeSkill(String targetTileId) {
    if (!_controller.canLocalPlayerActNow) return;
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

      if (!result.consumeTurn) {
        _controller._state = newState;
        _controller._turnManager.updateState(newState);

        final updatedUnit = newState.units.cast<UnitState?>().firstWhere(
          (u) => u?.unitId == activeUnitId,
          orElse: () => null,
        );
        if (updatedUnit != null && _controller._activeSkillSlot != null) {
          _controller._skillTargetTiles = _controller.skillExecutor
              .getValidTargets(
                newState,
                updatedUnit,
                _controller._activeSkillSlot!,
              );
        }
        notifyListeners();
        return;
      }

      final movedUnit = newState.units.cast<UnitState?>().firstWhere(
        (u) => u?.unitId == activeUnitId,
        orElse: () => null,
      );

      var trapTriggered = false;
      if (movedUnit != null && movedUnit.posTileId != priorUnit.posTileId) {
        if (movedUnit.alive) {
          newState = _controller.pickupSpikeIfOnTile(newState, movedUnit);
        }
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

      final preAdvanceState = newState;
      newState = _controller._turnManager.advanceTurn(activeUnitId);
      newState = _applySmokeExpirationTrades(preAdvanceState, newState);
      newState = _resolveGlobalEncounters(newState);
      newState = _controller.dropSpikeIfCarrierDead(newState);
      _controller._turnManager.updateState(newState);
      _controller._state = newState;
      _controller.checkSpikeExplosion();
      newState = _controller.state;

      // Check win condition
      if (_controller.winCondition == null) {
        _controller._winCondition = _controller.rulesEngine.checkWinCondition(
          newState,
        );
        if (_controller.winCondition != null) {
          _controller._state = newState.copyWith(phase: 'GameOver');
        }
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
