import '../../core/entities.dart';
import '../../core/game_serializer.dart';

class OnlineProfile {
  const OnlineProfile({
    required this.id,
    required this.username,
    required this.wins,
    required this.losses,
  });

  final String id;
  final String username;
  final int wins;
  final int losses;

  factory OnlineProfile.fromJson(Map<String, dynamic> json) {
    return OnlineProfile(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      wins: (json['win_count'] as num?)?.toInt() ?? 0,
      losses: (json['loss_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'win_count': wins,
      'loss_count': losses,
    };
  }
}

class OnlinePlayer {
  const OnlinePlayer({
    required this.playerId,
    required this.team,
    this.username,
    this.wins,
    this.losses,
  });

  final String playerId;
  final TeamId? team;
  final String? username;
  final int? wins;
  final int? losses;

  Map<String, dynamic> toPresencePayload() {
    return {
      'playerId': playerId,
      'team': team?.name,
      if (username != null) 'username': username,
    };
  }
}

class OnlineMatchRecord {
  const OnlineMatchRecord({
    required this.id,
    required this.matchCode,
    required this.attackerId,
    required this.defenderId,
    required this.attackerWins,
    required this.defenderWins,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.winnerTeam,
    this.endedReason,
    this.lastActionAt,
    this.nextTurnTeam,
    this.startedAt,
    this.hostId,
    this.guestId,
    this.attacker,
    this.defender,
  });

  final String id;
  final String matchCode;
  final String? attackerId;
  final String? defenderId;
  final String? hostId;
  final String? guestId;
  final int attackerWins;
  final int defenderWins;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final TeamId? winnerTeam;
  final String? endedReason;
  final DateTime? lastActionAt;
  final TeamId? nextTurnTeam;
  final DateTime? startedAt;
  final OnlineProfile? attacker;
  final OnlineProfile? defender;

  TeamId? teamFor(String profileId) {
    if (attackerId != null && profileId == attackerId) return TeamId.attacker;
    if (defenderId != null && profileId == defenderId) return TeamId.defender;
    return null;
  }

  bool get isFinished =>
      status == 'finished' || attackerWins >= 2 || defenderWins >= 2;
  int get roundIndex => attackerWins + defenderWins + 1;

  OnlineMatchRecord copyWith({
    String? attackerId,
    String? defenderId,
    int? attackerWins,
    int? defenderWins,
    String? status,
    DateTime? expiresAt,
    TeamId? winnerTeam,
    String? endedReason,
    DateTime? lastActionAt,
    TeamId? nextTurnTeam,
    DateTime? startedAt,
    OnlineProfile? attacker,
    OnlineProfile? defender,
  }) {
    return OnlineMatchRecord(
      id: id,
      matchCode: matchCode,
      attackerId: attackerId ?? this.attackerId,
      defenderId: defenderId ?? this.defenderId,
      hostId: hostId,
      guestId: guestId,
      attackerWins: attackerWins ?? this.attackerWins,
      defenderWins: defenderWins ?? this.defenderWins,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      winnerTeam: winnerTeam ?? this.winnerTeam,
      endedReason: endedReason ?? this.endedReason,
      lastActionAt: lastActionAt ?? this.lastActionAt,
      nextTurnTeam: nextTurnTeam ?? this.nextTurnTeam,
      startedAt: startedAt ?? this.startedAt,
      attacker: attacker ?? this.attacker,
      defender: defender ?? this.defender,
    );
  }
}

class OnlineSnapshotPayload {
  OnlineSnapshotPayload({
    required this.revision,
    required this.authorId,
    required this.sentAt,
    required this.state,
    required this.roundIndex,
    this.winningTeam,
    this.winReason,
  });

  final int revision;
  final String authorId;
  final DateTime sentAt;
  final GameState state;
  final int roundIndex;
  final TeamId? winningTeam;
  final String? winReason;

  Map<String, dynamic> toJson(GameSerializer serializer) {
    return {
      'revision': revision,
      'authorId': authorId,
      'sentAt': sentAt.toIso8601String(),
      'roundIndex': roundIndex,
      'state': serializer.toJson(state),
      if (winningTeam != null) 'winningTeam': winningTeam!.name,
      if (winReason != null) 'winReason': winReason,
    };
  }

  factory OnlineSnapshotPayload.fromJson(
    Map<String, dynamic> json,
    GameSerializer serializer,
  ) {
    final sentAtStr = json['sentAt'] as String? ?? '';
    final winTeamStr = json['winningTeam'] as String?;
    return OnlineSnapshotPayload(
      revision: (json['revision'] as num?)?.toInt() ?? 0,
      authorId: json['authorId'] as String? ?? '',
      sentAt:
          DateTime.tryParse(sentAtStr)?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      roundIndex: (json['roundIndex'] as num?)?.toInt() ?? 1,
      state: serializer.fromJson(
        Map<String, Object?>.from(json['state'] as Map? ?? {}),
      ),
      winningTeam: winTeamStr != null
          ? TeamId.values.firstWhere(
              (t) => t.name == winTeamStr,
              orElse: () => TeamId.attacker,
            )
          : null,
      winReason: json['winReason'] as String?,
    );
  }
}

sealed class OnlineMatchEvent {}

class OnlineSnapshotEvent extends OnlineMatchEvent {
  OnlineSnapshotEvent(this.payload, {this.actionId});
  final OnlineSnapshotPayload payload;
  final int? actionId;
}

class OnlinePresenceEvent extends OnlineMatchEvent {
  OnlinePresenceEvent(this.players);
  final List<OnlinePlayer> players;
}

class OnlineMatchMetaEvent extends OnlineMatchEvent {
  OnlineMatchMetaEvent(this.record);
  final OnlineMatchRecord record;
}

class OnlineErrorEvent extends OnlineMatchEvent {
  OnlineErrorEvent(this.message);
  final String message;
}
