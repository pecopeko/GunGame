import 'package:flutter/material.dart';

import '../../game/tactical_game.dart';
import 'overlay_widgets.dart';

class TooltipOverlay extends StatelessWidget {
  const TooltipOverlay({super.key, required this.game});

  final TacticalGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          child: TacticalPanel(
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FIELD INTEL',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: OverlayTokens.muted,
                        letterSpacing: 1.4,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No unit selected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: OverlayTokens.ink,
                      ),
                ),
                const TacticalDivider(),
                Row(
                  children: [
                    Icon(Icons.visibility, color: OverlayTokens.accent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'LoS: clear to Mid corridor',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: OverlayTokens.muted,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.cloud, color: OverlayTokens.smoke, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Smoke: 2 turns remaining',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: OverlayTokens.muted,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_pin, color: OverlayTokens.accentWarm, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Zone: Mid / Tile r1c2',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: OverlayTokens.muted,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
