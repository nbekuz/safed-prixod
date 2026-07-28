import 'package:safed_prixod/core/app_language.dart';

String localizedUnitName(Map<String, dynamic>? unit) {
  if (unit == null) return '';
  final name = unit['name'];
  if (name is! Map) return '';

  String? pick(Map? m) {
    if (m == null) return null;
    final v = m['name']?.toString().trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  final lang = name[kAppLanguageCode];
  if (lang is Map) {
    final v = pick(lang);
    if (v != null) return v;
  }
  for (final code in ['ru', 'uz', 'en']) {
    final alt = name[code];
    if (alt is Map) {
      final v = pick(alt);
      if (v != null) return v;
    }
  }
  return '';
}

String unitNameFromLine(Map<String, dynamic> line) {
  final p = line['product'];
  if (p is Map && p['unit'] is Map) {
    final name = localizedUnitName(
      Map<String, dynamic>.from(p['unit'] as Map),
    );
    if (name.isNotEmpty) return name;
  }

  final sale = line['product_unit'] ?? line['sale_unit'];
  if (p is Map) {
    final su = p['sale_unit'] ?? p['product_unit'] ?? sale;
    return _fallbackUnitLabel(su?.toString());
  }
  return _fallbackUnitLabel(sale?.toString());
}

String productUnitApiFromLine(Map<String, dynamic> line) {
  final p = line['product'];
  final raw = line['product_unit'] ??
      (p is Map ? p['product_unit'] ?? p['sale_unit'] : null);
  final u = (raw?.toString() ?? 'piece').toLowerCase();
  if (u == 'kg') return 'kg';
  if (u == 'gram' || u == 'g') return 'gram';
  return 'piece';
}

String _fallbackUnitLabel(String? saleUnit) {
  if (saleUnit == null) return '';
  final u = saleUnit.toLowerCase();
  if (u == 'piece' || u == 'pcs') return 'шт';
  if (u == 'kg') return 'kg';
  if (u == 'g') return 'g';
  return saleUnit;
}
