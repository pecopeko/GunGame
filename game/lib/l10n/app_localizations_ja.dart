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
  String get round => 'ラウンド';

  @override
  String get attackerSetup => 'アタッカー配置';

  @override
  String get defenderSetup => 'ディフェンダー配置';

  @override
  String get spikeSelect => 'スパイク選択';

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
  String get onlineMatchEndedReplayNotice => '試合終了 - 1日以内はリプレイ保持';

  @override
  String get onlineReplayButton => '最新リプレイを再現';

  @override
  String get onlineYouLabel => 'YOU';

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
