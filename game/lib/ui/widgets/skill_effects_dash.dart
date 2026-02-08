// ダッシュ演出のWidgetを定義する。
part of 'skill_effects_overlay.dart';

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
