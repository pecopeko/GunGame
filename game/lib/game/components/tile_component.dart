import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../core/entities.dart';

class TileComponent extends PositionComponent with TapCallbacks {
  TileComponent({
    required this.tile,
    required this.tileSize,
    this.isHighlighted = false,
    this.isSkillTarget = false,
    this.onTileTap,
  }) : super(
          position: Vector2(
            tile.col * tileSize,
            tile.row * tileSize,
          ),
          size: Vector2.all(tileSize),
        );

  final Tile tile;
  final double tileSize;
  bool isHighlighted;
  bool isSkillTarget;
  void Function(Tile)? onTileTap;

  Color get _baseColor {
    switch (tile.type) {
      case TileType.floor:
        return const Color(0xFF1A2126);
      case TileType.wall:
        return const Color(0xFF3A4248);
      case TileType.siteA:
        return const Color(0xFF2A4A5A);
      case TileType.siteB:
        return const Color(0xFF4A2A5A);
      case TileType.mid:
        return const Color(0xFF3A3A26);
    }
  }

  Color get _borderColor {
    switch (tile.type) {
      case TileType.siteA:
        return const Color(0xFF4A8AAA);
      case TileType.siteB:
        return const Color(0xFF8A4AAA);
      default:
        return const Color(0xFF2A3136);
    }
  }

  @override
  void render(Canvas canvas) {
    debugPrint('TileComponent: rendering ${tile.id} at position=$position size=$size');
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    
    // ベース色で塗りつぶし
    final fillPaint = Paint()..color = _baseColor;
    canvas.drawRect(rect, fillPaint);

    // Highlight for movement
    if (isHighlighted) {
      final highlightPaint = Paint()
        ..color = const Color(0xFF1BA784).withAlpha(102);
      canvas.drawRect(rect, highlightPaint);
    }

    // Highlight for skill target
    if (isSkillTarget) {
      final skillPaint = Paint()
        ..color = const Color(0xFFE1B563).withAlpha(102);
      canvas.drawRect(rect, skillPaint);
    }

    // Border
    final borderPaint = Paint()
      ..color = _borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(rect.deflate(0.75), borderPaint);

    // Zone label for sites
    if (tile.type == TileType.siteA || tile.type == TileType.siteB) {
      final label = tile.type == TileType.siteA ? 'A' : 'B';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: _borderColor.withOpacity(0.7),
            fontSize: tileSize * 0.3,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.x - textPainter.width) / 2,
          (size.y - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    onTileTap?.call(tile);
  }

  // 壁タイルにレンガパターンを描画
  void _drawBrickPattern(Canvas canvas, Rect rect) {
    final linePaint = Paint()
      ..color = const Color(0xFF3E2723).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 水平線（レンガの横目地）
    final rowHeight = rect.height / 3;
    for (int i = 1; i < 3; i++) {
      final y = rect.top + rowHeight * i;
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        linePaint,
      );
    }

    // 縦線（レンガの縦目地）- 互い違いパターン
    final colWidth = rect.width / 2;
    // 奇数行のオフセット（タイルの位置に基づく）
    final isOddTile = (tile.row + tile.col) % 2 == 1;
    
    // 上段
    if (isOddTile) {
      canvas.drawLine(
        Offset(rect.left + colWidth, rect.top),
        Offset(rect.left + colWidth, rect.top + rowHeight),
        linePaint,
      );
    }
    
    // 中段
    if (!isOddTile) {
      canvas.drawLine(
        Offset(rect.left + colWidth, rect.top + rowHeight),
        Offset(rect.left + colWidth, rect.top + rowHeight * 2),
        linePaint,
      );
    }
    
    // 下段
    if (isOddTile) {
      canvas.drawLine(
        Offset(rect.left + colWidth, rect.top + rowHeight * 2),
        Offset(rect.left + colWidth, rect.bottom),
        linePaint,
      );
    }
  }
}
