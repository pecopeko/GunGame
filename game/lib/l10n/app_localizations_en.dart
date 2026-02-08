// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TACTICAL';

  @override
  String get appSubtitle => 'SITES';

  @override
  String get appTagline => 'TURN CARD OPS';

  @override
  String get appFooter => '5v5 TACTICAL STRATEGY';

  @override
  String get startGame => 'START GAME';

  @override
  String get selectMode => 'SELECT MODE';

  @override
  String get selectModeSubtitle => 'Choose your battle ground';

  @override
  String get modeOnline => 'ONLINE MATCH';

  @override
  String get modeOnlineSubtitle => 'Compete against real players';

  @override
  String get modeBot => 'BOT MATCH';

  @override
  String get modeBotSubtitle => 'Practice with tactical AI';

  @override
  String get modeLocal => 'LOCAL 1V1';

  @override
  String get modeLocalSubtitle => 'Pass & play on one device';

  @override
  String get cancel => 'CANCEL';

  @override
  String get menu => 'Menu';

  @override
  String get quitGame => 'Quit Game';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get back => 'Back';

  @override
  String get settings => 'Settings';

  @override
  String get round => 'ROUND';

  @override
  String get attackerSetup => 'ATTACKER SETUP';

  @override
  String get defenderSetup => 'DEFENDER SETUP';

  @override
  String get spikeSelect => 'SPIKE SELECT';

  @override
  String get phasePlaying => 'PLAYING';

  @override
  String get phaseGameOver => 'GAME OVER';

  @override
  String get phaseUnknown => 'UNKNOWN';

  @override
  String get botDeciding => 'BOT DECIDING...';

  @override
  String get attacker => 'ATTACKER';

  @override
  String get defender => 'DEFENDER';

  @override
  String get attackerTurn => 'ATTACKER TURN';

  @override
  String get defenderTurn => 'DEFENDER TURN';

  @override
  String get yourTurn => 'YOUR TURN';

  @override
  String attackerAliveBadge(int count) {
    return 'A $count';
  }

  @override
  String defenderAliveBadge(int count) {
    return 'D $count';
  }

  @override
  String get botPlacing => 'Bot is deciding placement';

  @override
  String get skillMode => 'SKILL MODE';

  @override
  String get attackMode => 'ATTACK MODE';

  @override
  String get action => 'ACTION';

  @override
  String get skillModeHint => 'Tap an orange tile to use skill.';

  @override
  String get attackModeHint => 'Tap an enemy with red ring to attack.';

  @override
  String get actionHint => 'Select a unit, then choose a command.';

  @override
  String get victory => 'VICTORY';

  @override
  String get defeat => 'DEFEAT';

  @override
  String get selectSpikeCarrier => 'SELECT SPIKE CARRIER';

  @override
  String get selectSpikeCarrierHint => 'Tap an attacker to assign the spike.';

  @override
  String currentCarrier(String roleName) {
    return 'Carrier: $roleName';
  }

  @override
  String get confirmCarrier => 'CONFIRM CARRIER';

  @override
  String setupTitle(String teamLabel) {
    return '$teamLabel SETUP';
  }

  @override
  String get undoLastPlacement => 'Undo last placement';

  @override
  String placedCount(int placed, int max) {
    return 'Placed: $placed / $max';
  }

  @override
  String get teamFullHint => 'Team Full. Remove units to change composition.';

  @override
  String get confirmPlacement => 'CONFIRM PLACEMENT';

  @override
  String get roleEntry => 'ENTRY';

  @override
  String get roleRecon => 'RECON';

  @override
  String get roleSmoke => 'SMOKE';

  @override
  String get roleSentinel => 'SENTINEL';

  @override
  String get move => 'MOVE';

  @override
  String get tiles => 'TILES';

  @override
  String get skill1 => 'SKILL 01';

  @override
  String get skill2 => 'SKILL 02';

  @override
  String get plant => 'PLANT';

  @override
  String get onSite => 'ON SITE';

  @override
  String get defuse => 'DEFUSE';

  @override
  String get na => 'N/A';

  @override
  String get attackersWin => 'ATTACKERS WIN';

  @override
  String get defendersWin => 'DEFENDERS WIN';

  @override
  String get rematch => 'REMATCH';

  @override
  String get quit => 'QUIT';

  @override
  String get swapSides => 'SWAP SIDES';

  @override
  String get sideSwapTitle => 'SWITCHING SIDES';

  @override
  String get sideSwapSubtitle => 'Preparing next round';

  @override
  String sideSwapRoleLabel(String role) {
    return 'You are $role';
  }

  @override
  String get timeoutWin => 'Opponent timed out, you win.';

  @override
  String get timeoutLose => 'You timed out.';

  @override
  String get matchFinished => 'Match finished';

  @override
  String get bothTeamsEliminated => 'Both teams eliminated';

  @override
  String get attackersEliminated => 'Attackers eliminated';

  @override
  String get defendersEliminated => 'Defenders eliminated';

  @override
  String get ready => 'READY';

  @override
  String get spike => 'SPIKE';

  @override
  String get spikeSecured => 'SECURED';

  @override
  String get spikeCarried => 'CARRIED';

  @override
  String get spikeDropped => 'DROPPED';

  @override
  String get spikePlanted => 'PLANTED';

  @override
  String get spikeDefused => 'DEFUSED';

  @override
  String get spikeExploded => 'EXPLODED';

  @override
  String detonateIn(int turns) {
    return 'DETONATE IN $turns';
  }

  @override
  String get seekSite => 'SEEK SITE';

  @override
  String get recover => 'RECOVER';

  @override
  String get roundEnd => 'ROUND END';

  @override
  String get notSet => 'NOT SET';

  @override
  String get debugHudTitle => 'DEBUG HUD';

  @override
  String debugPhaseLabel(String phase) {
    return 'Phase: $phase';
  }

  @override
  String debugTurnLabel(String team) {
    return 'Turn: $team';
  }

  @override
  String debugUnitsLabel(int count) {
    return 'Units: $count';
  }

  @override
  String debugLogLabel(int count) {
    return 'Log: $count';
  }

  @override
  String debugSpikeLabel(String state) {
    return 'Spike: $state';
  }

  @override
  String get fieldIntelTitle => 'FIELD INTEL';

  @override
  String get noUnitSelected => 'No unit selected';

  @override
  String losClearToZone(String zone) {
    return 'LoS: clear to $zone corridor';
  }

  @override
  String smokeTurnsRemaining(int turns) {
    return 'Smoke: $turns turns remaining';
  }

  @override
  String zoneTileInfo(String zone, String tile) {
    return 'Zone: $zone / Tile $tile';
  }

  @override
  String get zoneMid => 'Mid';

  @override
  String get sampleTileId => 'r1c2';

  @override
  String get spikeNotDeployed => 'Spike not deployed';

  @override
  String get spikeBeingCarried => 'Spike being carried';

  @override
  String get spikeDroppedStatus => 'Spike dropped';

  @override
  String spikePlantedCountdown(int turns) {
    return 'Spike planted! $turns turns left';
  }

  @override
  String defusingProgress(int progress) {
    return 'Defusing... ($progress/2)';
  }

  @override
  String get spikeDefusedStatus => 'Spike defused';

  @override
  String get spikeExplodedStatus => 'Spike exploded';

  @override
  String get spikeDefusedWin => 'Spike defused!';

  @override
  String get spikeExplodedWin => 'Spike exploded!';

  @override
  String get feedbackTitle => 'Tell us your\nthoughts';

  @override
  String get feedbackSubtitle =>
      'If you have any concerns or suggestions, please let us know.';

  @override
  String get feedbackPlaceholder =>
      'e.g. I want to see the remaining time of the smoke on the HUD...';

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackSent => 'Sent Successfully';

  @override
  String get feedbackThanks =>
      'Thank you for your feedback!\nWe will review it shortly.';

  @override
  String get feedbackReturnToGame => 'Return to Game';

  @override
  String get feedbackChipLabel => 'FEEDBACK';

  @override
  String feedbackError(String error) {
    return 'Failed to send: $error';
  }

  @override
  String get feedbackEmptyError => 'Please enter your message';

  @override
  String get snsContactInfo => 'You can also contact us via SNS!';

  @override
  String snsLoadError(String error) {
    return 'Failed to load SNS: $error';
  }

  @override
  String urlLaunchError(String url) {
    return 'Could not launch $url';
  }

  @override
  String get onlineProfileTitle => 'ONLINE PROFILE';

  @override
  String get onlineMatchTitle => 'ONLINE MATCH';

  @override
  String get onlineUsernameLabel => 'Username (max 12)';

  @override
  String get onlineUsernameSave => 'Save and enter lobby';

  @override
  String get onlineUsernameRequiredError => 'Please enter a username';

  @override
  String get onlineUsernameTooLongError =>
      'Please keep it within 12 characters';

  @override
  String get onlineUsernameTakenError => 'That name is unavailable';

  @override
  String get onlineProfileLoading => 'Checking player profile...';

  @override
  String onlineProfileLoadError(String error) {
    return 'Failed to load profile: $error';
  }

  @override
  String get onlineRegistering => 'Registering...';

  @override
  String get onlineRegisterSuccess => 'Registration complete';

  @override
  String onlineRegisterError(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get onlineMatchCodeRequiredError => 'Please enter a match code';

  @override
  String get onlineNeedProfileError => 'Register a username first';

  @override
  String get onlineConnecting => 'Connecting...';

  @override
  String get onlineConnected => 'Connected';

  @override
  String get onlineConnectTimeout => 'Connection timed out';

  @override
  String onlineConnectFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get onlineReplayLoading => 'Loading replay...';

  @override
  String get onlineReplayUnavailable => 'Replay could not be loaded';

  @override
  String get onlineReplayActive => 'Replay mode (offline)';

  @override
  String onlineReplayFailed(String error) {
    return 'Replay load failed: $error';
  }

  @override
  String get onlineInitLoading => 'Initializing...';

  @override
  String get onlineReplayMode => 'Replay mode';

  @override
  String get onlineExit => 'Exit';

  @override
  String get onlineMatchTypeCode => 'Code Match';

  @override
  String get onlineMatchTypeRandom => 'Random Match';

  @override
  String get onlineHost => 'Host';

  @override
  String get onlineJoin => 'Join';

  @override
  String get onlineTeamLabel => 'Team';

  @override
  String get onlineMatchCodeLabel => 'Match code';

  @override
  String get onlineAutoCodeHint => 'Code will be generated automatically';

  @override
  String get onlineCreateRoom => 'Create room';

  @override
  String get onlineJoinRoom => 'Join';

  @override
  String get onlineRandomStart => 'Find match';

  @override
  String get onlineStatusConnected => 'Connected';

  @override
  String get onlineStatusDisconnected => 'Disconnected';

  @override
  String get onlineOpponentWaiting => 'Waiting';

  @override
  String get onlineOpponentPlacing => 'Opponent is placing';

  @override
  String get onlineOpponentSelectingSpike => 'Opponent selecting spike';

  @override
  String get onlineMatchingTitle => 'MATCHING';

  @override
  String onlineMatchingElapsed(int seconds) {
    return 'Elapsed ${seconds}s';
  }

  @override
  String get onlineMatchFoundTitle => 'MATCH FOUND';

  @override
  String get onlineTotalRecordLabel => 'Total record';

  @override
  String get onlineMatchEndedReplayNotice =>
      'Match ended - replay available for 1 day';

  @override
  String get onlineReplayButton => 'Replay latest';

  @override
  String get onlineYouLabel => 'YOU';

  @override
  String get versusShort => 'VS';

  @override
  String get siteALabel => 'A';

  @override
  String get siteBLabel => 'B';

  @override
  String onlineUsernameFormat(String name) {
    return 'Username: $name';
  }

  @override
  String onlineRecordFormat(int wins, int losses) {
    return 'Record: ${wins}W - ${losses}L';
  }

  @override
  String onlineRecordShortFormat(int wins, int losses) {
    return '${wins}W-${losses}L';
  }

  @override
  String onlineScoreFormat(int localWins, int oppWins, int target) {
    return '$localWins-$oppWins / First to $target';
  }

  @override
  String onlineCodeLabel(String code) {
    return 'Code: $code';
  }
}
