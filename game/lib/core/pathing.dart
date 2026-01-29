import 'dart:collection';

import 'entities.dart';

class Pathing {
  const Pathing();

  /// Returns set of tile IDs reachable from startTileId within moveRange steps.
  /// Uses BFS with Manhattan movement (up/down/left/right).
  Set<String> reachableTiles(
    MapState map,
    String startTileId,
    int moveRange,
    Set<String> occupiedTileIds, {
    bool includeOccupied = false,
  }) {
    final result = <String>{};
    final tileMap = {for (final t in map.tiles) t.id: t};

    final startTile = tileMap[startTileId];
    if (startTile == null) return result;

    // BFS
    final queue = Queue<_BfsNode>();
    final visited = <String>{};
    
    queue.add(_BfsNode(startTile, 0));
    visited.add(startTileId);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      
      if (current.distance > 0) {
        // Don't include start tile, and skip occupied tiles
        if (includeOccupied || !occupiedTileIds.contains(current.tile.id)) {
          result.add(current.tile.id);
        }
      }

      if (current.distance >= moveRange) continue;

      // Check neighbors (up, down, left, right)
      final neighbors = _getNeighbors(current.tile, map, tileMap);
      for (final neighbor in neighbors) {
        if (!visited.contains(neighbor.id) && neighbor.walkable) {
          visited.add(neighbor.id);
          queue.add(_BfsNode(neighbor, current.distance + 1));
        }
      }
    }

    return result;
  }

  /// Returns set of tile IDs within Manhattan range (no path blocking).
  /// Use for skill targeting where only distance matters.
  Set<String> tilesInRange(
    MapState map,
    String startTileId,
    int range, {
    bool includeStart = false,
    bool requireWalkable = false,
  }) {
    final result = <String>{};
    final tileMap = {for (final t in map.tiles) t.id: t};

    final startTile = tileMap[startTileId];
    if (startTile == null) return result;

    for (final tile in map.tiles) {
      final distance =
          (startTile.row - tile.row).abs() + (startTile.col - tile.col).abs();
      if (distance == 0 && !includeStart) continue;
      if (distance <= range) {
        if (!requireWalkable || tile.walkable) {
          result.add(tile.id);
        }
      }
    }

    return result;
  }

  /// Returns shortest path from start to target (inclusive), avoiding walls and blocked tiles.
  /// Empty list when no path exists.
  List<String> shortestPath(
    MapState map,
    String startTileId,
    String targetTileId,
    Set<String> blockedTileIds,
  ) {
    if (startTileId == targetTileId) {
      return [startTileId];
    }

    final tileMap = {for (final t in map.tiles) t.id: t};
    final startTile = tileMap[startTileId];
    final targetTile = tileMap[targetTileId];
    if (startTile == null || targetTile == null) return [];

    final queue = Queue<String>();
    final visited = <String>{};
    final parents = <String, String>{};

    queue.add(startTileId);
    visited.add(startTileId);

    while (queue.isNotEmpty) {
      final currentId = queue.removeFirst();
      if (currentId == targetTileId) {
        break;
      }

      final currentTile = tileMap[currentId];
      if (currentTile == null) continue;

      final neighbors = _getNeighbors(currentTile, map, tileMap);
      for (final neighbor in neighbors) {
        if (!neighbor.walkable) continue;
        if (blockedTileIds.contains(neighbor.id)) continue;
        if (visited.contains(neighbor.id)) continue;
        visited.add(neighbor.id);
        parents[neighbor.id] = currentId;
        queue.add(neighbor.id);
      }
    }

    if (!visited.contains(targetTileId)) return [];

    final path = <String>[];
    var current = targetTileId;
    while (current != startTileId) {
      path.add(current);
      final parent = parents[current];
      if (parent == null) break;
      current = parent;
    }
    path.add(startTileId);
    return path.reversed.toList();
  }

  List<Tile> _getNeighbors(
    Tile tile,
    MapState map,
    Map<String, Tile> tileMap,
  ) {
    final neighbors = <Tile>[];
    final directions = [
      [-1, 0], // up
      [1, 0],  // down
      [0, -1], // left
      [0, 1],  // right
    ];

    for (final dir in directions) {
      final newRow = tile.row + dir[0];
      final newCol = tile.col + dir[1];

      if (newRow >= 0 && newRow < map.rows && newCol >= 0 && newCol < map.cols) {
        final neighborId = 'r${newRow}c$newCol';
        final neighbor = tileMap[neighborId];
        if (neighbor != null) {
          neighbors.add(neighbor);
        }
      }
    }

    return neighbors;
  }

  /// Calculate Manhattan distance between two tile IDs
  int manhattanDistance(String tileId1, String tileId2, MapState map) {
    if (tileId1 == tileId2) return 0;
    
    // Parse tile IDs (assuming "r{row}c{col}")
    // Or look up in map. Looking up is safer but slightly slower if ID format is strict.
    // Let's look up for consistency.
    final tileMap = {for (final t in map.tiles) t.id: t};
    final t1 = tileMap[tileId1];
    final t2 = tileMap[tileId2];
    
    if (t1 == null || t2 == null) return 999; // Should not happen
    
    return (t1.row - t2.row).abs() + (t1.col - t2.col).abs();
  }
}

class _BfsNode {
  _BfsNode(this.tile, this.distance);
  final Tile tile;
  final int distance;
}
