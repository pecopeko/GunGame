import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

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
    //   await Supabase.instance.client.from('inquiries').insert({
    //     'message': _msgCtrl.text.trim(),
    //   });
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
      backgroundColor: const Color(0xFF0F1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2530),
        title: const Text(
          '要望を送る',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _sent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF4CAF50),
              size: 48,
            ),
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
              backgroundColor: const Color(0xFF4FC3F7),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'ゲームに戻る',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ご意見・ご要望をお聞かせください',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'ゲームの改善に役立てさせていただきます。',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A2530),
              borderRadius: BorderRadius.circular(12),
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
                hintText: 'ここに入力...',
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
              backgroundColor: const Color(0xFF4FC3F7),
              disabledBackgroundColor: const Color(0xFF4FC3F7).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _sending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '送信する',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
