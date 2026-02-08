// Fog of Warの描画を担当する。
import 'dart:ui';

import 'package:flame/components.dart';

class FogOfWarComponent extends PositionComponent {
  FogOfWarComponent({
    required this.rows,
    required this.cols,
    required this.tileSize,
    required this.visibleTileIds,
    required this.offsetX,
    required this.offsetY,
  }) : super(
          size: Vector2(cols * tileSize, rows * tileSize),
          position: Vector2(offsetX, offsetY),
        );

  final int rows;
  final int cols;
  final double tileSize;
  final double offsetX;
  final double offsetY;
  Set<String> visibleTileIds;

  @override
  void render(Canvas canvas) {
    final fogPaint = Paint()..color = const Color(0xDD0E1215);

    // Draw fog on non-visible tiles
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final tileId = 'r${r}c$c';
        if (!visibleTileIds.contains(tileId)) {
          final rect = Rect.fromLTWH(
            c * tileSize,
            r * tileSize,
            tileSize,
            tileSize,
          );
          canvas.drawRect(rect, fogPaint);
        }
      }
    }
  }

  void updateVisibility(Set<String> newVisibleTiles) {
    visibleTileIds = newVisibleTiles;
  }
}
