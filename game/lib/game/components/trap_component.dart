import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/entities.dart';

class TrapComponent extends PositionComponent {
  TrapComponent({
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

  double _pulseTime = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt * 3.0; // Pulse speed
  }

  Color get _teamColor {
    return effect.team == TeamId.attacker
        ? const Color(0xFFE15A5A)
        : const Color(0xFF5A8AE1);
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = tileSize * 0.3;

    // Base plate (Dark metal)
    final basePaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, basePaint);

    // Inner mechanism (Lighter metal)
    final mechPaint = Paint()
      ..color = const Color(0xFF95A5A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius * 0.7, mechPaint);

    // Active Core (Team Color, pulsing)
    final opacity = (sin(_pulseTime) + 1) / 2 * 0.5 + 0.5; // 0.5 to 1.0
    final corePaint = Paint()
      ..color = _teamColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.4, corePaint);

    // Glowing Ring
    final ringPaint = Paint()
      ..color = _teamColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius + 4, ringPaint);

    // Prongs/Claws (3 of them)
    // Draw 3 lines extending from center
    final prongPaint = Paint()
      ..color = const Color(0xFFBDC3C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final angle = i * (2 * pi / 3) + _pulseTime * 0.2; // Slow rotation
      final dx = cos(angle);
      final dy = sin(angle);
      canvas.drawLine(
        center + Offset(dx * radius * 0.5, dy * radius * 0.5),
        center + Offset(dx * radius * 1.2, dy * radius * 1.2),
        prongPaint,
      );
    }
  }
}
