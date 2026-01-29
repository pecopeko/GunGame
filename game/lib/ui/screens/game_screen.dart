import 'package:flutter/material.dart';

import '../../app/bot/bot_runner.dart';
import '../../app/game_controller.dart';
import '../../core/entities.dart';
import '../../core/game_mode.dart';
import '../widgets/game_board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.mode});

  final GameMode mode;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController controller;
  BotRunner? _botRunner;

  @override
  void initState() {
    super.initState();
    controller = GameController(state: GameState.initial());
    if (widget.mode == GameMode.bot) {
      controller.setViewTeam(TeamId.attacker);
      _botRunner = BotRunner(
        controller: controller,
        botTeam: TeamId.defender,
      );
    }
    _initGame();
  }

  Future<void> _initGame() async {
    await controller.initializeGame();
    if (mounted) {
      setState(() {});
    }
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
          return GameBoardWidget(controller: controller);
        },
      ),
    );
  }
}
