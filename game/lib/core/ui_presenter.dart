// UI表示用の補助情報を生成する。
import 'entities.dart';

class UiPresenter {
  const UiPresenter();

  String actionDescription(ActionType action) {
    switch (action) {
      case ActionType.move:
        return 'Move to a reachable tile.';
      case ActionType.attack:
        return 'Attack an enemy in range.';
      case ActionType.skill1:
        return 'Use Skill 1.';
      case ActionType.skill2:
        return 'Use Skill 2.';
      case ActionType.plant:
        return 'Plant the spike on a site.';
      case ActionType.defuse:
        return 'Defuse the spike.';
      case ActionType.pass:
        return 'Pass the turn.';
    }
  }
}
