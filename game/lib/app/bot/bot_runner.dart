import 'dart:async';

import '../../core/entities.dart';
import '../../core/pathing.dart';
import '../../core/vision_system.dart';
import '../game_controller.dart';
import 'basic_bot.dart';

class BotRunner {
  BotRunner({
    required GameController controller,
    required TeamId botTeam,
    BasicBot? bot,
    Duration delay = const Duration(milliseconds: 450),
  })  : _controller = controller,
        _botTeam = botTeam,
        _bot = bot ?? const BasicBot(),
        _delay = delay {
    _controller.addListener(_handleState);
    _handleState();
  }

  final GameController _controller;
  final TeamId _botTeam;
  final BasicBot _bot;
  final Duration _delay;
  Timer? _timer;
  bool _disposed = false;
  bool _busy = false;
  bool _canAct = true;

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _controller.removeListener(_handleState);
  }

  void _handleState() {
    if (_disposed || _busy) return;

    final state = _controller.state;
    if (state.phase != 'Playing' || _controller.winCondition != null) {
      return;
    }

    if (state.turnTeam != _botTeam) {
      _canAct = true;
      return;
    }

    if (!_canAct) return;

    _canAct = false;
    _busy = true;
    _timer?.cancel();
    _timer = Timer(_delay, _runTurn);
  }

  void _runTurn() {
    if (_disposed) return;

    final state = _controller.state;
    if (state.phase != 'Playing' || state.turnTeam != _botTeam) {
      _busy = false;
      return;
    }

    final action = _bot.decideAction(
      state: state,
      team: _botTeam,
      pathing: _controller.pathing,
      visionSystem: _controller.visionSystem,
    );

    if (action == null) {
      _controller.passTurn();
      _busy = false;
      return;
    }

    switch (action.type) {
      case BotActionType.defuse:
        _controller.selectUnit(action.unitId);
        if (_controller.canDefuse) {
          _controller.defuseSpike();
        } else {
          _controller.passTurn();
        }
        break;
      case BotActionType.move:
        if (action.targetTileId == null) {
          _controller.passTurn();
          break;
        }
        _controller.selectUnit(action.unitId);
        if (_controller.highlightedTiles.contains(action.targetTileId)) {
          _controller.moveUnit(action.targetTileId!);
        } else {
          _controller.passTurn();
        }
        break;
      case BotActionType.pass:
        _controller.passTurn();
        break;
    }

    _busy = false;
  }
}
