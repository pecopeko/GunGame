import 'package:flutter/material.dart';

import 'ui/screens/game_screen.dart';
import 'ui/screens/title_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TacticalApp());
}

class TacticalApp extends StatelessWidget {
  const TacticalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
          onStartGame: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const GameScreen()),
            );
          },
        ),
      ),
    );
  }
}
