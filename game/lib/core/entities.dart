enum TeamId { attacker, defender }

enum Role { entry, recon, smoke, sentinel }

enum TileType { floor, wall, siteA, siteB, mid }

enum ActionType { move, attack, skill1, skill2, plant, defuse, pass }

enum StatusType {
  stunned,
  blinded,
  smokeExitPenalty,
  droneTagged,
  revealed,
  trapped,
}

enum SkillSlot { skill1, skill2 }

enum SpikeStateType { unplanted, carried, dropped, planted, defused, exploded }

enum PlantSite { siteA, siteB }

enum EffectType { smoke, trap, camera, drone, flash, dash, stun }

class Tile {
  const Tile({
    required this.id,
    required this.row,
    required this.col,
    required this.type,
    required this.walkable,
    required this.blocksVision,
    required this.zone,
  });

  final String id;
  final int row;
  final int col;
  final TileType type;
  final bool walkable;
  final bool blocksVision;
  final String zone;
}

class SkillDef {
  const SkillDef({
    required this.name,
    required this.description,
    this.range,
    this.cooldownTurns,
    this.maxCharges,
  });

  final String name;
  final String description;
  final int? range;
  final int? cooldownTurns;
  final int? maxCharges;
}

class UnitCard {
  const UnitCard({
    required this.cardId,
    required this.role,
    required this.displayName,
    required this.maxHp,
    required this.moveRange,
    required this.attackRange,
    required this.skill1,
    required this.skill2,
  });

  final String cardId;
  final Role role;
  final String displayName;
  final int maxHp;
  final int moveRange;
  final int attackRange;
  final SkillDef skill1;
  final SkillDef skill2;
}

class StatusInstance {
  const StatusInstance({
    required this.type,
    required this.remainingTurns,
  });

  final StatusType type;
  final int remainingTurns;
}

class UnitState {
  const UnitState({
    required this.unitId,
    required this.team,
    required this.card,
    required this.hp,
    required this.posTileId,
    required this.alive,
    required this.activatedThisRound,
    required this.statuses,
    required this.cooldowns,
    required this.charges,
  });

  final String unitId;
  final TeamId team;
  final UnitCard card;
  final int hp;
  final String posTileId;
  final bool alive;
  final bool activatedThisRound;
  final List<StatusInstance> statuses;
  final Map<SkillSlot, int> cooldowns;
  final Map<SkillSlot, int> charges;
}

class SpikeState {
  const SpikeState({
    required this.state,
    this.carrierUnitId,
    this.plantedSite,
    this.plantedTileId,
    this.droppedTileId,
    this.explosionInRounds,
    this.defuseProgress,
    this.defusingUnitId,
  });

  final SpikeStateType state;
  final String? carrierUnitId;
  final PlantSite? plantedSite;
  final String? plantedTileId;
  final String? droppedTileId;
  final int? explosionInRounds;
  final int? defuseProgress;

  final String? defusingUnitId;
}

class EffectInstance {
  const EffectInstance({
    required this.id,
    required this.type,
    required this.ownerUnitId,
    required this.team,
    required this.tileId,
    required this.remainingTurns,
    this.range,
    this.targetTileId,
    this.totalTurns,
    this.movesRemaining,
    this.totalMoves,
  });

  final String id;
  final EffectType type;
  final String ownerUnitId;
  final TeamId team;
  final String tileId;
  final int remainingTurns;
  final int? range;
  final String? targetTileId;
  final int? totalTurns;
  final int? movesRemaining;
  final int? totalMoves;
}

class MapState {
  const MapState({
    required this.rows,
    required this.cols,
    required this.tiles,
  });

  final int rows;
  final int cols;
  final List<Tile> tiles;
}

class TurnEvent {
  const TurnEvent({
    required this.team,
    required this.unitId,
    required this.action,
    required this.params,
    required this.result,
  });

  final TeamId team;
  final String unitId;
  final ActionType action;
  final Map<String, Object?> params;
  final String result;
}

class GameState {
  const GameState({
    required this.seed,
    required this.roundIndex,
    required this.turnTeam,
    required this.phase,
    required this.map,
    required this.units,
    required this.spike,
    required this.effects,
    required this.log,
  });

  final int seed;
  final int roundIndex;
  final TeamId turnTeam;
  final String phase;
  final MapState map;
  final List<UnitState> units;
  final SpikeState spike;
  final List<EffectInstance> effects;
  final List<TurnEvent> log;

  factory GameState.initial() {
    return GameState(
      seed: 0,
      roundIndex: 1,
      turnTeam: TeamId.attacker,
      phase: 'Boot',
      map: const MapState(rows: 0, cols: 0, tiles: []),
      units: const [],
      spike: const SpikeState(state: SpikeStateType.unplanted),
      effects: const [],
      log: const [],
    );
  }

  GameState copyWith({
    int? seed,
    int? roundIndex,
    TeamId? turnTeam,
    String? phase,
    MapState? map,
    List<UnitState>? units,
    SpikeState? spike,
    List<EffectInstance>? effects,
    List<TurnEvent>? log,
  }) {
    return GameState(
      seed: seed ?? this.seed,
      roundIndex: roundIndex ?? this.roundIndex,
      turnTeam: turnTeam ?? this.turnTeam,
      phase: phase ?? this.phase,
      map: map ?? this.map,
      units: units ?? this.units,
      spike: spike ?? this.spike,
      effects: effects ?? this.effects,
      log: log ?? this.log,
    );
  }
}
