// オーバーレイ用の共通Widgetをまとめる。
import 'package:flutter/material.dart';

class OverlayTokens {
  const OverlayTokens();

  static const Color ink = Color(0xFFF2F4F5);
  static const Color muted = Color(0xFF9AA7B2);
  static const Color panel = Color(0xFF1A2126);
  static const Color panelSoft = Color(0xFF232C32);
  static const Color border = Color(0xFF33414B);
  static const Color accent = Color(0xFF1BA784);
  static const Color accentWarm = Color(0xFFE1B563);
  static const Color attacker = Color(0xFFE8615E);
  static const Color defender = Color(0xFF58A6FF);
  static const Color smoke = Color(0xFF8B98A4);
  static const Color alert = Color(0xFFF06D4F);

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1F2A33), Color(0xFF141B20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF232C32), Color(0xFF1A2126)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class TacticalPanel extends StatelessWidget {
  const TacticalPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.width,
    this.height,
    this.gradient,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? OverlayTokens.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? OverlayTokens.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0xAA050607),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class TacticalBadge extends StatelessWidget {
  const TacticalBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  final String label;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? OverlayTokens.panelSoft).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OverlayTokens.border),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor ?? OverlayTokens.ink,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class TacticalActionTile extends StatelessWidget {
  const TacticalActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.detail,
    this.accent,
    this.enabled = true,
    this.visualEnabled,
    this.highlighted = false,
    this.emphasis = 1.0,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final Color? accent;
  final bool enabled;
  final bool? visualEnabled;
  final bool highlighted;
  final double emphasis;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = accent ?? OverlayTokens.accent;
    final tone = emphasis.clamp(0.0, 1.0);
    final color = Color.lerp(OverlayTokens.muted, baseColor, tone)!;
    final labelColor = Color.lerp(OverlayTokens.muted, OverlayTokens.ink, tone)!;
    final detailColor = Color.lerp(OverlayTokens.muted, OverlayTokens.muted, tone)!;
    final visualOn = visualEnabled ?? enabled;
    final opacity = visualOn ? 1.0 : 0.4;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: TacticalPanel(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderColor: highlighted ? color : null,
        child: Opacity(
          opacity: opacity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(46),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: labelColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: detailColor,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TacticalDivider extends StatelessWidget {
  const TacticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x003A4852), Color(0xFF3A4852), Color(0x003A4852)],
        ),
      ),
    );
  }
}
