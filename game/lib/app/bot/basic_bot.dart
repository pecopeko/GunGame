// CPU対戦用の簡易ボットを実装する。
import '../../core/entities.dart';
import '../../core/pathing.dart';
import '../../core/vision_system.dart';

enum BotActionType { move, defuse, pass }

class BotAction {
  const BotAction._({
    required this.type,
    required this.unitId,
    this.targetTileId,
  });

  final BotActionType type;
  final String unitId;
  final String? targetTileId;

  factory BotAction.move({
    required String unitId,
    required String targetTileId,
  }) =>
      BotAction._(
        type: BotActionType.move,
        unitId: unitId,
        targetTileId: targetTileId,
      );

  factory BotAction.defuse({required String unitId}) => BotAction._(
        type: BotActionType.defuse,
        unitId: unitId,
      );

  factory BotAction.pass({required String unitId}) => BotAction._(
        type: BotActionType.pass,
        unitId: unitId,
      );
}

class BasicBot {
  const BasicBot();

  BotAction? decideAction({
    required GameState state,
    required TeamId team,
    required Pathing pathing,
    required VisionSystem visionSystem,
  }) {
    final units = state.units.where((u) => u.alive && u.team == team).toList();
    if (units.isEmpty) return null;

    final tileMap = {for (final t in state.map.tiles) t.id: t};
    final visibleEnemies = visionSystem.getVisibleEnemies(state, team);

    if (_hasImmediateEngagement(units, visibleEnemies, state, tileMap, visionSystem)) {
      return BotAction.pass(unitId: units.first.unitId);
    }

    if (team == TeamId.defender &&
        state.spike.state == SpikeStateType.planted &&
        state.spike.plantedTileId != null) {
      final defuser = units.firstWhere(
        (u) => u.posTileId == state.spike.plantedTileId,
        orElse: () => units.first,
      );
      if (defuser.posTileId == state.spike.plantedTileId) {
        return BotAction.defuse(unitId: defuser.unitId);
      }
    }

    final goalTiles = _chooseGoalTiles(
      state,
      team,
      units,
      pathing,
      visionSystem,
      visibleEnemies,
    );

    final allyTiles = units.map((u) => u.posTileId).toSet();
    BotAction? bestAction;
    var bestScore = 999999;

    final orderedUnits = List<UnitState>.from(units)
      ..sort((a, b) => a.unitId.compareTo(b.unitId));

    for (final unit in orderedUnits) {
      final moveRange = _effectiveMoveRange(unit);
      final blocked = Set<String>.from(allyTiles)..remove(unit.posTileId);
      final reachable = pathing.reachableTiles(
        state.map,
        unit.posTileId,
        moveRange,
        blocked,
      );
      if (reachable.isEmpty) continue;

      final chosen = _pickBestTile(
        unit: unit,
        reachable: reachable,
        goalTiles: goalTiles,
        visibleEnemies: visibleEnemies,
        state: state,
        tileMap: tileMap,
        visionSystem: visionSystem,
        pathing: pathing,
      );

      if (chosen != null && chosen.score < bestScore) {
        bestScore = chosen.score;
        bestAction = BotAction.move(
          unitId: unit.unitId,
          targetTileId: chosen.tileId,
        );
      }
    }

    if (bestAction != null) return bestAction;
    return BotAction.pass(unitId: orderedUnits.first.unitId);
  }

  bool _hasImmediateEngagement(
    List<UnitState> units,
    List<UnitState> enemies,
    GameState state,
    Map<String, Tile> tileMap,
    VisionSystem visionSystem,
  ) {
    if (enemies.isEmpty) return false;
    for (final unit in units) {
      final unitTile = tileMap[unit.posTileId];
      if (unitTile == null) continue;
      final range = _effectiveAttackRange(unit);
      if (range <= 0) continue;
      for (final enemy in enemies) {
        final enemyTile = tileMap[enemy.posTileId];
        if (enemyTile == null) continue;
        final dist = (unitTile.row - enemyTile.row).abs() +
            (unitTile.col - enemyTile.col).abs();
        if (dist > range) continue;
        if (visionSystem.hasLineOfSight(
          unitTile,
          enemyTile,
          state.map,
          tileMap,
          state: state,
        )) {
          return true;
        }
      }
    }
    return false;
  }

