import 'package:dio/dio.dart';
import 'package:safed_prixod/core/models/order_dto.dart';

class StaffOrdersApiService {
  StaffOrdersApiService(this._dio);
  final Dio _dio;

  Future<List<OrderDto>> activeOrders() async {
    final res = await _dio.get<dynamic>('orders/active/');
    return parseOrderList(res.data);
  }

  Future<OrderDto> fetchOrder(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('orders/$id/');
    return OrderDto.fromJson(Map<String, dynamic>.from(res.data ?? const {}));
  }

  Future<void> patchStatus(int orderId, String status) async {
    await _dio.patch<dynamic>(
      'orders/$orderId/status/',
      data: {'status': status},
    );
  }

  Future<void> scanBarcode(
    int orderId, {
    required String barcode,
    required String quantity,
    required String productUnit,
  }) async {
    await _dio.post<dynamic>(
      'orders/$orderId/picking/scan/',
      data: {
        'barcode': barcode,
        'quantity': quantity,
        'product_unit': productUnit,
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchCouriers() async {
    final res = await _dio.get<dynamic>('staff/couriers/');
    final data = res.data;
    if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<void> addCourier(int orderId, int courierId) async {
    await _dio.post<dynamic>(
      'orders/$orderId/add-courier/',
      data: {'courier_id': courierId},
    );
  }
}
