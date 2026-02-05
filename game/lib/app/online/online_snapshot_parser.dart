import 'dart:convert';

import '../../core/game_serializer.dart';
import 'online_match_models.dart';

OnlineSnapshotPayload? parseOnlineSnapshotPayload(
  dynamic raw,
  GameSerializer serializer,
) {
  final map = _jsonMapFrom(raw);
  if (map == null) return null;
  return OnlineSnapshotPayload.fromJson(map, serializer);
}

Map<String, dynamic>? _jsonMapFrom(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  if (raw is String) {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
  }
  return null;
}
