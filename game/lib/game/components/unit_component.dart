import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

import '../../core/entities.dart';

class UnitComponent extends PositionComponent with TapCallbacks {
  UnitComponent({
    required this.unitState,
    required this.tileSize,
    required Vector2 tilePosition,
    this.isSelected = false,
    this.isAttackable = false,
    this.onUnitTap,
  }) : super(
          position: tilePosition,
          size: Vector2.all(tileSize),
        );

  final UnitState unitState;
  final double tileSize;
  bool isSelected;
  bool isAttackable;
  void Function(UnitState)? onUnitTap;

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
    final center = Offset(size.x / 2, size.y / 2);
    final radius = tileSize * 0.35;

    // Attackable ring (red pulsing effect)
    if (isAttackable) {
      final attackPaint = Paint()
        ..color = const Color(0xFFFF4444)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawCircle(center, radius + 6, attackPaint);
    }

    // Selection ring
    if (isSelected) {
      final selectionPaint = Paint()
        ..color = const Color(0xFFE1B563)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, radius + 4, selectionPaint);
    }

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
  }

  @override
  void onTapUp(TapUpEvent event) {
    onUnitTap?.call(unitState);
  }

  void updatePosition(Vector2 newPosition) {
    position = newPosition;
  }
}
