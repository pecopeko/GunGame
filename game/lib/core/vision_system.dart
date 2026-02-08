// 視界計算と可視判定を行う。
import 'entities.dart';

class VisionSystem {
  const VisionSystem();

  /// Get all tile IDs visible to a team based on their units' positions.
  /// Uses line-of-sight calculation with wall blocking.
  Set<String> visibleTilesForTeam(GameState state, TeamId team) {
    final visibleTiles = <String>{};
    final map = state.map;
    final tileMap = {for (final t in map.tiles) t.id: t};

    // Get all alive units for this team
    final teamUnits = state.units.where((u) => u.team == team && u.alive);

    for (final unit in teamUnits) {
      final unitTile = tileMap[unit.posTileId];
      if (unitTile == null) continue;

      // Unit can always see its own tile
      visibleTiles.add(unit.posTileId);

      // Check visibility to all other tiles
      final maxRange = _hasStatus(unit, StatusType.blinded)
          ? 0
          : (_hasStatus(unit, StatusType.stunned) ? 1 : null);
      for (final targetTile in map.tiles) {
        if (targetTile.id == unit.posTileId) continue;

        if (maxRange != null) {
          final distance = (unitTile.row - targetTile.row).abs() +
              (unitTile.col - targetTile.col).abs();
          if (distance > maxRange) {
            continue;
          }
        }

        if (hasLineOfSight(unitTile, targetTile, map, tileMap, state: state)) {
          visibleTiles.add(targetTile.id);
        }
      }
    }
    
    // Add tiles visible by cameras? (Future implementation)
    // For now, revealed units are handled in getVisibleEnemies
    
    return visibleTiles;
  }



  /// Check if a tile is blocked by Smoke
  bool _isTileBlockedBySmoke(String tileId, GameState state) {
    return state.effects.any((e) => e.type == EffectType.smoke && e.tileId == tileId);
  }

  /// Check if there's a clear line of sight between two tiles.
  /// Uses Bresenham-style line drawing to check for wall blocking.
  bool hasLineOfSight(
    Tile from,
    Tile to,
    MapState map,
    Map<String, Tile> tileMap, {
    GameState? state, // Optional state for smoke check
  }) {
    // Site tiles (A-to-A or B-to-B) always see each other, even diagonally.
    if (from.type == to.type &&
        (from.type == TileType.siteA || from.type == TileType.siteB)) {
      if (state != null) {
        if (_isTileBlockedBySmoke(from.id, state) || _isTileBlockedBySmoke(to.id, state)) {
          return false;
        }
      }
      return true;
    }

    // Only allow straight (orthogonal) line of sight.
    if (from.row != to.row && from.col != to.col) return false;

    if (state != null) {
      if (_isTileBlockedBySmoke(from.id, state) || _isTileBlockedBySmoke(to.id, state)) {
        return false;
      }
    }

    // Get all tiles along the line
    final tilesOnLine = _getTilesOnLine(from.row, from.col, to.row, to.col);

    // Check if any intermediate tile blocks vision
    for (final pos in tilesOnLine) {
      // Skip start and end tiles
      if (pos[0] == from.row && pos[1] == from.col) continue;
      if (pos[0] == to.row && pos[1] == to.col) continue;

      final tileId = 'r${pos[0]}c${pos[1]}';
      final tile = tileMap[tileId];
      if (tile != null) {
        if (tile.blocksVision) return false;
        
        // Check smoke if state is provided
        if (state != null && _isTileBlockedBySmoke(tileId, state)) {
           return false;
        }
      }
    }

    return true;
  }

  /// Get all grid positions along a line using Bresenham's algorithm.
  List<List<int>> _getTilesOnLine(int r0, int c0, int r1, int c1) {
    final result = <List<int>>[];

    final dr = (r1 - r0).abs();
    final dc = (c1 - c0).abs();
    final sr = r0 < r1 ? 1 : -1;
    final sc = c0 < c1 ? 1 : -1;
    var err = dr - dc;

    var r = r0;
    var c = c0;

    while (true) {
      result.add([r, c]);

      if (r == r1 && c == c1) break;

      final e2 = 2 * err;
      if (e2 > -dc) {
        err -= dc;
        r += sr;
      }
      if (e2 < dr) {
        err += dr;
        c += sc;
      }
    }

    return result;
  }

  /// Get enemy units visible to a team.
  List<UnitState> getVisibleEnemies(GameState state, TeamId team) {
    final visibleTiles = visibleTilesForTeam(state, team);
    final enemyTeam = team == TeamId.attacker ? TeamId.defender : TeamId.attacker;
    return state.units
        .where((u) =>
            u.team == enemyTeam &&
            u.alive &&
            (visibleTiles.contains(u.posTileId) || 
             u.statuses.any((s) => s.type == StatusType.revealed)))
        .toList();
  }

  /// Check if a specific unit can see a target tile.
  bool canUnitSeeTile(UnitState unit, String targetTileId, GameState state) {
    final tileMap = {for (final t in state.map.tiles) t.id: t};
    final unitTile = tileMap[unit.posTileId];
    final targetTile = tileMap[targetTileId];

    if (unitTile == null || targetTile == null) return false;

    final maxRange = _hasStatus(unit, StatusType.blinded)
        ? 0
        : (_hasStatus(unit, StatusType.stunned) ? 1 : null);
    if (maxRange != null) {
      final distance =
          (unitTile.row - targetTile.row).abs() + (unitTile.col - targetTile.col).abs();
      if (distance > maxRange) {
        return false;
      }
    }

    return hasLineOfSight(unitTile, targetTile, state.map, tileMap, state: state);
  }

  List<String> tilesOnLine(String fromTileId, String toTileId, GameState state) {
    final tileMap = {for (final t in state.map.tiles) t.id: t};
    final from = tileMap[fromTileId];
    final to = tileMap[toTileId];
    if (from == null || to == null) return [];

    return _getTilesOnLine(from.row, from.col, to.row, to.col)
        .map((pos) => 'r${pos[0]}c${pos[1]}')
        .toList();
  }

  bool _hasStatus(UnitState unit, StatusType type) {
    return unit.statuses.any((s) => s.type == type && s.remainingTurns > 0);
  }
}
