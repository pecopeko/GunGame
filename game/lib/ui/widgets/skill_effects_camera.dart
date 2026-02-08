// カメラ演出のWidgetを定義する。
part of 'skill_effects_overlay.dart';

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
    canvas.drawArc(
      sweepRect,
      -math.pi / 3 + eased,
      math.pi / 2,
      false,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CameraPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