  List<String> _chooseGoalTiles(
    GameState state,
    TeamId team,
    List<UnitState> units,
    Pathing pathing,
    VisionSystem visionSystem,
    List<UnitState> visibleEnemies,
  ) {
    if (state.spike.state == SpikeStateType.planted) {
      if (state.spike.plantedTileId != null) {
        return [state.spike.plantedTileId!];
      }
    }

    if (team == TeamId.attacker && state.spike.state == SpikeStateType.dropped) {
      if (state.spike.droppedTileId != null) {
        return [state.spike.droppedTileId!];
      }
    }

    if (visibleEnemies.isNotEmpty) {
      return visibleEnemies.map((e) => e.posTileId).toList();
    }

    final siteTiles = state.map.tiles
        .where((t) => t.type == TileType.siteA || t.type == TileType.siteB)
        .map((t) => t.id)
        .toList();
    if (siteTiles.isNotEmpty) {
      return siteTiles;
    }

    final centerRow = (state.map.rows / 2).floor();
    final centerCol = (state.map.cols / 2).floor();
    return ['r${centerRow}c${centerCol}'];
  }

  int _effectiveMoveRange(UnitState unit) {
    final stunned = unit.statuses.any(
      (s) => s.type == StatusType.stunned && s.remainingTurns > 0,
    );
    return stunned ? 1 : unit.card.moveRange;
  }

  int _effectiveAttackRange(UnitState unit) {
    final blinded = unit.statuses.any(
      (s) => s.type == StatusType.blinded && s.remainingTurns > 0,
    );
    if (blinded) return 0;
    final revealed = unit.statuses.any(
      (s) => s.type == StatusType.revealed && s.remainingTurns > 0,
    );
    if (revealed) return 0;
    final stunned = unit.statuses.any(
      (s) => s.type == StatusType.stunned && s.remainingTurns > 0,
    );
    return stunned ? 1 : unit.card.attackRange;
  }

  _BotTileChoice? _pickBestTile({
    required UnitState unit,
    required Set<String> reachable,
    required List<String> goalTiles,
    required List<UnitState> visibleEnemies,
    required GameState state,
    required Map<String, Tile> tileMap,
    required VisionSystem visionSystem,
    required Pathing pathing,
  }) {
    final candidates = reachable.toList()..sort();
    if (candidates.isEmpty) return null;

    var best = _BotTileChoice(tileId: candidates.first, score: 999999);
    for (final tileId in candidates) {
      final tile = tileMap[tileId];
      if (tile == null) continue;

      var score = 0;
      final attackCount = _countAttackLines(
        unit: unit,
        fromTile: tile,
        visibleEnemies: visibleEnemies,
        state: state,
        tileMap: tileMap,
        visionSystem: visionSystem,
      );
      if (attackCount > 0) {
        score -= 120 * attackCount;
      }

      if (goalTiles.isNotEmpty) {
        var bestGoalDist = 9999;
        for (final goal in goalTiles) {
          final dist = pathing.manhattanDistance(tileId, goal, state.map);
          if (dist < bestGoalDist) {
            bestGoalDist = dist;
          }
        }
        score += bestGoalDist;
      }

      if (score < best.score) {
        best = _BotTileChoice(tileId: tileId, score: score);
      }
    }

    return best;
  }

  int _countAttackLines({
    required UnitState unit,
    required Tile fromTile,
    required List<UnitState> visibleEnemies,
    required GameState state,
    required Map<String, Tile> tileMap,
    required VisionSystem visionSystem,
  }) {
    if (visibleEnemies.isEmpty) return 0;
    final range = _effectiveAttackRange(unit);
    if (range <= 0) return 0;

    var count = 0;
    for (final enemy in visibleEnemies) {
      final enemyTile = tileMap[enemy.posTileId];
      if (enemyTile == null) continue;
      final dist = (fromTile.row - enemyTile.row).abs() +
          (fromTile.col - enemyTile.col).abs();
      if (dist > range) continue;
      if (visionSystem.hasLineOfSight(
        fromTile,
        enemyTile,
        state.map,
        tileMap,
        state: state,
      )) {
        count += 1;
      }
    }

    return count;
  }
}

class _BotTileChoice {
  const _BotTileChoice({required this.tileId, required this.score});

  final String tileId;
  final int score;
}
