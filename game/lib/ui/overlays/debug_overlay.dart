// デバッグ情報のオーバーレイを表示する。
import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../core/entities.dart';
import '../../game/tactical_game.dart';
import 'overlay_widgets.dart';

class DebugOverlay extends StatelessWidget {
  const DebugOverlay({super.key, required this.game});

  final TacticalGame game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = game.controller.state;
    final units = state.units.length;
    final logs = state.log.length;

    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 96, 0, 0),
            child: TacticalPanel(
              width: 200,
              padding: const EdgeInsets.all(10),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontFamily: 'Menlo',
                      color: OverlayTokens.muted,
                      fontSize: 11,
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.debugHudTitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: OverlayTokens.muted,
                              letterSpacing: 1.2,
                            )),
                    const SizedBox(height: 6),
                    Text(
                      l10n.debugPhaseLabel(_formatPhase(state.phase, l10n)),
                    ),
                    Text(l10n.debugTurnLabel(_formatTeam(state.turnTeam, l10n))),
                    Text(l10n.debugUnitsLabel(units)),
                    Text(l10n.debugLogLabel(logs)),
                    Text(
                      l10n.debugSpikeLabel(
                        _formatSpike(state.spike.state, l10n),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTeam(TeamId team, AppLocalizations l10n) {
    return team == TeamId.attacker ? l10n.attacker : l10n.defender;
  }

  String _formatSpike(SpikeStateType state, AppLocalizations l10n) {
    switch (state) {
      case SpikeStateType.unplanted:
        return l10n.spikeSecured;
      case SpikeStateType.carried:
        return l10n.spikeCarried;
      case SpikeStateType.dropped:
        return l10n.spikeDropped;
      case SpikeStateType.planted:
        return l10n.spikePlanted;
      case SpikeStateType.defused:
        return l10n.spikeDefused;
      case SpikeStateType.exploded:
        return l10n.spikeExploded;
    }
  }

  String _formatPhase(String phase, AppLocalizations l10n) {
    switch (phase) {
      case 'SetupAttacker':
        return l10n.attackerSetup;
      case 'SetupDefender':
        return l10n.defenderSetup;
      case 'SelectSpikeCarrier':
        return l10n.spikeSelect;
      case 'Playing':
        return l10n.phasePlaying;
      case 'GameOver':
        return l10n.phaseGameOver;
      default:
        return l10n.phaseUnknown;
    }
  }
}
