import 'package:flutter/material.dart';

import '../screens/game_screen.dart';
import '../screens/title_screen.dart';

void showGameSettingsSheet(BuildContext context) {
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1A2126),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'ゲームをやめますか？',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final navigator = Navigator.of(dialogContext, rootNavigator: true);
              navigator.pop();
              _goToTitle(navigator);
            },
            child: const Text('ゲームをやめる', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

void _goToTitle(NavigatorState navigator) {
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => TitleScreen(
        onStartGame: () {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const GameScreen()),
          );
        },
      ),
    ),
    (route) => false,
  );
}
