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
    if (state.phase == 'SelectSpikeCarrier' && _botTeam == TeamId.attacker) {
      _handleSpikeSelection(state);
      return;
    }
    if (state.phase.startsWith('Setup')) {
      _handleSetup(state);
      return;
    }
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

  void _handleSpikeSelection(GameState state) {
    if (!_canAct || _busy) return;
    _canAct = false;
    _busy = true;
    _timer?.cancel();
    _timer = Timer(_delay, _runSpikeSelection);
  }

  void _runSpikeSelection() {
    if (_disposed) return;
    final state = _controller.state;
    if (state.phase != 'SelectSpikeCarrier') {
      _busy = false;
      return;
    }

    final attacker = state.units.firstWhere(
      (u) => u.team == TeamId.attacker && u.alive,
      orElse: () => state.units.first,
    );
    _controller.onUnitTap(attacker.unitId);
    _controller.confirmSpikeCarrier();
    _busy = false;
    _canAct = true;
    _handleState();
  }

  void _handleSetup(GameState state) {
    final isBotSetupPhase = (_botTeam == TeamId.attacker && state.phase == 'SetupAttacker') ||
        (_botTeam == TeamId.defender && state.phase == 'SetupDefender');
    if (!isBotSetupPhase) {
      _canAct = true;
      return;
    }

    if (!_canAct || _busy) return;
    _canAct = false;
    _busy = true;
    _timer?.cancel();
    _timer = Timer(_delay, _runSetup);
  }

  void _runSetup() {
    if (_disposed) return;

    final state = _controller.state;
    if (state.phase != 'SetupAttacker' && state.phase != 'SetupDefender') {
      _busy = false;
      _canAct = true;
      return;
    }

    final teamUnits = state.units.where((u) => u.team == _botTeam).toList();
    if (teamUnits.length >= 5) {
      _controller.confirmPlacement();
      _busy = false;
      _canAct = true;
      _handleState();
      return;
    }

    final zones = _controller.getPlacementZones();
    final occupied = state.units.map((u) => u.posTileId).toSet();
    final available = zones.where((id) => !occupied.contains(id)).toList();
    if (available.isEmpty) {
      _busy = false;
      _canAct = true;
      return;
    }

    final role = _pickRole(teamUnits);
    _controller.selectRoleToSpawn(role);
    _controller.spawnUnit(available.first);
    _busy = false;
    _canAct = true;
    _handleSetup(_controller.state);
  }

  Role _pickRole(List<UnitState> units) {
    final counts = <Role, int>{
      Role.entry: 0,
      Role.recon: 0,
      Role.smoke: 0,
      Role.sentinel: 0,
    };
    for (final unit in units) {
      counts[unit.card.role] = (counts[unit.card.role] ?? 0) + 1;
    }

    Role best = Role.entry;
    var bestCount = 9999;
    counts.forEach((role, count) {
      if (count < bestCount) {
        best = role;
        bestCount = count;
      }
    });
    return best;
  }
}
