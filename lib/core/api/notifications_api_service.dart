import 'package:dio/dio.dart';

class NotificationsApiService {
  NotificationsApiService(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> list({
    required String audience,
    bool? isRead,
    int limit = 50,
    int offset = 0,
  }) async {
    final path = switch (audience) {
      'staff' => 'notifications/staff/',
      'courier' => 'notifications/courier/',
      'customer' => 'notifications/customer/',
      _ => 'notifications/',
    };
    final res = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {
        if (isRead != null) 'is_read': isRead,
        'limit': limit,
        'offset': offset,
      },
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }
}
