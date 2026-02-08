// 攻守交代のトランジションを表示する。
import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../core/entities.dart';
import '../overlays/overlay_widgets.dart';

class SideSwapOverlay extends StatefulWidget {
  const SideSwapOverlay({super.key, required this.team});

  final TeamId? team;

  @override
  State<SideSwapOverlay> createState() => _SideSwapOverlayState();
}

class _SideSwapOverlayState extends State<SideSwapOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  late final Animation<double> _iconTurn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 1.0, curve: Curves.easeOutBack),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _iconTurn = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final team = widget.team ?? TeamId.attacker;
    final teamLabel = team == TeamId.attacker ? l10n.attacker : l10n.defender;
    final teamColor = team == TeamId.attacker
        ? OverlayTokens.attacker
        : OverlayTokens.defender;

    return AbsorbPointer(
      absorbing: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: _fade.value,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xEE0B1116),
                          Color(0xFF0A0F13),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: SlideTransition(
                  position: _slide,
                  child: Transform.scale(
                    scale: 0.94 + (_scale.value * 0.06),
                    child: Opacity(
                      opacity: _fade.value,
                      child: TacticalPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 24,
                        ),
                        width: 320,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E2730), Color(0xFF151C22)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderColor: teamColor.withOpacity(0.6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    teamColor.withOpacity(0.0),
                                    teamColor.withOpacity(0.8),
                                    teamColor.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Transform.rotate(
                              angle: _iconTurn.value,
                              child: Icon(
                                Icons.swap_horiz_rounded,
                                size: 44,
                                color: teamColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.sideSwapTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: OverlayTokens.ink,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.sideSwapSubtitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: OverlayTokens.muted),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: teamColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: teamColor),
                              ),
                              child: Text(
                                l10n.sideSwapRoleLabel(teamLabel),
                                style: TextStyle(
                                  color: teamColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
