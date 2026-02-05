import 'package:flutter/material.dart';

import 'package:game/l10n/app_localizations.dart';

import '../../app/online/online_match_models.dart';
import '../../core/entities.dart';

enum OnlineMatchType { code, random }

class OnlineIdentityStep extends StatelessWidget {
  const OnlineIdentityStep({
    super.key,
    required this.usernameCtrl,
    required this.busy,
    required this.status,
    required this.error,
    required this.onSubmit,
    required this.onBack,
  });

  final TextEditingController usernameCtrl;
  final bool busy;
  final String? status;
  final String? error;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.onlineProfileTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onBack,
                child: Text(
                  l10n.back,
                  style: const TextStyle(letterSpacing: 2),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: usernameCtrl,
              decoration: InputDecoration(
                labelText: l10n.onlineUsernameLabel,
                filled: true,
                fillColor: const Color(0xFF161C21),
                labelStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              maxLength: 12,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: busy ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BA784),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l10n.onlineUsernameSave),
              ),
            ),
            const SizedBox(height: 8),
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.white70)),
            if (error != null)
              Text(error!, style: const TextStyle(color: Color(0xFFE57373))),
          ],
        ),
      ),
    );
  }
}

class OnlineLobbyStep extends StatelessWidget {
  const OnlineLobbyStep({
    super.key,
    required this.profile,
    required this.matchType,
    required this.hosting,
    required this.busy,
    required this.status,
    required this.error,
    required this.codeCtrl,
    required this.onMatchTypeChanged,
    required this.onHostingChanged,
    required this.onStartHost,
    required this.onStartJoin,
    required this.onStartRandom,
    required this.onCancel,
    required this.onBack,
  });

  final OnlineProfile profile;
  final OnlineMatchType matchType;
  final bool hosting;
  final bool busy;
  final String? status;
  final String? error;
  final TextEditingController codeCtrl;
  final ValueChanged<OnlineMatchType> onMatchTypeChanged;
  final ValueChanged<bool> onHostingChanged;
  final VoidCallback onStartHost;
  final VoidCallback onStartJoin;
  final VoidCallback onStartRandom;
  final VoidCallback onCancel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCodeMatch = matchType == OnlineMatchType.code;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.onlineMatchTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onBack,
                child: Text(
                  l10n.back,
                  style: const TextStyle(letterSpacing: 2),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF161C21),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.onlineUsernameFormat(profile.username),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.onlineRecordFormat(profile.wins, profile.losses),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ToggleButtons(
              isSelected: [
                matchType == OnlineMatchType.code,
                matchType == OnlineMatchType.random,
              ],
              onPressed: (i) {
                onMatchTypeChanged(
                  i == 0 ? OnlineMatchType.code : OnlineMatchType.random,
                );
              },
              color: Colors.white70,
              selectedColor: Colors.black,
              fillColor: const Color(0xFF1BA784),
              borderRadius: BorderRadius.circular(10),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(l10n.onlineMatchTypeCode),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(l10n.onlineMatchTypeRandom),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isCodeMatch) ...[
              ToggleButtons(
                isSelected: [hosting, !hosting],
                onPressed: (i) => onHostingChanged(i == 0),
                color: Colors.white70,
                selectedColor: Colors.black,
                fillColor: const Color(0xFF1BA784),
                borderRadius: BorderRadius.circular(10),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(l10n.onlineHost),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(l10n.onlineJoin),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (isCodeMatch && !hosting)
              TextField(
                controller: codeCtrl,
                decoration: InputDecoration(
                  labelText: l10n.onlineMatchCodeLabel,
                  filled: true,
                  fillColor: const Color(0xFF161C21),
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: const OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.characters,
              )
            else if (isCodeMatch)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161C21),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  l10n.onlineAutoCodeHint,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: busy
                    ? null
                    : (isCodeMatch
                          ? (hosting ? onStartHost : onStartJoin)
                          : onStartRandom),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BA784),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  isCodeMatch
                      ? (hosting ? l10n.onlineCreateRoom : l10n.onlineJoinRoom)
                      : l10n.onlineRandomStart,
                ),
              ),
            ),
            if (busy) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
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
            const SizedBox(height: 8),
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.white70)),
            if (error != null)
              Text(error!, style: const TextStyle(color: Color(0xFFE57373))),
          ],
        ),
      ),
    );
  }
}

class OnlineMatchHeader extends StatelessWidget {
  const OnlineMatchHeader({
    super.key,
    required this.match,
    required this.localProfile,
    required this.connected,
    required this.matchCode,
    required this.onQuit,
    required this.onReplay,
    required this.busy,
  });

  final OnlineMatchRecord? match;
  final OnlineProfile? localProfile;
  final bool connected;
  final String? matchCode;
  final VoidCallback onQuit;
  final VoidCallback? onReplay;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localSide = match?.teamFor(localProfile?.id ?? '') ?? TeamId.attacker;
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

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.onlineCodeLabel(matchCode ?? '-'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                StatusChip(
                  text: connected
                      ? l10n.onlineStatusConnected
                      : l10n.onlineStatusDisconnected,
                  ok: connected,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
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
                const SizedBox(width: 10),
                Text(
                  l10n.onlineScoreFormat(localRounds, oppRounds, 2),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
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
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Text(
                      l10n.onlineMatchEndedReplayNotice,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: busy ? null : onReplay,
                      child: Text(l10n.onlineReplayButton),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: onQuit,
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

class PlayerBadge extends StatelessWidget {
  const PlayerBadge({
    super.key,
    required this.label,
    required this.side,
    this.record = '',
  });

  final String label;
  final TeamId side;
  final String record;

  @override
  Widget build(BuildContext context) {
    final color = side == TeamId.attacker
        ? const Color(0xFFE57373)
        : const Color(0xFF4FC3F7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          if (record.isNotEmpty)
            Text(
              record,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.text, required this.ok});

  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFF1BA784).withOpacity(0.15) : Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ok ? const Color(0xFF1BA784) : Colors.white30,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: ok ? const Color(0xFF1BA784) : Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
