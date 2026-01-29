import 'package:flutter/material.dart';

import '../../app/game_controller.dart';
import '../../core/entities.dart';
import 'game_board_effects.dart';
import 'kill_effect_widget.dart';
import 'skill_effects_overlay.dart';
import 'spike_explosion_widget.dart';
import 'tile_widget.dart';

class GameBoardCanvas extends StatelessWidget {
  const GameBoardCanvas({
    super.key,
    required this.controller,
    required this.shakeAnimation,
    required this.shakeIntensity,
    required this.skillEffects,
    required this.killEffects,
    required this.spikeExplosions,
  });

  final GameController controller;
  final Animation<double> shakeAnimation;
  final double shakeIntensity;
  final List<SkillVfxEntry> skillEffects;
  final List<KillEffectEntry> killEffects;
  final List<SpikeExplosionEntry> spikeExplosions;

  @override
  Widget build(BuildContext context) {
    final map = controller.state.map;
    if (map.tiles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Create a map for quick tile lookup
    final tileMap = {for (final t in map.tiles) '${t.row},${t.col}': t};

    // Create unit position map - only show visible units
    final unitPositions = <String, UnitState>{};

    // My team is always visible to me
    final myTeamUnits =
        controller.state.units.where((u) => u.team == controller.viewTeam && u.alive);

    // Visible enemies
    final visibleEnemies = controller.visibleEnemies;

    for (final unit in [...myTeamUnits, ...visibleEnemies]) {
      unitPositions[unit.posTileId] = unit;
    }

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tileSize = constraints.maxWidth / map.cols;
              final effectSize = tileSize * 1.5;
              final tileById = {for (final t in map.tiles) t.id: t};
              final spike = controller.state.spike;
              final spikeTileId = spike.state == SpikeStateType.planted
                  ? spike.plantedTileId
                  : (spike.state == SpikeStateType.dropped ? spike.droppedTileId : null);

              return AnimatedBuilder(
                animation: shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: computeShakeOffset(shakeAnimation.value, shakeIntensity),
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
                        final isHighlighted = controller.highlightedTiles.contains(tile.id);
                        final isSelected = controller.selectedUnit?.posTileId == tile.id;
                        final isSkillTarget = controller.skillTargetTiles.contains(tile.id);
                        final isSpikeCarrier = unit != null &&
                            spike.state == SpikeStateType.carried &&
                            spike.carrierUnitId == unit.unitId;
                        final showSpike = spikeTileId != null && spikeTileId == tile.id;

                        return TileWidget(
                          tile: tile,
                          unit: unit,
                          isHighlighted: isHighlighted,
                          isSelected: isSelected,
                          isSkillTarget: isSkillTarget,
                          showSpike: showSpike,
                          isSpikeCarrier: isSpikeCarrier,
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
                        transientEffects: skillEffects,
                        currentTeam: controller.viewTeam,
                      ),
                    ),
                    IgnorePointer(
                      child: Stack(
                        children: [
                          for (final entry in spikeExplosions)
                            Positioned.fill(
                              child: SpikeExplosionWidget(
                                size: Size(tileSize * map.cols, tileSize * map.rows),
                                animation: entry.animation,
                              ),
                            ),
                          for (final entry in killEffects)
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
    );
  }
}
