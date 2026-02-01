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
    final canAttack = hasSelection && controller.canAttack;
    final isAttackMode = controller.isAttackMode;
    final isGameOver = controller.winCondition != null;

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
              TacticalPanel(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      controller.isSkillMode 
                          ? l10n.skillMode
                          : (isAttackMode ? l10n.attackMode : l10n.action),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: controller.isSkillMode 
                                ? OverlayTokens.accentWarm
                                : (isAttackMode ? OverlayTokens.alert : OverlayTokens.muted),
                            letterSpacing: 1.6,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.isSkillMode
                            ? l10n.skillModeHint
                            : (isAttackMode 
                                ? l10n.attackModeHint
                                : l10n.actionHint),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: OverlayTokens.ink,
                            ),
                      ),
                    ),
                    if (hasSelection)
                      TacticalBadge(
                        label: controller.selectedUnit?.card.displayName.toUpperCase() ?? '',
                        color: OverlayTokens.accent.withAlpha(51),
                        textColor: OverlayTokens.accent,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
                    enabled: hasSelection && !isAttackMode,
                    onTap: hasSelection
                        ? () => controller.resetActionModes()
                        : null,
                  ),

                  if (!hasSelection || controller.shouldShowSkill(SkillSlot.skill1))
                    TacticalActionTile(
                      icon: Icons.blur_on,
                      label: controller.selectedUnit?.card.skill1.name ?? l10n.skill1,
                      detail: hasSelection ? controller.getSkillStatus(SkillSlot.skill1) : l10n.na,
                      accent: OverlayTokens.accentWarm,
                      enabled: hasSelection && controller.canUseSkill(SkillSlot.skill1),
                      highlighted: controller.isSkillMode && controller.activeSkillSlot == SkillSlot.skill1,
                      onTap: hasSelection && controller.canUseSkill(SkillSlot.skill1)
                          ? () {
                              if (controller.isSkillMode &&
                                  controller.activeSkillSlot == SkillSlot.skill1) {
                                controller.resetActionModes();
                              } else {
                                controller.enterSkillMode(SkillSlot.skill1);
                              }
                            }
                          : null,
                    ),
                  if (!hasSelection || controller.shouldShowSkill(SkillSlot.skill2))
                    TacticalActionTile(
                      icon: Icons.blur_circular,
                      label: controller.selectedUnit?.card.skill2.name ?? l10n.skill2,
                      detail: hasSelection ? controller.getSkillStatus(SkillSlot.skill2) : l10n.na,
                      accent: OverlayTokens.smoke,
                      enabled: hasSelection && controller.canUseSkill(SkillSlot.skill2),
                      highlighted: controller.isSkillMode && controller.activeSkillSlot == SkillSlot.skill2,
                      onTap: hasSelection && controller.canUseSkill(SkillSlot.skill2)
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
    final isLocal = mode == GameMode.local;
    final isBot = mode == GameMode.bot;

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
                color: isAttackerWin ? OverlayTokens.attacker : OverlayTokens.defender,
              ),
              const SizedBox(height: 16),
              Text(
                isAttackerWin ? l10n.attackersWin : l10n.defendersWin,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isAttackerWin ? OverlayTokens.attacker : OverlayTokens.defender,
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                win.reason,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: OverlayTokens.muted,
                    ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(l10n.rematch),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: onQuit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(l10n.swapSides),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: onQuit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      child: Text(l10n.quit),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
