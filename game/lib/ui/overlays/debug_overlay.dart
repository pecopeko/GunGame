import 'package:flutter/material.dart';

import '../../core/entities.dart';
import '../../game/tactical_game.dart';
import 'overlay_widgets.dart';

class DebugOverlay extends StatelessWidget {
  const DebugOverlay({super.key, required this.game});

  final TacticalGame game;

  @override
  Widget build(BuildContext context) {
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
                    Text('DEBUG HUD',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: OverlayTokens.muted,
                              letterSpacing: 1.2,
                            )),
                    const SizedBox(height: 6),
                    Text('Phase: ${state.phase}'),
                    Text('Turn: ${_formatTeam(state.turnTeam)}'),
                    Text('Units: $units'),
                    Text('Log: $logs'),
                    Text('Spike: ${_formatSpike(state.spike.state)}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTeam(TeamId team) {
    return team == TeamId.attacker ? 'Attacker' : 'Defender';
  }

  String _formatSpike(SpikeStateType state) {
    switch (state) {
      case SpikeStateType.unplanted:
        return 'Unplanted';
      case SpikeStateType.carried:
        return 'Carried';
      case SpikeStateType.planted:
        return 'Planted';
      case SpikeStateType.defused:
        return 'Defused';
      case SpikeStateType.exploded:
        return 'Exploded';
    }
  }
}
