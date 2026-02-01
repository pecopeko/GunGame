import 'package:supabase_flutter/supabase_flutter.dart';

class SnsRepo {
  final _sp = Supabase.instance.client;

  /// public.sns から (sns, url) のリストを返す
  Future<List<({String sns, String url})>> fetchList() async {
    final List data = await _sp.from('sns').select('sns,url');

    final out = <({String sns, String url})>[];
    for (final row in data) {
      final s = (row['sns'] as String? ?? '');
      final u = (row['url'] as String? ?? '');
      out.add((sns: s, url: u));
    }
    return out;
  }
}
