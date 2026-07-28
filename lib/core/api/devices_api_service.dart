import 'dart:io';

import 'package:dio/dio.dart';

class DevicesApiService {
  DevicesApiService(this._dio);
  final Dio _dio;

  static String deviceTypeFromPlatform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }

  Future<void> registerToken(String deviceToken) async {
    await _dio.post<dynamic>(
      'devices/',
      data: {
        'device_token': deviceToken,
        'device_type': deviceTypeFromPlatform(),
      },
    );
  }
}
