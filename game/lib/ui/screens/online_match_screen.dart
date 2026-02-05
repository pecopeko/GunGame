import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

import '../../app/game_controller.dart';
import '../../app/online/online_identity_store.dart';
import '../../app/online/online_match_coordinator.dart';
import '../../app/online/online_match_models.dart';
import '../../app/online/online_match_service.dart';
import '../../app/online/online_profile_api.dart';
import '../../core/entities.dart';
import '../../core/game_mode.dart';
import '../widgets/game_board_widget.dart';
import 'game_screen.dart';
import 'title_screen.dart';
import 'online_match_views.dart';

enum _OnlineStage { identity, lobby, playing }

class OnlineMatchScreen extends StatefulWidget {
  const OnlineMatchScreen({super.key});

  @override
  State<OnlineMatchScreen> createState() => _OnlineMatchScreenState();
}

class _OnlineMatchScreenState extends State<OnlineMatchScreen> {
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();
  final OnlineIdentityStore _identityStore = const OnlineIdentityStore();
  final OnlineProfileApi _profileApi = OnlineProfileApi();
  bool _hosting = true;
  OnlineMatchType _matchType = OnlineMatchType.code;
  bool _busy = false;
  String? _status;
  String? _error;
  OnlineProfile? _profile;
  _OnlineStage _stage = _OnlineStage.identity;
  int _startToken = 0;

