// 盤面上のWorldレイヤーを構成する。
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../app/game_controller.dart';
import '../../core/entities.dart';
import 'fog_of_war_component.dart';
import 'grid_component.dart';
import 'kill_effect_component.dart';
import 'trap_component.dart';
import 'camera_beacon_component.dart';
import 'drone_component.dart';
import 'tile_component.dart';
import 'unit_component.dart';

class WorldLayer extends Component with HasGameRef {
  WorldLayer(this.controller);

  final GameController controller;
  
  // Smaller tiles, visible on screen
  static const double tileSize = 55.0;
  static const double offsetX = 15.0;
  static const double offsetY = 100.0; // Much lower offset

  final Map<String, TileComponent> _tileComponents = {};
  final Map<String, UnitComponent> _unitComponents = {};
  final Map<String, Component> _effectComponents = {};
  FogOfWarComponent? _fogComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugPrint('WorldLayer: onLoad started');
    
    controller.addListener(_onStateChanged);
    
    // Wait for game initialization
    debugPrint('WorldLayer: calling initializeGame');
    await controller.initializeGame();
    debugPrint('WorldLayer: initializeGame done, tiles=${controller.state.map.tiles.length}');
    
    _buildBoard();
    debugPrint('WorldLayer: _buildBoard done');
  }

  void _buildBoard() {
    final map = controller.state.map;
    debugPrint('WorldLayer: _buildBoard tiles=${map.tiles.length}');
    if (map.tiles.isEmpty) return;

    // Add grid background
    add(GridComponent(
      rows: map.rows,
      cols: map.cols,
      tileSize: tileSize,
    )..position = Vector2(offsetX, offsetY));

    // Add tiles
    for (final tile in map.tiles) {
      final tileComp = TileComponent(
        tile: tile,
        tileSize: tileSize,
        onTileTap: _onTileTap,
      )..position = Vector2(
          offsetX + tile.col * tileSize,
          offsetY + tile.row * tileSize,
        );
      
      _tileComponents[tile.id] = tileComp;
      add(tileComp);
    }

    // Add units (with visibility check)
    _rebuildUnits();
    
    // Add effects
    _rebuildEffects();

    // TEMPORARILY DISABLED: Add fog of war layer (rendered on top)
    // _fogComponent = FogOfWarComponent(
    //   rows: map.rows,
    //   cols: map.cols,
    //   tileSize: tileSize,
    //   visibleTileIds: controller.visibleTilesForCurrentTeam,
    //   offsetX: offsetX,
    //   offsetY: offsetY,
    // );
    // add(_fogComponent!);
  }

  void _rebuildUnits() {
    // Remove old unit components
    for (final comp in _unitComponents.values) {
      comp.removeFromParent();
    }
    _unitComponents.clear();

    final visibleTiles = controller.visibleTilesForCurrentTeam;
    final currentTeam = controller.state.turnTeam;

    // Add new unit components
    for (final unit in controller.state.units) {
      if (!unit.alive) continue;

      final isOwnUnit = unit.team == currentTeam;
      final isRevealed = unit.statuses.any((s) => s.type == StatusType.revealed);
      final isVisible = isOwnUnit || isRevealed || visibleTiles.contains(unit.posTileId);

      if (!isVisible) continue;

      final tile = controller.state.map.tiles.firstWhere(
        (t) => t.id == unit.posTileId,
      );

      final unitComp = UnitComponent(
        unitState: unit,
        tileSize: tileSize,
        tilePosition: Vector2(
          offsetX + tile.col * tileSize,
          offsetY + tile.row * tileSize,
        ),
        isSelected: unit.unitId == controller.selectedUnitId,
        isAttackable: controller.attackableUnitIds.contains(unit.unitId),
        onUnitTap: _onUnitTap,
      );

      _unitComponents[unit.unitId] = unitComp;
      add(unitComp);
    }
  }

  void _onStateChanged() {
    // Check for deaths to play effects BEFORE rebuilding
    for (final unitId in _unitComponents.keys) {
      final unitInfo = controller.state.units.cast<UnitState?>().firstWhere(
        (u) => u?.unitId == unitId,
        orElse: () => null,
      );
      
      // If found and dead, and we have the component (position)
      // If found and dead, and we have the component (position)
      if (unitInfo != null) {
        if (!unitInfo.alive) {
          final comp = _unitComponents[unitId];
          if (comp != null) {
            final centerPos = comp.position + Vector2.all(tileSize / 2);
             add(KillEffectComponent(
              position: centerPos,
              unitState: unitInfo,
              tileSize: tileSize,
            ));
            debugPrint('WorldLayer: Kill effect spawned for $unitId at $centerPos');
          } else {
            debugPrint('WorldLayer: Unit $unitId is dead but no component found to spawn effect at');
          }
        }
      } else {
        // unitInfo null means removed from list.
        // If it was in _unitComponents, it might have died and been removed?
        // Or just an error.
        // debugPrint('WorldLayer: Unit $unitId not found in state units');
      }
    }

    // Update fog of war
    _fogComponent?.updateVisibility(controller.visibleTilesForCurrentTeam);

    // Update tile highlights (movement and skill)
    for (final entry in _tileComponents.entries) {
      entry.value.isHighlighted = 
          controller.highlightedTiles.contains(entry.key);
      entry.value.isSkillTarget =
          controller.skillTargetTiles.contains(entry.key);
    }

    // Rebuild units to update visibility
    _rebuildUnits();
    
    // Rebuild effects
    _rebuildEffects();
  }

  void _onTileTap(Tile tile) {
    controller.onTileTap(tile.id);
  }

  void _onUnitTap(UnitState unit) {
    controller.onUnitTap(unit.unitId);
  }

  @override
  void onRemove() {
    controller.removeListener(_onStateChanged);
    super.onRemove();
  }

  void _rebuildEffects() {
    // Remove old effect components
    for (final comp in _effectComponents.values) {
      comp.removeFromParent();
    }
    _effectComponents.clear();

    final visibleTiles = controller.visibleTilesForCurrentTeam;
    final currentTeam = controller.state.turnTeam;

    // Add new effect components
    for (final effect in controller.state.effects) {
      if (effect.remainingTurns <= 0) continue;

      // Visibility check for effects?
      // Traps generally invisible unless revealed? 
      // For now, let's make them visible if on visible tile OR if owned by current team.
      final isOwn = effect.team == currentTeam;
      // Also if effect is 'Trap' and enemy, maybe hidden?
      // User didn't specify invisibility rules, but let's stick to standard map visibility.
      // If tile is visible, object is visible. (Unless Trap logic says otherwise).
      // Let's assume visible for now to see the designs.
      
      final isTrigger = effect.id.startsWith('trap_trigger_') ||
          effect.id.startsWith('camera_trigger_');
      final isVisible = isTrigger
          ? false
          : (effect.type == EffectType.trap || effect.type == EffectType.camera
              ? isOwn
              : (effect.type == EffectType.drone ||
                  isOwn ||
                  visibleTiles.contains(effect.tileId)));
      if (!isVisible) continue;

      final tile = controller.state.map.tiles.firstWhere(
        (t) => t.id == effect.tileId,
        orElse: () => const Tile(id: '', row: 0, col: 0, type: TileType.floor, walkable: true, blocksVision: false, zone: ''),
      );
      if (tile.id.isEmpty) continue;

      final pos = Vector2(
        offsetX + tile.col * tileSize + tileSize / 2, // Centered
        offsetY + tile.row * tileSize + tileSize / 2,
      );

      Component? comp;
      switch (effect.type) {
        case EffectType.trap:
          comp = TrapComponent(effect: effect, tileSize: tileSize, position: pos);
          break;
        case EffectType.camera:
          comp = CameraBeaconComponent(effect: effect, tileSize: tileSize, position: pos);
          break;
        case EffectType.drone:
          comp = DroneComponent(effect: effect, tileSize: tileSize, position: pos);
          break;
        case EffectType.smoke:
          // SmokeComponent not requested to be designed yet, or maybe uses default?
          // I didn't see SmokeComponent imported but file existed.
          // Let's skip rendering smoke here unless I import it, or just ignore for now.
          break;
        case EffectType.flash:
        case EffectType.dash:
        case EffectType.stun:
          break;
      }

      if (comp != null) {
        _effectComponents[effect.id] = comp;
        add(comp);
      }
    }
  }
}
