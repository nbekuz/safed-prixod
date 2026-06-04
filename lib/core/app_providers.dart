import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safed_prixod/core/api_config.dart';
import 'package:safed_core/safed_core.dart';

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

final accessTokenProvider = StateProvider<String?>((_) => null);

final dioProvider = Provider<Dio>((ref) {
  return createSafedDio(
    baseUrl: ApiConfig.baseUrl,
    readToken: () => ref.read(accessTokenProvider),
  );
});

final authApiProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(ref.watch(dioProvider)),
);

final staffOrdersApiProvider = Provider<StaffOrdersApiService>(
  (ref) => StaffOrdersApiService(ref.watch(dioProvider)),
);

final notificationsApiProvider = Provider<NotificationsApiService>(
  (ref) => NotificationsApiService(ref.watch(dioProvider)),
);

final isLoggedInProvider = Provider<bool>(
  (ref) => (ref.watch(accessTokenProvider) ?? '').isNotEmpty,
);
