import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../screens/feedback_screen.dart';
import '../screens/game_screen.dart';
import '../screens/title_screen.dart';

void showGameSettingsSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: const Color(0xFF1A2126),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.menu,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              // ゲームをやめる
              _MenuButton(
                label: l10n.quitGame,
                icon: Icons.exit_to_app,
                color: const Color(0xFFE57373),
                onTap: () {
                  final navigator = Navigator.of(dialogContext, rootNavigator: true);
                  navigator.pop();
                  _goToTitle(navigator);
                },
              ),
              const SizedBox(height: 16),
              // 要望をする
              _MenuButton(
                label: l10n.sendFeedback,
                icon: Icons.feedback_outlined,
                color: const Color(0xFF4FC3F7),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).push(_smoothRoute(const FeedbackScreen()));
                },
              ),
              const SizedBox(height: 16),
              // 戻る
              _MenuButton(
                label: l10n.back,
                icon: Icons.arrow_back,
                color: Colors.white70,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Route<void> _smoothRoute(Widget child) {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.3), width: 1),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _goToTitle(NavigatorState navigator) {
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => TitleScreen(
        onSelectMode: (mode) {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => GameScreen(mode: mode)),
          );
        },
      ),
    ),
    (route) => false,
  );
}
