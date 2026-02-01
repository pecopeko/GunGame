import '../../core/entities.dart';
import '../../core/game_serializer.dart';

class OnlinePlayer {
  const OnlinePlayer({
    required this.playerId,
    required this.team,
  });

  final String playerId;
  final TeamId? team;

  Map<String, dynamic> toPresencePayload() {
    return {
      'playerId': playerId,
      'team': team?.name,
    };
  }
}

class OnlineSnapshotPayload {
  OnlineSnapshotPayload({
    required this.revision,
    required this.authorId,
    required this.sentAt,
    required this.state,
  });

  final int revision;
  final String authorId;
  final DateTime sentAt;
  final GameState state;

  Map<String, dynamic> toJson(GameSerializer serializer) {
    return {
      'revision': revision,
      'authorId': authorId,
      'sentAt': sentAt.toIso8601String(),
      'state': serializer.toJson(state),
    };
  }

  factory OnlineSnapshotPayload.fromJson(
    Map<String, dynamic> json,
    GameSerializer serializer,
  ) {
    final sentAtStr = json['sentAt'] as String? ?? '';
    return OnlineSnapshotPayload(
      revision: (json['revision'] as num?)?.toInt() ?? 0,
      authorId: json['authorId'] as String? ?? '',
      sentAt: DateTime.tryParse(sentAtStr)?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      state: serializer.fromJson(Map<String, Object?>.from(json['state'] as Map? ?? {})),
    );
  }
}

sealed class OnlineMatchEvent {}

class OnlineSnapshotEvent extends OnlineMatchEvent {
  OnlineSnapshotEvent(this.payload);
  final OnlineSnapshotPayload payload;
}

class OnlinePresenceEvent extends OnlineMatchEvent {
  OnlinePresenceEvent(this.players);
  final List<OnlinePlayer> players;
}

class OnlineErrorEvent extends OnlineMatchEvent {
  OnlineErrorEvent(this.message);
  final String message;
}
