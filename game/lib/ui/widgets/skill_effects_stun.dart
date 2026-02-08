// スタン演出のWidgetを定義する。
part of 'skill_effects_overlay.dart';

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
