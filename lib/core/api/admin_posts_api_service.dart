import 'package:dio/dio.dart';

class AdminPostsApiService {
  AdminPostsApiService(this._dio);
  final Dio _dio;

  Future<List<Map<String, dynamic>>> list({bool? isActive}) async {
    final res = await _dio.get<dynamic>(
      'posts/',
      queryParameters: {
        if (isActive != null) 'is_active': isActive,
      },
    );
    final data = res.data;
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

  Future<Map<String, dynamic>> fetch(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('posts/$id/');
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  Future<void> create(FormData formData) async {
    await _dio.post<dynamic>('posts/create/', data: formData);
  }

  Future<void> update(int id, FormData formData) async {
    await _dio.put<dynamic>('posts/$id/update/', data: formData);
  }

  Future<void> delete(int id) async {
    await _dio.delete<dynamic>('posts/$id/delete/');
  }

  Future<void> deleteImage(int imageId) async {
    await _dio.delete<dynamic>('post-images/$imageId/delete/');
  }

  Future<void> addImages(int postId, FormData formData) async {
    await _dio.post<dynamic>('post-images/create/', data: formData);
  }
}
