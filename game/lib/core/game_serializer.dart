import 'entities.dart';

class GameSerializer {
  const GameSerializer();

  Map<String, Object?> toJson(GameState state) {
    return <String, Object?>{
      'seed': state.seed,
      'roundIndex': state.roundIndex,
      'turnTeam': _teamToString(state.turnTeam),
      'phase': state.phase,
      'map': _mapToJson(state.map),
      'units': state.units.map(_unitToJson).toList(),
      'spike': _spikeToJson(state.spike),
      'effects': state.effects.map(_effectToJson).toList(),
      'log': state.log.map(_logToJson).toList(),
    };
  }

  GameState fromJson(Map<String, Object?> json) {
    final mapJson = json['map'] as Map<String, Object?>?;
    final map = mapJson != null ? _mapFromJson(mapJson) : const MapState(rows: 0, cols: 0, tiles: []);

    final unitsJson = json['units'] as List<dynamic>? ?? const [];
    final units = unitsJson
        .whereType<Map<String, Object?>>()
        .map(_unitFromJson)
        .toList();

    final effectsJson = json['effects'] as List<dynamic>? ?? const [];
    final effects = effectsJson
        .whereType<Map<String, Object?>>()
        .map(_effectFromJson)
        .toList();

    final logJson = json['log'] as List<dynamic>? ?? const [];
    final log = logJson
        .whereType<Map<String, Object?>>()
        .map(_logFromJson)
        .toList();

    return GameState(
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      roundIndex: (json['roundIndex'] as num?)?.toInt() ?? 1,
      turnTeam: _teamFromString(json['turnTeam'] as String?),
      phase: json['phase'] as String? ?? 'Boot',
      map: map,
      units: units,
      spike: _spikeFromJson(json['spike'] as Map<String, Object?>? ?? const {}),
      effects: effects,
      log: log,
    );
  }

  Map<String, Object?> _mapToJson(MapState map) {
    return {
      'rows': map.rows,
      'cols': map.cols,
      'tiles': map.tiles.map(_tileToJson).toList(),
    };
  }

  MapState _mapFromJson(Map<String, Object?> json) {
    final tilesJson = json['tiles'] as List<dynamic>? ?? const [];
    final tiles = tilesJson
        .whereType<Map<String, Object?>>()
        .map(_tileFromJson)
        .toList();

    return MapState(
      rows: (json['rows'] as num?)?.toInt() ?? 0,
      cols: (json['cols'] as num?)?.toInt() ?? 0,
      tiles: tiles,
    );
  }

  Map<String, Object?> _tileToJson(Tile tile) {
    return {
      'id': tile.id,
      'row': tile.row,
      'col': tile.col,
      'type': _tileTypeToString(tile.type),
      'walkable': tile.walkable,
      'blocksVision': tile.blocksVision,
      'zone': tile.zone,
    };
  }

  Tile _tileFromJson(Map<String, Object?> json) {
    return Tile(
      id: json['id'] as String? ?? '',
      row: (json['row'] as num?)?.toInt() ?? 0,
      col: (json['col'] as num?)?.toInt() ?? 0,
      type: _tileTypeFromString(json['type'] as String?),
      walkable: json['walkable'] as bool? ?? true,
      blocksVision: json['blocksVision'] as bool? ?? false,
      zone: json['zone'] as String? ?? '',
    );
  }

  Map<String, Object?> _unitToJson(UnitState unit) {
    return {
      'unitId': unit.unitId,
      'team': _teamToString(unit.team),
      'card': _unitCardToJson(unit.card),
      'hp': unit.hp,
      'posTileId': unit.posTileId,
      'alive': unit.alive,
      'activatedThisRound': unit.activatedThisRound,
      'statuses': unit.statuses.map(_statusToJson).toList(),
      'cooldowns': unit.cooldowns.map((key, value) => MapEntry(_skillSlotToString(key), value)),
      'charges': unit.charges.map((key, value) => MapEntry(_skillSlotToString(key), value)),
    };
  }

