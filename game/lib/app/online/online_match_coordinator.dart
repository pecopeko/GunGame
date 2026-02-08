// オンライン対戦の同期と進行を調整する。
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../game_controller.dart';
import '../../core/entities.dart';
import '../../core/rules_engine.dart';
import 'online_match_models.dart';
import 'online_match_service.dart';

class OnlineMatchCoordinator extends ChangeNotifier {
  OnlineMatchCoordinator({
    required this.controller,
    required this.service,
    required this.player,
    required this.initialTeam,
    required bool isHost,
  }) : _isHost = isHost;

  final GameController controller;
  final OnlineMatchService service;
  final OnlinePlayer player;
  final TeamId initialTeam;
  bool _isHost;
  bool get isHost => _isHost;

  StreamSubscription<OnlineMatchEvent>? _serviceSub;
  VoidCallback? _controllerListener;
  bool _suppressBroadcast = false;
  bool _connected = false;
  int _localRevision = 0;
  int _remoteActionId = 0;
  final Map<String, int> _remoteRevisionByAuthor = {};
  bool _roundRecorded = false;
  bool _didSendInitialSnapshot = false;
  OnlineMatchRecord? _match;
  TeamId? _localTeam;
  TeamId? _startingTeam;
  int? _startingRoundIndex;
  GameState? _lastSentState;

  bool get connected => _connected;
  OnlineMatchRecord? get match => _match;
  TeamId? get localTeam => _localTeam;

  Future<void> start({bool sendInitialSnapshot = false}) async {
    _serviceSub = service.events.listen(_handleEvent);
    final record = await service.initialize();
    _match = record;
    _localTeam = record.teamFor(player.playerId) ?? initialTeam;
    _startingTeam ??= _localTeam;
    _startingRoundIndex ??= record.roundIndex;
    _isHost = record.hostId == player.playerId;
    controller.setOnlineLocalTeam(_localTeam);
    controller.setViewTeam(_localTeam);
    _controllerListener = _handleLocalChange;
    controller.addListener(_controllerListener!);
    _connected = true;
    notifyListeners();
    await _maybeSendInitialSnapshot(record: record, force: sendInitialSnapshot);
  }

  Future<void> sendSnapshot({bool force = false}) async {
    if (_suppressBroadcast && !force) return;
    _localRevision += 1;
    final derivedWin =
        controller.winCondition ??
        controller.deriveWinConditionFromState(controller.state);
    final payload = OnlineSnapshotPayload(
      revision: _localRevision,
      authorId: player.playerId,
      sentAt: DateTime.now().toUtc(),
      state: controller.state,
      roundIndex: _match?.roundIndex ?? controller.state.roundIndex,
      winningTeam: derivedWin?.winner,
      winReason: derivedWin?.reason,
    );
    await service.sendSnapshot(payload);
  }

  void _handleLocalChange() {
    if (_suppressBroadcast) return;
    if (!_canBroadcast(controller.state)) return;
    if (identical(_lastSentState, controller.state)) return;
    _lastSentState = controller.state;
    sendSnapshot();
    final winTeam =
        controller.winCondition?.winner ??
        controller.deriveWinConditionFromState(controller.state)?.winner;
    if (winTeam != null && !_roundRecorded && isHost) {
      _roundRecorded = true;
      service.recordRoundResult(
        winningTeam: winTeam,
        finalState: controller.state,
      );
    }
  }

  bool _canBroadcast(GameState state) {
    return _localTeam != null;
  }

