import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/game_controller.dart';
import '../../core/entities.dart';
import '../overlays/action_bar_overlay.dart';
import 'game_settings_sheet.dart';
import 'kill_effect_widget.dart';
import 'placement_bar_widget.dart';
import 'skill_effects_overlay.dart';
import 'tile_widget.dart';

/// Flutter widget-based game board
class GameBoardWidget extends StatefulWidget {
  const GameBoardWidget({super.key, required this.controller});

  final GameController controller;

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> with TickerProviderStateMixin {
  final Map<String, bool> _aliveById = {};
  final List<_KillEffectEntry> _killEffects = [];
  final Set<String> _knownEffectIds = {};
  final List<SkillVfxEntry> _skillEffects = [];
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _seedAliveState(widget.controller.state);
    _seedEffectIds(widget.controller.state.effects);
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
      _seedAliveState(widget.controller.state);
      _seedEffectIds(widget.controller.state.effects);
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
  }

  void _spawnKillEffect(UnitState unit) {
    if (!mounted || unit.posTileId.isEmpty) return;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final entry = _KillEffectEntry(
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

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final map = controller.state.map;
    if (map.tiles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Create a map for quick tile lookup
    final tileMap = {for (final t in map.tiles) '${t.row},${t.col}': t};
    
    // Create unit position map - only show visible units
    final unitPositions = <String, UnitState>{};
    
    // My team is always visible to me
    final myTeamUnits = controller.state.units.where(
      (u) => u.team == controller.state.turnTeam && u.alive
    );
    
    // Visible enemies
    final visibleEnemies = controller.visibleEnemies;
    
    for (final unit in [...myTeamUnits, ...visibleEnemies]) {
      unitPositions[unit.posTileId] = unit;
    }

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
            _buildHud(context),
            // Game board
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tileSize = constraints.maxWidth / map.cols;
                        final effectSize = tileSize * 1.5;
                        final tileById = {for (final t in map.tiles) t.id: t};

                        return AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: _shakeOffset(_shakeController.value),
                              child: child,
                            );
                          },
                          child: Stack(
                            children: [
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: map.cols,
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 0,
                                ),
                                itemCount: map.rows * map.cols,
                                itemBuilder: (context, index) {
                                  final row = index ~/ map.cols;
                                  final col = index % map.cols;
                                  final tile = tileMap['$row,$col'];

                                  if (tile == null) {
                                    return const SizedBox.shrink();
                                  }

                                  final unit = unitPositions[tile.id];
                                final isHighlighted =
                                    controller.highlightedTiles.contains(tile.id);
                                final isSelected = controller.selectedUnit?.posTileId == tile.id;
                                final isSkillTarget =
                                    controller.skillTargetTiles.contains(tile.id);

                                return TileWidget(
                                  tile: tile,
                                  unit: unit,
                                  isHighlighted: isHighlighted,
                                  isSelected: isSelected,
                                  isSkillTarget: isSkillTarget,
                                  onTap: () => controller.onTileTap(tile.id),
                                );
                              },
                            ),
                              IgnorePointer(
                                child: SkillEffectsOverlay(
                                  tileById: tileById,
                                  tileSize: tileSize,
                                  rows: map.rows,
                                  cols: map.cols,
                                  effects: controller.state.effects,
                                  transientEffects: _skillEffects,
                                ),
                              ),
                              IgnorePointer(
                                child: Stack(
                                  children: [
                                    for (final entry in _killEffects)
                                      if (tileById[entry.tileId] != null)
                                        Positioned(
                                          left: tileById[entry.tileId]!.col * tileSize +
                                              tileSize / 2 -
                                              effectSize / 2,
                                          top: tileById[entry.tileId]!.row * tileSize +
                                              tileSize / 2 -
                                              effectSize / 2,
                                          child: AnimatedBuilder(
                                            animation: entry.animation,
                                            builder: (context, _) {
                                              return KillEffectWidget(
                                                progress: entry.animation.value,
                                                team: entry.team,
                                                role: entry.role,
                                                size: effectSize,
                                              );
                                            },
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Action bar at bottom
            _buildActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHud(BuildContext context) {
    final controller = widget.controller;
    final state = controller.state;
    final isSetup = state.phase.startsWith('Setup');
    final String turnLabel;
    final Color turnColor;
    
    if (isSetup) {
      final isAttackerSetup = state.phase == 'SetupAttacker';
      turnLabel = isAttackerSetup ? 'ATTACKER SETUP' : 'DEFENDER SETUP';
      turnColor = isAttackerSetup ? const Color(0xFFE57373) : const Color(0xFF4FC3F7);
    } else {
      turnLabel = state.turnTeam == TeamId.attacker ? 'ATTACKER' : 'DEFENDER';
      turnColor = state.turnTeam == TeamId.attacker 
          ? const Color(0xFFE57373) 
          : const Color(0xFF4FC3F7);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => showGameSettingsSheet(context),
                  icon: const Icon(Icons.settings, color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                  tooltip: 'Settings',
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ROUND ${state.roundIndex}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        turnLabel,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: turnColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.spikeStatusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final controller = widget.controller;
    // Check if in setup phase
    if (controller.state.phase.startsWith('Setup')) {
      return PlacementBarWidget(controller: controller);
    }

    return ActionBarOverlay(controller: controller);
  }
}

Offset _shakeOffset(double t) {
  final amplitude = 6.0 * (1.0 - t);
  final angle = t * math.pi * 10;
  return Offset(math.sin(angle) * amplitude, math.cos(angle) * amplitude * 0.6);
}

class _KillEffectEntry {
  _KillEffectEntry({
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
