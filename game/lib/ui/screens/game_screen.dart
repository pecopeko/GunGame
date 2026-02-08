// 対戦中のメインゲーム画面を構成する。
import 'package:flutter/material.dart';

import '../../app/bot/bot_runner.dart';
import '../../app/game_controller.dart';
import '../../core/entities.dart';
import '../../core/game_mode.dart';
import 'title_screen.dart';
import '../widgets/game_board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.mode});

  final GameMode mode;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;
  BotRunner? _botRunner;
  TeamId _botTeam = TeamId.defender;

  @override
  void initState() {
    super.initState();
    _startMatch();
  }

  Future<void> _initGame() async {
    await controller.initializeGame();
    if (mounted) {
      setState(() {});
    }
  }

  void _startMatch() {
    controller = GameController(state: GameState.initial());
    _botRunner?.dispose();
    _botRunner = null;

    if (widget.mode == GameMode.bot) {
      final playerTeam =
          _botTeam == TeamId.attacker ? TeamId.defender : TeamId.attacker;
      controller.setViewTeam(playerTeam);
      _botRunner = BotRunner(
        controller: controller,
        botTeam: _botTeam,
      );
    }
    _initGame();
  }

  void _restartLocalMatch() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GameScreen(mode: widget.mode)),
    );
  }

  void _quitToTitle() {
    final navigator = Navigator.of(context);
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

  void _swapBotSides() {
    _botTeam = _botTeam == TeamId.attacker ? TeamId.defender : TeamId.attacker;
    _startMatch();
  }

  @override
  void dispose() {
    _botRunner?.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return GameBoardWidget(
            controller: controller,
            mode: widget.mode,
            onRematch: widget.mode == GameMode.local ? _restartLocalMatch : null,
            onQuit: widget.mode == GameMode.local || widget.mode == GameMode.bot
                ? _quitToTitle
                : null,
            onSwapSides: widget.mode == GameMode.bot ? _swapBotSides : null,
          );
        },
      ),
    );
  }
}
