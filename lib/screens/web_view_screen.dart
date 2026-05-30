import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lightweight screen that simply opens [url] in the system browser.
/// No webview dependency needed.
class WebViewScreen extends StatelessWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    // Launch immediately in system browser and pop back.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (context.mounted) Navigator.of(context).pop();
    });

    return const Scaffold(
      backgroundColor: Color(0xFF0A0520),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFD4A017)),
      ),
    );
  }
}
