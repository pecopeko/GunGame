import 'package:flutter/material.dart';

import '../../core/entities.dart';
import '../../game/tactical_game.dart';
import 'overlay_widgets.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final TacticalGame game;

  @override
  Widget build(BuildContext context) {
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
        state.turnTeam == TeamId.attacker ? 'ATTACKER' : 'DEFENDER';
    final spikeLabel = _formatSpike(state.spike);

    return IgnorePointer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TacticalPanel(
            gradient: OverlayTokens.headerGradient,
            child: Row(
              children: [
                _InfoBlock(
                  title: 'ROUND',
                  value: '0${state.roundIndex}',
                  subtitle: state.phase.toUpperCase(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$turnLabel TURN',
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
                          TacticalBadge(label: 'READY $unactivated'),
                          TacticalBadge(
                            label: 'A $attackerAlive',
                            color: OverlayTokens.attacker.withOpacity(0.12),
                            textColor: OverlayTokens.attacker,
                          ),
                          TacticalBadge(
                            label: 'D $defenderAlive',
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
                  title: 'SPIKE',
                  value: spikeLabel,
                  subtitle: _formatSpikeDetail(state.spike),
                  alignEnd: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSpike(SpikeState spike) {
    switch (spike.state) {
      case SpikeStateType.unplanted:
        return 'SECURED';
      case SpikeStateType.carried:
        return 'CARRIED';
      case SpikeStateType.dropped:
        return 'DROPPED';
      case SpikeStateType.planted:
        return 'PLANTED';
      case SpikeStateType.defused:
        return 'DEFUSED';
      case SpikeStateType.exploded:
        return 'EXPLODED';
    }
  }

  String _formatSpikeDetail(SpikeState spike) {
    if (spike.state == SpikeStateType.planted) {
      final turns = spike.explosionInRounds ?? 0;
      return 'DETONATE IN $turns';
    }
    if (spike.state == SpikeStateType.carried) {
      return 'SEEK SITE';
    }
    if (spike.state == SpikeStateType.dropped) {
      return 'RECOVER';
    }
    if (spike.state == SpikeStateType.defused) {
      return 'ROUND END';
    }
    return 'NOT SET';
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
