// スモーク演出のWidgetを定義する。
part of 'skill_effects_overlay.dart';

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
