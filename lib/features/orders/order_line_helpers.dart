import 'package:safed_prixod/features/orders/unit_helpers.dart';

String? shelfLocationFromLine(Map<String, dynamic> line) {
  final p = line['product'];
  if (p is! Map) return null;
  final raw = p['shelf_location'];
  if (raw == null) return null;
  final s = raw.toString().trim();
  return s.isEmpty ? null : s;
}

String formatQuantityNumber(dynamic raw) {
  if (raw == null) return '—';
  final v = double.tryParse(raw.toString().replaceAll(',', '.'));
  if (v == null) return raw.toString();
  if (v == v.roundToDouble()) return v.round().toString();
  final s = v.toStringAsFixed(3);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

String formatOrderedQuantityShort(Map<String, dynamic> line) {
  final n = formatQuantityNumber(line['ordered_quantity']);
  final unit = unitNameFromLine(line);
  if (unit.isEmpty) return n;
  return '$n $unit';
}

String? quantityFieldSuffix(Map<String, dynamic> line) {
  final unit = unitNameFromLine(line);
  return unit.isEmpty ? null : unit;
}
