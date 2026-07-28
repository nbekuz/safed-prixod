import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safed_prixod/core/api_config.dart';
import 'package:safed_prixod/core/app_router.dart';
import 'package:safed_prixod/core/app_providers.dart';
import 'package:safed_prixod/core/app_language.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/core/push_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotifications.initialize();
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
    final t = await ref.read(tokenStorageProvider).readAccess();
    if (t != null && t.isNotEmpty) {
      ref.read(accessTokenProvider.notifier).state = t;
    }
    await PushNotifications.bind(ref);
    if (mounted) {
      setState(() => _ready = true);
    }
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

    ref.listen<String?>(accessTokenProvider, (_, next) {
      if ((next ?? '').isNotEmpty) {
        PushNotifications.syncToken(ref);
      }
    });

    final router = createPrixodRouter(loggedIn: loggedIn);

    return MaterialApp.router(
      title: ApiConfig.appDisplayName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: kAppLocale,
      supportedLocales: const [kAppLocale],
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
