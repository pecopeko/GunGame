// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'TACTICAL';

  @override
  String get appSubtitle => 'SITES';

  @override
  String get appTagline => '턴제 카드 작전';

  @override
  String get appFooter => '5v5 전술 전략';

  @override
  String get startGame => '게임 시작';

  @override
  String get selectMode => '모드 선택';

  @override
  String get selectModeSubtitle => '전장을 선택하세요';

  @override
  String get modeOnline => '온라인 매치';

  @override
  String get modeOnlineSubtitle => '실제 플레이어와 대전';

  @override
  String get modeBot => '봇 매치';

  @override
  String get modeBotSubtitle => 'AI와 연습';

  @override
  String get modeLocal => '로컬 1V1';

  @override
  String get modeLocalSubtitle => '하나의 기기에서 번갈아 플레이';

  @override
  String get cancel => '취소';

  @override
  String get menu => '메뉴';

  @override
  String get quitGame => '게임 종료';

  @override
  String get sendFeedback => '피드백 보내기';

  @override
  String get back => '뒤로';

  @override
  String get settings => '설정';

  @override
  String get round => '라운드';

  @override
  String get attackerSetup => '공격팀 배치';

  @override
  String get defenderSetup => '수비팀 배치';

  @override
  String get spikeSelect => '스파이크 선택';

  @override
  String get phasePlaying => '진행 중';

  @override
  String get phaseGameOver => '게임 종료';

  @override
  String get phaseUnknown => '알 수 없음';

  @override
  String get botDeciding => '봇 생각 중...';

  @override
  String get attacker => '공격팀';

  @override
  String get defender => '수비팀';

  @override
  String get attackerTurn => '공격팀 턴';

  @override
  String get defenderTurn => '수비팀 턴';

  @override
  String get yourTurn => '내 차례';

  @override
  String attackerAliveBadge(int count) {
    return 'A $count';
  }

  @override
  String defenderAliveBadge(int count) {
    return 'D $count';
  }

  @override
  String get botPlacing => '봇이 배치를 결정하고 있습니다';

  @override
  String get skillMode => '스킬 모드';

  @override
  String get attackMode => '공격 모드';

  @override
  String get action => '행동';

  @override
  String get skillModeHint => '주황색 타일을 탭하여 스킬 사용';

  @override
  String get attackModeHint => '빨간 링이 있는 적을 탭하여 공격';

  @override
  String get actionHint => '유닛을 선택한 후 명령을 선택하세요';

  @override
  String get victory => '승리';

  @override
  String get defeat => '패배';

  @override
  String get selectSpikeCarrier => '스파이크 운반자 선택';

  @override
  String get selectSpikeCarrierHint => '공격팀 유닛을 탭해 스파이크를 지정하세요.';

  @override
  String currentCarrier(String roleName) {
    return '운반자: $roleName';
  }

  @override
  String get confirmCarrier => '운반자 확정';

  @override
  String setupTitle(String teamLabel) {
    return '$teamLabel 배치';
  }

  @override
  String get undoLastPlacement => '마지막 배치 취소';

  @override
  String placedCount(int placed, int max) {
    return '배치: $placed / $max';
  }

  @override
  String get teamFullHint => '팀이 가득 찼습니다. 편성을 바꾸려면 유닛을 제거하세요.';

  @override
  String get confirmPlacement => '배치 확정';

  @override
  String get roleEntry => '엔트리';

  @override
  String get roleRecon => '리콘';

  @override
  String get roleSmoke => '스모크';

  @override
  String get roleSentinel => '센티널';

  @override
  String get move => '이동';

  @override
  String get tiles => '칸';

  @override
  String get skill1 => '스킬 01';

  @override
  String get skill2 => '스킬 02';

  @override
  String get plant => '설치';

  @override
  String get onSite => '사이트 위';

  @override
  String get defuse => '해제';

  @override
  String get na => 'N/A';

  @override
  String get attackersWin => '공격팀 승리';

  @override
  String get defendersWin => '수비팀 승리';

  @override
  String get rematch => '재경기';

  @override
  String get quit => '종료';

  @override
  String get swapSides => '진영 교체';

  @override
  String get sideSwapTitle => '공수 교대';

  @override
  String get sideSwapSubtitle => '다음 라운드 준비 중';

  @override
  String sideSwapRoleLabel(String role) {
    return '당신은 $role';
  }

  @override
  String get timeoutWin => '상대가 타임아웃되어 당신이 승리했습니다';

  @override
  String get timeoutLose => '타임아웃되었습니다';

  @override
  String get matchFinished => '경기 종료';

  @override
  String get bothTeamsEliminated => '양 팀 전멸';

  @override
  String get attackersEliminated => '공격팀 전멸';

  @override
  String get defendersEliminated => '수비팀 전멸';

  @override
  String get ready => '준비 완료';

  @override
  String get spike => '스파이크';

  @override
  String get spikeSecured => '보유 중';

  @override
  String get spikeCarried => '운반 중';

  @override
  String get spikeDropped => '떨어짐';

  @override
  String get spikePlanted => '설치됨';

  @override
  String get spikeDefused => '해제됨';

  @override
  String get spikeExploded => '폭발함';

  @override
  String detonateIn(int turns) {
    return '$turns 후 폭발';
  }

  @override
  String get seekSite => '사이트로';

  @override
  String get recover => '회수';

  @override
  String get roundEnd => '라운드 종료';

  @override
  String get notSet => '미설정';

  @override
  String get debugHudTitle => 'DEBUG HUD';

  @override
  String debugPhaseLabel(String phase) {
    return '단계: $phase';
  }

  @override
  String debugTurnLabel(String team) {
    return '턴: $team';
  }

  @override
  String debugUnitsLabel(int count) {
    return '유닛: $count';
  }

  @override
  String debugLogLabel(int count) {
    return '로그: $count';
  }

  @override
  String debugSpikeLabel(String state) {
    return '스파이크: $state';
  }

  @override
  String get fieldIntelTitle => '전장 정보';

  @override
  String get noUnitSelected => '선택된 유닛 없음';

  @override
  String losClearToZone(String zone) {
    return '시야: $zone 통로까지 확보';
  }

  @override
  String smokeTurnsRemaining(int turns) {
    return '스모크: $turns턴 남음';
  }

  @override
  String zoneTileInfo(String zone, String tile) {
    return '구역: $zone / 타일 $tile';
  }

  @override
  String get zoneMid => '미드';

  @override
  String get sampleTileId => 'r1c2';

  @override
  String get spikeNotDeployed => '스파이크 미배치';

  @override
  String get spikeBeingCarried => '스파이크 운반 중';

  @override
  String get spikeDroppedStatus => '스파이크 떨어짐';

  @override
  String spikePlantedCountdown(int turns) {
    return '스파이크 설치됨! $turns 턴 남음';
  }

  @override
  String defusingProgress(int progress) {
    return '해제 중... ($progress/2)';
  }

  @override
  String get spikeDefusedStatus => '스파이크 해제됨';

  @override
  String get spikeExplodedStatus => '스파이크 폭발함';

  @override
  String get spikeDefusedWin => '스파이크 해제!';

  @override
  String get spikeExplodedWin => '스파이크 폭발!';

  @override
  String get feedbackTitle => '의견을\n들려주세요';

  @override
  String get feedbackSubtitle => '우려 사항이나 제안이 있으시면 알려주세요.';

  @override
  String get feedbackPlaceholder => '예: HUD에 스모크의 남은 시간을 표시해 주세요...';

  @override
  String get feedbackSend => '보내기';

  @override
  String get feedbackSent => '전송 완료';

  @override
  String get feedbackThanks => '피드백 감사합니다!\n곧 검토하겠습니다.';

  @override
  String get feedbackReturnToGame => '게임으로 돌아가기';

  @override
  String get feedbackChipLabel => '피드백';

  @override
  String feedbackError(String error) {
    return '전송 실패: $error';
  }

  @override
  String get feedbackEmptyError => '내용을 입력해 주세요';

  @override
  String get snsContactInfo => 'SNS로도 문의할 수 있습니다!';

  @override
  String snsLoadError(String error) {
    return 'SNS 로드 실패: $error';
  }

  @override
  String urlLaunchError(String url) {
    return '열 수 없습니다: $url';
  }

  @override
  String get onlineProfileTitle => 'ONLINE PROFILE';

  @override
  String get onlineMatchTitle => 'ONLINE MATCH';

  @override
  String get onlineUsernameLabel => '사용자 이름 (12자 이내)';

  @override
  String get onlineUsernameSave => '저장하고 로비로';

  @override
  String get onlineUsernameRequiredError => '사용자 이름을 입력해 주세요';

  @override
  String get onlineUsernameTooLongError => '12자 이내로 입력해 주세요';

  @override
  String get onlineUsernameTakenError => '사용할 수 없는 이름입니다';

  @override
  String get onlineProfileLoading => '프로필 확인 중...';

  @override
  String onlineProfileLoadError(String error) {
    return '프로필을 불러오지 못했습니다: $error';
  }

  @override
  String get onlineRegistering => '등록 중...';

  @override
  String get onlineRegisterSuccess => '등록 완료';

  @override
  String onlineRegisterError(String error) {
    return '등록에 실패했습니다: $error';
  }

  @override
  String get onlineMatchCodeRequiredError => '매치 코드를 입력해 주세요';

  @override
  String get onlineNeedProfileError => '먼저 사용자 이름을 등록하세요';

  @override
  String get onlineConnecting => '연결 중...';

  @override
  String get onlineConnected => '연결 완료';

  @override
  String get onlineConnectTimeout => '연결 시간이 초과되었습니다';

  @override
  String onlineConnectFailed(String error) {
    return '연결 실패: $error';
  }

  @override
  String get onlineReplayLoading => '리플레이 로딩 중...';

  @override
  String get onlineReplayUnavailable => '리플레이를 불러올 수 없습니다';

  @override
  String get onlineReplayActive => '리플레이 모드(오프라인)';

  @override
  String onlineReplayFailed(String error) {
    return '리플레이 로딩 실패: $error';
  }

  @override
  String get onlineInitLoading => '초기화 중...';

  @override
  String get onlineReplayMode => '리플레이 모드';

  @override
  String get onlineExit => '종료';

  @override
  String get onlineMatchTypeCode => '암호 매치';

  @override
  String get onlineMatchTypeRandom => '랜덤 매치';

  @override
  String get onlineHost => '호스트';

  @override
  String get onlineJoin => '참가';

  @override
  String get onlineTeamLabel => '팀';

  @override
  String get onlineMatchCodeLabel => '매치 코드';

  @override
  String get onlineAutoCodeHint => '코드는 자동 생성됩니다';

  @override
  String get onlineCreateRoom => '방 만들기';

  @override
  String get onlineJoinRoom => '참가하기';

  @override
  String get onlineRandomStart => '매칭 시작';

  @override
  String get onlineStatusConnected => '연결됨';

  @override
  String get onlineStatusDisconnected => '미연결';

  @override
  String get onlineOpponentWaiting => '상대 대기';

  @override
  String get onlineOpponentPlacing => '상대 배치 중';

  @override
  String get onlineOpponentSelectingSpike => '상대 스파이크 선택 중';

  @override
  String get onlineMatchingTitle => '매칭 중';

  @override
  String onlineMatchingElapsed(int seconds) {
    return '경과 $seconds초';
  }

  @override
  String get onlineMatchFoundTitle => '매칭 성립';

  @override
  String get onlineTotalRecordLabel => '통산 전적';

  @override
  String get onlineMatchEndedReplayNotice => '경기 종료 - 1일간 리플레이 가능';

  @override
  String get onlineReplayButton => '최신 리플레이';

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
    return '사용자 이름: $name';
  }

  @override
  String onlineRecordFormat(int wins, int losses) {
    return '전적: ${wins}W - ${losses}L';
  }

  @override
  String onlineRecordShortFormat(int wins, int losses) {
    return '${wins}W-${losses}L';
  }

  @override
  String onlineScoreFormat(int localWins, int oppWins, int target) {
    return '$localWins-$oppWins / $target선승';
  }

  @override
  String onlineCodeLabel(String code) {
    return '코드: $code';
  }
}
