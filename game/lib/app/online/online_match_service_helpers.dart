// OnlineMatchServiceの補助関数群。
import 'dart:math' as math;

import '../../core/entities.dart';
import 'online_match_models.dart';

OnlineMatchRecord mapMatchRecord(Map<String, dynamic> row) {
  final expiresStr = row['expires_at'] as String? ?? '';
  final createdStr = row['created_at'] as String? ?? '';
  final endedReason = row['ended_reason'] as String?;
  final winnerTeamStr = row['winner_team'] as String?;
  final nextTurnStr = row['next_turn_team'] as String?;
  final lastActionStr = row['last_action_at'] as String?;
  final startedAtStr = row['started_at'] as String?;
  return OnlineMatchRecord(
    id: row['id'] as String? ?? '',
    matchCode: row['match_code'] as String? ?? '',
    hostId: row['host_id'] as String?,
    guestId: row['guest_id'] as String?,
    attackerId: row['attacker_id'] as String?,
    defenderId: row['defender_id'] as String?,
    attackerWins: (row['attacker_round_wins'] as num?)?.toInt() ?? 0,
    defenderWins: (row['defender_round_wins'] as num?)?.toInt() ?? 0,
    status: row['status'] as String? ?? 'waiting',
    winnerTeam: winnerTeamStr != null
        ? TeamId.values.firstWhere(
            (t) => t.name == winnerTeamStr,
            orElse: () => TeamId.attacker,
          )
        : null,
    endedReason: endedReason,
    lastActionAt: DateTime.tryParse(lastActionStr ?? '')?.toUtc(),
    nextTurnTeam: nextTurnStr != null
        ? TeamId.values.firstWhere(
            (t) => t.name == nextTurnStr,
            orElse: () => TeamId.attacker,
          )
        : null,
    startedAt: DateTime.tryParse(startedAtStr ?? '')?.toUtc(),
    createdAt:
        DateTime.tryParse(createdStr)?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    expiresAt:
        DateTime.tryParse(expiresStr)?.toUtc() ??
        DateTime.now().toUtc().add(const Duration(days: 1)),
  );
}

Map<String, dynamic>? matchMapFrom(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  if (raw is List && raw.isNotEmpty) {
    final first = raw.first;
    if (first is Map) {
      return Map<String, dynamic>.from(first as Map);
    }
  }
  return null;
}

bool isBlocked(DateTime? until) {
  if (until == null) return false;
  return DateTime.now().isBefore(until);
}

Duration backoffDelay({
  required int streak,
  required int baseSeconds,
  required int maxSeconds,
}) {
  final step = math.min(5, streak);
  final seconds = baseSeconds * (1 << step);
  return Duration(seconds: math.min(maxSeconds, seconds));
}

Map<String, dynamic> mergeMatchRecordMap(
  Map<String, dynamic> incoming,
  OnlineMatchRecord? previous,
) {
  if (previous == null) return incoming;
  final merged = Map<String, dynamic>.from(incoming);
  final fallback = recordToRow(previous);
  fallback.forEach((key, value) {
    if (!merged.containsKey(key)) {
      merged[key] = value;
    }
  });
  return merged;
}

Map<String, dynamic> recordToRow(OnlineMatchRecord record) {
  return {
    'id': record.id,
    'match_code': record.matchCode,
    'host_id': record.hostId,
    'guest_id': record.guestId,
    'attacker_id': record.attackerId,
    'defender_id': record.defenderId,
    'attacker_round_wins': record.attackerWins,
    'defender_round_wins': record.defenderWins,
    'status': record.status,
    'expires_at': record.expiresAt.toIso8601String(),
    'created_at': record.createdAt.toIso8601String(),
    if (record.winnerTeam != null) 'winner_team': record.winnerTeam!.name,
    if (record.endedReason != null) 'ended_reason': record.endedReason,
    if (record.lastActionAt != null)
      'last_action_at': record.lastActionAt!.toIso8601String(),
    if (record.nextTurnTeam != null)
      'next_turn_team': record.nextTurnTeam!.name,
    if (record.startedAt != null)
      'started_at': record.startedAt!.toIso8601String(),
  };
}
