import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Feedback screen for user inquiries
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  bool _sending = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendInquiry() async {
    if (_msgCtrl.text.trim().isEmpty) {
      setState(() {
        _error = '内容を入力してください';
      });
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.from('inquiries').insert({
        'message': _msgCtrl.text.trim(),
      });
      if (mounted) {
        setState(() {
          _sent = true;
          _sending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '送信に失敗しました: $e';
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1216),
      body: SafeArea(
        child: Stack(
          children: [
            _BackgroundGlow(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _sent ? _buildSuccessView() : _buildFormView(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatusHalo(
            color: const Color(0xFF5DE8A4),
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 24),
          const Text(
            '送信完了',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'ご要望ありがとうございます！\n確認次第対応いたします。',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5DE8A4),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'ゲームに戻る',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _ModeChip(
              label: 'FEEDBACK',
              icon: Icons.feedback_outlined,
              accent: const Color(0xFF5DE8A4),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'ご意見・ご要望を\nお聞かせください',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '戦術体験を磨くための声をお待ちしています。',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5DE8A4).withOpacity(0.4),
                  const Color(0xFF4FC3F7).withOpacity(0.2),
                  const Color(0xFFE1B563).withOpacity(0.3),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121B22).withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _error != null
                      ? const Color(0xFFE57373)
                      : Colors.white24,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _msgCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: '例: スモークの残り時間をHUDに表示してほしい...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onChanged: (_) {
                  if (_error != null) {
                    setState(() => _error = null);
                  }
                },
              ),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(
              color: Color(0xFFE57373),
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _sending ? null : _sendInquiry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5DE8A4),
              disabledBackgroundColor: const Color(0xFF5DE8A4).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _sending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Text(
                    '送信する',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -40,
          child: _GlowBlob(
            color: const Color(0xFF5DE8A4),
            size: 220,
          ),
        ),
        Positioned(
          bottom: -120,
          left: -60,
          child: _GlowBlob(
            color: const Color(0xFF4FC3F7),
            size: 260,
          ),
        ),
        Positioned(
          bottom: 120,
          right: -40,
          child: _GlowBlob(
            color: const Color(0xFFE1B563),
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

class _StatusHalo extends StatelessWidget {
  const _StatusHalo({
    required this.color,
    required this.icon,
  });

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
