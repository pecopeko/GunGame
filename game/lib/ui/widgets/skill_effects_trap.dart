// トラップ発動演出を定義する。
part of 'skill_effects_overlay.dart';

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
