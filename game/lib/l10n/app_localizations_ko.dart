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
  String get round => '라운드';

  @override
  String get attackerSetup => '공격팀 배치';

  @override
  String get defenderSetup => '수비팀 배치';

  @override
  String get spikeSelect => '스파이크 선택';

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
}
