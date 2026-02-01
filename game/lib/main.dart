import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/game_mode.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/online_match_screen.dart';
import 'ui/screens/title_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://glpnlarhekitkrebnxmn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdscG5sYXJoZWtpdGtyZWJueG1uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5MDkzMzMsImV4cCI6MjA2MTQ4NTMzM30.BCd83hU3oh96tCDdHK3mX7I7R02wQ9vWRINFSoXWYCY',
  );
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
                builder: (_) =>
                    mode == GameMode.online ? const OnlineMatchScreen() : GameScreen(mode: mode),
              ),
            );
          },
        ),
      ),
    );
  }
}
