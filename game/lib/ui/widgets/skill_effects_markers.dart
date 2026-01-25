part of 'skill_effects_overlay.dart';

class SmokeFieldPainter extends CustomPainter {
  SmokeFieldPainter({
    required this.tileById,
    required this.tileSize,
    required this.effects,
  });

  final Map<String, Tile> tileById;
  final double tileSize;
  final List<EffectInstance> effects;

  @override
  void paint(Canvas canvas, Size size) {
    for (final effect in effects) {
      final tile = tileById[effect.tileId];
      if (tile == null) continue;
      final center = Offset(
        tile.col * tileSize + tileSize / 2,
        tile.row * tileSize + tileSize / 2,
      );
      final radius = tileSize * 0.8;
      final fade = (effect.totalTurns != null && effect.remainingTurns <= 2)
          ? (0.15 + effect.remainingTurns * 0.2)
          : 1.0;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF0F1B22).withOpacity(0.85 * fade),
            const Color(0xFF050709).withOpacity(1.0 * fade),
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        );
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SmokeFieldPainter oldDelegate) {
    if (oldDelegate.effects.length != effects.length) {
      return true;
    }
    for (var i = 0; i < effects.length; i++) {
      if (oldDelegate.effects[i].remainingTurns != effects[i].remainingTurns) {
        return true;
      }
    }
    return false;
  }
}

class TrapMarker extends StatelessWidget {
  const TrapMarker({required this.center, required this.size});

  final Offset center;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: CustomPaint(
        size: Size.square(size),
        painter: TrapMarkerPainter(),
      ),
    );
  }
}

class TrapMarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF7A59).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.85)
      ..lineTo(size.width * 0.1, size.height * 0.85)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CameraMarker extends StatelessWidget {
  const CameraMarker({required this.center, required this.size});

  final Offset center;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: CustomPaint(
        size: Size.square(size),
        painter: CameraMarkerPainter(),
      ),
    );
  }
}

class CameraMarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = const Color(0xFF75C9FF).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.35, ringPaint);

    final dotPaint = Paint()..color = const Color(0xFFFFFFFF).withOpacity(0.9);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.12, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DroneMarker extends StatelessWidget {
  const DroneMarker({required this.center, required this.size});

  final Offset center;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: CustomPaint(
        size: Size.square(size),
        painter: DroneMarkerPainter(),
      ),
    );
  }
}

class DroneMarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final headSize = size.width * 0.65;
    final headRect = Rect.fromCenter(
      center: center,
      width: headSize,
      height: headSize * 0.75,
    );

    final headPaint = Paint()
      ..color = const Color(0xFFB7C0C7)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, Radius.circular(headSize * 0.12)),
      headPaint,
    );

    final framePaint = Paint()
      ..color = const Color(0xFF768391)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect.deflate(size.width * 0.06), Radius.circular(headSize * 0.1)),
      framePaint,
    );

    final eyePaint = Paint()..color = const Color(0xFF9BE7FF);
    final eyeOffset = headSize * 0.18;
    final eyeRadius = headSize * 0.08;
    canvas.drawCircle(center + Offset(-eyeOffset, -eyeOffset * 0.1), eyeRadius, eyePaint);
    canvas.drawCircle(center + Offset(eyeOffset, -eyeOffset * 0.1), eyeRadius, eyePaint);

    final mouthPaint = Paint()
      ..color = const Color(0xFF2F3640)
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center + Offset(-eyeOffset, eyeOffset * 0.5),
      center + Offset(eyeOffset, eyeOffset * 0.5),
      mouthPaint,
    );

    final antennaPaint = Paint()
      ..color = const Color(0xFF9BE7FF)
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center + Offset(0, -headRect.height / 2),
      center + Offset(0, -headRect.height / 2 - size.width * 0.12),
      antennaPaint,
    );
    canvas.drawCircle(
      center + Offset(0, -headRect.height / 2 - size.width * 0.16),
      size.width * 0.06,
      antennaPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
