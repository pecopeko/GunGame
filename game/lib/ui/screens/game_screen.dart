import 'package:flutter/material.dart';

import '../../app/game_controller.dart';
import '../../core/entities.dart';
import '../widgets/game_board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController(state: GameState.initial());
    _initGame();
  }

  Future<void> _initGame() async {
    await controller.initializeGame();
    if (mounted) {
      setState(() {});
    }
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
