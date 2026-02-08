// Flameゲーム本体の構成を定義する。
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../app/game_controller.dart';
import 'components/world_layer.dart';

class TacticalGame extends FlameGame {
  TacticalGame(this.controller);

  final GameController controller;

  @override
  Color backgroundColor() => const Color(0xFF0A0D10);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugPrint('TacticalGame: onLoad started');
    add(WorldLayer(controller));
    debugPrint('TacticalGame: WorldLayer added');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Debug: draw a red rectangle to verify rendering works
    final paint = Paint()..color = const Color(0xFFFF0000);
    canvas.drawRect(const Rect.fromLTWH(50, 50, 200, 100), paint);
    debugPrint('TacticalGame: render called');
  }
}

