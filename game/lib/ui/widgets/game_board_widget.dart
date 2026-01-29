import 'package:flutter/material.dart';

import '../../app/game_controller.dart';
import '../../core/entities.dart';
import '../overlays/action_bar_overlay.dart';
import 'game_board_canvas.dart';
import 'game_board_effects.dart';
import 'game_board_hud.dart';
import 'placement_bar_widget.dart';
import 'skill_effects_overlay.dart';

/// Flutter widget-based game board
class GameBoardWidget extends StatefulWidget {
  const GameBoardWidget({super.key, required this.controller});

  final GameController controller;

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> with TickerProviderStateMixin {
  final Map<String, bool> _aliveById = {};
  final List<KillEffectEntry> _killEffects = [];
  final Set<String> _knownEffectIds = {};
  final List<SkillVfxEntry> _skillEffects = [];
  final List<SpikeExplosionEntry> _spikeExplosions = [];
  late final AnimationController _shakeController;
  SpikeStateType? _lastSpikeState;
  double _shakeIntensity = 1.0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _seedAliveState(widget.controller.state);
    _seedEffectIds(widget.controller.state.effects);
    _lastSpikeState = widget.controller.state.spike.state;
    widget.controller.addListener(_handleStateChanged);
  }

  @override
  void didUpdateWidget(GameBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleStateChanged);
      for (final entry in _killEffects) {
        entry.controller.dispose();
      }
      _killEffects.clear();
      for (final entry in _skillEffects) {
        entry.controller.dispose();
      }
      _aliveById.clear();
      _knownEffectIds.clear();
      for (final entry in _spikeExplosions) {
        entry.controller.dispose();
      }
      _spikeExplosions.clear();
      _seedAliveState(widget.controller.state);
      _seedEffectIds(widget.controller.state.effects);
      _lastSpikeState = widget.controller.state.spike.state;
      widget.controller.addListener(_handleStateChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStateChanged);
    for (final entry in _killEffects) {
      entry.controller.dispose();
    }
    _killEffects.clear();
    for (final entry in _skillEffects) {
      entry.controller.dispose();
    }
    _skillEffects.clear();
    for (final entry in _spikeExplosions) {
      entry.controller.dispose();
    }
    _spikeExplosions.clear();
    _shakeController.dispose();
    super.dispose();
  }

  void _seedAliveState(GameState state) {
    for (final unit in state.units) {
      _aliveById[unit.unitId] = unit.alive;
    }
  }

  void _seedEffectIds(List<EffectInstance> effects) {
    for (final effect in effects) {
      _knownEffectIds.add(effect.id);
    }
  }

  void _handleStateChanged() {
    final state = widget.controller.state;
    for (final unit in state.units) {
      final wasAlive = _aliveById[unit.unitId] ?? unit.alive;
      if (wasAlive && !unit.alive) {
        _spawnKillEffect(unit);
      }
      _aliveById[unit.unitId] = unit.alive;
    }

    for (final effect in state.effects) {
      if (_knownEffectIds.add(effect.id)) {
        _spawnSkillEffect(effect);
      }
    }

    final spikeState = state.spike.state;
    if (_lastSpikeState != spikeState && spikeState == SpikeStateType.exploded) {
      _spawnSpikeExplosion();
    }
    _lastSpikeState = spikeState;
  }

  void _spawnKillEffect(UnitState unit) {
    if (!mounted || unit.posTileId.isEmpty) return;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final entry = KillEffectEntry(
      tileId: unit.posTileId,
      team: unit.team,
      role: unit.card.role,
      controller: controller,
      animation: animation,
    );

    setState(() {
      _killEffects.add(entry);
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _killEffects.remove(entry);
          });
        }
        controller.dispose();
      }
    });

    controller.forward();
    _shakeIntensity = 1.0;
    _shakeController.forward(from: 0.0);
  }

  void _spawnSkillEffect(EffectInstance effect) {
    if (effect.type != EffectType.flash &&
        effect.type != EffectType.dash &&
        effect.type != EffectType.smoke &&
        effect.type != EffectType.trap &&
        effect.type != EffectType.camera &&
        effect.type != EffectType.drone &&
        effect.type != EffectType.stun) {
      return;
    }
    final isTriggerEffect = effect.id.startsWith('trap_trigger_') ||
        effect.id.startsWith('camera_trigger_');
    if (!isTriggerEffect &&
        (effect.type == EffectType.trap || effect.type == EffectType.camera) &&
        effect.team != widget.controller.state.turnTeam) {
      return;
    }

    if (effect.type == EffectType.trap || effect.type == EffectType.camera) {
      _shakeIntensity = 1.6;
      _shakeController.forward(from: 0.0);
    }

    final durationMs = switch (effect.type) {
      EffectType.flash => 700,
      EffectType.dash => 600,
      EffectType.smoke => 900,
      EffectType.trap => 800,
      EffectType.camera => 800,
      EffectType.drone => 900,
      EffectType.stun => 700,
      _ => 700,
    };

    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    final entry = SkillVfxEntry(
      id: effect.id,
      type: effect.type,
      tileId: effect.tileId,
      targetTileId: effect.targetTileId,
      controller: controller,
      animation: animation,
    );

    setState(() {
      _skillEffects.add(entry);
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _skillEffects.remove(entry);
          });
        }
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _spawnSpikeExplosion() {
    if (!mounted) return;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    final entry = SpikeExplosionEntry(controller: controller, animation: animation);
    setState(() {
      _spikeExplosions.add(entry);
    });
    _shakeIntensity = 2.2;
    _shakeController.forward(from: 0.0);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _spikeExplosions.remove(entry);
          });
        }
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2A3A4A),
            const Color(0xFF1A2530),
            const Color(0xFF0F1A20),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // HUD at top
            GameBoardHud(controller: widget.controller),
            // Game board
            Expanded(
              child: GameBoardCanvas(
                controller: widget.controller,
                shakeAnimation: _shakeController,
                shakeIntensity: _shakeIntensity,
                skillEffects: _skillEffects,
                killEffects: _killEffects,
                spikeExplosions: _spikeExplosions,
              ),
            ),
            // Action bar at bottom
            _buildActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final controller = widget.controller;
    // Check if in setup phase
    if (controller.state.phase.startsWith('Setup') ||
        controller.state.phase == 'SelectSpikeCarrier') {
      return PlacementBarWidget(controller: controller);
    }

    return ActionBarOverlay(controller: controller);
  }
}
