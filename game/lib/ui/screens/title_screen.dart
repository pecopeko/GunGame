import 'package:flutter/material.dart';

import '../overlays/overlay_widgets.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.onStartGame});

  final VoidCallback onStartGame;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0D10),
              Color(0xFF141A1F),
              Color(0xFF1A2530),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo / Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF1BA784).withAlpha(128),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'TACTICAL',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF1BA784),
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 8,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SITES',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFFE1B563),
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 12,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'TURN CARD OPS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: OverlayTokens.muted,
                      letterSpacing: 4,
                    ),
              ),
              const Spacer(flex: 2),
              // Start Button
              GestureDetector(
                onTap: onStartGame,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1BA784), Color(0xFF148F6F)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1BA784).withAlpha(77),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'START GAME',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Footer
              Text(
                '5v5 TACTICAL STRATEGY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: OverlayTokens.muted.withAlpha(128),
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
