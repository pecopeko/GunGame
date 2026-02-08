// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'TACTICAL';

  @override
  String get appSubtitle => 'SITES';

  @override
  String get appTagline => 'ターン制カードオプス';

  @override
  String get appFooter => '5v5 タクティカル戦略';

  @override
  String get startGame => 'ゲーム開始';

  @override
  String get selectMode => 'モード選択';

  @override
  String get selectModeSubtitle => 'バトルグラウンドを選択';

  @override
  String get modeOnline => 'オンラインマッチ';

  @override
  String get modeOnlineSubtitle => 'リアルプレイヤーと対戦';

  @override
  String get modeBot => 'ボットマッチ';

  @override
  String get modeBotSubtitle => 'AIと練習';

  @override
  String get modeLocal => 'ローカル 1V1';

  @override
  String get modeLocalSubtitle => '1台のデバイスで交互にプレイ';

  @override
  String get cancel => 'キャンセル';

  @override
  String get menu => 'メニュー';

  @override
  String get quitGame => 'ゲームをやめる';

  @override
  String get sendFeedback => '要望をする';

  @override
  String get back => '戻る';

  @override
  String get settings => '設定';

  @override
  String get round => 'ラウンド';

  @override
  String get attackerSetup => 'アタッカー配置';

  @override
  String get defenderSetup => 'ディフェンダー配置';

  @override
  String get spikeSelect => 'スパイク選択';

  @override
  String get phasePlaying => '進行中';

  @override
  String get phaseGameOver => '終了';

  @override
  String get phaseUnknown => '不明';

  @override
  String get botDeciding => 'ボット思考中...';

  @override
  String get attacker => 'アタッカー';

  @override
  String get defender => 'ディフェンダー';

  @override
  String get attackerTurn => 'アタッカーターン';

  @override
  String get defenderTurn => 'ディフェンダーターン';

  @override
  String get yourTurn => 'あなたの手番';

  @override
  String attackerAliveBadge(int count) {
    return 'A $count';
  }

  @override
  String defenderAliveBadge(int count) {
    return 'D $count';
  }

  @override
  String get botPlacing => 'ボットが配置を決めています';

  @override
  String get skillMode => 'スキルモード';

  @override
  String get attackMode => 'アタックモード';

  @override
  String get action => 'アクション';

  @override
  String get skillModeHint => 'オレンジのタイルをタップしてスキルを使用';

  @override
  String get attackModeHint => '赤いリングの敵をタップして攻撃';

  @override
  String get actionHint => 'ユニットを選択してコマンドを選択';

  @override
  String get victory => '勝利';

  @override
  String get defeat => '敗北';

  @override
  String get selectSpikeCarrier => 'スパイク所持者を選択';

  @override
  String get selectSpikeCarrierHint => 'アタッカーをタップしてスパイクを渡します。';

  @override
  String currentCarrier(String roleName) {
    return '所持者: $roleName';
  }

  @override
  String get confirmCarrier => '所持者を確定';

  @override
  String setupTitle(String teamLabel) {
    return '$teamLabel 配置';
  }

  @override
  String get undoLastPlacement => 'ひとつ戻す';

  @override
  String placedCount(int placed, int max) {
    return '配置: $placed / $max';
  }

  @override
  String get teamFullHint => '編成上限です。変更するには配置を戻してください。';

  @override
  String get confirmPlacement => '配置を確定';

  @override
  String get roleEntry => 'エントリー';

  @override
  String get roleRecon => 'リコン';

  @override
  String get roleSmoke => 'スモーク';

  @override
  String get roleSentinel => 'センチネル';

  @override
  String get move => '移動';

  @override
  String get tiles => 'マス';

  @override
  String get skill1 => 'スキル 01';

  @override
  String get skill2 => 'スキル 02';

  @override
  String get plant => '設置';

  @override
  String get onSite => 'サイト上';

  @override
  String get defuse => '解除';

  @override
  String get na => 'N/A';

  @override
  String get attackersWin => 'アタッカー勝利';

  @override
  String get defendersWin => 'ディフェンダー勝利';

  @override
  String get rematch => 'リマッチ';

  @override
  String get quit => '終了';

  @override
  String get swapSides => 'サイド交換';

  @override
  String get sideSwapTitle => '攻守交代します';

  @override
  String get sideSwapSubtitle => '次のラウンド準備中';

  @override
  String sideSwapRoleLabel(String role) {
    return 'あなたは $role';
  }

  @override
  String get timeoutWin => 'タイムアウトしたためあなたの勝ちです';

  @override
  String get timeoutLose => 'タイムアウトしました';

  @override
  String get matchFinished => '試合終了';

  @override
  String get bothTeamsEliminated => '双方全滅';

  @override
  String get attackersEliminated => 'アタッカー全滅';

  @override
  String get defendersEliminated => 'ディフェンダー全滅';

  @override
  String get ready => '準備完了';

  @override
  String get spike => 'スパイク';

  @override
  String get spikeSecured => '保持中';

  @override
  String get spikeCarried => '運搬中';

  @override
  String get spikeDropped => '落下中';

  @override
  String get spikePlanted => '設置済';

  @override
  String get spikeDefused => '解除済';

  @override
  String get spikeExploded => '爆発';

  @override
  String detonateIn(int turns) {
    return '爆発まで $turns';
  }

  @override
  String get seekSite => 'サイトへ';

  @override
  String get recover => '回収';

  @override
  String get roundEnd => 'ラウンド終了';

  @override
  String get notSet => '未設定';

  @override
  String get debugHudTitle => 'DEBUG HUD';

  @override
  String debugPhaseLabel(String phase) {
    return 'フェーズ: $phase';
  }

  @override
  String debugTurnLabel(String team) {
    return '手番: $team';
  }

  @override
  String debugUnitsLabel(int count) {
    return 'ユニット: $count';
  }

  @override
  String debugLogLabel(int count) {
    return 'ログ: $count';
  }

  @override
  String debugSpikeLabel(String state) {
    return 'スパイク: $state';
  }

  @override
  String get fieldIntelTitle => 'フィールド情報';

  @override
  String get noUnitSelected => 'ユニット未選択';

  @override
  String losClearToZone(String zone) {
    return '視界: $zone 通路までクリア';
  }

  @override
  String smokeTurnsRemaining(int turns) {
    return 'スモーク: 残り $turns ターン';
  }

  @override
  String zoneTileInfo(String zone, String tile) {
    return 'ゾーン: $zone / タイル $tile';
  }

  @override
  String get zoneMid => 'ミッド';

  @override
  String get sampleTileId => 'r1c2';

  @override
  String get spikeNotDeployed => 'スパイク未配備';

  @override
  String get spikeBeingCarried => 'スパイク運搬中';

  @override
  String get spikeDroppedStatus => 'スパイク落下';

  @override
  String spikePlantedCountdown(int turns) {
    return 'スパイク設置済！残り $turns ターン';
  }

  @override
  String defusingProgress(int progress) {
    return '解除中... ($progress/2)';
  }

  @override
  String get spikeDefusedStatus => 'スパイク解除';

  @override
  String get spikeExplodedStatus => 'スパイク爆発';

  @override
  String get spikeDefusedWin => 'スパイク解除！';

  @override
  String get spikeExplodedWin => 'スパイク爆発！';

  @override
  String get feedbackTitle => 'ご意見・ご要望を\nお聞かせください';

  @override
  String get feedbackSubtitle => '気になる点や改善案があれば、遠慮なく届けてください。';

  @override
  String get feedbackPlaceholder => '例: スモークの残り時間をHUDに表示してほしい...';

  @override
  String get feedbackSend => '送信する';

  @override
  String get feedbackSent => '送信完了';

  @override
  String get feedbackThanks => 'ご要望ありがとうございます！\n確認次第対応いたします。';

  @override
  String get feedbackReturnToGame => 'ゲームに戻る';

  @override
  String get feedbackChipLabel => 'フィードバック';

  @override
  String feedbackError(String error) {
    return '送信に失敗しました: $error';
  }

  @override
  String get feedbackEmptyError => '内容を入力してください';

  @override
  String get snsContactInfo => 'SNSでもお問い合わせ大丈夫です！';

  @override
  String snsLoadError(String error) {
    return 'SNSの取得に失敗しました: $error';
  }

  @override
  String urlLaunchError(String url) {
    return 'リンクを開けませんでした: $url';
  }

  @override
  String get onlineProfileTitle => 'ONLINE PROFILE';

  @override
  String get onlineMatchTitle => 'ONLINE MATCH';

  @override
  String get onlineUsernameLabel => 'ユーザーネーム（12文字以内）';

  @override
  String get onlineUsernameSave => '保存してロビーへ';

  @override
  String get onlineUsernameRequiredError => 'ユーザーネームを入力してください';

  @override
  String get onlineUsernameTooLongError => '12文字以内で入力してください';

  @override
  String get onlineUsernameTakenError => 'その名前は使えません';

  @override
  String get onlineProfileLoading => 'プレイヤー情報を確認中...';

  @override
  String onlineProfileLoadError(String error) {
    return 'プロファイル取得に失敗しました: $error';
  }

  @override
  String get onlineRegistering => '登録中...';

  @override
  String get onlineRegisterSuccess => '登録完了';

  @override
  String onlineRegisterError(String error) {
    return '登録に失敗しました: $error';
  }

  @override
  String get onlineMatchCodeRequiredError => 'マッチコードを入力してください';

  @override
  String get onlineNeedProfileError => 'まずユーザーネームを登録してください';

  @override
  String get onlineConnecting => '接続中...';

  @override
  String get onlineConnected => '接続完了';

  @override
  String get onlineConnectTimeout => '接続がタイムアウトしました';

  @override
  String onlineConnectFailed(String error) {
    return '接続に失敗しました: $error';
  }

  @override
  String get onlineReplayLoading => 'リプレイ取得中...';

  @override
  String get onlineReplayUnavailable => 'リプレイを取得できませんでした';

  @override
  String get onlineReplayActive => 'リプレイ表示中（オフライン）';

  @override
  String onlineReplayFailed(String error) {
    return 'リプレイ取得に失敗しました: $error';
  }

  @override
  String get onlineInitLoading => '初期化中...';

  @override
  String get onlineReplayMode => 'リプレイモード';

  @override
  String get onlineExit => '終了';

  @override
  String get onlineMatchTypeCode => '合言葉対戦';

  @override
  String get onlineMatchTypeRandom => 'ランダムマッチ';

  @override
  String get onlineHost => 'ホスト';

  @override
  String get onlineJoin => '参加';

  @override
  String get onlineTeamLabel => '担当チーム';

  @override
  String get onlineMatchCodeLabel => 'マッチコード';

  @override
  String get onlineAutoCodeHint => 'コードは自動生成されます';

  @override
  String get onlineCreateRoom => '部屋を作成';

  @override
  String get onlineJoinRoom => '参加する';

  @override
  String get onlineRandomStart => 'マッチング開始';

  @override
  String get onlineStatusConnected => '接続中';

  @override
  String get onlineStatusDisconnected => '未接続';

  @override
  String get onlineOpponentWaiting => '相手待ち';

  @override
  String get onlineOpponentPlacing => '相手が配置中';

  @override
  String get onlineOpponentSelectingSpike => '相手がスパイク選択中';

  @override
  String get onlineMatchingTitle => 'マッチング中';

  @override
  String onlineMatchingElapsed(int seconds) {
    return '経過 $seconds秒';
  }

  @override
  String get onlineMatchFoundTitle => 'マッチング成立';

  @override
  String get onlineTotalRecordLabel => '通算戦績';

  @override
  String get onlineMatchEndedReplayNotice => '試合終了 - 1日以内はリプレイ保持';

  @override
  String get onlineReplayButton => '最新リプレイを再現';

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
    return 'ユーザーネーム: $name';
  }

  @override
  String onlineRecordFormat(int wins, int losses) {
    return '戦績: ${wins}W - ${losses}L';
  }

  @override
  String onlineRecordShortFormat(int wins, int losses) {
    return '${wins}W-${losses}L';
  }

  @override
  String onlineScoreFormat(int localWins, int oppWins, int target) {
    return '$localWins-$oppWins / 先取$target';
  }

  @override
  String onlineCodeLabel(String code) {
    return 'コード: $code';
  }
}
