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
  String get round => 'ROUND';

  @override
  String get attackerSetup => 'ATTACKER SETUP';

  @override
  String get defenderSetup => 'DEFENDER SETUP';

  @override
  String get spikeSelect => 'SPIKE SELECT';

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
}
