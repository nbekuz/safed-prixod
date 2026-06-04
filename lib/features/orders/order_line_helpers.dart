import 'package:safed_prixod/features/orders/unit_helpers.dart';
import 'package:safed_prixod/l10n/app_locale.dart';

/// Buyurtma qatoridagi mahsulot maydonlari.
String? shelfLocationFromLine(Map<String, dynamic> line) {
  final p = line['product'];
  if (p is! Map) return null;
  final raw = p['shelf_location'];
  if (raw == null) return null;
  final s = raw.toString().trim();
  return s.isEmpty ? null : s;
}

/// 1.000 → 1, 1.500 → 1.5
String formatQuantityNumber(dynamic raw) {
  if (raw == null) return '—';
  final v = double.tryParse(raw.toString().replaceAll(',', '.'));
  if (v == null) return raw.toString();
  if (v == v.roundToDouble()) return v.round().toString();
  final s = v.toStringAsFixed(3);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// Buyurtma miqdori: «3 kg», «40 dona» (units API / product.unit).
String formatOrderedQuantityShort(
  Map<String, dynamic> line,
  AppLocale locale,
) {
  final n = formatQuantityNumber(line['ordered_quantity']);
  final unit = unitNameFromLine(line, locale);
  if (unit.isEmpty) return n;
  return '$n $unit';
}

/// Miqdor maydoni suffixi.
String? quantityFieldSuffix(Map<String, dynamic> line, AppLocale locale) {
  final unit = unitNameFromLine(line, locale);
  return unit.isEmpty ? null : unit;
}
