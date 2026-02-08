// カメラビーコン表示を担当する。
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/entities.dart';

class CameraBeaconComponent extends PositionComponent {
  CameraBeaconComponent({
    required this.effect,
    required this.tileSize,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(tileSize),
          anchor: Anchor.center,
        );

  final EffectInstance effect;
  final double tileSize;

  double _scanAngle = 0.0;
  double _time = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    // Scan back and forth: -45 to +45 degrees (approx -0.8 to 0.8 rad)
    _scanAngle = sin(_time * 2.0) * 0.8;
  }

  Color get _teamColor {
    return effect.team == TeamId.attacker
        ? const Color(0xFFE15A5A)
        : const Color(0xFF5A8AE1);
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final bodySize = tileSize * 0.25;

    // Camera Body (Rectangle/Boxy)
    final bodyPaint = Paint()
      ..color = const Color(0xFF34495E)
      ..style = PaintingStyle.fill;
    
    final bodyRect = Rect.fromCenter(center: center, width: bodySize * 1.5, height: bodySize);
    // Draw mount (tripod legs or base)
    final mountPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(center + Offset(0, bodySize/2), center + Offset(-bodySize/2, bodySize), mountPaint);
    canvas.drawLine(center + Offset(0, bodySize/2), center + Offset(bodySize/2, bodySize), mountPaint);
    
    // Draw body
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)), bodyPaint);

    // Lens/Eye (Rotates)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_scanAngle);

    // Lens housing
    final lensHousingPaint = Paint()
      ..color = const Color(0xFFBDC3C7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, -bodySize * 0.1), bodySize * 0.4, lensHousingPaint);

    // Glowing Lens
    final lensPaint = Paint()
      ..color = _teamColor // Team color eye
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, -bodySize * 0.1), bodySize * 0.25, lensPaint);
    
    // Shine on lens
    final shinePaint = Paint()..color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(Offset(bodySize * 0.1, -bodySize * 0.2), bodySize * 0.08, shinePaint);

    // View Cone (Faint)
    final conePaint = Paint()
      ..color = _teamColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(tileSize * 0.6, -tileSize * 0.8);
    path.quadraticBezierTo(0, -tileSize * 1.0, -tileSize * 0.6, -tileSize * 0.8);
    path.close();
    // Rotate cone to face "forward" (up relative to camera rotation?)
    // Actually standard canvas is y-down. So "up" is -y.
    // The path draws upwards.
    canvas.drawPath(path, conePaint);
    
    canvas.restore();
    
    // Status Light (Blinking)
    if ((_time * 2).toInt() % 2 == 0) {
       final statusColor = effect.team == TeamId.attacker ? Colors.red : Colors.blue;
       canvas.drawCircle(center + Offset(bodySize * 0.6, -bodySize * 0.4), 2, Paint()..color = statusColor);
    }
  }
}
