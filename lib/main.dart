import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safed_prixod/core/api_config.dart';
import 'package:safed_prixod/core/app_router.dart';
import 'package:safed_prixod/core/app_providers.dart';
import 'package:safed_prixod/core/camera_permission.dart';
import 'package:safed_core/safed_core.dart';
import 'package:safed_prixod/core/locale_provider.dart';
import 'package:safed_prixod/l10n/app_locale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SafedPrixodApp()));
}

class SafedPrixodApp extends ConsumerStatefulWidget {
  const SafedPrixodApp({super.key});

  @override
  ConsumerState<SafedPrixodApp> createState() => _SafedPrixodAppState();
}

class _SafedPrixodAppState extends ConsumerState<SafedPrixodApp> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    await requestCameraPermissionOnLaunch();
    await ref.read(staffLocaleProvider.notifier).restore();
    await ref.read(localeProvider.notifier).restore();
    final t = await ref.read(tokenStorageProvider).readAccess();
    if (t != null && t.isNotEmpty) {
      ref.read(accessTokenProvider.notifier).state = t;
    }
    if (mounted) {
      _printAccessToken(ref.read(accessTokenProvider));
      setState(() => _ready = true);
    }
  }

  void _printAccessToken(String? token) {
    debugPrint('[Prixod] access token (full): ${token ?? '(null)'}');
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final loggedIn = ref.watch(isLoggedInProvider);
    final staffLocale = ref.watch(staffLocaleProvider);

    ref.listen(staffLocaleProvider, (_, next) {
      final mapped = AppLocale.fromCode(next.languageCode);
      if (mapped != ref.read(localeProvider)) {
        ref.read(localeProvider.notifier).setLocale(mapped);
      }
    });

    ref.listen<String?>(accessTokenProvider, (_, next) {
      _printAccessToken(next);
    });

    final router = createPrixodRouter(loggedIn: loggedIn);

    return MaterialApp.router(
      title: '${ApiConfig.brandName} Prixod',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: staffLocale,
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (_, child) => AppToastOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