  GameController? _controller;
  OnlineMatchCoordinator? _coordinator;
  OnlineMatchService? _service;
  bool _didBootstrap = false;
  Timer? _autoExitTimer;
  bool _autoExitScheduled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBootstrap) return;
    _didBootstrap = true;
    _bootstrapIdentity();
  }

  Future<void> _bootstrapIdentity() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _status = l10n.onlineProfileLoading;
    });
    try {
      final storedId = await _identityStore.loadPlayerId();
      OnlineProfile? profile;
      if (storedId != null) {
        profile = await _profileApi.fetchProfile(storedId);
      }
      if (profile != null) {
        _usernameCtrl.text = profile.username;
        setState(() {
          _profile = profile;
          _stage = _OnlineStage.lobby;
          _status = null;
        });
      } else {
        final cachedName = await _identityStore.loadUsername();
        if (cachedName != null) {
          _usernameCtrl.text = cachedName;
        }
        setState(() {
          _stage = _OnlineStage.identity;
          _status = null;
        });
      }
    } catch (e) {
      setState(() {
        _stage = _OnlineStage.identity;
        _error = l10n.onlineProfileLoadError(e.toString());
      });
    }
  }

  Future<void> _registerUsername() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _usernameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.onlineUsernameRequiredError);
      return;
    }
    if (name.length > 12) {
      setState(() => _error = l10n.onlineUsernameTooLongError);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _status = l10n.onlineRegistering;
    });
    try {
      final profile = await _profileApi.createProfile(username: name);
      await _identityStore.saveIdentity(
        playerId: profile.id,
        username: profile.username,
      );
      setState(() {
        _profile = profile;
        _stage = _OnlineStage.lobby;
        _status = l10n.onlineRegisterSuccess;
      });
    } on UsernameTakenException {
      setState(() {
        _error = l10n.onlineUsernameTakenError;
      });
    } catch (e) {
      setState(() {
        _error = l10n.onlineRegisterError(e.toString());
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  void dispose() {
    _autoExitTimer?.cancel();
    _codeCtrl.dispose();
    _usernameCtrl.dispose();
    _coordinator?.dispose();
    _service?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startHost() async {
    final code = _randomCode();
    await _startMatch(code: code, isHost: true);
  }

  Future<void> _startRandom() async {
    await _startMatch(code: null, isHost: false, isRandomMatch: true);
  }

  Future<void> _startJoin() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = l10n.onlineMatchCodeRequiredError);
      return;
    }
    await _startMatch(code: code, isHost: false);
  }

  Future<void> _startMatch({
    required String? code,
    required bool isHost,
    bool isRandomMatch = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (_profile == null) {
      setState(() => _error = l10n.onlineNeedProfileError);
      return;
    }
    _autoExitTimer?.cancel();
    _autoExitScheduled = false;
    await _leaveActiveMatch();
    final currentToken = ++_startToken;
    setState(() {
      _busy = true;
      _status = l10n.onlineConnecting;
      _error = null;
    });

    _coordinator?.dispose();
    _service?.dispose();
    _controller?.dispose();

    final controller = GameController(state: GameState.initial());
    try {
      await controller.initializeGame();
    } catch (e) {
      controller.dispose();
      if (!mounted || currentToken != _startToken) return;
      setState(() {
        _error = l10n.onlineConnectFailed(e.toString());
        _busy = false;
        _status = null;
      });
      return;
    }

    final localTeam = isHost ? TeamId.attacker : TeamId.defender;

    final service = OnlineMatchService(
      matchCode: code,
      localProfile: _profile!,
      isHost: isHost,
      isRandomMatch: isRandomMatch,
    );
    final coordinator = OnlineMatchCoordinator(
      controller: controller,
      service: service,
      player: OnlinePlayer(
        playerId: _profile!.id,
        team: localTeam,
        username: _profile!.username,
        wins: _profile!.wins,
        losses: _profile!.losses,
      ),
      initialTeam: localTeam,
      isHost: isHost,
    );

    try {
      await coordinator
          .start(sendInitialSnapshot: isHost)
          .timeout(const Duration(seconds: 12));
      if (!mounted || currentToken != _startToken) {
        coordinator.dispose();
        service.dispose();
        controller.dispose();
        unawaited(_leaveActiveMatch());
        return;
      }
      setState(() {
        _controller = controller;
        _coordinator = coordinator;
        _service = service;
        _stage = _OnlineStage.playing;
        _busy = false;
        _status = l10n.onlineConnected;
      });
    } on TimeoutException {
      coordinator.dispose();
      service.dispose();
      controller.dispose();
      if (!mounted || currentToken != _startToken) return;
      unawaited(_leaveActiveMatch());
      setState(() {
        _error = l10n.onlineConnectTimeout;
        _busy = false;
        _status = null;
      });
    } catch (e) {
      coordinator.dispose();
      service.dispose();
      controller.dispose();
      if (!mounted || currentToken != _startToken) return;
      unawaited(_leaveActiveMatch());
      setState(() {
        _error = l10n.onlineConnectFailed(e.toString());
        _busy = false;
        _status = null;
      });
    }
  }

  void _cancelMatchSearch() {
    _startToken++;
    _coordinator?.dispose();
    _service?.dispose();
    _controller?.dispose();
    _coordinator = null;
    _service = null;
    _controller = null;
    if (mounted) {
      setState(() {
        _busy = false;
        _status = null;
        _error = null;
      });
    }
    _quitToTitle();
  }

  Future<void> _leaveActiveMatch() async {
    final profile = _profile;
    if (profile == null) return;
    try {
      await _profileApi.leaveActiveMatch(profileId: profile.id);
    } catch (_) {}
  }

  void _quitToTitle() {
    unawaited(_leaveActiveMatch());
    final navigator = Navigator.of(context);
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => TitleScreen(
          onSelectMode: (mode) {
            navigator.pushReplacement(
              MaterialPageRoute(
                builder: (_) => mode == GameMode.online
                    ? const OnlineMatchScreen()
                    : GameScreen(mode: mode),
              ),
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
        child: switch (_stage) {
          _OnlineStage.identity => OnlineIdentityStep(
            usernameCtrl: _usernameCtrl,
            busy: _busy,
            status: _status,
            error: _error,
            onSubmit: _registerUsername,
            onBack: _quitToTitle,
          ),
          _OnlineStage.lobby =>
            _profile == null
                ? OnlineIdentityStep(
                    usernameCtrl: _usernameCtrl,
                    busy: _busy,
                    status: _status,
                    error: _error,
                    onSubmit: _registerUsername,
                    onBack: _quitToTitle,
                  )
                : OnlineLobbyStep(
                    profile: _profile!,
                    matchType: _matchType,
                    hosting: _hosting,
                    busy: _busy,
                    status: _status,
                    error: _error,
                    codeCtrl: _codeCtrl,
                    onMatchTypeChanged: (value) {
                      setState(() {
                        _matchType = value;
                      });
                    },
                    onHostingChanged: (v) => setState(() => _hosting = v),
                    onStartHost: _startHost,
                    onStartJoin: _startJoin,
                    onStartRandom: _startRandom,
                    onCancel: _cancelMatchSearch,
                    onBack: _quitToTitle,
                  ),
          _OnlineStage.playing => _buildBoard(context),
        },
      ),
    );
  }

  Future<void> _loadReplaySnapshot() async {
    final l10n = AppLocalizations.of(context)!;
    final service = _service;
    if (service == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _status = l10n.onlineReplayLoading;
    });
    try {
      final state = await service.loadLatestReplay();
      if (state == null) {
        setState(() {
          _error = l10n.onlineReplayUnavailable;
          _busy = false;
          _status = null;
        });
        return;
      }
      _coordinator?.dispose();
      _coordinator = null;
      _service?.dispose();
      _service = null;
      _controller?.dispose();
      final controller = GameController(state: state);
      setState(() {
        _controller = controller;
        _stage = _OnlineStage.playing;
        _busy = false;
        _status = l10n.onlineReplayActive;
      });
    } catch (e) {
      setState(() {
        _error = l10n.onlineReplayFailed(e.toString());
        _busy = false;
        _status = null;
      });
    }
  }

  Widget _buildBoard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = _controller;
    final coordinator = _coordinator;
    if (controller == null) {
      return Center(
        child: Text(
          l10n.onlineInitLoading,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }
    if (coordinator == null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Text(
                  l10n.onlineReplayMode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                if (_status != null)
                  Text(_status!, style: const TextStyle(color: Colors.white70)),
                const Spacer(),
                OutlinedButton(
                  onPressed: _quitToTitle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  child: Text(l10n.onlineExit),
                ),
              ],
            ),
          ),
          Expanded(
            child: GameBoardWidget(
              controller: controller,
              mode: GameMode.local,
              onQuit: _quitToTitle,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: ListenableBuilder(
            listenable: coordinator,
            builder: (context, _) {
              return OnlineMatchHeader(
                match: coordinator.match,
                localProfile: _profile,
                connected: coordinator.connected,
                matchCode: coordinator.match?.matchCode,
                onQuit: _quitToTitle,
                onReplay: _loadReplaySnapshot,
                busy: _busy,
              );
            },
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              _maybeScheduleAutoExit(controller);
              return GameBoardWidget(
                controller: controller,
                mode: GameMode.online,
                onQuit: _quitToTitle,
              );
            },
          ),
        ),
      ],
    );
  }

  void _maybeScheduleAutoExit(GameController controller) {
    if (_autoExitScheduled) return;
    final win = controller.winCondition;
    if (win == null) return;
    if (win.reason != 'timeout' && win.reason != 'abandon') return;
    final localTeam = controller.onlineLocalTeam;
    if (localTeam == null || localTeam == win.winner) return;
    _autoExitScheduled = true;
    _autoExitTimer?.cancel();
    _autoExitTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _quitToTitle();
      }
    });
  }

  String _randomCode({int length = 6}) {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  TeamId _randomTeam() {
    return Random().nextBool() ? TeamId.attacker : TeamId.defender;
  }
}
