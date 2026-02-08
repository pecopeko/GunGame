// オンライン対戦APIとの通信を担当する。
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/entities.dart';
import '../../core/game_serializer.dart';
import 'online_match_models.dart';
import 'online_snapshot_parser.dart';
import 'online_match_service_helpers.dart';

class OnlineMatchService {
  OnlineMatchService({
    required this.matchCode,
    required this.localProfile,
    required this.isHost,
    this.isRandomMatch = false,
    SupabaseClient? client,
    GameSerializer? serializer,
  }) : client = client ?? Supabase.instance.client,
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
  Timer? _snapshotPollTimer;
  bool _snapshotPollInFlight = false;
  DateTime? _snapshotPollBlockedUntil;
  int _snapshotPollErrorStreak = 0;
  Timer? _timeoutPollTimer;
  bool _timeoutPollInFlight = false;
  DateTime? _timeoutPollBlockedUntil;
  int _timeoutPollErrorStreak = 0;
  bool _active = true;

  OnlineMatchRecord? get record => _record;

  Future<OnlineMatchRecord> initialize() async {
    final base = await _enterMatchRow();
    final hydrated = await _hydrateProfiles(base);
    _record = hydrated;
    _emitEvent(OnlineMatchMetaEvent(hydrated));

    await _refreshLatestRevision();
    await _subscribeToRealtime();
    _startSnapshotPolling();
    _startTimeoutPolling();
    await _emitLatestAction();
    return hydrated;
  }

  Future<void> disconnect() async {
    _snapshotPollTimer?.cancel();
    _snapshotPollTimer = null;
    _snapshotPollInFlight = false;
    _snapshotPollBlockedUntil = null;
    _snapshotPollErrorStreak = 0;
    _timeoutPollTimer?.cancel();
    _timeoutPollTimer = null;
    _timeoutPollInFlight = false;
    _timeoutPollBlockedUntil = null;
    _timeoutPollErrorStreak = 0;
    await _channel?.unsubscribe();
    _channel = null;
    _listening = false;
  }

  Future<void> setActive(bool active) async {
    if (_active == active) return;
    _active = active;
    if (!active) {
      await disconnect();
      return;
    }
    if (_record == null) return;
    await _subscribeToRealtime();
    _startSnapshotPolling();
    _startTimeoutPolling();
    await _emitLatestAction();
  }

  Future<void> sendSnapshot(OnlineSnapshotPayload snapshot) async {
    final record = _record;
    if (record == null) return;
    try {
      final inserted = await client
          .from('online_actions')
          .insert({
            'match_id': record.id,
            'revision': snapshot.revision,
            'round_index': snapshot.roundIndex,
            'actor_id': localProfile.id,
            'team': snapshot.state.turnTeam.name,
            'payload': snapshot.toJson(serializer),
          })
          .select('id')
          .single();
      _latestActionId = (inserted['id'] as num?)?.toInt() ?? _latestActionId;
    } catch (e) {
      _emitEvent(OnlineErrorEvent('action_send_failed: $e'));
    }
  }

  Future<void> recordRoundResult({
    required TeamId winningTeam,
    required GameState finalState,
  }) async {
    final record = _record;
    if (record == null || !isHost) return;

    final attackerWins =
        record.attackerWins + (winningTeam == TeamId.attacker ? 1 : 0);
    final defenderWins =
        record.defenderWins + (winningTeam == TeamId.defender ? 1 : 0);
    final finished = attackerWins >= 2 || defenderWins >= 2;

    final nextAttackerId = finished ? record.attackerId : record.defenderId;
    final nextDefenderId = finished ? record.defenderId : record.attackerId;
    final nextAttackerWins = finished ? attackerWins : defenderWins;
    final nextDefenderWins = finished ? defenderWins : attackerWins;

    final payload = <String, dynamic>{
      'attacker_round_wins': nextAttackerWins,
      'defender_round_wins': nextDefenderWins,
      'status': finished ? 'finished' : 'active',
      if (finished) 'winner_team': winningTeam.name,
      if (finished) 'ended_reason': 'score',
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
      final hydrated = await _hydrateProfiles(mapMatchRecord(updated));
      _record = hydrated;
      _emitEvent(OnlineMatchMetaEvent(hydrated));

      final winnerId = winningTeam == TeamId.attacker
          ? record.attackerId
          : record.defenderId;
      final loserId = winningTeam == TeamId.attacker
          ? record.defenderId
          : record.attackerId;

      if (finished && winnerId != null && loserId != null) {
        await _incrementStats(winnerId: winnerId, loserId: loserId);
      }
    } catch (e) {
      _emitEvent(OnlineErrorEvent('round_record_failed: $e'));
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
      _emitEvent(OnlineErrorEvent('replay_load_failed: $e'));
      return null;
    }
  }

