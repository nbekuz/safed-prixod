import 'package:dio/dio.dart';

String messageFromDio(DioException e) {
  final data = e.response?.data;
  if (data is Map) {
    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty) {
      return detail.map((x) => x.toString()).join('\n');
    }
    final parts = <String>[];
    for (final entry in data.entries) {
      if (entry.key == 'detail') continue;
      final v = entry.value;
      if (v is List && v.isNotEmpty) {
        parts.add('${entry.key}: ${v.first}');
      } else if (v != null) {
        parts.add('${entry.key}: $v');
      }
    }
    if (parts.isNotEmpty) return parts.join('\n');
  }
  if (data is String && data.trim().isNotEmpty) return data;
  return e.message ?? 'Ошибка сети';
}

String messageFromObject(Object? error) {
  if (error is DioException) return messageFromDio(error);
  if (error == null) return 'Неизвестная ошибка';
  return error.toString();
}
