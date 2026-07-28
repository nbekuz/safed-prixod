import 'package:dio/dio.dart';

typedef TokenReader = String? Function();

Dio createSafedDio({
  required String baseUrl,
  required TokenReader readToken,
  String acceptLanguage = 'ru',
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Accept-Language': acceptLanguage,
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}
