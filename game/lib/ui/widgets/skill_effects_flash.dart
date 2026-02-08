// フラッシュ演出のWidgetを定義する。
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
