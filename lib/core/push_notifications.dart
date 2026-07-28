import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/core/app_providers.dart';
import 'package:safed_prixod/core/app_router.dart';
import 'package:safed_prixod/features/notifications/staff_notifications_page.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] background: ${message.messageId}');
}

class PushNotifications {
  PushNotifications._();

  static bool _initialized = false;
  static String? _lastRegisteredToken;

  static Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _initialized = true;
      debugPrint('[FCM] Firebase initialized');
    } catch (e, st) {
      debugPrint('[FCM] init failed: $e\n$st');
    }
  }

  static Future<void> bind(WidgetRef ref) async {
    if (!_initialized) return;

    final messaging = FirebaseMessaging.instance;
    await _requestPermissions();
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      _onForegroundMessage(ref, message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      _openNotifications();
    });

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openNotifications();
      });
    }

    messaging.onTokenRefresh.listen((token) {
      _registerToken(ref, token);
    });

    final token = await messaging.getToken();
    if (token != null) {
      await _registerToken(ref, token);
    }
  }

  static Future<void> syncToken(WidgetRef ref) async {
    if (!_initialized) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _registerToken(ref, token);
    }
  }

  static Future<void> _requestPermissions() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  static Future<void> _registerToken(WidgetRef ref, String token) async {
    if (!(ref.read(isLoggedInProvider))) return;
    if (_lastRegisteredToken == token) return;

    try {
      await ref.read(devicesApiProvider).registerToken(token);
      _lastRegisteredToken = token;
      debugPrint('[FCM] device token registered');
    } catch (e, st) {
      debugPrint('[FCM] register failed: $e\n$st');
    }
  }

  static void _onForegroundMessage(WidgetRef ref, RemoteMessage message) {
    ref.invalidate(staffNotificationsProvider);

    final title = message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    if ((title ?? '').isNotEmpty || (body ?? '').isNotEmpty) {
      ref.read(appToastProvider.notifier).info(
        [title, body].where((s) => s != null && s.isNotEmpty).join('\n'),
      );
    }
  }

  static void _openNotifications() {
    final ctx = prixodNavigatorKey.currentContext;
    if (ctx == null) return;
    GoRouter.of(ctx).go('/notifications');
  }
}
