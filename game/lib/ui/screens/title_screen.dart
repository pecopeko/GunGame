import 'package:flutter/material.dart';

import '../../core/game_mode.dart';
import '../overlays/overlay_widgets.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.onSelectMode});

  final ValueChanged<GameMode> onSelectMode;

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
                onTap: () => _showModeSelect(context),
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

  void _showModeSelect(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F1B24),
                  Color(0xFF182530),
                  Color(0xFF1E2F3B),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1BA784).withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1BA784).withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SELECT MODE',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose your battle ground',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: OverlayTokens.muted.withOpacity(0.8),
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 20),
                _ModeOptionCard(
                  title: 'ONLINE MATCH',
                  subtitle: 'Compete against real players',
                  icon: Icons.wifi_tethering_rounded,
                  accent: const Color(0xFF1BA784),
                  onTap: () => _select(context, GameMode.online),
                ),
                const SizedBox(height: 12),
                _ModeOptionCard(
                  title: 'BOT MATCH',
                  subtitle: 'Practice with tactical AI',
                  icon: Icons.smart_toy_outlined,
                  accent: const Color(0xFFE1B563),
                  onTap: () => _select(context, GameMode.bot),
                ),
                const SizedBox(height: 12),
                _ModeOptionCard(
                  title: 'LOCAL 1V1',
                  subtitle: 'Pass & play on one device',
                  icon: Icons.people_alt_outlined,
                  accent: const Color(0xFF4FC3F7),
                  onTap: () => _select(context, GameMode.local),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(letterSpacing: 2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _select(BuildContext context, GameMode mode) {
    Navigator.of(context).pop();
    onSelectMode(mode);
  }
}

class _ModeOptionCard extends StatelessWidget {
  const _ModeOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withOpacity(0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.15),
                border: Border.all(color: accent.withOpacity(0.6), width: 1),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: accent.withOpacity(0.9), size: 16),
          ],
        ),
      ),
    );
  }
}
