// オンライン対戦のプレイヤーバッジを描画する。
import 'package:flutter/material.dart';

import '../../core/entities.dart';

class PlayerBadge extends StatelessWidget {
  const PlayerBadge({
    super.key,
    required this.label,
    required this.side,
    this.record = '',
  });

  final String label;
  final TeamId side;
  final String record;

  @override
  Widget build(BuildContext context) {
    final color = side == TeamId.attacker
        ? const Color(0xFFE57373)
        : const Color(0xFF4FC3F7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          if (record.isNotEmpty)
            Text(
              record,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.text, required this.ok});

  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFF1BA784).withOpacity(0.15) : Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ok ? const Color(0xFF1BA784) : Colors.white30,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: ok ? const Color(0xFF1BA784) : Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
