import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/entities.dart';

/// Individual tile widget
class TileWidget extends StatelessWidget {
  const TileWidget({
    super.key,
    required this.tile,
    this.unit,
    this.isHighlighted = false,
    this.isSelected = false,
    this.isSkillTarget = false,
    required this.onTap,
  });

  final Tile tile;
  final UnitState? unit;
  final bool isHighlighted;
  final bool isSelected;
  final bool isSkillTarget;
  final VoidCallback onTap;

  Color get _tileColor {
    if (!tile.walkable) {
      return const Color(0xFF5D4037); // Wall - Brown
    }

    switch (tile.type) {
      case TileType.siteA:
        return const Color(0xFF3D7AB8); // Blue
      case TileType.siteB:
        return const Color(0xFFB83D3D); // Red
      case TileType.mid:
        return const Color(0xFF8FB83D); // Yellow-green
      default:
        return const Color(0xFFF5F5F5); // Floor - almost white
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _tileColor,
          // Remove rounded corners to close gaps visually
          borderRadius: BorderRadius.zero,
          border: isSelected
              ? Border.all(color: Colors.yellow, width: 3)
              : isSkillTarget
                  ? Border.all(color: const Color(0xFFFFA74A), width: 2.5)
                  : isHighlighted
                      // Make highlight border inside to avoid layout shift
                      ? Border.fromBorderSide(const BorderSide(color: Colors.greenAccent, width: 2))
                      : (!tile.walkable)
                          // Add border to walls for "3D" look
                          ? Border.all(color: Colors.black26, width: 1)
                          : Border.all(color: Colors.grey.shade300, width: 0.5),
          boxShadow: tile.walkable
              ? [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Brick pattern for walls
            if (!tile.walkable)
              Positioned.fill(
                child: CustomPaint(
                  painter: BrickPainter(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            // Zone label
            if (_shouldShowLabel)
              Positioned(
                top: 2,
                left: 4,
                child: Text(
                  _zoneLabel,
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // Unit
            if (unit != null)
              Center(
                child: UnitIcon(unit: unit!),
              ),
          ],
        ),
      ),
    );
  }

  bool get _shouldShowLabel {
    return tile.type == TileType.siteA || tile.type == TileType.siteB;
  }

  String get _zoneLabel {
    switch (tile.type) {
      case TileType.siteA:
        return 'A';
      case TileType.siteB:
        return 'B';
      default:
        return '';
    }
  }
}

class BrickPainter extends CustomPainter {
  BrickPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final w = size.width;
    final h = size.height;

    // Horizontal lines (3 rows)
    final rowH = h / 3;
    canvas.drawLine(Offset(0, rowH), Offset(w, rowH), paint);
    canvas.drawLine(Offset(0, rowH * 2), Offset(w, rowH * 2), paint);

    // Vertical lines (staggered)
    // Row 1 & 3: Line in middle
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, rowH), paint);
    canvas.drawLine(Offset(w / 2, rowH * 2), Offset(w / 2, h), paint);

    // Row 2: Lines at 1/4 and 3/4
    canvas.drawLine(Offset(w / 4, rowH), Offset(w / 4, rowH * 2), paint);
    canvas.drawLine(Offset(w * 0.75, rowH), Offset(w * 0.75, rowH * 2), paint);
  }

  @override
  bool shouldRepaint(BrickPainter oldDelegate) => color != oldDelegate.color;
}

class UnitIcon extends StatefulWidget {
  const UnitIcon({super.key, required this.unit});

  final UnitState unit;

  @override
  State<UnitIcon> createState() => _UnitIconState();
}

class _UnitIconState extends State<UnitIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _syncShake();
  }

  @override
  void didUpdateWidget(UnitIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncShake();
  }

  void _syncShake() {
    if (_isStunned) {
      if (!_shakeController.isAnimating) {
        _shakeController.repeat(reverse: true);
      }
    } else {
      if (_shakeController.isAnimating) {
        _shakeController.stop();
        _shakeController.reset();
      }
    }
  }

  bool get _isStunned {
    return widget.unit.statuses.any(
      (s) => s.type == StatusType.stunned && s.remainingTurns > 0,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;
    final isAttacker = unit.team == TeamId.attacker;
    final bgColor = isAttacker ? const Color(0xFFE57373) : const Color(0xFF4FC3F7);
    final isRevealed = unit.statuses.any((s) => s.type == StatusType.revealed && s.remainingTurns > 0);
    final revealGlow = const Color(0xFF38E58A);
    final isBlinded = unit.statuses.any((s) => s.type == StatusType.blinded && s.remainingTurns > 0);
    final blindGlow = const Color(0xFFFFE88C);
    final stunGlow = const Color(0xFFFFB74D);

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shakeAmount = _isStunned ? 2.0 : 0.0;
        final dx = math.sin(_shakeController.value * math.pi * 2) * shakeAmount;
        final dy = math.cos(_shakeController.value * math.pi * 4) * (shakeAmount * 0.5);
        return Transform.translate(
          offset: Offset(dx, dy),
          child: child,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: isRevealed ? revealGlow : Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withAlpha(128),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
                if (isRevealed)
                  BoxShadow(
                    color: revealGlow.withOpacity(0.7),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                if (_isStunned)
                  BoxShadow(
                    color: stunGlow.withOpacity(0.8),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                _roleIcon(unit.card.role),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          if (isBlinded)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: blindGlow.withOpacity(0.85),
                        blurRadius: 14,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.7),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _roleIcon(Role role) {
    switch (role) {
      case Role.entry:
        return '⚔️';
      case Role.recon:
        return '👁️';
      case Role.smoke:
        return '💨';
      case Role.sentinel:
        return '🛡️';
    }
  }
}