  void dispose() {
    _snapshotPollTimer?.cancel();
    _snapshotPollTimer = null;
    _timeoutPollTimer?.cancel();
    _timeoutPollTimer = null;
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
      final actionId = (latest['id'] as num?)?.toInt() ?? 0;
      if (actionId <= _latestActionId) return;
      final snap = parseOnlineSnapshotPayload(latest['payload'], serializer);
      if (snap == null) return;
      _latestActionId = actionId;
      _emitEvent(OnlineSnapshotEvent(snap, actionId: actionId));
    } catch (e) {
      _emitEvent(OnlineErrorEvent('snapshot_load_failed: $e'));
    }
  }

  Future<void> _handleMatchChange(PostgresChangePayload payload) async {
    final incoming = Map<String, dynamic>.from(payload.newRecord);
    final merged = mergeMatchRecordMap(incoming, _record);
    final record = mapMatchRecord(merged);
    final hydrated = await _hydrateProfiles(record);
    _record = hydrated;
    _emitEvent(OnlineMatchMetaEvent(hydrated));
  }

  void _handleActionChange(PostgresChangePayload payload) {
    final data = payload.newRecord;
    final actionId = (data['id'] as num?)?.toInt() ?? 0;
    if (actionId <= _latestActionId) return;
    try {
      final snap = parseOnlineSnapshotPayload(data['payload'], serializer);
      if (snap == null) return;
      _latestActionId = actionId;
      // Do not gate on `revision` here: both clients can start from 1, which
      // would drop the opponent's first action. We gate by DB row id instead.
      _emitEvent(OnlineSnapshotEvent(snap, actionId: actionId));
    } catch (e) {
      _emitEvent(OnlineErrorEvent('snapshot_parse_failed: $e'));
    }
  }

  void _startSnapshotPolling() {
    _snapshotPollTimer?.cancel();
    _snapshotPollInFlight = false;
    _snapshotPollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_active) return;
      unawaited(_pollLatestAction());
    });
  }

  Future<void> _pollLatestAction() async {
    if (_snapshotPollInFlight) return;
    if (!_active) return;
    if (isBlocked(_snapshotPollBlockedUntil)) return;
    final matchId = _record?.id;
    if (matchId == null) return;
    _snapshotPollInFlight = true;
    try {
      final latest = await client
          .from('online_actions')
          .select('id,payload')
          .eq('match_id', matchId)
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();
      if (latest == null) return;
      final actionId = (latest['id'] as num?)?.toInt() ?? 0;
      if (actionId <= _latestActionId) return;
      final snap = parseOnlineSnapshotPayload(latest['payload'], serializer);
      if (snap == null) return;
      _latestActionId = actionId;
      _emitEvent(OnlineSnapshotEvent(snap, actionId: actionId));
      _snapshotPollErrorStreak = 0;
      _snapshotPollBlockedUntil = null;
    } catch (e) {
      _snapshotPollErrorStreak += 1;
      _snapshotPollBlockedUntil = DateTime.now().add(
        backoffDelay(
          streak: _snapshotPollErrorStreak,
          baseSeconds: 1,
          maxSeconds: 20,
        ),
      );
      _emitEvent(OnlineErrorEvent('snapshot_poll_failed: $e'));
    } finally {
      _snapshotPollInFlight = false;
    }
  }

  void _startTimeoutPolling() {
    _timeoutPollTimer?.cancel();
    _timeoutPollInFlight = false;
    _timeoutPollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_active) return;
      unawaited(_pollTimeout());
    });
  }

  Future<void> _pollTimeout() async {
    if (_timeoutPollInFlight) return;
    if (!_active) return;
    if (isBlocked(_timeoutPollBlockedUntil)) return;
    final matchId = _record?.id;
    if (matchId == null) return;
    _timeoutPollInFlight = true;
    try {
      final raw = await client.rpc(
        'online_match_check_timeout',
        params: {'p_match_id': matchId},
      );
      final map = matchMapFrom(raw);
      if (map == null) return;
      final updated = mapMatchRecord(map);
      _record = updated;
      _emitEvent(OnlineMatchMetaEvent(updated));
      _timeoutPollErrorStreak = 0;
      _timeoutPollBlockedUntil = null;
    } catch (e) {
      _timeoutPollErrorStreak += 1;
      _timeoutPollBlockedUntil = DateTime.now().add(
        backoffDelay(
          streak: _timeoutPollErrorStreak,
          baseSeconds: 5,
          maxSeconds: 60,
        ),
      );
      _emitEvent(OnlineErrorEvent('timeout_check_failed: $e'));
    } finally {
      _timeoutPollInFlight = false;
    }
  }

  void _emitEvent(OnlineMatchEvent event) {
    if (_events.isClosed) return;
    _events.add(event);
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

  Future<OnlineMatchRecord> _enterMatchRow() async {
    final code = matchCode?.trim();
    final raw = await client.rpc(
      'online_match_enter',
      params: {
        'p_profile_id': localProfile.id,
        'p_match_code': code,
        'p_is_host': isHost,
        'p_is_random': isRandomMatch,
      },
    );
    final map = matchMapFrom(raw);
    if (map == null) {
      throw Exception('match_enter_failed');
    }
    return mapMatchRecord(map);
  }

  Future<OnlineMatchRecord> _hydrateProfiles(OnlineMatchRecord record) async {
    final ids = <String>[];
    if (record.attackerId != null) ids.add(record.attackerId!);
    if (record.defenderId != null) ids.add(record.defenderId!);
    if (ids.isEmpty) return record;

    try {
      final rows = await client
          .from('online_profiles')
          .select()
          .inFilter('id', ids);
      final profiles = <String, OnlineProfile>{};
      for (final row in rows) {
        final map = Map<String, dynamic>.from(row as Map);
        final profile = OnlineProfile.fromJson(map);
        profiles[profile.id] = profile;
      }
      return record.copyWith(
        attacker: record.attackerId != null
            ? profiles[record.attackerId!]
            : null,
        defender: record.defenderId != null
            ? profiles[record.defenderId!]
            : null,
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
      await client.rpc(
        'increment_profile_stats',
        params: {'profile_id': winnerId, 'did_win': true},
      );
      await client.rpc(
        'increment_profile_stats',
        params: {'profile_id': loserId, 'did_win': false},
      );
    } catch (e) {
      _emitEvent(OnlineErrorEvent('profile_stats_failed: $e'));
    }
  }
}
