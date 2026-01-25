import '../../core/entities.dart';

class BasicBot {
  const BasicBot();

  ActionType pickAction(GameState state) {
    // TODO: choose a legal action for the active unit.
    return ActionType.pass;
  }
}
