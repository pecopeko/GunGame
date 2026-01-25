import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/entities.dart';

class DroneComponent extends PositionComponent {
  DroneComponent({
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

  double _hoverTime = 0.0;
  double _scanTime = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _hoverTime += dt * 2.0;
    _scanTime += dt * 1.5;
  }

  Color get _teamColor {
    return effect.team == TeamId.attacker
        ? const Color(0xFFE15A5A)
        : const Color(0xFF5A8AE1);
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    // Bobbing effect
    final bobOffset = sin(_hoverTime) * 3.0;
    final drawCenter = center + Offset(0, bobOffset);

    final headSize = tileSize * 0.5;
    final headRect = Rect.fromCenter(
      center: drawCenter,
      width: headSize,
      height: headSize * 0.75,
    );

    final headPaint = Paint()
      ..color = const Color(0xFFB7C0C7)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, Radius.circular(headSize * 0.12)),
      headPaint,
    );

    final panelPaint = Paint()
      ..color = const Color(0xFF6C7A86)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        headRect.deflate(headSize * 0.12),
        Radius.circular(headSize * 0.1),
      ),
      panelPaint,
    );

    final eyePaint = Paint()..color = _teamColor;
    final eyeOffset = headSize * 0.12;
    final eyeRadius = headSize * 0.08;
    canvas.drawCircle(drawCenter + Offset(-eyeOffset, -eyeOffset * 0.1), eyeRadius, eyePaint);
    canvas.drawCircle(drawCenter + Offset(eyeOffset, -eyeOffset * 0.1), eyeRadius, eyePaint);

    final mouthPaint = Paint()
      ..color = const Color(0xFF2F3640)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      drawCenter + Offset(-eyeOffset, eyeOffset * 0.6),
      drawCenter + Offset(eyeOffset, eyeOffset * 0.6),
      mouthPaint,
    );

    final antennaPaint = Paint()
      ..color = const Color(0xFF8C99A4)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      drawCenter + Offset(0, -headRect.height / 2),
      drawCenter + Offset(0, -headRect.height / 2 - headSize * 0.2),
      antennaPaint,
    );
    canvas.drawCircle(
      drawCenter + Offset(0, -headRect.height / 2 - headSize * 0.25),
      headSize * 0.06,
      Paint()..color = _teamColor,
    );

    final beamAngle = _scanTime;
    final beamLen = tileSize * 0.7;
    final beamPaint = Paint()
      ..shader = RadialGradient(
        colors: [_teamColor.withOpacity(0.45), _teamColor.withOpacity(0.0)],
      ).createShader(Rect.fromCircle(center: drawCenter, radius: beamLen));

    final path = Path();
    path.moveTo(drawCenter.dx, drawCenter.dy + headSize * 0.2);
    path.lineTo(
      drawCenter.dx + cos(beamAngle - 0.35) * beamLen,
      drawCenter.dy + sin(beamAngle - 0.35) * beamLen,
    );
    path.lineTo(
      drawCenter.dx + cos(beamAngle + 0.35) * beamLen,
      drawCenter.dy + sin(beamAngle + 0.35) * beamLen,
    );
    path.close();
    canvas.drawPath(path, beamPaint);
  }
}
