// オンライン識別情報の保存を担当する。
import 'package:shared_preferences/shared_preferences.dart';

class OnlineIdentityStore {
  const OnlineIdentityStore();

  static const _keyPlayerId = 'online_player_id';
  static const _keyUsername = 'online_username';

  Future<String?> loadPlayerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPlayerId);
  }

  Future<String?> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<void> saveIdentity({
    required String playerId,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlayerId, playerId);
    await prefs.setString(_keyUsername, username);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPlayerId);
    await prefs.remove(_keyUsername);
  }
}
