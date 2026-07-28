import 'package:dio/dio.dart';

class CatalogMetaApiService {
  CatalogMetaApiService(this._dio);
  final Dio _dio;

  Future<List<dynamic>> categories() async {
    final res = await _dio.get<dynamic>('categories/');
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['results'] is List) {
      return List<dynamic>.from(data['results'] as List);
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> badges() async {
    final res = await _dio.get<dynamic>('badges/');
    return _parseList(res.data);
  }

  Future<List<Map<String, dynamic>>> units() async {
    final res = await _dio.get<dynamic>('units/');
    return _parseList(res.data);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }
}
