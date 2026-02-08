// オンライン対戦中ヘッダーを表示する。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../app/online/online_match_models.dart';
import '../../core/entities.dart';
import 'online_match_badges.dart';

const Duration _onlineMatchTimeout = Duration(minutes: 2);

class OnlineMatchHeader extends StatefulWidget {
  const OnlineMatchHeader({
    super.key,
    required this.match,
    required this.localProfile,
    required this.connected,
    required this.matchCode,
    required this.onQuit,
    this.localTeamOverride,
  });

  final OnlineMatchRecord? match;
  final OnlineProfile? localProfile;
  final bool connected;
  final String? matchCode;
  final VoidCallback onQuit;
  final TeamId? localTeamOverride;

  @override
  State<OnlineMatchHeader> createState() => _OnlineMatchHeaderState();
}

class _OnlineMatchHeaderState extends State<OnlineMatchHeader> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void didUpdateWidget(OnlineMatchHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldTick(widget.match) && !_shouldTick(oldWidget.match)) {
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
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_shouldTick(widget.match)) return;
      setState(() {});
    });
  }

  bool _shouldTick(OnlineMatchRecord? match) {
    if (match == null) return false;
    if (match.isFinished) return false;
    if (match.status != 'active') return false;
    return match.lastActionAt != null;
  }

  Duration? _remainingTimeout(OnlineMatchRecord? match) {
    if (!_shouldTick(match)) return null;
    final lastActionAt = match!.lastActionAt!;
    final elapsed = DateTime.now().toUtc().difference(lastActionAt);
    return _onlineMatchTimeout - elapsed;
  }

  String _formatRemaining(Duration remaining) {
    final clampedSeconds = remaining.inSeconds.clamp(0, 5999);
    final minutes = clampedSeconds ~/ 60;
    final seconds = clampedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final match = widget.match;
    final localProfile = widget.localProfile;
    final localSide =
        widget.localTeamOverride ??
        match?.teamFor(localProfile?.id ?? '') ??
        TeamId.attacker;
    final opponentSide = localSide == TeamId.attacker
        ? TeamId.defender
        : TeamId.attacker;
    final opponentProfile = opponentSide == TeamId.attacker
        ? match?.attacker
        : match?.defender;
    final localRounds = match == null || localProfile == null
        ? 0
        : (localSide == TeamId.attacker
              ? match!.attackerWins
              : match!.defenderWins);
    final oppRounds = match == null || localProfile == null
        ? 0
        : (localSide == TeamId.attacker
              ? match!.defenderWins
              : match!.attackerWins);
    final remaining = _remainingTimeout(match);
    final timeoutText =
        remaining == null ? null : _formatRemaining(remaining);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.onlineCodeLabel(widget.matchCode ?? '-'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  StatusChip(
                    text: widget.connected
                        ? l10n.onlineStatusConnected
                        : l10n.onlineStatusDisconnected,
                    ok: widget.connected,
                  ),
                  if (timeoutText != null)
                    _TimeoutChip(text: 'TIMEOUT $timeoutText'),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  PlayerBadge(
                    label: localProfile?.username ?? l10n.onlineYouLabel,
                    side: localSide,
                    record: localProfile == null
                        ? ''
                        : l10n.onlineRecordShortFormat(
                            localProfile!.wins,
                            localProfile!.losses,
                          ),
                  ),
                  Text(
                    l10n.onlineScoreFormat(localRounds, oppRounds, 2),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  PlayerBadge(
                    label:
                        opponentProfile?.username ?? l10n.onlineOpponentWaiting,
                    side: opponentSide,
                    record: opponentProfile == null
                        ? ''
                        : l10n.onlineRecordShortFormat(
                            opponentProfile.wins,
                            opponentProfile.losses,
                          ),
                  ),
                ],
              ),
              if (match?.isFinished == true)
                const SizedBox(height: 6),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: widget.onQuit,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white24),
          ),
          child: Text(l10n.onlineExit),
        ),
      ],
    );
  }
}

class _TimeoutChip extends StatelessWidget {
  const _TimeoutChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x33FFB84D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x66FFB84D)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFFFC857),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
