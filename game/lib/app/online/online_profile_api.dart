import 'package:supabase_flutter/supabase_flutter.dart';

import 'online_match_models.dart';

class UsernameTakenException implements Exception {
  UsernameTakenException([this.message = 'username_taken']);
  final String message;

  @override
  String toString() => message;
}

class OnlineProfileApi {
  OnlineProfileApi({SupabaseClient? client})
    : client = client ?? Supabase.instance.client;

  final SupabaseClient client;

  Future<OnlineProfile> createProfile({required String username}) async {
    final payload = {'username': username.trim()};
    try {
      final row = await client
          .from('online_profiles')
          .insert(payload)
          .select()
          .single();
      return OnlineProfile.fromJson(Map<String, dynamic>.from(row));
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw UsernameTakenException();
      }
      rethrow;
    }
  }

  Future<OnlineProfile?> fetchProfile(String id) async {
    final row = await client
        .from('online_profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return OnlineProfile.fromJson(Map<String, dynamic>.from(row));
  }

  Future<OnlineProfile?> fetchByUsername(String username) async {
    final row = await client
        .from('online_profiles')
        .select()
        .eq('username', username.trim())
        .maybeSingle();
    if (row == null) return null;
    return OnlineProfile.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> leaveActiveMatch({required String profileId}) async {
    await client.rpc('online_match_leave', params: {'p_profile_id': profileId});
  }
}
