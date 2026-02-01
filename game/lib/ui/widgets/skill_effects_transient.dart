part of 'skill_effects_overlay.dart';

class FlashEffectWidget extends StatelessWidget {
  const FlashEffectWidget({
    required this.center,
    required this.size,
    required this.animation,
  });

  final Offset center;
  final double size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size.square(size),
            painter: FlashPainter(progress: animation.value),
          );
        },
      ),
    );
  }
}

class FlashPainter extends CustomPainter {
  FlashPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOut.transform(progress);
    final flashOpacity = (1.0 - eased).clamp(0.0, 1.0);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final fillPaint = Paint()
      ..color = const Color(0xFFFFF1A6).withOpacity(0.22 * flashOpacity);
    canvas.drawRect(rect, fillPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.35 * flashOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;
    canvas.drawRect(rect.deflate(size.width * 0.05), borderPaint);
  }

  @override
  bool shouldRepaint(covariant FlashPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class SmokePuffWidget extends StatelessWidget {
  const SmokePuffWidget({
    required this.center,
    required this.size,
    required this.animation,
  });

  final Offset center;
  final double size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size.square(size),
            painter: SmokePuffPainter(progress: animation.value),
          );
        },
      ),
    );
  }
}

class SmokePuffPainter extends CustomPainter {
  SmokePuffPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOut.transform(progress);
    final center = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - eased).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = const Color(0xFF2E3942).withOpacity(0.7 * opacity)
      ..blendMode = BlendMode.srcOver;

    final baseRadius = size.width * (0.25 + 0.35 * eased);
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 2 + 0.3;
      final offset = Offset(
        math.cos(angle) * baseRadius * 0.4,
        math.sin(angle) * baseRadius * 0.4,
      );
      canvas.drawCircle(center + offset, baseRadius * (0.9 + i * 0.1), paint);
    }

    final corePaint = Paint()
      ..color = const Color(0xFF1B232B).withOpacity(0.8 * opacity);
    canvas.drawCircle(center, baseRadius * 0.7, corePaint);
  }

  @override
  bool shouldRepaint(covariant SmokePuffPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class DashEffectWidget extends StatelessWidget {
  const DashEffectWidget({
    required this.start,
    required this.end,
    required this.size,
    required this.animation,
  });

  final Offset start;
  final Offset end;
  final double size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final padding = size * 0.6;
    final left = math.min(start.dx, end.dx) - padding;
    final top = math.min(start.dy, end.dy) - padding;
    final width = (start.dx - end.dx).abs() + padding * 2;
    final height = (start.dy - end.dy).abs() + padding * 2;
    final localStart = Offset(start.dx - left, start.dy - top);
    final localEnd = Offset(end.dx - left, end.dy - top);

    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size(width, height),
            painter: DashPainter(
              progress: animation.value,
              start: localStart,
              end: localEnd,
              strokeWidth: size * 0.18,
            ),
          );
        },
      ),
    );
  }
}

class DashPainter extends CustomPainter {
  DashPainter({
    required this.progress,
    required this.start,
    required this.end,
    required this.strokeWidth,
  });

  final double progress;
  final Offset start;
  final Offset end;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOut.transform(progress);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF9BE7FF).withOpacity(0.2 + 0.6 * (1.0 - eased)),
          const Color(0xFFFFFFFF).withOpacity(0.8 * (1.0 - eased)),
        ],
      ).createShader(
        Rect.fromPoints(start, end),
      )
      ..strokeWidth = strokeWidth * (1.0 - eased * 0.3)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.screen;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant DashPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.start != start ||
        oldDelegate.end != end;
  }
}

class TrapPulseWidget extends StatelessWidget {
  const TrapPulseWidget({
    required this.center,
    required this.size,
    required this.animation,
  });

  final Offset center;
  final double size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size.square(size),
            painter: TrapPulsePainter(progress: animation.value),
          );
        },
      ),
    );
  }
}

class TrapPulsePainter extends CustomPainter {
  TrapPulsePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOut.transform(progress);
    final opacity = (1.0 - eased).clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height / 2);
    final coreRadius = size.width * (0.18 + eased * 0.45);

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF1E8).withOpacity(0.6 * opacity),
          const Color(0xFFFF7A59).withOpacity(0.35 * opacity),
          const Color(0xFF6B1111).withOpacity(0.08 * opacity),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: coreRadius))
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, coreRadius, corePaint);

    final ringPaint = Paint()
      ..color = const Color(0xFFFF4A2A).withOpacity(0.5 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, coreRadius * 0.9, ringPaint);

    final innerRingPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.35 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, coreRadius * 0.6, innerRingPaint);
  }

  @override
  bool shouldRepaint(covariant TrapPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class CameraPulseWidget extends StatelessWidget {
  const CameraPulseWidget({
    required this.center,
    required this.size,
    required this.animation,
  });

  final Offset center;
  final double size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size.square(size),
            painter: CameraPulsePainter(progress: animation.value),
          );
        },
      ),
    );
  }
}

class CameraPulsePainter extends CustomPainter {
  CameraPulsePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOut.transform(progress);
    final opacity = (1.0 - eased).clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * (0.18 + eased * 0.55);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF).withOpacity(0.5 * opacity),
          const Color(0xFF75C9FF).withOpacity(0.25 * opacity),
          const Color(0xFF0B1D2A).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, radius, glowPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFF5BCBFF).withOpacity(0.55 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, radius * 0.85, ringPaint);

    final sweepPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.45 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;
    final sweepRect = Rect.fromCircle(
      center: center,
      radius: radius * 0.95,
    );
    canvas.drawArc(sweepRect, -math.pi / 3 + eased, math.pi / 2, false, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant CameraPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class DronePulseWidget extends StatelessWidget {
  const DronePulseWidget({
    required this.center,
    required this.size,
    required this.animation,
  });

  final Offset center;
  final double size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size.square(size),
            painter: DronePulsePainter(progress: animation.value),
          );
        },
      ),
    );
  }
}

class DronePulsePainter extends CustomPainter {
  DronePulsePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOut.transform(progress);
    final opacity = (1.0 - eased).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = const Color(0xFF9BE7FF).withOpacity(0.6 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;

    final radius = size.width * (0.2 + eased * 0.5);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);

    final arcPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.5 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius * 0.7,
    );
    canvas.drawArc(rect, -math.pi / 2, math.pi / 1.5, false, arcPaint);

    final sparkPaint = Paint()
      ..color = const Color(0xFFB4FFEC).withOpacity(0.5 * opacity)
      ..strokeWidth = size.width * 0.02
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 + eased * math.pi;
      final len = radius * 0.6;
      canvas.drawLine(
        Offset(size.width / 2, size.height / 2),
        Offset(
          size.width / 2 + math.cos(angle) * len,
          size.height / 2 + math.sin(angle) * len,
        ),
        sparkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DronePulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class StunShockWidget extends StatelessWidget {
  const StunShockWidget({
    required this.center,
    required this.size,
    required this.animation,
  });

  final Offset center;
  final double size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size.square(size),
            painter: StunShockPainter(progress: animation.value),
          );
        },
      ),
    );
  }
}

class StunShockPainter extends CustomPainter {
  StunShockPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOut.transform(progress);
    final opacity = (1.0 - eased).clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * (0.2 + eased * 0.55);

    final ringPaint = Paint()
      ..color = const Color(0xFFFFC857).withOpacity(0.7 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, ringPaint);

    final boltPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.7 * opacity)
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final angle = (i * math.pi * 2 / 3) + eased * 0.6;
      final inner = radius * 0.2;
      final outer = radius * 0.9;
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        boltPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StunShockPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
