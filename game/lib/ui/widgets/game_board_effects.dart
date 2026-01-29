import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/entities.dart';

Offset computeShakeOffset(double t, double intensity) {
  final amplitude = 8.0 * intensity * (1.0 - t);
  final angle = t * math.pi * 10;
  return Offset(math.sin(angle) * amplitude, math.cos(angle) * amplitude * 0.6);
}

class KillEffectEntry {
  KillEffectEntry({
    required this.tileId,
    required this.team,
    required this.role,
    required this.controller,
    required this.animation,
  });

  final String tileId;
  final TeamId team;
  final Role role;
  final AnimationController controller;
  final Animation<double> animation;
}

class SpikeExplosionEntry {
  SpikeExplosionEntry({
    required this.controller,
    required this.animation,
  });

  final AnimationController controller;
  final Animation<double> animation;
}
