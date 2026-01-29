import 'package:flutter/material.dart';

import '../../app/game_controller.dart';
import '../../core/entities.dart';
import 'game_settings_sheet.dart';

class GameBoardHud extends StatelessWidget {
  const GameBoardHud({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final isSetup = state.phase.startsWith('Setup');
    final String turnLabel;
    final Color turnColor;

    if (isSetup) {
      final isAttackerSetup = state.phase == 'SetupAttacker';
      turnLabel = isAttackerSetup ? 'ATTACKER SETUP' : 'DEFENDER SETUP';
      turnColor = isAttackerSetup ? const Color(0xFFE57373) : const Color(0xFF4FC3F7);
    } else if (state.phase == 'SelectSpikeCarrier') {
      turnLabel = 'SPIKE SELECT';
      turnColor = const Color(0xFFE1B563);
    } else {
      turnLabel = state.turnTeam == TeamId.attacker ? 'ATTACKER' : 'DEFENDER';
      turnColor = state.turnTeam == TeamId.attacker
          ? const Color(0xFFE57373)
          : const Color(0xFF4FC3F7);
    }

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
                        'ROUND ${state.roundIndex}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        turnLabel,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: turnColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.spikeStatusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}
