import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/entities.dart';

part 'skill_effects_markers.dart';
part 'skill_effects_transient.dart';

class SkillVfxEntry {
  SkillVfxEntry({
    required this.id,
    required this.type,
    required this.tileId,
    required this.controller,
    required this.animation,
    this.targetTileId,
  });

  final String id;
  final EffectType type;
  final String tileId;
  final String? targetTileId;
  final AnimationController controller;
  final Animation<double> animation;
}

class SkillEffectsOverlay extends StatelessWidget {
  const SkillEffectsOverlay({
    super.key,
    required this.tileById,
    required this.tileSize,
    required this.rows,
    required this.cols,
    required this.effects,
    required this.transientEffects,
  });

  final Map<String, Tile> tileById;
  final double tileSize;
  final int rows;
  final int cols;
  final List<EffectInstance> effects;
  final List<SkillVfxEntry> transientEffects;

  @override
  Widget build(BuildContext context) {
    final boardSize = Size(tileSize * cols, tileSize * rows);
    final smokeEffects = effects.where((e) => e.type == EffectType.smoke).toList();
    final persistentMarkers = effects.where(
      (e) =>
          e.type == EffectType.trap ||
          e.type == EffectType.camera ||
          e.type == EffectType.drone,
    );

    return Stack(
      children: [
        if (smokeEffects.isNotEmpty)
          CustomPaint(
            size: boardSize,
            painter: SmokeFieldPainter(
              tileById: tileById,
              tileSize: tileSize,
              effects: smokeEffects,
            ),
          ),
        for (final effect in persistentMarkers) _buildMarker(effect),
        for (final entry in transientEffects) _buildTransient(entry),
      ],
    );
  }

  Widget _buildTransient(SkillVfxEntry entry) {
    final tile = tileById[entry.tileId];
    if (tile == null) {
      return const SizedBox.shrink();
    }

    switch (entry.type) {
      case EffectType.flash:
        return FlashEffectWidget(
          center: _tileCenter(tile),
          size: tileSize * 2.8,
          animation: entry.animation,
        );
      case EffectType.dash:
        final targetTile = entry.targetTileId == null ? null : tileById[entry.targetTileId!];
        if (targetTile == null) {
          return const SizedBox.shrink();
        }
        return DashEffectWidget(
          start: _tileCenter(tile),
          end: _tileCenter(targetTile),
          size: tileSize,
          animation: entry.animation,
        );
      case EffectType.smoke:
        return SmokePuffWidget(
          center: _tileCenter(tile),
          size: tileSize * 2.6,
          animation: entry.animation,
        );
      case EffectType.trap:
        return TrapPulseWidget(
          center: _tileCenter(tile),
          size: tileSize * 1.8,
          animation: entry.animation,
        );
      case EffectType.camera:
        return CameraPulseWidget(
          center: _tileCenter(tile),
          size: tileSize * 2.0,
          animation: entry.animation,
        );
      case EffectType.drone:
        return DronePulseWidget(
          center: _tileCenter(tile),
          size: tileSize * 2.2,
          animation: entry.animation,
        );
      case EffectType.stun:
        return StunShockWidget(
          center: _tileCenter(tile),
          size: tileSize * 2.0,
          animation: entry.animation,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMarker(EffectInstance effect) {
    final tile = tileById[effect.tileId];
    if (tile == null) {
      return const SizedBox.shrink();
    }

    switch (effect.type) {
      case EffectType.trap:
        return TrapMarker(center: _tileCenter(tile), size: tileSize * 0.9);
      case EffectType.camera:
        return CameraMarker(center: _tileCenter(tile), size: tileSize * 0.95);
      case EffectType.drone:
        return DroneMarker(center: _tileCenter(tile), size: tileSize * 1.0);
      default:
        return const SizedBox.shrink();
    }
  }

  Offset _tileCenter(Tile tile) {
    return Offset(
      tile.col * tileSize + tileSize / 2,
      tile.row * tileSize + tileSize / 2,
    );
  }
}
