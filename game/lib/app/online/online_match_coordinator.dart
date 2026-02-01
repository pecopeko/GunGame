import 'dart:async';

import 'package:flutter/foundation.dart';

import '../game_controller.dart';
import '../../core/entities.dart';
import 'online_match_models.dart';
import 'online_match_service.dart';

class OnlineMatchCoordinator extends ChangeNotifier {
  OnlineMatchCoordinator({
    required this.controller,
    required this.service,
    required this.player,
    required this.localTeam,
    required this.isHost,
  }) {
    controller.setOnlineLocalTeam(localTeam);
    controller.setViewTeam(localTeam);
    _controllerListener = _handleLocalChange;
    controller.addListener(_controllerListener!);
    _serviceSub = service.events.listen(_handleEvent);
  }

  final GameController controller;
  final OnlineMatchService service;
  final OnlinePlayer player;
  final TeamId localTeam;
  final bool isHost;

  StreamSubscription<OnlineMatchEvent>? _serviceSub;
  VoidCallback? _controllerListener;
  bool _suppressBroadcast = false;
  bool _connected = false;
  int _localRevision = 0;
  int _remoteRevision = 0;
  List<OnlinePlayer> _players = [];

  bool get connected => _connected;
  List<OnlinePlayer> get players => List.unmodifiable(_players);

  Future<void> start({bool sendInitialSnapshot = false}) async {
    await service.connect(player: player);
    _connected = true;
    notifyListeners();
    if (sendInitialSnapshot) {
      await sendSnapshot(force: true);
    }
  }

  Future<void> sendSnapshot({bool force = false}) async {
    if (_suppressBroadcast && !force) return;
    _localRevision += 1;
    final payload = OnlineSnapshotPayload(
      revision: _localRevision,
      authorId: player.playerId,
      sentAt: DateTime.now().toUtc(),
      state: controller.state,
    );
    await service.sendSnapshot(payload);
  }

  void _handleLocalChange() {
    if (_suppressBroadcast) return;
    // Fire-and-forget; failure is surfaced via service event if any.
    sendSnapshot();
  }

  void _handleEvent(OnlineMatchEvent event) {
    if (event is OnlineSnapshotEvent) {
      _applySnapshot(event.payload);
    } else if (event is OnlinePresenceEvent) {
      _players = event.players;
      notifyListeners();
      final hasPeer = _players.any((p) => p.playerId != player.playerId);
      if (isHost && hasPeer) {
        sendSnapshot(force: true);
      }
    } else if (event is OnlineErrorEvent) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Online match error: ${event.message}');
      }
    }
  }

  void _applySnapshot(OnlineSnapshotPayload payload) {
    if (payload.authorId == player.playerId) return;
    if (payload.revision <= _remoteRevision) return;
    _remoteRevision = payload.revision;
    _suppressBroadcast = true;
    controller.hydrateFromExternal(payload.state);
    _suppressBroadcast = false;
  }

  @override
  void dispose() {
    if (_controllerListener != null) {
      controller.removeListener(_controllerListener!);
    }
    _serviceSub?.cancel();
    service.disconnect();
    super.dispose();
  }
}