  UnitState _unitFromJson(Map<String, Object?> json) {
    final statusesJson = json['statuses'] as List<dynamic>? ?? const [];
    final statuses = statusesJson
        .whereType<Map<String, Object?>>()
        .map(_statusFromJson)
        .toList();

    final cooldownsJson = json['cooldowns'] as Map<String, Object?>? ?? const {};
    final cooldowns = <SkillSlot, int>{};
    cooldownsJson.forEach((key, value) {
      final slot = _skillSlotFromString(key);
      if (slot != null) {
        cooldowns[slot] = (value as num?)?.toInt() ?? 0;
      }
    });

    final chargesJson = json['charges'] as Map<String, Object?>? ?? const {};
    final charges = <SkillSlot, int>{};
    chargesJson.forEach((key, value) {
      final slot = _skillSlotFromString(key);
      if (slot != null) {
        charges[slot] = (value as num?)?.toInt() ?? 0;
      }
    });

    return UnitState(
      unitId: json['unitId'] as String? ?? '',
      team: _teamFromString(json['team'] as String?),
      card: _unitCardFromJson(json['card'] as Map<String, Object?>? ?? const {}),
      hp: (json['hp'] as num?)?.toInt() ?? 0,
      posTileId: json['posTileId'] as String? ?? '',
      alive: json['alive'] as bool? ?? false,
      activatedThisRound: json['activatedThisRound'] as bool? ?? false,
      statuses: statuses,
      cooldowns: cooldowns,
      charges: charges,
    );
  }

  Map<String, Object?> _unitCardToJson(UnitCard card) {
    return {
      'cardId': card.cardId,
      'role': _roleToString(card.role),
      'displayName': card.displayName,
      'maxHp': card.maxHp,
      'moveRange': card.moveRange,
      'attackRange': card.attackRange,
      'skill1': _skillDefToJson(card.skill1),
      'skill2': _skillDefToJson(card.skill2),
    };
  }

  UnitCard _unitCardFromJson(Map<String, Object?> json) {
    return UnitCard(
      cardId: json['cardId'] as String? ?? '',
      role: _roleFromString(json['role'] as String?),
      displayName: json['displayName'] as String? ?? '',
      maxHp: (json['maxHp'] as num?)?.toInt() ?? 1,
      moveRange: (json['moveRange'] as num?)?.toInt() ?? 2,
      attackRange: (json['attackRange'] as num?)?.toInt() ?? 3,
      skill1: _skillDefFromJson(json['skill1'] as Map<String, Object?>? ?? const {}),
      skill2: _skillDefFromJson(json['skill2'] as Map<String, Object?>? ?? const {}),
    );
  }

  Map<String, Object?> _skillDefToJson(SkillDef skill) {
    return {
      'name': skill.name,
      'description': skill.description,
      if (skill.range != null) 'range': skill.range,
      if (skill.cooldownTurns != null) 'cooldownTurns': skill.cooldownTurns,
      if (skill.maxCharges != null) 'maxCharges': skill.maxCharges,
    };
  }

  SkillDef _skillDefFromJson(Map<String, Object?> json) {
    return SkillDef(
      name: json['name'] as String? ?? 'Empty',
      description: json['description'] as String? ?? '',
      range: (json['range'] as num?)?.toInt(),
      cooldownTurns: (json['cooldownTurns'] as num?)?.toInt(),
      maxCharges: (json['maxCharges'] as num?)?.toInt(),
    );
  }

  Map<String, Object?> _statusToJson(StatusInstance status) {
    return {
      'type': _statusToString(status.type),
      'remainingTurns': status.remainingTurns,
    };
  }

