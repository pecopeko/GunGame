// フィードバック画面の共通Widget群。
import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/sns_repo.dart';

class FeedbackBackground extends StatelessWidget {
  const FeedbackBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _BackgroundGlow(),
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.08,
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FeedbackHeaderBar extends StatelessWidget {
  const FeedbackHeaderBar({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _ModeChip(
          label: l10n.feedbackChipLabel,
          icon: Icons.feedback_outlined,
          accent: Color(0xFF5DE8A4),
        ),
        const Spacer(),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, color: Colors.white70),
        ),
      ],
    );
  }
}

class FeedbackStatusHalo extends StatelessWidget {
  const FeedbackStatusHalo({super.key, required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.25),
            color.withOpacity(0.0),
          ],
        ),
      ),
      child: Icon(icon, color: color, size: 44),
    );
  }
}

class FeedbackSnsSection extends StatelessWidget {
  const FeedbackSnsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<List<({String sns, String url})>>(
      future: SnsRepo().fetchList(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l10n.snsLoadError(snap.error.toString()),
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final items = snap.data ?? const [];
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.snsContactInfo,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 0,
              children: items.map((e) {
                return FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _open(context, e.url),
                  icon: Icon(Icons.north_east, color: cs.primary),
                  label: Text(
                    e.sns,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception(l10n.urlLaunchError(url));
    }
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned(
          top: -80,
          right: -40,
          child: _GlowBlob(
            color: Color(0xFF5DE8A4),
            size: 220,
          ),
        ),
        Positioned(
          bottom: -120,
          left: -60,
          child: _GlowBlob(
            color: Color(0xFF4FC3F7),
            size: 260,
          ),
        ),
        Positioned(
          bottom: 120,
          right: -40,
          child: _GlowBlob(
            color: Color(0xFFE1B563),
            size: 180,
          ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.4),
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1C2A34)
      ..strokeWidth = 1;

    const spacing = 28.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
