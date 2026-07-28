/// API holatini `created`, `confirmed` kabi kichik harfli kodga aylantiradi.
String normalizeOrderStatusCode(String raw) {
  var s = raw.trim().toLowerCase().replaceAll('-', '_');
  if (s.contains(' ')) {
    s = s.replaceAll(' ', '_');
  }
  const aliases = <String, String>{
    'in_progress': 'picking',
    'inprogress': 'picking',
    'canceled': 'cancelled',
  };
  return aliases[s] ?? s;
}

class OrderDto {
  OrderDto({
    required this.id,
    required this.status,
    this.statusDisplay,
    this.comment,
    this.canUserCancel = false,
    this.orderPricing,
    this.deliverySlot,
    this.orderProducts = const [],
    this.orderCouriers = const [],
    this.userData,
    this.createdAt,
  });

  final int id;
  final String status;
  final String? statusDisplay;
  final String? comment;
  final bool canUserCancel;
  final Map<String, dynamic>? orderPricing;
  final Map<String, dynamic>? deliverySlot;
  final List<Map<String, dynamic>> orderProducts;
  final List<Map<String, dynamic>> orderCouriers;
  final Map<String, dynamic>? userData;
  final String? createdAt;

  String? get paymentType => orderPricing?['payment_type']?.toString();
  String? get estimatedTotal =>
      orderPricing?['estimated_total']?.toString() ??
      orderPricing?['total_amount']?.toString();
  String? get address => deliverySlot?['address']?.toString();

  String? get deliveryDate => deliverySlot?['date']?.toString();
  String? get deliveryTimeStart => deliverySlot?['time_start']?.toString();
  String? get deliveryTimeEnd => deliverySlot?['time_end']?.toString();

  DateTime? get deliverySortAt {
    final date = deliveryDate;
    if (date == null || date.isEmpty) return null;
    final parts = date.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    var hour = 23;
    var minute = 59;
    final start = deliveryTimeStart;
    if (start != null && start.contains(':')) {
      final tp = start.split(':');
      hour = int.tryParse(tp[0]) ?? hour;
      minute = int.tryParse(tp.length > 1 ? tp[1] : '') ?? minute;
    }
    return DateTime(y, m, d, hour, minute);
  }

  String get customerName {
    final u = userData;
    if (u == null) return '';
    final first = u['first_name']?.toString().trim() ?? '';
    final last = u['last_name']?.toString().trim() ?? '';
    return [first, last].where((s) => s.isNotEmpty).join(' ');
  }

  String? get customerPhone => userData?['phone']?.toString();

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    final ops = json['order_products'];
    final couriers = json['order_couriers'];
    final rawStatus =
        json['status']?.toString() ??
        json['status_display']?.toString() ??
        'created';
    return OrderDto(
      id: json['id'] as int,
      status: normalizeOrderStatusCode(rawStatus),
      statusDisplay: json['status_display']?.toString(),
      comment: json['comment']?.toString(),
      canUserCancel: json['can_user_cancel'] == true,
      orderPricing: json['order_pricing'] is Map
          ? Map<String, dynamic>.from(json['order_pricing'] as Map)
          : null,
      deliverySlot: json['delivery_slot'] is Map
          ? Map<String, dynamic>.from(json['delivery_slot'] as Map)
          : null,
      orderProducts: ops is List
          ? ops
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : const [],
      orderCouriers: couriers is List
          ? couriers
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : const [],
      userData: json['user_data'] is Map
          ? Map<String, dynamic>.from(json['user_data'] as Map)
          : null,
      createdAt: json['created_at']?.toString(),
    );
  }
}

List<OrderDto> parseOrderList(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map((e) => OrderDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  if (data is Map && data['results'] is List) {
    return parseOrderList(data['results']);
  }
  return const [];
}
