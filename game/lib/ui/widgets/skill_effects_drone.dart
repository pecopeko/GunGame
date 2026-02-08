// ドローン演出のWidgetを定義する。
part of 'skill_effects_overlay.dart';

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
