import 'package:dio/dio.dart';

class AdminProductsApiService {
  AdminProductsApiService(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> list({
    required int page,
    required int pageSize,
    String? search,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'products/',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  Future<Map<String, dynamic>> fetch(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('products/$id/');
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  Future<void> create(FormData formData) async {
    await _dio.post<dynamic>('products/', data: formData);
  }

  Future<void> update(int id, FormData formData) async {
    await _dio.put<dynamic>('products/$id/', data: formData);
  }

  Future<void> delete(int id) async {
    await _dio.delete<dynamic>('products/$id/');
  }

  Future<void> updateBarcode(int barcodeRecordId, String barcode) async {
    await _dio.put<dynamic>(
      'product-barcodes/$barcodeRecordId/',
      data: {'barcode': barcode},
    );
  }

  Future<void> deleteImage(int imageId) async {
    await _dio.delete<dynamic>('product-images/$imageId/');
  }
}
