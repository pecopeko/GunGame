import 'package:flutter/material.dart';

class SpikeExplosionWidget extends StatelessWidget {
  const SpikeExplosionWidget({
    super.key,
    required this.size,
    required this.animation,
  });

  final Size size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          size: size,
          painter: SpikeExplosionPainter(progress: animation.value),
        );
      },
    );
  }
}

class SpikeExplosionPainter extends CustomPainter {
  SpikeExplosionPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOutCubic.transform(progress);
    final flash = (1.0 - eased).clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.8;
    final radius = maxRadius * (0.15 + eased * 0.85);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF).withOpacity(0.8 * flash),
          const Color(0xFFFFC857).withOpacity(0.55 * flash),
          const Color(0xFFFF6A3D).withOpacity(0.3 * flash),
          const Color(0xFF2B0F0F).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, radius, glowPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.6 * flash)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.02
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, radius * 0.8, ringPaint);

    final shockPaint = Paint()
      ..color = const Color(0xFFFFB74D).withOpacity(0.5 * flash)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.03
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, radius, shockPaint);

    final screenPaint = Paint()
      ..color = const Color(0xFFFFF4D1).withOpacity(0.2 * flash)
      ..blendMode = BlendMode.screen;
    canvas.drawRect(Offset.zero & size, screenPaint);
  }

  @override
  bool shouldRepaint(covariant SpikeExplosionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
