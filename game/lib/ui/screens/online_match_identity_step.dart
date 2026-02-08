// オンライン対戦のプロフィール登録UI。
import 'package:flutter/material.dart';
import 'package:game/l10n/app_localizations.dart';

class OnlineIdentityStep extends StatelessWidget {
  const OnlineIdentityStep({
    super.key,
    required this.usernameCtrl,
    required this.busy,
    required this.status,
    required this.error,
    required this.onSubmit,
    required this.onBack,
  });

  final TextEditingController usernameCtrl;
  final bool busy;
  final String? status;
  final String? error;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.onlineProfileTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onBack,
                child: Text(
                  l10n.back,
                  style: const TextStyle(letterSpacing: 2),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: usernameCtrl,
              decoration: InputDecoration(
                labelText: l10n.onlineUsernameLabel,
                filled: true,
                fillColor: const Color(0xFF161C21),
                labelStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              maxLength: 12,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: busy ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BA784),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l10n.onlineUsernameSave),
              ),
            ),
            const SizedBox(height: 8),
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.white70)),
            if (error != null)
              Text(error!, style: const TextStyle(color: Color(0xFFE57373))),
          ],
        ),
      ),
    );
  }
}
