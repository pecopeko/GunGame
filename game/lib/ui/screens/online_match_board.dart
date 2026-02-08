// オンライン対戦中の盤面表示と自動退出を管理する。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../app/game_controller.dart';
import '../../app/online/online_match_coordinator.dart';
import '../../app/online/online_match_models.dart';
import '../../core/entities.dart';
import '../../core/game_mode.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/side_swap_overlay.dart';
import 'online_match_views.dart';
import 'online_match_search_view.dart';

class OnlineMatchBoard extends StatefulWidget {
  const OnlineMatchBoard({
    super.key,
    required this.controller,
    required this.coordinator,
    required this.localProfile,
    required this.status,
    required this.onQuit,
    required this.onRematch,
    required this.searchStartedAt,
    required this.showMatchCode,
    required this.matchCode,
  });

  final GameController controller;
  final OnlineMatchCoordinator? coordinator;
  final OnlineProfile? localProfile;
  final String? status;
  final VoidCallback onQuit;
  final VoidCallback onRematch;
  final DateTime? searchStartedAt;
  final bool showMatchCode;
  final String? matchCode;

  @override
  State<OnlineMatchBoard> createState() => _OnlineMatchBoardState();
}

class _OnlineMatchBoardState extends State<OnlineMatchBoard> {
  bool _showMatchFound = false;
  bool _matchReadyAnnounced = false;
  Timer? _matchFoundTimer;
  Timer? _sideSwapTimer;
  int? _lastRoundIndex;
  int? _lastSideSwapRound;
  TeamId? _lastLocalTeam;
  TeamId? _sideSwapTeam;
  bool _showSideSwapOverlay = false;

  @override
  void dispose() {
    _matchFoundTimer?.cancel();
    _sideSwapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = widget.controller;
    final coordinator = widget.coordinator;

    if (coordinator == null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                if (widget.status != null)
                  Text(
                    widget.status!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                const Spacer(),
                OutlinedButton(
                  onPressed: widget.onQuit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  child: Text(l10n.onlineExit),
                ),
              ],
            ),
          ),
          Expanded(
            child: GameBoardWidget(
              controller: controller,
              mode: GameMode.local,
              onQuit: widget.onQuit,
              onRematch: widget.onRematch,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return ListenableBuilder(
                listenable: coordinator,
                builder: (context, _) {
                  final match = coordinator.match;
                  _scheduleSideSwapIfNeeded(match, coordinator.localTeam);
                  final matchReady = _isMatchReady(match);
                  final showSearch =
                      !matchReady || _showMatchFound || !_matchReadyAnnounced;
                  if (matchReady && !_matchReadyAnnounced) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _announceMatchFound();
                    });
                  }
                  if (showSearch) {
                    return OnlineMatchSearchView(
                      localProfile: widget.localProfile,
                      match: match,
                      matchCode: widget.matchCode,
                      startedAt: widget.searchStartedAt,
                      showMatchFound: _showMatchFound,
                      showMatchCode: widget.showMatchCode,
                      onCancel: widget.onQuit,
                    );
                  }
                  _maybeScheduleAutoExit(controller);
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.white12)),
                        ),
                        child: OnlineMatchHeader(
                          match: match,
                          localProfile: widget.localProfile,
                          connected: coordinator.connected,
                          matchCode: match?.matchCode,
                          onQuit: widget.onQuit,
                          localTeamOverride: coordinator.localTeam,
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            GameBoardWidget(
                              controller: controller,
                              mode: GameMode.online,
                              onQuit: widget.onQuit,
                              onRematch: widget.onRematch,
                            ),
                            if (_showSideSwapOverlay)
                              Positioned.fill(
                                child: SideSwapOverlay(team: _sideSwapTeam),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _maybeScheduleAutoExit(GameController controller) {
    final win = controller.winCondition;
    if (win == null) return;
    if (win.reason != 'timeout' && win.reason != 'abandon') return;
    // Keep the result screen visible on timeout/abandon.
    return;
  }

  bool _isMatchReady(OnlineMatchRecord? match) {
    if (match == null) return false;
    return match.attackerId != null && match.defenderId != null;
  }

  void _announceMatchFound() {
    if (!mounted || _matchReadyAnnounced) return;
    setState(() {
      _matchReadyAnnounced = true;
      _showMatchFound = true;
    });
    _matchFoundTimer?.cancel();
    _matchFoundTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _showMatchFound = false;
      });
    });
  }

  void _scheduleSideSwapIfNeeded(
    OnlineMatchRecord? match,
    TeamId? localTeam,
  ) {
    if (!mounted || match == null || widget.localProfile == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleSideSwap(match, localTeam);
    });
  }

  void _handleSideSwap(OnlineMatchRecord match, TeamId? localTeam) {
    if (!mounted || match.isFinished) return;
    if (localTeam == null) return;
    final roundIndex = match.roundIndex;
    final previousRound = _lastRoundIndex;
    final previousTeam = _lastLocalTeam;

    _lastRoundIndex = roundIndex;
    _lastLocalTeam = localTeam;

    if (previousRound == null || previousTeam == null) return;
    if (roundIndex <= previousRound) return;
    if (localTeam == previousTeam) return;
    if (_lastSideSwapRound == roundIndex) return;
    _lastSideSwapRound = roundIndex;
    _showSideSwap(localTeam);
  }

  void _showSideSwap(TeamId team) {
    _sideSwapTimer?.cancel();
    setState(() {
      _sideSwapTeam = team;
      _showSideSwapOverlay = true;
    });
    _sideSwapTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _showSideSwapOverlay = false;
      });
    });
  }
}
