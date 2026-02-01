import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/game_controller.dart';
import '../../app/online/online_match_coordinator.dart';
import '../../app/online/online_match_models.dart';
import '../../app/online/online_match_service.dart';
import '../../core/entities.dart';
import '../../core/game_mode.dart';
import '../widgets/game_board_widget.dart';
import 'game_screen.dart';
import 'title_screen.dart';

enum _OnlineStage {
  lobby,
  playing,
}

class OnlineMatchScreen extends StatefulWidget {
  const OnlineMatchScreen({super.key});

  @override
  State<OnlineMatchScreen> createState() => _OnlineMatchScreenState();
}

class _OnlineMatchScreenState extends State<OnlineMatchScreen> {
  final TextEditingController _codeCtrl = TextEditingController();
  TeamId _team = TeamId.attacker;
  bool _hosting = true;
  bool _busy = false;
  String? _status;
  String? _error;
  String? _matchCode;
  String? _playerId;
  _OnlineStage _stage = _OnlineStage.lobby;

  GameController? _controller;
  OnlineMatchCoordinator? _coordinator;
  OnlineMatchService? _service;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _coordinator?.dispose();
    _service?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startHost() async {
    final code = _randomCode();
    await _startMatch(code: code, team: _team, isHost: true);
  }

  Future<void> _startJoin() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'マッチコードを入力してください');
      return;
    }
    await _startMatch(code: code, team: _team, isHost: false);
  }

  Future<void> _startMatch({
    required String code,
    required TeamId team,
    required bool isHost,
  }) async {
    setState(() {
      _busy = true;
      _status = '接続中...';
      _error = null;
    });

    _coordinator?.dispose();
    _service?.dispose();
    _controller?.dispose();

    final playerId = _playerId ?? _randomId();
    _playerId = playerId;

    final controller = GameController(state: GameState.initial());
    controller.setOnlineLocalTeam(team);
    controller.setViewTeam(team);
    await controller.initializeGame();

    final service = OnlineMatchService(matchId: code, playerId: playerId);
    final coordinator = OnlineMatchCoordinator(
      controller: controller,
      service: service,
      player: OnlinePlayer(playerId: playerId, team: team),
      localTeam: team,
      isHost: isHost,
    );

    try {
      await coordinator.start(sendInitialSnapshot: isHost);
      setState(() {
        _controller = controller;
        _coordinator = coordinator;
        _service = service;
        _matchCode = code;
        _stage = _OnlineStage.playing;
        _busy = false;
        _status = '接続完了';
      });
    } catch (e) {
      coordinator.dispose();
      service.dispose();
      controller.dispose();
      setState(() {
        _error = '接続に失敗しました: $e';
        _busy = false;
        _status = null;
      });
    }
  }

  void _quitToTitle() {
    final navigator = Navigator.of(context);
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => TitleScreen(
          onSelectMode: (mode) {
            navigator.pushReplacement(
              MaterialPageRoute(builder: (_) => mode == GameMode.online ? const OnlineMatchScreen() : GameScreen(mode: mode)),
            );
          },
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1215),
      body: SafeArea(
        child: _stage == _OnlineStage.lobby ? _buildLobby(context) : _buildBoard(context),
      ),
    );
  }

  Widget _buildLobby(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ONLINE MATCH',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            ToggleButtons(
              isSelected: [_hosting, !_hosting],
              onPressed: (i) {
                setState(() => _hosting = i == 0);
              },
              color: Colors.white70,
              selectedColor: Colors.black,
              fillColor: const Color(0xFF1BA784),
              borderRadius: BorderRadius.circular(10),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text('ホスト'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text('参加'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('担当チーム', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                DropdownButton<TeamId>(
                  value: _team,
                  dropdownColor: const Color(0xFF1A2126),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) => setState(() => _team = value ?? TeamId.attacker),
                  items: const [
                    DropdownMenuItem(
                      value: TeamId.attacker,
                      child: Text('ATTACKER'),
                    ),
                    DropdownMenuItem(
                      value: TeamId.defender,
                      child: Text('DEFENDER'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_hosting)
              TextField(
                controller: _codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'マッチコード',
                  filled: true,
                  fillColor: Color(0xFF161C21),
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.characters,
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161C21),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text(
                  'コードは自動生成されます',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _busy ? null : (_hosting ? _startHost : _startJoin),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BA784),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_hosting ? '部屋を作成' : '参加する'),
              ),
            ),
            const SizedBox(height: 8),
            if (_status != null)
              Text(
                _status!,
                style: const TextStyle(color: Colors.white70),
              ),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFE57373)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard(BuildContext context) {
    final controller = _controller;
    final coordinator = _coordinator;
    if (controller == null || coordinator == null) {
      return const Center(
        child: Text('初期化中...', style: TextStyle(color: Colors.white70)),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white12),
            ),
          ),
          child: ListenableBuilder(
            listenable: coordinator,
            builder: (context, _) {
              final peers = coordinator.players.where((p) => p.playerId != _playerId).toList();
              return Row(
                children: [
                  Text(
                    'コード: ${_matchCode ?? '-'}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 12),
                  _statusChip(coordinator.connected ? '接続中' : '未接続', coordinator.connected),
                  const Spacer(),
                  if (peers.isNotEmpty)
                    Row(
                      children: peers
                          .map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _statusChip(
                                p.team == TeamId.attacker ? 'ATTACKER接続' : 'DEFENDER接続',
                                true,
                              ),
                            ),
                          )
                          .toList(),
                    )
                  else
                    _statusChip('相手待ち', false),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _quitToTitle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                    ),
                    child: const Text('退出'),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: GameBoardWidget(
            controller: controller,
            mode: GameMode.online,
            onQuit: _quitToTitle,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String text, bool ok) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFF1BA784).withOpacity(0.15) : Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ok ? const Color(0xFF1BA784) : Colors.white30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: ok ? const Color(0xFF1BA784) : Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _randomCode({int length = 6}) {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  String _randomId({int length = 12}) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
