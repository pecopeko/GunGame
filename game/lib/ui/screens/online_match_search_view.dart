// オンライン対戦のマッチング中/成立画面。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../app/online/online_match_models.dart';
import '../../core/entities.dart';

class OnlineMatchSearchView extends StatefulWidget {
  const OnlineMatchSearchView({
    super.key,
    required this.localProfile,
    required this.match,
    required this.matchCode,
    required this.startedAt,
    required this.showMatchFound,
    required this.showMatchCode,
    required this.onCancel,
  });

  final OnlineProfile? localProfile;
  final OnlineMatchRecord? match;
  final String? matchCode;
  final DateTime? startedAt;
  final bool showMatchFound;
  final bool showMatchCode;
  final VoidCallback onCancel;

  @override
  State<OnlineMatchSearchView> createState() => _OnlineMatchSearchViewState();
}

class _OnlineMatchSearchViewState extends State<OnlineMatchSearchView> {
  Timer? _ticker;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _resetElapsed();
    _startTicker();
  }

  @override
  void didUpdateWidget(OnlineMatchSearchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startedAt != oldWidget.startedAt) {
      _resetElapsed();
    }
    if (widget.showMatchFound != oldWidget.showMatchFound) {
      _startTicker();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    if (widget.showMatchFound) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_resetElapsed);
    });
  }

  void _resetElapsed() {
    final start = widget.startedAt;
    _elapsedSeconds = start == null
        ? 0
        : DateTime.now().difference(start).inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localProfile = widget.localProfile;
    final match = widget.match;
    final localTeam = _resolveTeam(match, localProfile) ?? TeamId.attacker;
    final opponentTeam = localTeam == TeamId.attacker
        ? TeamId.defender
        : TeamId.attacker;
    final opponentProfile = _resolveOpponent(match, localProfile, opponentTeam);

    final title = widget.showMatchFound
        ? l10n.onlineMatchFoundTitle
        : l10n.onlineMatchingTitle;
    final showMatchCode = !widget.showMatchFound && widget.showMatchCode;
    final matchCode = widget.matchCode ?? match?.matchCode ?? '';

    return Container(
      width: double.infinity,
      color: const Color(0xFF0E1215),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showMatchFound)
                const Icon(Icons.check_circle, color: Color(0xFF1BA784), size: 48)
              else
                const Icon(Icons.radar, color: Color(0xFF1BA784), size: 44),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              if (!widget.showMatchFound)
                Text(
                  l10n.onlineMatchingElapsed(_elapsedSeconds),
                  style: const TextStyle(color: Colors.white70),
                ),
              if (showMatchCode) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161C21),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.onlineMatchCodeLabel,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        matchCode.isEmpty ? '-' : matchCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _RecordCard(
                      title: localProfile?.username ?? l10n.onlineYouLabel,
                      recordLabel: l10n.onlineTotalRecordLabel,
                      recordValue: localProfile == null
                          ? '--'
                          : l10n.onlineRecordShortFormat(
                              localProfile.wins,
                              localProfile.losses,
                            ),
                      accent: _teamColor(localTeam),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    children: [
                      Text(
                        l10n.versusShort,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _RecordCard(
                      title: opponentProfile?.username ??
                          l10n.onlineOpponentWaiting,
                      recordLabel: l10n.onlineTotalRecordLabel,
                      recordValue: opponentProfile == null
                          ? '--'
                          : l10n.onlineRecordShortFormat(
                              opponentProfile.wins,
                              opponentProfile.losses,
                            ),
                      accent: _teamColor(opponentTeam),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (!widget.showMatchFound)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B6B),
                      side: const BorderSide(color: Color(0xFFFF6B6B)),
                      backgroundColor: const Color(0x33FF6B6B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  TeamId? _resolveTeam(OnlineMatchRecord? match, OnlineProfile? profile) {
    if (match == null || profile == null) return null;
    if (match.attackerId == profile.id) return TeamId.attacker;
    if (match.defenderId == profile.id) return TeamId.defender;
    return null;
  }

  OnlineProfile? _resolveOpponent(
    OnlineMatchRecord? match,
    OnlineProfile? localProfile,
    TeamId opponentTeam,
  ) {
    if (match == null) return null;
    if (localProfile != null) {
      if (match.attackerId == localProfile.id) return match.defender;
      if (match.defenderId == localProfile.id) return match.attacker;
    }
    return opponentTeam == TeamId.attacker ? match.attacker : match.defender;
  }

  Color _teamColor(TeamId team) {
    return team == TeamId.attacker
        ? const Color(0xFFE57373)
        : const Color(0xFF4FC3F7);
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.title,
    required this.recordLabel,
    required this.recordValue,
    required this.accent,
  });

  final String title;
  final String recordLabel;
  final String recordValue;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161C21),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            recordLabel,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            recordValue,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
