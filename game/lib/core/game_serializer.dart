import 'entities.dart';

class GameSerializer {
  const GameSerializer();

  Map<String, Object?> toJson(GameState state) {
    // TODO: serialize GameState for replay or network use.
    return <String, Object?>{};
  }

  GameState fromJson(Map<String, Object?> json) {
    // TODO: deserialize into GameState.
    return GameState.initial();
  }
}