  void _handleEvent(OnlineMatchEvent event) {
    if (event is OnlineSnapshotEvent) {
      _applySnapshot(event);
    } else if (event is OnlineMatchMetaEvent) {
      _handleMeta(event.record);
    } else if (event is OnlineErrorEvent) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Online match error: ${event.message}');
      }
    }
  }

  Future<void> _handleMeta(OnlineMatchRecord record) async {
    final previousRounds = _match == null
        ? 0
        : (_match!.attackerWins + _match!.defenderWins);
    _match = record;
    _isHost = record.hostId == player.playerId;
    final teamFromRecord = record.teamFor(player.playerId);
    final expectedTeam = _expectedTeamForRound(record.roundIndex);
    var resolvedTeam = teamFromRecord ?? expectedTeam ?? _localTeam;
    if (expectedTeam != null &&
        resolvedTeam == _localTeam &&
        expectedTeam != _localTeam) {
      resolvedTeam = expectedTeam;
    }
    if (resolvedTeam != null && resolvedTeam != _localTeam) {
      _localTeam = resolvedTeam;
      controller.setOnlineLocalTeam(resolvedTeam);
      controller.setViewTeam(resolvedTeam);
    }

    if (record.isFinished && record.winnerTeam != null) {
      final endReason = record.endedReason;
      final isForfeit = endReason == 'timeout' || endReason == 'abandon';
      controller.applyExternalWinCondition(
        WinCondition(
          winner: record.winnerTeam!,
          reason: isForfeit ? (endReason ?? 'timeout') : 'match_finished',
        ),
      );
      notifyListeners();
      return;
    }

    final currentRounds = record.attackerWins + record.defenderWins;
    final isNewRound = currentRounds > previousRounds && !record.isFinished;
    if (isNewRound) {
      _roundRecorded = false;
      _localRevision = 0;
      _remoteRevisionByAuthor.clear();
      _didSendInitialSnapshot = false;
      await controller.initializeGame();
      final teamForPlayer = record.teamFor(player.playerId) ?? _localTeam;
      _localTeam = teamForPlayer;
      if (teamForPlayer != null) {
        controller.setOnlineLocalTeam(teamForPlayer);
        controller.setViewTeam(teamForPlayer);
      }
      if (isHost) {
        await _maybeSendInitialSnapshot(record: record, force: true);
      }
    } else {
      await _maybeSendInitialSnapshot(record: record);
    }
    notifyListeners();
  }

  void _applySnapshot(OnlineSnapshotEvent event) {
    final payload = event.payload;
    if (payload.authorId == player.playerId) return;
    if (event.actionId != null) {
      if (event.actionId! <= _remoteActionId) return;
      _remoteActionId = event.actionId!;
    } else {
      final lastRevision = _remoteRevisionByAuthor[payload.authorId] ?? 0;
      if (payload.revision <= lastRevision) return;
      _remoteRevisionByAuthor[payload.authorId] = payload.revision;
    }

    _suppressBroadcast = true;
    controller.hydrateFromExternal(payload.state);
    final winningTeam = payload.winningTeam;
    final winReason = payload.winReason;
    if (winningTeam != null && _shouldApplyMatchEnd(winReason)) {
      controller.applyExternalWinCondition(
        WinCondition(
          winner: winningTeam,
          reason: winReason ?? 'match_finished',
        ),
      );
    }
    _suppressBroadcast = false;

    if (winningTeam != null && !_roundRecorded && isHost) {
      _roundRecorded = true;
      service.recordRoundResult(
        winningTeam: winningTeam,
        finalState: controller.state,
      );
    }
  }

  bool _shouldApplyMatchEnd(String? reason) {
    if (reason == null) return false;
    return reason == 'match_finished' ||
        reason == 'timeout' ||
        reason == 'abandon';
  }

  bool _matchHasBothPlayers(OnlineMatchRecord record) {
    return record.attackerId != null && record.defenderId != null;
  }

  TeamId? _expectedTeamForRound(int roundIndex) {
    final startTeam = _startingTeam;
    final startRound = _startingRoundIndex;
    if (startTeam == null || startRound == null) return null;
    final delta = roundIndex - startRound;
    if (delta % 2 == 0) return startTeam;
    return startTeam == TeamId.attacker ? TeamId.defender : TeamId.attacker;
  }

  Future<void> _maybeSendInitialSnapshot({
    required OnlineMatchRecord? record,
    bool force = false,
  }) async {
    if (record == null) return;
    if (_didSendInitialSnapshot) return;
    if (!force && !_isHost) return;
    if (!_matchHasBothPlayers(record)) return;
    _didSendInitialSnapshot = true;
    await sendSnapshot(force: true);
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
