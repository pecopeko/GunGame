// ターンとラウンドの進行を管理する。
import 'entities.dart';

class TurnManager {
  TurnManager(this._state);

  GameState _state;

  GameState get state => _state;

  void updateState(GameState newState) {
    _state = newState;
  }

  /// Advance to the next turn with strict team alternation.
  /// Falls back to the current side if the opposite side has no alive units.
  GameState advanceTurn(String activatedUnitId) {
    final updatedUnits = _state.units.map((unit) {
      final updatedStatuses = unit.statuses
          .map(
            (s) => StatusInstance(
              type: s.type,
              remainingTurns: s.remainingTurns - 1,
            ),
          )
          .where((s) => s.remainingTurns > 0)
          .toList();

      return UnitState(
        unitId: unit.unitId,
        team: unit.team,
        card: unit.card,
        hp: unit.hp,
        posTileId: unit.posTileId,
        alive: unit.alive,
        activatedThisRound: false,
        statuses: updatedStatuses,
        cooldowns: unit.cooldowns,
        charges: unit.charges,
      );
    }).toList();

    final updatedEffects = _state.effects
        .map(
          (e) => EffectInstance(
            id: e.id,
            type: e.type,
            ownerUnitId: e.ownerUnitId,
            team: e.team,
            tileId: e.tileId,
            remainingTurns: e.remainingTurns - 1,
            range: e.range,
            targetTileId: e.targetTileId,
            totalTurns: e.totalTurns,
            movesRemaining: e.movesRemaining,
            totalMoves: e.totalMoves,
          ),
        )
        .where((e) => e.remainingTurns > 0)
        .toList();

    final oppositeTeam = _state.turnTeam == TeamId.attacker
        ? TeamId.defender
        : TeamId.attacker;
    final oppositeAlive = updatedUnits.any(
      (u) => u.team == oppositeTeam && u.alive,
    );
    final currentAlive = updatedUnits.any(
      (u) => u.team == _state.turnTeam && u.alive,
    );
    final nextTeam = oppositeAlive
        ? oppositeTeam
        : (currentAlive ? _state.turnTeam : oppositeTeam);

    _state = _state.copyWith(
      units: updatedUnits,
      turnTeam: nextTeam,
      effects: updatedEffects,
    );
    return _state;
  }

  /// Kept for compatibility with callers.
  List<UnitState> getUnactivatedUnits(TeamId team) {
    return _state.units.where((u) => u.team == team && u.alive).toList();
  }
}
