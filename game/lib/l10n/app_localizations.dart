import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TACTICAL'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SITES'**
  String get appSubtitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'TURN CARD OPS'**
  String get appTagline;

  /// No description provided for @appFooter.
  ///
  /// In en, this message translates to:
  /// **'5v5 TACTICAL STRATEGY'**
  String get appFooter;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'START GAME'**
  String get startGame;

  /// No description provided for @selectMode.
  ///
  /// In en, this message translates to:
  /// **'SELECT MODE'**
  String get selectMode;

  /// No description provided for @selectModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your battle ground'**
  String get selectModeSubtitle;

  /// No description provided for @modeOnline.
  ///
  /// In en, this message translates to:
  /// **'ONLINE MATCH'**
  String get modeOnline;

  /// No description provided for @modeOnlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compete against real players'**
  String get modeOnlineSubtitle;

  /// No description provided for @modeBot.
  ///
  /// In en, this message translates to:
  /// **'BOT MATCH'**
  String get modeBot;

  /// No description provided for @modeBotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Practice with tactical AI'**
  String get modeBotSubtitle;

  /// No description provided for @modeLocal.
  ///
  /// In en, this message translates to:
  /// **'LOCAL 1V1'**
  String get modeLocal;

  /// No description provided for @modeLocalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pass & play on one device'**
  String get modeLocalSubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @quitGame.
  ///
  /// In en, this message translates to:
  /// **'Quit Game'**
  String get quitGame;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'ROUND'**
  String get round;

  /// No description provided for @attackerSetup.
  ///
  /// In en, this message translates to:
  /// **'ATTACKER SETUP'**
  String get attackerSetup;

  /// No description provided for @defenderSetup.
  ///
  /// In en, this message translates to:
  /// **'DEFENDER SETUP'**
  String get defenderSetup;

  /// No description provided for @spikeSelect.
  ///
  /// In en, this message translates to:
  /// **'SPIKE SELECT'**
  String get spikeSelect;

  /// No description provided for @botDeciding.
  ///
  /// In en, this message translates to:
  /// **'BOT DECIDING...'**
  String get botDeciding;

  /// No description provided for @attacker.
  ///
  /// In en, this message translates to:
  /// **'ATTACKER'**
  String get attacker;

  /// No description provided for @defender.
  ///
  /// In en, this message translates to:
  /// **'DEFENDER'**
  String get defender;

  /// No description provided for @attackerTurn.
  ///
  /// In en, this message translates to:
  /// **'ATTACKER TURN'**
  String get attackerTurn;

  /// No description provided for @defenderTurn.
  ///
  /// In en, this message translates to:
  /// **'DEFENDER TURN'**
  String get defenderTurn;

  /// No description provided for @botPlacing.
  ///
  /// In en, this message translates to:
  /// **'Bot is deciding placement'**
  String get botPlacing;

  /// No description provided for @skillMode.
  ///
  /// In en, this message translates to:
  /// **'SKILL MODE'**
  String get skillMode;

  /// No description provided for @attackMode.
  ///
  /// In en, this message translates to:
  /// **'ATTACK MODE'**
  String get attackMode;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'ACTION'**
  String get action;

  /// No description provided for @skillModeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an orange tile to use skill.'**
  String get skillModeHint;

  /// No description provided for @attackModeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an enemy with red ring to attack.'**
  String get attackModeHint;

  /// No description provided for @actionHint.
  ///
  /// In en, this message translates to:
  /// **'Select a unit, then choose a command.'**
  String get actionHint;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'MOVE'**
  String get move;

  /// No description provided for @tiles.
  ///
  /// In en, this message translates to:
  /// **'TILES'**
  String get tiles;

  /// No description provided for @skill1.
  ///
  /// In en, this message translates to:
  /// **'SKILL 01'**
  String get skill1;

  /// No description provided for @skill2.
  ///
  /// In en, this message translates to:
  /// **'SKILL 02'**
  String get skill2;

  /// No description provided for @plant.
  ///
  /// In en, this message translates to:
  /// **'PLANT'**
  String get plant;

  /// No description provided for @onSite.
  ///
  /// In en, this message translates to:
  /// **'ON SITE'**
  String get onSite;

  /// No description provided for @defuse.
  ///
  /// In en, this message translates to:
  /// **'DEFUSE'**
  String get defuse;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @attackersWin.
  ///
  /// In en, this message translates to:
  /// **'ATTACKERS WIN'**
  String get attackersWin;

  /// No description provided for @defendersWin.
  ///
  /// In en, this message translates to:
  /// **'DEFENDERS WIN'**
  String get defendersWin;

  /// No description provided for @rematch.
  ///
  /// In en, this message translates to:
  /// **'REMATCH'**
  String get rematch;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'QUIT'**
  String get quit;

  /// No description provided for @swapSides.
  ///
  /// In en, this message translates to:
  /// **'SWAP SIDES'**
  String get swapSides;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get ready;

  /// No description provided for @spike.
  ///
  /// In en, this message translates to:
  /// **'SPIKE'**
  String get spike;

  /// No description provided for @spikeSecured.
  ///
  /// In en, this message translates to:
  /// **'SECURED'**
  String get spikeSecured;

  /// No description provided for @spikeCarried.
  ///
  /// In en, this message translates to:
  /// **'CARRIED'**
  String get spikeCarried;

  /// No description provided for @spikeDropped.
  ///
  /// In en, this message translates to:
  /// **'DROPPED'**
  String get spikeDropped;

  /// No description provided for @spikePlanted.
  ///
  /// In en, this message translates to:
  /// **'PLANTED'**
  String get spikePlanted;

  /// No description provided for @spikeDefused.
  ///
  /// In en, this message translates to:
  /// **'DEFUSED'**
  String get spikeDefused;

  /// No description provided for @spikeExploded.
  ///
  /// In en, this message translates to:
  /// **'EXPLODED'**
  String get spikeExploded;

  /// No description provided for @detonateIn.
  ///
  /// In en, this message translates to:
  /// **'DETONATE IN {turns}'**
  String detonateIn(int turns);

  /// No description provided for @seekSite.
  ///
  /// In en, this message translates to:
  /// **'SEEK SITE'**
  String get seekSite;

  /// No description provided for @recover.
  ///
  /// In en, this message translates to:
  /// **'RECOVER'**
  String get recover;

  /// No description provided for @roundEnd.
  ///
  /// In en, this message translates to:
  /// **'ROUND END'**
  String get roundEnd;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'NOT SET'**
  String get notSet;

  /// No description provided for @spikeNotDeployed.
  ///
  /// In en, this message translates to:
  /// **'Spike not deployed'**
  String get spikeNotDeployed;

  /// No description provided for @spikeBeingCarried.
  ///
  /// In en, this message translates to:
  /// **'Spike being carried'**
  String get spikeBeingCarried;

  /// No description provided for @spikeDroppedStatus.
  ///
  /// In en, this message translates to:
  /// **'Spike dropped'**
  String get spikeDroppedStatus;

  /// No description provided for @spikePlantedCountdown.
  ///
  /// In en, this message translates to:
  /// **'Spike planted! {turns} turns left'**
  String spikePlantedCountdown(int turns);

  /// No description provided for @defusingProgress.
  ///
  /// In en, this message translates to:
  /// **'Defusing... ({progress}/2)'**
  String defusingProgress(int progress);

  /// No description provided for @spikeDefusedStatus.
  ///
  /// In en, this message translates to:
  /// **'Spike defused'**
  String get spikeDefusedStatus;

  /// No description provided for @spikeExplodedStatus.
  ///
  /// In en, this message translates to:
  /// **'Spike exploded'**
  String get spikeExplodedStatus;

  /// No description provided for @spikeDefusedWin.
  ///
  /// In en, this message translates to:
  /// **'Spike defused!'**
  String get spikeDefusedWin;

  /// No description provided for @spikeExplodedWin.
  ///
  /// In en, this message translates to:
  /// **'Spike exploded!'**
  String get spikeExplodedWin;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us your\nthoughts'**
  String get feedbackTitle;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If you have any concerns or suggestions, please let us know.'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. I want to see the remaining time of the smoke on the HUD...'**
  String get feedbackPlaceholder;

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSend;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Sent Successfully'**
  String get feedbackSent;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!\nWe will review it shortly.'**
  String get feedbackThanks;

  /// No description provided for @feedbackReturnToGame.
  ///
  /// In en, this message translates to:
  /// **'Return to Game'**
  String get feedbackReturnToGame;

  /// No description provided for @feedbackError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send: {error}'**
  String feedbackError(String error);

  /// No description provided for @feedbackEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your message'**
  String get feedbackEmptyError;

  /// No description provided for @snsContactInfo.
  ///
  /// In en, this message translates to:
  /// **'You can also contact us via SNS!'**
  String get snsContactInfo;

  /// No description provided for @snsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load SNS: {error}'**
  String snsLoadError(String error);

  /// No description provided for @onlineProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'ONLINE PROFILE'**
  String get onlineProfileTitle;

  /// No description provided for @onlineMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'ONLINE MATCH'**
  String get onlineMatchTitle;

  /// No description provided for @onlineUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username (max 12)'**
  String get onlineUsernameLabel;

  /// No description provided for @onlineUsernameSave.
  ///
  /// In en, this message translates to:
  /// **'Save and enter lobby'**
  String get onlineUsernameSave;

  /// No description provided for @onlineUsernameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get onlineUsernameRequiredError;

  /// No description provided for @onlineUsernameTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Please keep it within 12 characters'**
  String get onlineUsernameTooLongError;

  /// No description provided for @onlineUsernameTakenError.
  ///
  /// In en, this message translates to:
  /// **'That name is unavailable'**
  String get onlineUsernameTakenError;

  /// No description provided for @onlineProfileLoading.
  ///
  /// In en, this message translates to:
  /// **'Checking player profile...'**
  String get onlineProfileLoading;

  /// No description provided for @onlineProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {error}'**
  String onlineProfileLoadError(String error);

  /// No description provided for @onlineRegistering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get onlineRegistering;

  /// No description provided for @onlineRegisterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration complete'**
  String get onlineRegisterSuccess;

  /// No description provided for @onlineRegisterError.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String onlineRegisterError(String error);

  /// No description provided for @onlineMatchCodeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a match code'**
  String get onlineMatchCodeRequiredError;

  /// No description provided for @onlineNeedProfileError.
  ///
  /// In en, this message translates to:
  /// **'Register a username first'**
  String get onlineNeedProfileError;

  /// No description provided for @onlineConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get onlineConnecting;

  /// No description provided for @onlineConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get onlineConnected;

  /// No description provided for @onlineConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed: {error}'**
  String onlineConnectFailed(String error);

  /// No description provided for @onlineReplayLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading replay...'**
  String get onlineReplayLoading;

  /// No description provided for @onlineReplayUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Replay could not be loaded'**
  String get onlineReplayUnavailable;

  /// No description provided for @onlineReplayActive.
  ///
  /// In en, this message translates to:
  /// **'Replay mode (offline)'**
  String get onlineReplayActive;

  /// No description provided for @onlineReplayFailed.
  ///
  /// In en, this message translates to:
  /// **'Replay load failed: {error}'**
  String onlineReplayFailed(String error);

  /// No description provided for @onlineInitLoading.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get onlineInitLoading;

  /// No description provided for @onlineReplayMode.
  ///
  /// In en, this message translates to:
  /// **'Replay mode'**
  String get onlineReplayMode;

  /// No description provided for @onlineExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get onlineExit;

  /// No description provided for @onlineMatchTypeCode.
  ///
  /// In en, this message translates to:
  /// **'Code Match'**
  String get onlineMatchTypeCode;

  /// No description provided for @onlineMatchTypeRandom.
  ///
  /// In en, this message translates to:
  /// **'Random Match'**
  String get onlineMatchTypeRandom;

  /// No description provided for @onlineHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get onlineHost;

  /// No description provided for @onlineJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get onlineJoin;

  /// No description provided for @onlineTeamLabel.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get onlineTeamLabel;

  /// No description provided for @onlineMatchCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Match code'**
  String get onlineMatchCodeLabel;

  /// No description provided for @onlineAutoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Code will be generated automatically'**
  String get onlineAutoCodeHint;

  /// No description provided for @onlineCreateRoom.
  ///
  /// In en, this message translates to:
  /// **'Create room'**
  String get onlineCreateRoom;

  /// No description provided for @onlineJoinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get onlineJoinRoom;

  /// No description provided for @onlineRandomStart.
  ///
  /// In en, this message translates to:
  /// **'Find match'**
  String get onlineRandomStart;

  /// No description provided for @onlineStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get onlineStatusConnected;

  /// No description provided for @onlineStatusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get onlineStatusDisconnected;

  /// No description provided for @onlineOpponentWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get onlineOpponentWaiting;

  /// No description provided for @onlineOpponentPlacing.
  ///
  /// In en, this message translates to:
  /// **'Opponent is placing'**
  String get onlineOpponentPlacing;

  /// No description provided for @onlineOpponentSelectingSpike.
  ///
  /// In en, this message translates to:
  /// **'Opponent selecting spike'**
  String get onlineOpponentSelectingSpike;

  /// No description provided for @onlineMatchEndedReplayNotice.
  ///
  /// In en, this message translates to:
  /// **'Match ended - replay available for 1 day'**
  String get onlineMatchEndedReplayNotice;

  /// No description provided for @onlineReplayButton.
  ///
  /// In en, this message translates to:
  /// **'Replay latest'**
  String get onlineReplayButton;

  /// No description provided for @onlineYouLabel.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get onlineYouLabel;

  /// No description provided for @onlineUsernameFormat.
  ///
  /// In en, this message translates to:
  /// **'Username: {name}'**
  String onlineUsernameFormat(String name);

  /// No description provided for @onlineRecordFormat.
  ///
  /// In en, this message translates to:
  /// **'Record: {wins}W - {losses}L'**
  String onlineRecordFormat(int wins, int losses);

  /// No description provided for @onlineRecordShortFormat.
  ///
  /// In en, this message translates to:
  /// **'{wins}W-{losses}L'**
  String onlineRecordShortFormat(int wins, int losses);

  /// No description provided for @onlineScoreFormat.
  ///
  /// In en, this message translates to:
  /// **'{localWins}-{oppWins} / First to {target}'**
  String onlineScoreFormat(int localWins, int oppWins, int target);

  /// No description provided for @onlineCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String onlineCodeLabel(String code);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
