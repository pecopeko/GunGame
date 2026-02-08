// 初期配置用のコマンドバーを表示する。
import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../app/game_controller.dart';
import '../../core/entities.dart';

class PlacementBarWidget extends StatelessWidget {
  const PlacementBarWidget({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;
    final isSpikeSelect = state.phase == 'SelectSpikeCarrier';
    final isAttackerSetup = state.phase == 'SetupAttacker';
    final currentTeam = isAttackerSetup ? TeamId.attacker : TeamId.defender;
    final localTeam = controller.onlineLocalTeam;
    if (localTeam != null) {
      if (isSpikeSelect && localTeam != TeamId.attacker) {
        return const SizedBox.shrink();
      }
      if (state.phase == 'SetupAttacker' && localTeam != TeamId.attacker) {
        return const SizedBox.shrink();
      }
      if (state.phase == 'SetupDefender' && localTeam != TeamId.defender) {
        return const SizedBox.shrink();
      }
    }

    final effectiveTeam = localTeam ?? currentTeam;
    final placedCount = state.units.where((u) => u.team == currentTeam).length;
    final maxUnits = 5;

    final roles = [Role.entry, Role.recon, Role.smoke, Role.sentinel];

    if (localTeam == null &&
        (controller.isBotOpponentActive || controller.isBotSetupPhase)) {
      return const SizedBox.shrink();
    }

    if (isSpikeSelect) {
      final selected = controller.selectedUnit;
      final canConfirm = controller.canConfirmSpikeCarrier;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.selectSpikeCarrier,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selected == null
                  ? l10n.selectSpikeCarrierHint
                  : l10n.currentCarrier(_getRoleName(l10n, selected.card.role)),
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canConfirm ? controller.confirmSpikeCarrier : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE1B563),
                  disabledBackgroundColor: Colors.grey.shade800,
                ),
                child: Text(
                  l10n.confirmCarrier,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.setupTitle(
                  effectiveTeam == TeamId.attacker
                      ? l10n.attacker
                      : l10n.defender,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.white70),
                    onPressed: placedCount > 0
                        ? controller.undoLastPlacement
                        : null,
                    tooltip: l10n.undoLastPlacement,
                  ),
                  Text(
                    l10n.placedCount(placedCount, maxUnits),
                    style: TextStyle(
                      color: placedCount == maxUnits
                          ? Colors.greenAccent
                          : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (placedCount < maxUnits)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: roles.map((role) {
                  final isSelected = controller.selectedRoleToSpawn == role;
                  return GestureDetector(
                    onTap: () => controller.selectRoleToSpawn(role),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.yellow.withAlpha(50)
                            : Colors.black26,
                        border: Border.all(
                          color: isSelected ? Colors.yellow : Colors.white24,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getRoleIcon(role),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getRoleName(l10n, role),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                l10n.teamFullHint,
                style: const TextStyle(color: Colors.orangeAccent),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isPlacementComplete
                  ? controller.confirmPlacement
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveTeam == TeamId.attacker
                    ? const Color(0xFFE57373)
                    : const Color(0xFF4FC3F7),
                disabledBackgroundColor: Colors.grey.shade800,
              ),
              child: Text(
                l10n.confirmPlacement,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleIcon(Role role) {
    switch (role) {
      case Role.entry:
        return '⚔️';
      case Role.recon:
        return '👁️';
      case Role.smoke:
        return '💨';
      case Role.sentinel:
        return '🛡️';
    }
  }

  String _getRoleName(AppLocalizations l10n, Role role) {
    switch (role) {
      case Role.entry:
        return l10n.roleEntry;
      case Role.recon:
        return l10n.roleRecon;
      case Role.smoke:
        return l10n.roleSmoke;
      case Role.sentinel:
        return l10n.roleSentinel;
    }
  }
}
