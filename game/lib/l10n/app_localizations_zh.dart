// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'TACTICAL';

  @override
  String get appSubtitle => 'SITES';

  @override
  String get appTagline => '回合制卡牌对战';

  @override
  String get appFooter => '5v5 战术策略';

  @override
  String get startGame => '开始游戏';

  @override
  String get selectMode => '选择模式';

  @override
  String get selectModeSubtitle => '选择你的战场';

  @override
  String get modeOnline => '在线对战';

  @override
  String get modeOnlineSubtitle => '与真人玩家对战';

  @override
  String get modeBot => '人机对战';

  @override
  String get modeBotSubtitle => '与AI进行练习';

  @override
  String get modeLocal => '本地 1V1';

  @override
  String get modeLocalSubtitle => '一台设备轮流游玩';

  @override
  String get cancel => '取消';

  @override
  String get menu => '菜单';

  @override
  String get quitGame => '退出游戏';

  @override
  String get sendFeedback => '发送反馈';

  @override
  String get back => '返回';

  @override
  String get round => '回合';

  @override
  String get attackerSetup => '攻击方部署';

  @override
  String get defenderSetup => '防守方部署';

  @override
  String get spikeSelect => '选择炸弹携带者';

  @override
  String get botDeciding => '电脑思考中...';

  @override
  String get attacker => '攻击方';

  @override
  String get defender => '防守方';

  @override
  String get attackerTurn => '攻击方回合';

  @override
  String get defenderTurn => '防守方回合';

  @override
  String get botPlacing => '电脑正在决定部署';

  @override
  String get skillMode => '技能模式';

  @override
  String get attackMode => '攻击模式';

  @override
  String get action => '行动';

  @override
  String get skillModeHint => '点击橙色格子使用技能';

  @override
  String get attackModeHint => '点击有红圈的敌人进行攻击';

  @override
  String get actionHint => '选择单位，然后选择命令';

  @override
  String get move => '移动';

  @override
  String get tiles => '格';

  @override
  String get skill1 => '技能 01';

  @override
  String get skill2 => '技能 02';

  @override
  String get plant => '安装';

  @override
  String get onSite => '在点位';

  @override
  String get defuse => '拆除';

  @override
  String get na => 'N/A';

  @override
  String get attackersWin => '攻击方胜利';

  @override
  String get defendersWin => '防守方胜利';

  @override
  String get rematch => '重新比赛';

  @override
  String get quit => '退出';

  @override
  String get swapSides => '交换阵营';

  @override
  String get ready => '准备就绪';

  @override
  String get spike => '炸弹';

  @override
  String get spikeSecured => '已保管';

  @override
  String get spikeCarried => '携带中';

  @override
  String get spikeDropped => '已掉落';

  @override
  String get spikePlanted => '已安装';

  @override
  String get spikeDefused => '已拆除';

  @override
  String get spikeExploded => '已爆炸';

  @override
  String detonateIn(int turns) {
    return '$turns 后爆炸';
  }

  @override
  String get seekSite => '前往点位';

  @override
  String get recover => '回收';

  @override
  String get roundEnd => '回合结束';

  @override
  String get notSet => '未设置';

  @override
  String get spikeNotDeployed => '炸弹未部署';

  @override
  String get spikeBeingCarried => '炸弹携带中';

  @override
  String get spikeDroppedStatus => '炸弹已掉落';

  @override
  String spikePlantedCountdown(int turns) {
    return '炸弹已安装！剩余 $turns 回合';
  }

  @override
  String defusingProgress(int progress) {
    return '拆除中... ($progress/2)';
  }

  @override
  String get spikeDefusedStatus => '炸弹已拆除';

  @override
  String get spikeExplodedStatus => '炸弹已爆炸';

  @override
  String get spikeDefusedWin => '炸弹已拆除！';

  @override
  String get spikeExplodedWin => '炸弹已爆炸！';

  @override
  String get feedbackTitle => '请告诉我们\n您的想法';

  @override
  String get feedbackSubtitle => '如果您有任何疑虑或建议，请告诉我们。';

  @override
  String get feedbackPlaceholder => '例如：我希望在HUD上显示烟雾的剩余时间...';

  @override
  String get feedbackSend => '发送';

  @override
  String get feedbackSent => '发送成功';

  @override
  String get feedbackThanks => '感谢您的反馈！\n我们会尽快查看。';

  @override
  String get feedbackReturnToGame => '返回游戏';

  @override
  String feedbackError(String error) {
    return '发送失败: $error';
  }

  @override
  String get feedbackEmptyError => '请输入内容';

  @override
  String get snsContactInfo => '您也可以通过社交媒体联系我们！';

  @override
  String snsLoadError(String error) {
    return '加载社交媒体失败: $error';
  }

  @override
  String get onlineProfileTitle => 'ONLINE PROFILE';

  @override
  String get onlineMatchTitle => 'ONLINE MATCH';

  @override
  String get onlineUsernameLabel => '用户名（最多12字）';

  @override
  String get onlineUsernameSave => '保存并进入大厅';

  @override
  String get onlineUsernameRequiredError => '请输入用户名';

  @override
  String get onlineUsernameTooLongError => '请控制在12个字符以内';

  @override
  String get onlineUsernameTakenError => '该名字不可用';

  @override
  String get onlineProfileLoading => '正在检查玩家资料...';

  @override
  String onlineProfileLoadError(String error) {
    return '获取资料失败: $error';
  }

  @override
  String get onlineRegistering => '注册中...';

  @override
  String get onlineRegisterSuccess => '注册完成';

  @override
  String onlineRegisterError(String error) {
    return '注册失败: $error';
  }

  @override
  String get onlineMatchCodeRequiredError => '请输入匹配码';

  @override
  String get onlineNeedProfileError => '请先注册用户名';

  @override
  String get onlineConnecting => '连接中...';

  @override
  String get onlineConnected => '连接成功';

  @override
  String onlineConnectFailed(String error) {
    return '连接失败: $error';
  }

  @override
  String get onlineReplayLoading => '加载回放中...';

  @override
  String get onlineReplayUnavailable => '无法获取回放';

  @override
  String get onlineReplayActive => '回放模式（离线）';

  @override
  String onlineReplayFailed(String error) {
    return '回放加载失败: $error';
  }

  @override
  String get onlineInitLoading => '初始化中...';

  @override
  String get onlineReplayMode => '回放模式';

  @override
  String get onlineExit => '退出';

  @override
  String get onlineMatchTypeCode => '口令对战';

  @override
  String get onlineMatchTypeRandom => '随机匹配';

  @override
  String get onlineHost => '房主';

  @override
  String get onlineJoin => '加入';

  @override
  String get onlineTeamLabel => '队伍';

  @override
  String get onlineMatchCodeLabel => '匹配码';

  @override
  String get onlineAutoCodeHint => '匹配码将自动生成';

  @override
  String get onlineCreateRoom => '创建房间';

  @override
  String get onlineJoinRoom => '加入房间';

  @override
  String get onlineRandomStart => '开始匹配';

  @override
  String get onlineStatusConnected => '已连接';

  @override
  String get onlineStatusDisconnected => '未连接';

  @override
  String get onlineOpponentWaiting => '等待对手';

  @override
  String get onlineOpponentPlacing => '对手正在部署';

  @override
  String get onlineOpponentSelectingSpike => '对手正在选择炸弹';

  @override
  String get onlineMatchEndedReplayNotice => '比赛结束 - 1天内可回放';

  @override
  String get onlineReplayButton => '查看最新回放';

  @override
  String get onlineYouLabel => 'YOU';

  @override
  String onlineUsernameFormat(String name) {
    return '用户名: $name';
  }

  @override
  String onlineRecordFormat(int wins, int losses) {
    return '战绩: ${wins}W - ${losses}L';
  }

  @override
  String onlineRecordShortFormat(int wins, int losses) {
    return '${wins}W-${losses}L';
  }

  @override
  String onlineScoreFormat(int localWins, int oppWins, int target) {
    return '$localWins-$oppWins / 先到$target';
  }

  @override
  String onlineCodeLabel(String code) {
    return '代码: $code';
  }
}
