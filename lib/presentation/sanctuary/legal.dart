import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/aegis_palette.dart';

/// Footer with the App-Store-required Privacy / Support links. Opens the URLs
/// in the system browser via url_launcher (no in-app webview dependency).
class LegalRow extends StatelessWidget {
  const LegalRow({super.key});

  static const _privacy = 'https://zeusboltdash.com/privacy-policy.html';
  static const _support = 'https://zeusboltdash.com/support.html';

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _link('Privacy Policy', () => _open(_privacy)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('•',
              style: TextStyle(
                  color: AegisPalette.parchmentDim.withValues(alpha: 0.6))),
        ),
        _link('Support', () => _open(_support)),
      ],
    );
  }

  Widget _link(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF7FB2E8),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF7FB2E8),
        ),
      ),
    );
  }
}
