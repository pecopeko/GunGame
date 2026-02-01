import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/entities.dart';
import '../../core/game_serializer.dart';
import 'online_match_models.dart';

class OnlineMatchService {
  OnlineMatchService({
    required this.matchId,
    required this.playerId,
    GameSerializer? serializer,
  }) : serializer = serializer ?? const GameSerializer();

  final String matchId;
  final String playerId;
  final GameSerializer serializer;

  final _events = StreamController<OnlineMatchEvent>.broadcast();
  Stream<OnlineMatchEvent> get events => _events.stream;

  RealtimeChannel? _channel;

  Future<void> connect({required OnlinePlayer player}) async {
    await disconnect();
    final opts = RealtimeChannelConfig(
      ack: true,
      self: false,
      key: player.playerId,
      enabled: true,
    );
    final channel = Supabase.instance.client.channel('online_match_$matchId', opts: opts);
    _channel = channel;

    channel
      ..onBroadcast(event: 'snapshot', callback: _handleSnapshot)
      ..onPresenceSync((_) => _emitPresence())
      ..onPresenceJoin((_) => _emitPresence())
      ..onPresenceLeave((_) => _emitPresence());

    channel.subscribe();
    await channel.track(player.toPresencePayload());
  }

  Future<void> disconnect() async {
    await _channel?.unsubscribe();
    _channel = null;
  }

  Future<void> sendSnapshot(OnlineSnapshotPayload snapshot) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.sendBroadcastMessage(event: 'snapshot', payload: snapshot.toJson(serializer));
  }

  void _handleSnapshot(Map<String, dynamic> payload) {
    final rawPayload = payload['payload'];
    final raw = rawPayload is Map ? Map<String, dynamic>.from(rawPayload) : Map<String, dynamic>.from(payload);
    try {
      final snap = OnlineSnapshotPayload.fromJson(raw, serializer);
      _events.add(OnlineSnapshotEvent(snap));
    } catch (e) {
      _events.add(OnlineErrorEvent('snapshot_parse_failed: $e'));
    }
  }

  void _emitPresence() {
    final channel = _channel;
    if (channel == null) return;
    final states = channel.presenceState();
    final players = <OnlinePlayer>[];
    for (final state in states) {
      for (final presence in state.presences) {
        final payload = Map<String, dynamic>.from(presence.payload);
        players.add(
          OnlinePlayer(
            playerId: state.key,
            team: _parseTeam(payload['team']),
          ),
        );
      }
    }
    _events.add(OnlinePresenceEvent(players));
  }

  TeamId? _parseTeam(dynamic raw) {
    final value = raw as String?;
    if (value == null) return null;
    try {
      return TeamId.values.firstWhere((t) => t.name == value);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _events.close();
  }
}
