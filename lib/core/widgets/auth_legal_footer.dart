import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:safed_prixod/core/legal_urls.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthLegalFooter extends StatefulWidget {
  const AuthLegalFooter({super.key});

  @override
  State<AuthLegalFooter> createState() => _AuthLegalFooterState();
}

class _AuthLegalFooterState extends State<AuthLegalFooter> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () => _open(LegalUrls.terms);
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => _open(LegalUrls.privacy);
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      height: 1.45,
    );
    final linkStyle = baseStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: 'Продолжая, вы соглашаетесь с '),
            TextSpan(
              text: 'Условиями использования',
              style: linkStyle,
              recognizer: _termsTap,
            ),
            const TextSpan(text: ' и '),
            TextSpan(
              text: 'Политикой конфиденциальности',
              style: linkStyle,
              recognizer: _privacyTap,
            ),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
