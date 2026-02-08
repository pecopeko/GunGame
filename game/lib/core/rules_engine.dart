// 行動合法性と戦闘解決を担当する。
import 'entities.dart';
import 'vision_system.dart';

/// Combat result after resolving an attack
enum CombatResult {
  attackerWins,   // Target killed
  defenderWins,   // Attacker killed (counter-kill)
  bothDie,        // Trade
}

/// Detailed combat resolution result
class CombatResolution {
  const CombatResolution({
    required this.result,
    required this.attackerScore,
    required this.defenderScore,
    required this.attackerHadFirstSight,
    required this.description,
  });

  final CombatResult result;
  final int attackerScore;
  final int defenderScore;
  final bool attackerHadFirstSight;
  final String description;
}

class RulesEngine {
  const RulesEngine();

  static const int baseCombat = 2;
  static const int firstSightBonus = 5; // Increased to ensure kill
  static const int holdingBonus = 5;     // New: Defender holds angle -> wins trade
  static const int blindedPenalty = 2;
  static const int stunnedPenalty = 10;  // Increased to guarantee loss
  static const int smokeExitPenalty = 2; // Increased
  static const int droneTaggedPenalty = 1;

  // ... (isLegalAction, getAttackableTargets unchanged)

  /// Resolve combat between attacker and target
  CombatResolution resolveCombat(
    GameState state,
    UnitState attacker,
    UnitState target,
    VisionSystem visionSystem,
  ) {
    final tileMap = {for (final t in state.map.tiles) t.id: t};
    final attackerTile = tileMap[attacker.posTileId];
    final targetTile = tileMap[target.posTileId];

    // Calculate if attacker has first sight advantage
    final attackerSeesTarget = visionSystem.canUnitSeeTile(
        attacker, target.posTileId, state);
    
    // Target visibility depends on Blinded status
    final targetIsBlinded = _hasStatus(target, StatusType.blinded);
    final targetIsStunned = _hasStatus(target, StatusType.stunned);
    final targetIsRevealed = _hasStatus(target, StatusType.revealed);
    final attackerIsRevealed = _hasStatus(attacker, StatusType.revealed);
    
    // Target effective vision for combat (stunned can still see)
    final targetSeesAttacker = !targetIsBlinded &&
        (!targetIsRevealed || attackerIsRevealed) &&
        visionSystem.canUnitSeeTile(target, attacker.posTileId, state);

    // First Sight: Attacker sees target, but target doesn't see attacker (Flank/Blind)
    final hasFirstSightAdvantage = attackerSeesTarget && !targetSeesAttacker;

    // Holding Advantage: Target sees attacker (and is not blinded/stunned)
    // This applies in mutual vision scenarios, giving advantage to the stationary unit (Target).
    final hasHoldingAdvantage = targetSeesAttacker && !targetIsStunned;

    // Check if first sight is invalidated by status effects
    final firstSightInvalidated = _hasStatus(attacker, StatusType.smokeExitPenalty) ||
        _hasStatus(attacker, StatusType.droneTagged);

    // Calculate attack score
    var attackScore = baseCombat;
    if (hasFirstSightAdvantage && !firstSightInvalidated) {
      attackScore += firstSightBonus;
    }
    if (_hasStatus(attacker, StatusType.smokeExitPenalty)) {
      attackScore -= smokeExitPenalty;
    }
    if (_hasStatus(attacker, StatusType.droneTagged)) {
      attackScore -= droneTaggedPenalty;
    }

    // Calculate defense score
    var defenseScore = baseCombat;
    if (hasHoldingAdvantage) {
      defenseScore += holdingBonus;
    }
    if (_hasStatus(target, StatusType.blinded)) {
      defenseScore -= blindedPenalty;
    }
    if (_hasStatus(target, StatusType.stunned)) {
      defenseScore -= stunnedPenalty;
    }

    // Determine result
    CombatResult result;
    String description;

    if (attackScore > defenseScore) {
      result = CombatResult.attackerWins;
      description = 'Attacker Wins ($attackScore vs $defenseScore)';
    } else if (attackScore < defenseScore) {
      result = CombatResult.defenderWins;
      description = 'Defender Wins (Holding) ($defenseScore vs $attackScore)';
    } else {
      result = CombatResult.bothDie;
      description = 'Trade ($attackScore vs $defenseScore)';
    }

    return CombatResolution(
      result: result,
      attackerScore: attackScore,
      defenderScore: defenseScore,
      attackerHadFirstSight: hasFirstSightAdvantage && !firstSightInvalidated,
      description: description,
    );
  }

  /// Apply combat result to game state
  GameState applyCombatResult(
    GameState state,
    String attackerId,
    String targetId,
    CombatResult result,
  ) {
    final updatedUnits = state.units.map((unit) {
      if (unit.unitId == targetId &&
          (result == CombatResult.attackerWins || result == CombatResult.bothDie)) {
        return _killUnit(unit);
      }
      if (unit.unitId == attackerId &&
          (result == CombatResult.defenderWins || result == CombatResult.bothDie)) {
        return _killUnit(unit);
      }
      if (result == CombatResult.attackerWins && unit.unitId == attackerId) {
        return _addStatus(unit, StatusType.revealed, 3);
      }
      if (result == CombatResult.defenderWins && unit.unitId == targetId) {
        return _addStatus(unit, StatusType.revealed, 3);
      }
      return unit;
    }).toList();

    return state.copyWith(units: updatedUnits);
  }

  /// Check win conditions
  WinCondition? checkWinCondition(GameState state) {
    if (state.phase != 'Playing') {
      return null;
    }
    final attackersAlive = state.units
        .where((u) => u.team == TeamId.attacker && u.alive)
        .length;
    final defendersAlive = state.units
        .where((u) => u.team == TeamId.defender && u.alive)
        .length;

    if (attackersAlive == 0 && defendersAlive == 0) {
      // Both teams eliminated - defender wins (time out rules)
      return WinCondition(
        winner: TeamId.defender,
        reason: 'both_eliminated',
      );
    }

    if (attackersAlive == 0) {
      return WinCondition(
        winner: TeamId.defender,
        reason: 'attackers_eliminated',
      );
    }

    if (defendersAlive == 0) {
      return WinCondition(
        winner: TeamId.attacker,
        reason: 'defenders_eliminated',
      );
    }

    return null; // Game continues
  }

  bool _hasStatus(UnitState unit, StatusType type) {
    return unit.statuses.any((s) => s.type == type && s.remainingTurns > 0);
  }

  UnitState _killUnit(UnitState unit) {
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

  UnitState _addStatus(UnitState unit, StatusType type, int turns) {
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
}

class WinCondition {
  const WinCondition({required this.winner, required this.reason});
  final TeamId winner;
  final String reason;
}
