// 撃破時の演出を表示する。
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/entities.dart';

class KillEffectWidget extends StatelessWidget {
  const KillEffectWidget({
    super.key,
    required this.progress,
    required this.team,
    required this.role,
    required this.size,
  });

  final double progress;
  final TeamId team;
  final Role role;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _KillEffectPainter(
        progress: progress,
        team: team,
        role: role,
      ),
    );
  }
}

class _KillEffectPainter extends CustomPainter {
  _KillEffectPainter({
    required this.progress,
    required this.team,
    required this.role,
  });

  final double progress;
  final TeamId team;
  final Role role;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final center = Offset(size.width / 2, size.height / 2);

    _drawShockwave(canvas, center, size, eased);
    _drawRadialBurst(canvas, center, size, eased);
    _drawSparks(canvas, center, size, eased);
    _drawFlash(canvas, center, size, eased);

    _renderSplit(canvas, center, size, eased);

    _drawSlash(canvas, center, size, eased);
    _drawGlowHalo(canvas, center, size, eased);
  }

  void _renderSplit(Canvas canvas, Offset center, Size size, double eased) {
    final separation = size.width * 0.35 * eased;
    final delta = separation / math.sqrt(2);
    final offsetTR = Offset(delta, -delta);
    final offsetBL = Offset(-delta, delta);

    final clipTR = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    final clipBL = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.save();
    canvas.translate(offsetTR.dx, offsetTR.dy);
    canvas.clipPath(clipTR);
    _drawUnit(canvas, center, size);
    canvas.restore();

    canvas.save();
    canvas.translate(offsetBL.dx, offsetBL.dy);
    canvas.clipPath(clipBL);
    _drawUnit(canvas, center, size);
    canvas.restore();
  }

  void _drawShockwave(Canvas canvas, Offset center, Size size, double eased) {
    final ringRadius = size.width * (0.15 + eased * 0.75);
    final ringOpacity = (1.0 - eased).clamp(0.0, 1.0);
    final ringPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.35 * ringOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, ringRadius, ringPaint);
  }

  void _drawRadialBurst(Canvas canvas, Offset center, Size size, double eased) {
    final burstPaint = Paint()
      ..color = _roleColor.withOpacity(0.6 * (1.0 - eased))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..blendMode = BlendMode.plus;
    const rayCount = 8;
    final baseLen = size.width * (0.25 + eased * 0.45);
    for (var i = 0; i < rayCount; i++) {
      final angle = (math.pi * 2 / rayCount) * i + 0.3;
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + dir * (size.width * 0.1),
        center + dir * baseLen,
        burstPaint,
      );
    }
  }

  void _drawSparks(Canvas canvas, Offset center, Size size, double eased) {
    final sparkPaint = Paint()
      ..color = _teamColor.withOpacity(0.7 * (1.0 - eased))
      ..strokeWidth = size.width * 0.02
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.screen;
    const sparkCount = 12;
    for (var i = 0; i < sparkCount; i++) {
      final angle = (math.pi * 2 / sparkCount) * i - 0.2;
      final dir = Offset(math.cos(angle), math.sin(angle));
      final len = size.width * (0.12 + eased * 0.25);
      final start = center + dir * (size.width * 0.05);
      final end = start + dir * len;
      canvas.drawLine(start, end, sparkPaint);
    }
  }

  void _drawFlash(Canvas canvas, Offset center, Size size, double eased) {
    final flashOpacity = (1.0 - eased).clamp(0.0, 1.0);
    final flashPaint = Paint()
      ..color = const Color(0xFFFF3B3B).withOpacity(0.35 * flashOpacity)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, size.width * 0.55, flashPaint);
  }

  void _drawSlash(Canvas canvas, Offset center, Size size, double eased) {
    final slashOpacity = (1.0 - eased).clamp(0.0, 1.0);
    final slashPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.9 * slashOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.screen;
    final slashOffset = size.width * (0.15 + eased * 0.05);
    canvas.drawLine(
      center - Offset(slashOffset, slashOffset),
      center + Offset(slashOffset, slashOffset),
      slashPaint,
    );
  }

  void _drawGlowHalo(Canvas canvas, Offset center, Size size, double eased) {
    final haloPaint = Paint()
      ..color = _teamColor.withOpacity(0.35 * (1.0 - eased))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, size.width * 0.3, haloPaint);
  }

  void _drawUnit(Canvas canvas, Offset center, Size size) {
    final radius = size.width * 0.23;

    final bodyPaint = Paint()..color = _teamColor;
    canvas.drawCircle(center, radius, bodyPaint);

    final innerPaint = Paint()..color = _roleColor;
    canvas.drawCircle(center, radius * 0.7, innerPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawCircle(center, radius, borderPaint);
  }

  Color get _teamColor {
    return team == TeamId.attacker ? const Color(0xFFE15A5A) : const Color(0xFF5A8AE1);
  }

  Color get _roleColor {
    switch (role) {
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

  @override
  bool shouldRepaint(_KillEffectPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.team != team ||
        oldDelegate.role != role;
  }
}
