import 'entities.dart';

class TurnManager {
  TurnManager(this._state);

  GameState _state;

  GameState get state => _state;

  /// Update the internal state reference
  void updateState(GameState newState) {
    _state = newState;
  }

  /// Advance to the next turn. Returns updated GameState.
  /// - Marks current unit as activated
  /// - Swaps turn team
  /// - If all units on new team are activated, ends round
  GameState advanceTurn(String activatedUnitId) {
    // Mark unit as activated
    final updatedUnits = _state.units.map((unit) {
      if (unit.unitId == activatedUnitId) {
        return _unitWithActivated(unit, true);
      }
      return unit;
    }).toList();

    // Swap team
    final nextTeam = _state.turnTeam == TeamId.attacker
        ? TeamId.defender
        : TeamId.attacker;

    // Simplified logic: Always swap turns to next team if they have alive units.
    // If next team has NO alive units, keep current team? (Or Game Over handles dead team?)
    // This allows infinite actions per unit effectively.
    
    // Decrement global effects (Smoke, Trap, etc)
    final updatedEffects = _state.effects
        .map((e) => EffectInstance(
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
            ))
        .where((e) => e.remainingTurns > 0)
        .toList();
    
    final nextTeamAlive = updatedUnits.any((u) => u.team == nextTeam && u.alive);
    
    if (nextTeamAlive) {
       _state = _state.copyWith(
        units: updatedUnits,
        turnTeam: nextTeam,
        effects: updatedEffects,
      );
    } else {
       // Only one team alive? Keep current turn.
       _state = _state.copyWith(
        units: updatedUnits,
        // turnTeam stays same
        effects: updatedEffects,
      );
    }

    return _state;
  }

  /// End round: reset activation, increment round index
  GameState _endRound(List<UnitState> units) {
    final resetUnits = units.map((u) => _unitWithActivated(u, false)).toList();
    
    _state = _state.copyWith(
      units: resetUnits,
      roundIndex: _state.roundIndex + 1,
      turnTeam: TeamId.attacker, // Attacker starts each round
    );
    return _state;
  }

  UnitState _unitWithActivated(UnitState unit, bool activated) {
    return UnitState(
      unitId: unit.unitId,
      team: unit.team,
      card: unit.card,
      hp: unit.hp,
      posTileId: unit.posTileId,
      alive: unit.alive,
      activatedThisRound: activated,
      // Decrement statuses only when activated -> false (Round End)? 
      // Or when activated (Turn End)?
      // AGENTS.md says "Reduce when unit starts turn (activates)".
      // So if activated=true, we reduce.
      statuses: activated 
          ? unit.statuses
              .map((s) => StatusInstance(type: s.type, remainingTurns: s.remainingTurns - 1))
              .where((s) => s.remainingTurns > 0)
              .toList()
          : unit.statuses,
      cooldowns: unit.cooldowns,
      charges: unit.charges,
    );
  }

  /// Get units that can still act this turn
  List<UnitState> getUnactivatedUnits(TeamId team) {
    return _state.units
        .where((u) => u.team == team && u.alive && !u.activatedThisRound)
        .toList();
  }
}
