// アクションバーUIを管理する。
import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../app/game_controller.dart';
import '../../core/entities.dart';
import '../../core/game_mode.dart';
import 'overlay_widgets.dart';

class ActionBarOverlay extends StatelessWidget {
  const ActionBarOverlay({
    super.key,
    required this.controller,
    this.mode,
    this.onRematch,
    this.onQuit,
    this.onSwapSides,
  });

  final GameController controller;
  final GameMode? mode;
  final VoidCallback? onRematch;
  final VoidCallback? onQuit;
  final VoidCallback? onSwapSides;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final hasSelection = controller.selectedUnitId != null;
    final isAttackMode = controller.isAttackMode;
    final isGameOver = controller.winCondition != null;
    final isOnlineOrBot = mode == GameMode.online || mode == GameMode.bot;
    final canActNow = isOnlineOrBot ? controller.canLocalPlayerActNow : true;
    final emphasis = canActNow ? 1.0 : 0.0;
    final visualEnabled = canActNow;

    // Show win/lose overlay if game over
    if (isGameOver) {
      return _buildGameOverOverlay(context);
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  TacticalActionTile(
                    icon: Icons.directions_walk,
                    label: l10n.move,
                    detail: hasSelection
                        ? '${controller.selectedUnit?.card.moveRange ?? 2} ${l10n.tiles}'
                        : '- ${l10n.tiles}',
                    accent: OverlayTokens.accent,
                    emphasis: emphasis,
                    visualEnabled: visualEnabled,
                    enabled: hasSelection && !isAttackMode,
                    onTap: hasSelection
                        ? () => controller.resetActionModes()
                        : null,
                  ),

                  if (!hasSelection ||
                      controller.shouldShowSkill(SkillSlot.skill1))
                    TacticalActionTile(
                      icon: Icons.blur_on,
                      label:
                          controller.selectedUnit?.card.skill1.name ??
                          l10n.skill1,
                      detail: hasSelection
                          ? controller.getSkillStatus(SkillSlot.skill1)
                          : l10n.na,
                      accent: OverlayTokens.accentWarm,
                      emphasis: emphasis,
                      visualEnabled: visualEnabled,
                      enabled:
                          hasSelection &&
                          controller.canUseSkill(SkillSlot.skill1),
                      highlighted:
                          controller.isSkillMode &&
                          controller.activeSkillSlot == SkillSlot.skill1,
                      onTap:
                          hasSelection &&
                              controller.canUseSkill(SkillSlot.skill1)
                          ? () {
                              if (controller.isSkillMode &&
                                  controller.activeSkillSlot ==
                                      SkillSlot.skill1) {
                                controller.resetActionModes();
                              } else {
                                controller.enterSkillMode(SkillSlot.skill1);
                              }
                            }
                          : null,
                    ),
                  if (!hasSelection ||
                      controller.shouldShowSkill(SkillSlot.skill2))
                    TacticalActionTile(
                      icon: Icons.blur_circular,
                      label:
                          controller.selectedUnit?.card.skill2.name ??
                          l10n.skill2,
                      detail: hasSelection
                          ? controller.getSkillStatus(SkillSlot.skill2)
                          : l10n.na,
                      accent: OverlayTokens.smoke,
                      emphasis: emphasis,
                      visualEnabled: visualEnabled,
                      enabled:
                          hasSelection &&
                          controller.canUseSkill(SkillSlot.skill2),
                      highlighted:
                          controller.isSkillMode &&
                          controller.activeSkillSlot == SkillSlot.skill2,
                      onTap:
                          hasSelection &&
                              controller.canUseSkill(SkillSlot.skill2)
                          ? () {
                              if (controller.isSkillMode) {
                                controller.cancelSkillMode();
                              } else {
                                controller.enterSkillMode(SkillSlot.skill2);
                              }
                            }
                          : null,
                    ),
                  TacticalActionTile(
                    icon: Icons.gps_fixed,
                    label: l10n.plant,
                    detail: controller.canPlant ? l10n.onSite : l10n.na,
                    accent: OverlayTokens.attacker,
                    emphasis: emphasis,
                    visualEnabled: visualEnabled,
                    enabled: controller.canPlant,
                    onTap: controller.canPlant ? controller.plantSpike : null,
                  ),
                  TacticalActionTile(
                    icon: Icons.shield_outlined,
                    label: l10n.defuse,
                    detail: controller.canDefuse
                        ? '${(controller.state.spike.defuseProgress ?? 0) + 1}/2'
                        : l10n.na,
                    accent: OverlayTokens.defender,
                    emphasis: emphasis,
                    visualEnabled: visualEnabled,
                    enabled: controller.canDefuse,
                    onTap: controller.canDefuse ? controller.defuseSpike : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final win = controller.winCondition!;
    final isAttackerWin = win.winner == TeamId.attacker;
    final localTeam = controller.onlineLocalTeam;
    final showPersonalResult = localTeam != null;
    final isLocalWin = localTeam == win.winner;
    final isLocal = mode == GameMode.local;
    final isBot = mode == GameMode.bot;
    final isOnline = mode == GameMode.online;
    final isOnlineMatchFinished = win.reason == 'match_finished';

    final reasonText = _reasonText(l10n, win.reason, isLocalWin: isLocalWin);

    return SafeArea(
      child: Center(
        child: TacticalPanel(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAttackerWin ? Icons.flash_on : Icons.shield,
                size: 64,
                color: isAttackerWin
                    ? OverlayTokens.attacker
                    : OverlayTokens.defender,
              ),
              const SizedBox(height: 16),
              Text(
                showPersonalResult
                    ? (isLocalWin ? l10n.victory : l10n.defeat)
                    : (isAttackerWin ? l10n.attackersWin : l10n.defendersWin),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isAttackerWin
                      ? OverlayTokens.attacker
                      : OverlayTokens.defender,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reasonText,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: OverlayTokens.muted),
              ),
              if (isLocal) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: onRematch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1BA784),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(l10n.rematch),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: onQuit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: Text(l10n.quit),
                    ),
                  ],
                ),
              ],
              if (isBot) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: onSwapSides,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE1B563),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(l10n.swapSides),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: onQuit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: Text(l10n.quit),
                    ),
                  ],
                ),
              ],
              if (isOnline && isOnlineMatchFinished) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: onRematch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1BA784),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(l10n.rematch),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: onQuit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: Text(l10n.quitGame),
                    ),
                  ],
                ),
              ],
              if (isOnline && !isOnlineMatchFinished && onQuit != null) ...[
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: onQuit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: Text(l10n.quitGame),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _reasonText(
    AppLocalizations l10n,
    String reason, {
    required bool isLocalWin,
  }) {
    if (reason == 'timeout' || reason == 'abandon') {
      return isLocalWin ? l10n.timeoutWin : l10n.timeoutLose;
    }
    if (reason == 'match_finished') {
      return l10n.matchFinished;
    }
    if (reason == 'spike_defused') {
      return l10n.spikeDefusedWin;
    }
    if (reason == 'spike_exploded') {
      return l10n.spikeExplodedWin;
    }
    if (reason == 'both_eliminated') {
      return l10n.bothTeamsEliminated;
    }
    if (reason == 'attackers_eliminated') {
      return l10n.attackersEliminated;
    }
    if (reason == 'defenders_eliminated') {
      return l10n.defendersEliminated;
    }
    return reason;
  }
}
