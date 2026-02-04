import 'dart:async';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/entities.dart';
import '../../core/game_serializer.dart';
import 'online_match_models.dart';

class OnlineMatchService {
  OnlineMatchService({
    required this.matchCode,
    required this.localProfile,
    required this.isHost,
    this.isRandomMatch = false,
    SupabaseClient? client,
    GameSerializer? serializer,
  })  : client = client ?? Supabase.instance.client,
        serializer = serializer ?? const GameSerializer();

  final String? matchCode;
  final OnlineProfile localProfile;
  final bool isHost;
  final bool isRandomMatch;
  final SupabaseClient client;
  final GameSerializer serializer;

  final _events = StreamController<OnlineMatchEvent>.broadcast();
  Stream<OnlineMatchEvent> get events => _events.stream;

  OnlineMatchRecord? _record;
  RealtimeChannel? _channel;
  int _latestActionId = 0;
  bool _listening = false;

  OnlineMatchRecord? get record => _record;

  Future<OnlineMatchRecord> initialize() async {
    final base = await _ensureMatchRow();
    final hydrated = await _hydrateProfiles(base);
    _record = hydrated;
    _events.add(OnlineMatchMetaEvent(hydrated));

    await _refreshLatestRevision();
    await _subscribeToRealtime();
    await _emitLatestAction();
    return hydrated;
  }

  Future<void> disconnect() async {
    await _channel?.unsubscribe();
    _channel = null;
    _listening = false;
  }

  Future<void> sendSnapshot(OnlineSnapshotPayload snapshot) async {
    final record = _record;
    if (record == null) return;
    try {
      final inserted = await client.from('online_actions').insert({
        'match_id': record.id,
        'revision': snapshot.revision,
        'round_index': snapshot.roundIndex,
        'actor_id': localProfile.id,
        'team': snapshot.state.turnTeam.name,
        'payload': snapshot.toJson(serializer),
      }).select('id').single();
      _latestActionId = (inserted['id'] as num?)?.toInt() ?? _latestActionId;
    } catch (e) {
      _events.add(OnlineErrorEvent('action_send_failed: $e'));
    }
  }

  Future<void> recordRoundResult({
    required TeamId winningTeam,
    required GameState finalState,
  }) async {
    final record = _record;
    if (record == null || !isHost) return;

    final attackerWins = record.attackerWins + (winningTeam == TeamId.attacker ? 1 : 0);
    final defenderWins = record.defenderWins + (winningTeam == TeamId.defender ? 1 : 0);
    final finished = attackerWins >= 2 || defenderWins >= 2;

    final nextAttackerId = finished ? record.attackerId : record.defenderId;
    final nextDefenderId = finished ? record.defenderId : record.attackerId;

    final payload = <String, dynamic>{
      'attacker_round_wins': attackerWins,
      'defender_round_wins': defenderWins,
      'status': finished ? 'finished' : 'active',
      if (finished) 'ended_at': DateTime.now().toUtc().toIso8601String(),
      if (!finished) 'attacker_id': nextAttackerId,
      if (!finished) 'defender_id': nextDefenderId,
    };

    try {
      final updated = await client
          .from('online_matches')
          .update(payload)
          .eq('id', record.id)
          .select()
          .single();
      final hydrated = await _hydrateProfiles(_mapRecord(updated));
      _record = hydrated;
      _events.add(OnlineMatchMetaEvent(hydrated));

      final winnerId = winningTeam == TeamId.attacker ? record.attackerId : record.defenderId;
      final loserId = winningTeam == TeamId.attacker ? record.defenderId : record.attackerId;

      if (finished && winnerId != null && loserId != null) {
        await _incrementStats(winnerId: winnerId, loserId: loserId);
      }
    } catch (e) {
      _events.add(OnlineErrorEvent('round_record_failed: $e'));
    }
  }

