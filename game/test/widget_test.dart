import 'package:flutter_test/flutter_test.dart';

import 'package:game/core/pathing.dart';
import 'package:game/core/entities.dart';

void main() {
  group('Pathing', () {
    test('reachableTiles returns correct tiles for move range 2', () {
      const pathing = Pathing();

      // Create a simple 3x3 map
      final map = MapState(
        rows: 3,
        cols: 3,
        tiles: [
          for (var r = 0; r < 3; r++)
            for (var c = 0; c < 3; c++)
              Tile(
                id: 'r${r}c$c',
                row: r,
                col: c,
                type: TileType.floor,
                walkable: true,
                blocksVision: false,
                zone: 'Mid',
              ),
        ],
      );

      // Start from center tile (1,1)
      final reachable = pathing.reachableTiles(map, 'r1c1', 2, {});

      // Should reach all adjacent tiles within 2 steps
      expect(reachable.contains('r0c0'), true);
      expect(reachable.contains('r0c1'), true);
      expect(reachable.contains('r0c2'), true);
      expect(reachable.contains('r1c0'), true);
      expect(reachable.contains('r1c2'), true);
      expect(reachable.contains('r2c0'), true);
      expect(reachable.contains('r2c1'), true);
      expect(reachable.contains('r2c2'), true);
      // Start tile should not be included
      expect(reachable.contains('r1c1'), false);
    });

    test('reachableTiles respects walls', () {
      const pathing = Pathing();

      // Create a 3x3 map with a wall in the middle
      final tiles = <Tile>[];
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          final isWall = r == 1 && c == 1;
          tiles.add(Tile(
            id: 'r${r}c$c',
            row: r,
            col: c,
            type: isWall ? TileType.wall : TileType.floor,
            walkable: !isWall,
            blocksVision: isWall,
            zone: 'Mid',
          ));
        }
      }

      final map = MapState(rows: 3, cols: 3, tiles: tiles);

      // Start from top-left corner (0,0)
      final reachable = pathing.reachableTiles(map, 'r0c0', 2, {});

      // Wall at (1,1) should not be reachable
      expect(reachable.contains('r1c1'), false);
      // Adjacent tiles should be reachable
      expect(reachable.contains('r0c1'), true);
      expect(reachable.contains('r1c0'), true);
    });
  });
}
