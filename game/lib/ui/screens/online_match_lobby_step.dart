// オンライン対戦のロビー入力UI。
import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../app/online/online_match_models.dart';
import 'online_match_types.dart';

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
                      ? (hosting
                            ? l10n.onlineCreateRoom
                            : l10n.onlineJoinRoom)
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