  Future<GameState?> loadLatestReplay() async {
    final matchId = _record?.id;
    if (matchId == null) return null;
    try {
      final row = await client
          .from('online_actions')
          .select('payload')
          .eq('match_id', matchId)
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();
      if (row == null) return null;
      final payload = Map<String, dynamic>.from(row['payload'] as Map? ?? {});
      final snap = OnlineSnapshotPayload.fromJson(payload, serializer);
      return snap.state;
    } catch (e) {
      _events.add(OnlineErrorEvent('replay_load_failed: $e'));
      return null;
    }
  }

  void dispose() {
    _events.close();
  }

  Future<void> _subscribeToRealtime() async {
    final record = _record;
    if (record == null || _listening) return;
    final channel = client.channel('online_match_${record.id}');

    channel
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'online_actions',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'match_id',
          value: record.id,
        ),
        callback: _handleActionChange,
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'online_matches',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: record.id,
        ),
        callback: (payload) {
          unawaited(_handleMatchChange(payload));
        },
      )
      ..subscribe();

    _channel = channel;
    _listening = true;
  }

  Future<void> _emitLatestAction() async {
    final matchId = _record?.id;
    if (matchId == null) return;
    try {
      final latest = await client
          .from('online_actions')
          .select('id,payload')
          .eq('match_id', matchId)
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();
      if (latest == null) return;
      _latestActionId = (latest['id'] as num?)?.toInt() ?? _latestActionId;
      final raw = Map<String, dynamic>.from(latest['payload'] as Map? ?? {});
      final snap = OnlineSnapshotPayload.fromJson(raw, serializer);
      _events.add(OnlineSnapshotEvent(snap));
    } catch (e) {
      _events.add(OnlineErrorEvent('snapshot_load_failed: $e'));
    }
  }

  Future<void> _handleMatchChange(PostgresChangePayload payload) async {
    final record = _mapRecord(Map<String, dynamic>.from(payload.newRecord));
    final hydrated = await _hydrateProfiles(record);
    _record = hydrated;
    _events.add(OnlineMatchMetaEvent(hydrated));
  }

  void _handleActionChange(PostgresChangePayload payload) {
    final data = payload.newRecord;
    final actionId = (data['id'] as num?)?.toInt() ?? 0;
    if (actionId <= _latestActionId) return;
    _latestActionId = actionId;
    final rawPayload = Map<String, dynamic>.from(data['payload'] as Map? ?? {});
    try {
      final snap = OnlineSnapshotPayload.fromJson(rawPayload, serializer);
      // Do not gate on `revision` here: both clients can start from 1, which
      // would drop the opponent's first action. We gate by DB row id instead.
      _events.add(OnlineSnapshotEvent(snap));
    } catch (e) {
      _events.add(OnlineErrorEvent('snapshot_parse_failed: $e'));
    }
  }

  Future<void> _refreshLatestRevision() async {
    final matchId = _record?.id;
    if (matchId == null) return;
    try {
      final latest = await client
          .from('online_actions')
          .select('id')
          .eq('match_id', matchId)
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();
      _latestActionId = (latest?['id'] as num?)?.toInt() ?? 0;
    } catch (_) {
      _latestActionId = 0;
    }
  }

  Future<OnlineMatchRecord> _ensureMatchRow() async {
    if (isRandomMatch) {
      return _findOrCreateRandomMatch();
    }
    final code = matchCode?.trim();
    if (code == null || code.isEmpty) {
      throw Exception('match_code_required');
    }
    if (isHost) {
      final expires = DateTime.now().toUtc().add(const Duration(days: 1)).toIso8601String();
      try {
        final inserted = await client.from('online_matches').insert({
          'match_code': code,
          'host_id': localProfile.id,
          'guest_id': null,
          'attacker_id': localProfile.id,
          'defender_id': null,
          'status': 'waiting',
          'expires_at': expires,
        }).select().single();
        return _mapRecord(inserted);
      } on PostgrestException catch (e) {
        throw Exception('match_create_failed: ${e.message}');
      }
    } else {
      final existing = await client
          .from('online_matches')
          .select()
          .eq('match_code', code)
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .maybeSingle();
      if (existing == null) {
        throw Exception('match_not_found');
      }
      final record = _mapRecord(existing);
      return _joinMatch(record);
    }
  }

  Future<OnlineMatchRecord> _findOrCreateRandomMatch() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final rows = await client
        .from('online_matches')
        .select()
        .eq('status', 'waiting')
        .isFilter('guest_id', null)
        .neq('host_id', localProfile.id)
        .gt('expires_at', nowIso)
        .order('created_at')
        .limit(1);

    if (rows.isNotEmpty) {
      final record = _mapRecord(Map<String, dynamic>.from(rows.first as Map));
      return _joinMatch(record);
    }

    final expires = DateTime.now().toUtc().add(const Duration(days: 1)).toIso8601String();
    final inserted = await client.from('online_matches').insert({
      'match_code': _randomCode(),
      'host_id': localProfile.id,
      'guest_id': null,
      'attacker_id': localProfile.id,
      'defender_id': null,
      'status': 'waiting',
      'expires_at': expires,
    }).select().single();
    return _mapRecord(inserted);
  }

  Future<OnlineMatchRecord> _joinMatch(OnlineMatchRecord record) async {
    final updates = <String, dynamic>{};
    if (record.guestId == null) {
      updates['guest_id'] = localProfile.id;
    }

    if (record.attackerId == null && record.defenderId == null) {
      updates['attacker_id'] = record.hostId ?? localProfile.id;
      updates['defender_id'] = localProfile.id;
    } else if (record.attackerId == null) {
      updates['attacker_id'] = localProfile.id;
    } else if (record.defenderId == null) {
      updates['defender_id'] = localProfile.id;
    } else if (record.attackerId != localProfile.id && record.defenderId != localProfile.id) {
      throw Exception('match_full');
    }

    updates['status'] = 'active';
    if (updates.isNotEmpty) {
      final updated = await client
          .from('online_matches')
          .update(updates)
          .eq('id', record.id)
          .select()
          .single();
      return _mapRecord(updated);
    }
    return record;
  }

  String _randomCode({int length = 6}) {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  OnlineMatchRecord _mapRecord(Map<String, dynamic> row) {
    final expiresStr = row['expires_at'] as String? ?? '';
    final createdStr = row['created_at'] as String? ?? '';
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
      createdAt: DateTime.tryParse(createdStr)?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      expiresAt: DateTime.tryParse(expiresStr)?.toUtc() ??
          DateTime.now().toUtc().add(const Duration(days: 1)),
    );
  }

  Future<OnlineMatchRecord> _hydrateProfiles(OnlineMatchRecord record) async {
    final ids = <String>[];
    if (record.attackerId != null) ids.add(record.attackerId!);
    if (record.defenderId != null) ids.add(record.defenderId!);
    if (ids.isEmpty) return record;

    try {
      final rows = await client.from('online_profiles').select().inFilter('id', ids);
      final profiles = <String, OnlineProfile>{};
      for (final row in rows) {
        final map = Map<String, dynamic>.from(row as Map);
        final profile = OnlineProfile.fromJson(map);
        profiles[profile.id] = profile;
      }
      return record.copyWith(
        attacker: record.attackerId != null ? profiles[record.attackerId!] : null,
        defender: record.defenderId != null ? profiles[record.defenderId!] : null,
      );
    } catch (_) {
      return record;
    }
  }

  Future<void> _incrementStats({
    required String winnerId,
    required String loserId,
  }) async {
    try {
      await client.rpc('increment_profile_stats', params: {
        'profile_id': winnerId,
        'did_win': true,
      });
      await client.rpc('increment_profile_stats', params: {
        'profile_id': loserId,
        'did_win': false,
      });
    } catch (e) {
      _events.add(OnlineErrorEvent('profile_stats_failed: $e'));
    }
  }
}
