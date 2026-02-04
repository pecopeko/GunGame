import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../app/game_controller.dart';
import '../../core/entities.dart';
import 'game_settings_sheet.dart';

class GameBoardHud extends StatelessWidget {
  const GameBoardHud({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;
    final isSetup = state.phase.startsWith('Setup');
    final String turnLabel;
    final Color turnColor;

    if (isSetup) {
      final isAttackerSetup = state.phase == 'SetupAttacker';
      turnLabel = isAttackerSetup ? l10n.attackerSetup : l10n.defenderSetup;
      turnColor = isAttackerSetup ? const Color(0xFFE57373) : const Color(0xFF4FC3F7);
    } else if (state.phase == 'SelectSpikeCarrier') {
      final localTeam = controller.onlineLocalTeam;
      if (localTeam != null && localTeam != TeamId.attacker) {
        turnLabel = l10n.onlineOpponentSelectingSpike;
        turnColor = const Color(0xFFE1B563);
      } else if (controller.isBotOpponentActive) {
        turnLabel = l10n.botDeciding;
        turnColor = const Color(0xFF4FC3F7);
      } else {
        turnLabel = l10n.spikeSelect;
        turnColor = const Color(0xFFE1B563);
      }
    } else {
      turnLabel = state.turnTeam == TeamId.attacker ? l10n.attacker : l10n.defender;
      turnColor = state.turnTeam == TeamId.attacker
          ? const Color(0xFFE57373)
          : const Color(0xFF4FC3F7);
    }

    final localTeam = controller.onlineLocalTeam;
    final isOnlineWaiting = localTeam != null &&
        isSetup &&
        ((state.phase == 'SetupAttacker' && localTeam != TeamId.attacker) ||
            (state.phase == 'SetupDefender' && localTeam != TeamId.defender));

    final statusText = isOnlineWaiting
        ? l10n.onlineOpponentPlacing
        : controller.isBotSetupPhase
            ? l10n.botPlacing
            : controller.getSpikeStatusText(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => showGameSettingsSheet(context),
                  icon: const Icon(Icons.settings, color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                  tooltip: 'Settings',
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.round} ${state.roundIndex}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          turnLabel,
                          style: TextStyle(
                            color: turnColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    statusText,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
