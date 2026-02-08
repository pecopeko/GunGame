// 撃破演出コンポーネントを提供する。
import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/entities.dart';

class KillEffectComponent extends PositionComponent {
  KillEffectComponent({
    required Vector2 position,
    required this.unitState,
    required this.tileSize,
  }) : super(position: position, size: Vector2.all(tileSize * 1.5), anchor: Anchor.center, priority: 100);

  final UnitState unitState;
  final double tileSize;

  double _lifeTime = 0.0;
  final double _duration = 0.8; // Slightly longer heavily emphasized effect

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTime += dt;
    if (_lifeTime >= _duration) {
      removeFromParent();
    }
  }

  Color get _teamColor {
    return unitState.team == TeamId.attacker
        ? const Color(0xFFE15A5A)
        : const Color(0xFF5A8AE1);
  }

  Color get _roleColor {
    switch (unitState.card.role) {
      case Role.entry:
        return const Color(0xFFFF6B6B);
      case Role.recon:
        return const Color(0xFF4ECDC4);
      case Role.smoke:
        return const Color(0xFF95A5A6);
      case Role.sentinel:
        return const Color(0xFFF39C12);
    }
  }

  String get _roleIcon {
    switch (unitState.card.role) {
      case Role.entry:
        return 'E';
      case Role.recon:
        return 'R';
      case Role.smoke:
        return 'S';
      case Role.sentinel:
        return 'T';
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_lifeTime / _duration).clamp(0.0, 1.0);
    final center = Offset(size.x / 2, size.y / 2);
    
    // Background flash (brief)
    if (progress < 0.2) {
      final flashOpacity = (1.0 - progress / 0.2).clamp(0.0, 1.0);
      final flashPaint = Paint()
        ..color = const Color(0xFFFF0000).withOpacity(0.3 * flashOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, size.x * 0.8, flashPaint);
    }

    // Split Animation
    _renderSplitUnit(canvas, center, progress);

    // Slash line (visible briefly at the start)
    if (progress < 0.4) {
      final slashOpacity = (1.0 - progress / 0.4).clamp(0.0, 1.0);
      final slashPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withOpacity(slashOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..blendMode = BlendMode.screen;

      final slashLen = size.x;
      // Diagonal slash from top-left to bottom-right (roughly)
      // Actually, let's make it horizontal-ish or standard diagonal
      // Let's match the split direction.
      // Split axis: (-1, 1) direction.
      // Line is perpendicular: (1, 1).
      
      canvas.drawLine(
        center - const Offset(30, 30),
        center + const Offset(30, 30),
        slashPaint,
      );
    }
  }

  void _renderSplitUnit(Canvas canvas, Offset center, double progress) {
    // We want to split the unit into two halves.
    // The cut line is diagonal: y = x (top-left to bottom-right is NOT y=x in screen coords normally, but let's say -45 degrees)
    // Actually, screen coords: x right, y down. 
    // A cut from top-left (0,0) to bottom-right (w,h) means matching points where x ~ y.
    
    // Let's define the cut normal vector (direction of separation).
    // If cut is diagonal like /, the normal is (-1, 1) or (1, -1).
    // Let's say top-half moves up-left, bottom-half moves down-right.
    
    // Separation amount
    final separation = 40.0 * math.pow(progress, 0.3); // Moves quickly then slows? or linear?
    // Let's use an easing out curve
    
    final dx = separation * 0.707; // cos(45)
    final dy = separation * 0.707;

    // --- Top-Left Half ---
    canvas.save();
    // Clip to the upper-left side of the diagonal
    final path1 = Path();
    path1.moveTo(-size.x, -size.y);
    path1.lineTo(size.x * 2, -size.y); // far right top
    path1.lineTo(-size.x, size.y * 2); // far bottom left
    path1.close();
    // Wait, simpler clip: 
    // Rectangle that is rotated?
    // Let's just define a polygon that represents the half-plane.
    
    // Line equation: x - y = 0  => x = y.
    // Top-right side (x > y) vs Bottom-left side (y > x).
    // Let's do top-right and bottom-left for specific diagonal.
    // User asked for "slash diagonally". 
    
    // Let's maintain the cut line as passing through center.
    // Plane 1: Top-Right (or Top-Left).
    // Let's do Top-Left to Bottom-Right Line? No, usually slashing is / or \.
    // Let's assume slashing \ (Top-Left to Bottom-Right).
    // The pieces would separate perpendicular to that line. Top-Right piece and Bottom-Left piece.
    
    // Top-Right Piece moves Top-Right (+x, -y).
    // Bottom-Left Piece moves Bottom-Left (-x, +y).
    
    // Clip for Top-Right Piece: y < x + epsilon? No, coordinate system is y down.
    // Line: y = x.
    // Top-Right region: x > y.
    
    final clipPathTR = Path();
    clipPathTR.moveTo(center.dx - size.x, center.dy - size.x); // Top-Left-ish (outside)
    clipPathTR.lineTo(center.dx + size.x, center.dy - size.x); // Top-Right (outside)
    clipPathTR.lineTo(center.dx + size.x, center.dy + size.x); // Bottom-Right (outside)
    clipPathTR.close();
    // This is a triangle. Not quite a half plane.
    // A huge rectangle rotated is easier.
    
    // Let's rely on simple translation + clipRect if possible, but we need diagonal.
    // We'll manual build the path.
    // The line passes through center. Vector (1,1).
    // Normal (-1, 1).
    
    // Let's define the separation vector.
    final offsetTR = Offset(dx, -dy); // Move Right-Up
    final offsetBL = Offset(-dx, dy); // Move Left-Down
    
    // Draw Top-Right Half
    canvas.save();
    canvas.translate(offsetTR.dx, offsetTR.dy);
    
    // Clip to x > y roughly.
    // Path: (Center) -> (Big Positive X, Center Y + Big X) ...
    // Let's simply rotate the canvas, clip a rect, rotate back? No.
    // Define a path for the half.
    final p1 = Path();
    p1.moveTo(center.dx - size.x, center.dy - size.x); // Top-Left far
    p1.lineTo(center.dx + size.x, center.dy - size.x); // Top-Right far
    p1.lineTo(center.dx + size.x, center.dy + size.x); // Bottom-Right far
    p1.close();
    // This defines the Upper-Right triangle if line is TL to BR.
    
    canvas.clipPath(p1);
    _renderUnit(canvas, center);
    canvas.restore();
    
    // Draw Bottom-Left Half
    canvas.save();
    canvas.translate(offsetBL.dx, offsetBL.dy);
    
    final p2 = Path();
    p2.moveTo(center.dx - size.x, center.dy - size.x); // Top-Left far
    p2.lineTo(center.dx + size.x, center.dy + size.x); // Bottom-Right far
    p2.lineTo(center.dx - size.x, center.dy + size.x); // Bottom-Left far
    p2.close();
    
    canvas.clipPath(p2);
    _renderUnit(canvas, center);
    canvas.restore();
  }

  void _renderUnit(Canvas canvas, Offset center) {
    final radius = tileSize * 0.35;

    // Unit body (outer circle - team color)
    final bodyPaint = Paint()..color = _teamColor;
    canvas.drawCircle(center, radius, bodyPaint);

    // Inner circle (role color)
    final innerPaint = Paint()..color = _roleColor;
    canvas.drawCircle(center, radius * 0.7, innerPaint);

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Role letter
    final textPainter = TextPainter(
      text: TextSpan(
        text: _roleIcon,
        style: TextStyle(
          color: const Color(0xFFFFFFFF),
          fontSize: tileSize * 0.25,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
    
    // Dead "X" or eyes to signify death?
    // The splitting itself is the signifier, maybe adding dead eyes is too much detail?
    // Let's add simple "X X" eyes if possible, or just the slash is enough.
    // The user asked for "Imposter (Among us) style... slashed diagonally and splits".
    // Among Us also has a bone sticking out, but we don't need to be that gorey/specific yet.
    // The slash is the key.
  }
}
