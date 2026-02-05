import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/game_mode.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/online_match_screen.dart';
import 'ui/screens/title_screen.dart';

const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://tvkhgsvqozcevurxaeym.supabase.co',
);
const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR2a2hnc3Zxb3pjZXZ1cnhhZXltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNTUwNDUsImV4cCI6MjA4NTgzMTA0NX0.3AcvmTFCxoYErQWS3RixrRgvJ0ua9AXfIMPlnlKReas',
);

void _validateSupabaseEnv() {
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Supabase env is missing (SUPABASE_URL / SUPABASE_ANON_KEY).',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _validateSupabaseEnv();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const TacticalApp());
}

class TacticalApp extends StatelessWidget {
  const TacticalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
        Locale('zh'),
        Locale('ko'),
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Avenir Next',
        scaffoldBackgroundColor: const Color(0xFF0E1215),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1BA784),
          secondary: Color(0xFFE1B563),
          surface: Color(0xFF1A2126),
          onSurface: Color(0xFFF2F4F5),
        ),
      ),
      home: Builder(
        builder: (context) => TitleScreen(
          onSelectMode: (mode) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => mode == GameMode.online
                    ? const OnlineMatchScreen()
                    : GameScreen(mode: mode),
              ),
            );
          },
        ),
      ),
    );
  }
}
