// ゲーム盤面のHUDオーバーレイを描画する。
import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../core/entities.dart';
import '../../game/tactical_game.dart';
import 'overlay_widgets.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final TacticalGame game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = game.controller.state;
    final attackerAlive = state.units
        .where((unit) => unit.team == TeamId.attacker && unit.alive)
        .length;
    final defenderAlive = state.units
        .where((unit) => unit.team == TeamId.defender && unit.alive)
        .length;
    final unactivated = state.units
        .where((unit) =>
            unit.team == state.turnTeam && unit.alive && !unit.activatedThisRound)
        .length;
    final turnLabel =
        state.turnTeam == TeamId.attacker ? l10n.attacker : l10n.defender;
    final spikeLabel = _formatSpike(state.spike, l10n);

    return IgnorePointer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TacticalPanel(
            gradient: OverlayTokens.headerGradient,
            child: Row(
              children: [
                _InfoBlock(
                  title: l10n.round,
                  value: '0${state.roundIndex}',
                  subtitle: _formatPhase(state.phase, l10n),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.turnTeam == TeamId.attacker 
                            ? l10n.attackerTurn 
                            : l10n.defenderTurn,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: state.turnTeam == TeamId.attacker
                                  ? OverlayTokens.attacker
                                  : OverlayTokens.defender,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          TacticalBadge(label: '${l10n.ready} $unactivated'),
                          TacticalBadge(
                            label: l10n.attackerAliveBadge(attackerAlive),
                            color: OverlayTokens.attacker.withOpacity(0.12),
                            textColor: OverlayTokens.attacker,
                          ),
                          TacticalBadge(
                            label: l10n.defenderAliveBadge(defenderAlive),
                            color: OverlayTokens.defender.withOpacity(0.12),
                            textColor: OverlayTokens.defender,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _InfoBlock(
                  title: l10n.spike,
                  value: spikeLabel,
                  subtitle: _formatSpikeDetail(state.spike, l10n),
                  alignEnd: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSpike(SpikeState spike, AppLocalizations l10n) {
    switch (spike.state) {
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

  String _formatSpikeDetail(SpikeState spike, AppLocalizations l10n) {
    if (spike.state == SpikeStateType.planted) {
      final turns = spike.explosionInRounds ?? 0;
      return l10n.detonateIn(turns);
    }
    if (spike.state == SpikeStateType.carried) {
      return l10n.seekSite;
    }
    if (spike.state == SpikeStateType.dropped) {
      return l10n.recover;
    }
    if (spike.state == SpikeStateType.defused) {
      return l10n.roundEnd;
    }
    return l10n.notSet;
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

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.title,
    required this.value,
    required this.subtitle,
    this.alignEnd = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: OverlayTokens.muted,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: OverlayTokens.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: OverlayTokens.muted,
          ),
        ),
      ],
    );
  }
}
