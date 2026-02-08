// タイル情報などのツールチップを表示する。
import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../game/tactical_game.dart';
import 'overlay_widgets.dart';

class TooltipOverlay extends StatelessWidget {
  const TooltipOverlay({super.key, required this.game});

  final TacticalGame game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zoneLabel = l10n.zoneMid;
    final tileLabel = l10n.sampleTileId;

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
                  l10n.fieldIntelTitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: OverlayTokens.muted,
                        letterSpacing: 1.4,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noUnitSelected,
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
                        l10n.losClearToZone(zoneLabel),
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
                        l10n.smokeTurnsRemaining(2),
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
                        l10n.zoneTileInfo(zoneLabel, tileLabel),
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
