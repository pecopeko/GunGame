import 'package:flutter/material.dart';

import '../../app/game_controller.dart';
import '../../core/entities.dart';
import 'overlay_widgets.dart';

class ActionBarOverlay extends StatelessWidget {
  const ActionBarOverlay({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    // fast check for game over from controller if needed, 
    // though usually handled by parent or separate overlay.
    // We'll keep the logic here for now.
    
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
                          ? 'SKILL MODE'
                          : (isAttackMode ? 'ATTACK MODE' : 'ACTION'),
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
                            ? 'Tap an orange tile to use skill.'
                            : (isAttackMode 
                                ? 'Tap an enemy with red ring to attack.'
                                : 'Select a unit, then choose a command.'),
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
                    label: 'MOVE',
                    detail: hasSelection 
                        ? '${controller.selectedUnit?.card.moveRange ?? 2} TILES'
                        : '- TILES',
                    accent: OverlayTokens.accent,
                    enabled: hasSelection && !isAttackMode,
                    // If in skill mode, tapping MOVE resets to move mode.
                    // If already in move mode, do nothing or re-highlight.
                    onTap: hasSelection
                        ? () => controller.resetActionModes()
                        : null,
                  ),

                  TacticalActionTile(
                    icon: Icons.blur_on,
                    label: controller.selectedUnit?.card.skill1.name ?? 'SKILL 01',
                    detail: hasSelection ? controller.getSkillStatus(SkillSlot.skill1) : 'N/A',
                    accent: OverlayTokens.accentWarm,
                    enabled: hasSelection && controller.canUseSkill(SkillSlot.skill1),
                    highlighted: controller.isSkillMode && controller.activeSkillSlot == SkillSlot.skill1,
                    onTap: hasSelection && controller.canUseSkill(SkillSlot.skill1)
                        ? () {
                            if (controller.isSkillMode && controller.activeSkillSlot == SkillSlot.skill1) {
                              controller.resetActionModes();
                            } else {
                              controller.enterSkillMode(SkillSlot.skill1);
                            }
                          }
                        : null,
                  ),
                  TacticalActionTile(
                    icon: Icons.blur_circular,
                    label: controller.selectedUnit?.card.skill2.name ?? 'SKILL 02',
                    detail: hasSelection ? controller.getSkillStatus(SkillSlot.skill2) : 'N/A',
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
                    label: 'PLANT',
                    detail: controller.canPlant ? 'ON SITE' : 'N/A',
                    accent: OverlayTokens.attacker,
                    enabled: controller.canPlant,
                    onTap: controller.canPlant ? controller.plantSpike : null,
                  ),
                  TacticalActionTile(
                    icon: Icons.shield_outlined,
                    label: 'DEFUSE',
                    detail: controller.canDefuse 
                        ? '${(controller.state.spike.defuseProgress ?? 0) + 1}/2'
                        : 'N/A',
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
    final win = controller.winCondition!;
    final isAttackerWin = win.winner == TeamId.attacker;

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
                isAttackerWin ? 'ATTACKERS WIN' : 'DEFENDERS WIN',
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
            ],
          ),
        ),
      ),
    );
  }
}