  StatusInstance _statusFromJson(Map<String, Object?> json) {
    return StatusInstance(
      type: _statusFromString(json['type'] as String?),
      remainingTurns: (json['remainingTurns'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object?> _spikeToJson(SpikeState spike) {
    return {
      'state': _spikeStateToString(spike.state),
      'carrierUnitId': spike.carrierUnitId,
      'plantedSite': spike.plantedSite?.name,
      'plantedTileId': spike.plantedTileId,
      'droppedTileId': spike.droppedTileId,
      'explosionInRounds': spike.explosionInRounds,
      'defuseProgress': spike.defuseProgress,
      'defusingUnitId': spike.defusingUnitId,
    };
  }

  SpikeState _spikeFromJson(Map<String, Object?> json) {
    final state = _spikeStateFromString(json['state'] as String?);
    final plantedSiteStr = json['plantedSite'] as String?;
    return SpikeState(
      state: state,
      carrierUnitId: json['carrierUnitId'] as String?,
      plantedSite: plantedSiteStr != null ? _plantSiteFromString(plantedSiteStr) : null,
      plantedTileId: json['plantedTileId'] as String?,
      droppedTileId: json['droppedTileId'] as String?,
      explosionInRounds: (json['explosionInRounds'] as num?)?.toInt(),
      defuseProgress: (json['defuseProgress'] as num?)?.toInt(),
      defusingUnitId: json['defusingUnitId'] as String?,
    );
  }

  Map<String, Object?> _effectToJson(EffectInstance effect) {
    return {
      'id': effect.id,
      'type': _effectTypeToString(effect.type),
      'ownerUnitId': effect.ownerUnitId,
      'team': _teamToString(effect.team),
      'tileId': effect.tileId,
      'remainingTurns': effect.remainingTurns,
      'range': effect.range,
      'targetTileId': effect.targetTileId,
      'totalTurns': effect.totalTurns,
      'movesRemaining': effect.movesRemaining,
      'totalMoves': effect.totalMoves,
    };
  }

  EffectInstance _effectFromJson(Map<String, Object?> json) {
    return EffectInstance(
      id: json['id'] as String? ?? '',
      type: _effectTypeFromString(json['type'] as String?),
      ownerUnitId: json['ownerUnitId'] as String? ?? '',
      team: _teamFromString(json['team'] as String?),
      tileId: json['tileId'] as String? ?? '',
      remainingTurns: (json['remainingTurns'] as num?)?.toInt() ?? 0,
      range: (json['range'] as num?)?.toInt(),
      targetTileId: json['targetTileId'] as String?,
      totalTurns: (json['totalTurns'] as num?)?.toInt(),
      movesRemaining: (json['movesRemaining'] as num?)?.toInt(),
      totalMoves: (json['totalMoves'] as num?)?.toInt(),
    );
  }

  Map<String, Object?> _logToJson(TurnEvent event) {
    return {
      'team': _teamToString(event.team),
      'unitId': event.unitId,
      'action': _actionToString(event.action),
      'params': event.params,
      'result': event.result,
    };
  }

  TurnEvent _logFromJson(Map<String, Object?> json) {
    final paramsRaw = json['params'];
    final params = paramsRaw is Map ? Map<String, Object?>.from(paramsRaw) : <String, Object?>{};
    return TurnEvent(
      team: _teamFromString(json['team'] as String?),
      unitId: json['unitId'] as String? ?? '',
      action: _actionFromString(json['action'] as String?),
      params: params,
      result: json['result'] as String? ?? '',
    );
  }

  String _teamToString(TeamId team) => team.name;

  TeamId _teamFromString(String? value) {
    return TeamId.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TeamId.attacker,
    );
  }

  String _roleToString(Role role) => role.name;

  Role _roleFromString(String? value) {
    return Role.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Role.entry,
    );
  }

  String _tileTypeToString(TileType type) => type.name;

  TileType _tileTypeFromString(String? value) {
    return TileType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TileType.floor,
    );
  }

  String _statusToString(StatusType type) => type.name;

  StatusType _statusFromString(String? value) {
    return StatusType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StatusType.revealed,
    );
  }

  String _skillSlotToString(SkillSlot slot) => slot.name;

  SkillSlot? _skillSlotFromString(String? value) {
    if (value == null) return null;
    return SkillSlot.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SkillSlot.skill1,
    );
  }

  String _spikeStateToString(SpikeStateType state) => state.name;

  SpikeStateType _spikeStateFromString(String? value) {
    return SpikeStateType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SpikeStateType.unplanted,
    );
  }

  PlantSite _plantSiteFromString(String? value) {
    return PlantSite.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PlantSite.siteA,
    );
  }

  String _effectTypeToString(EffectType type) => type.name;

  EffectType _effectTypeFromString(String? value) {
    return EffectType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EffectType.smoke,
    );
  }

  String _actionToString(ActionType action) => action.name;

  ActionType _actionFromString(String? value) {
    return ActionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActionType.pass,
    );
  }
}
