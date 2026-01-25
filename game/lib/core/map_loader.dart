import 'dart:convert';

import 'package:flutter/services.dart';

import 'entities.dart';

class MapLoader {
  const MapLoader();

  Future<MapState> loadFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final data = json.decode(jsonString) as Map<String, dynamic>;
    return parseMapData(data);
  }

  MapState parseMapData(Map<String, dynamic> data) {
    final rows = data['rows'] as int;
    final cols = data['cols'] as int;
    final tilesJson = data['tiles'] as List<dynamic>;

    final tiles = tilesJson.map((t) {
      final tileData = t as Map<String, dynamic>;
      return Tile(
        id: tileData['id'] as String,
        row: tileData['row'] as int,
        col: tileData['col'] as int,
        type: _parseTileType(tileData['type'] as String),
        walkable: tileData['walkable'] as bool,
        blocksVision: tileData['blocksVision'] as bool,
        zone: tileData['zone'] as String,
      );
    }).toList();

    return MapState(rows: rows, cols: cols, tiles: tiles);
  }

  TileType _parseTileType(String type) {
    final cleanType = type.trim();
    switch (cleanType) {
      case 'floor':
        return TileType.floor;
      case 'wall':
        return TileType.wall;
      case 'siteA':
        return TileType.siteA;
      case 'siteB':
        return TileType.siteB;
      case 'mid':
        return TileType.mid;
      default:
        // ignore: avoid_print
        print('WARNING: Unknown tile type "$type" (parsed as "$cleanType"), defaulting to floor');
        return TileType.floor;
    }
  }
}
