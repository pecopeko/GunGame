import 'dart:ui';

import 'package:flame/components.dart';

class GridComponent extends PositionComponent {
  GridComponent({
    required this.rows,
    required this.cols,
    required this.tileSize,
  }) : super(
          size: Vector2(cols * tileSize, rows * tileSize),
        );

  final int rows;
  final int cols;
  final double tileSize;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF2A3136)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Vertical lines
    for (var c = 0; c <= cols; c++) {
      final x = c * tileSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, rows * tileSize),
        paint,
      );
    }

    // Horizontal lines
    for (var r = 0; r <= rows; r++) {
      final y = r * tileSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(cols * tileSize, y),
        paint,
      );
    }
  }
}
