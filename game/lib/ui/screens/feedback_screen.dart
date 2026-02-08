// フィードバック送信画面を表示する。
import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/feedback_widgets.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    if (_msgCtrl.text.trim().isEmpty) {
      setState(() {
        _error = l10n.feedbackEmptyError;
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
          _error = l10n.feedbackError(e.toString());
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
            const FeedbackBackground(),
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
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FeedbackStatusHalo(
            color: Color(0xFF5DE8A4),
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.feedbackSent,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.feedbackThanks,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
            child: Text(
              l10n.feedbackReturnToGame,
              style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeedbackHeaderBar(
          onClose: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.feedbackTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.feedbackSubtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5DE8A4).withOpacity(0.4),
                  const Color(0xFF1BA784).withOpacity(0.35),
                  const Color(0xFF4FC3F7).withOpacity(0.25),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111A21).withOpacity(0.96),
                borderRadius: BorderRadius.circular(16),
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
                decoration: InputDecoration(
                  hintText: l10n.feedbackPlaceholder,
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(18),
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
                : Text(
                    l10n.feedbackSend,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        const FeedbackSnsSection(),
      ],
    );
  }
}
