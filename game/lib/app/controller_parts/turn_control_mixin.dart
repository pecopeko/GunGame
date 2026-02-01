part of '../game_controller.dart';

mixin TurnControlMixin on ChangeNotifier {
  GameController get _controller => this as GameController;

  void passTurn() {
    final state = _controller.state;
    if (state.phase != 'Playing') return;

    final unit = state.units.cast<UnitState?>().firstWhere(
          (u) => u?.team == state.turnTeam && u?.alive == true,
          orElse: () => null,
        );
    if (unit == null) return;

    final preAdvanceState = state;
    var newState = _controller._turnManager.advanceTurn(unit.unitId);
    newState = _controller._applySmokeExpirationTrades(preAdvanceState, newState);
    newState = _controller._resolveGlobalEncounters(newState);
    newState = _controller.dropSpikeIfCarrierDead(newState);

    _controller._state = newState;
    _controller._turnManager.updateState(newState);
    _controller.checkSpikeExplosion();
    newState = _controller.state;

    if (_controller.winCondition == null) {
      _controller._winCondition = _controller.rulesEngine.checkWinCondition(newState);
      if (_controller.winCondition != null) {
        _controller._state = newState.copyWith(phase: 'GameOver');
      }
    }

    _controller._selectedUnitId = null;
    _controller._highlightedTiles = {};
    _controller._isAttackMode = false;
    _controller._attackableUnitIds = {};
    _controller._isSkillMode = false;
    _controller._activeSkillSlot = null;
    _controller._skillTargetTiles = {};
    notifyListeners();
  }
}
