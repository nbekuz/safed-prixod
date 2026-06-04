import 'package:safed_prixod/l10n/app_locale.dart';

/// Product display name from API translations for the active locale.
String productNameForLocale(
  Map<String, dynamic> line,
  AppLocale locale,
  String Function(int productId) fallback,
) {
  final p = line['product'];
  if (p is! Map) {
    final id = line['product_id'];
    return fallback(id is int ? id : 0);
  }

  final tr = p['translations'];
  if (tr is Map) {
    final lang = tr[locale.languageCode];
    if (lang is Map && lang['name'] != null) {
      return lang['name'].toString();
    }
    for (final code in ['uz', 'ru']) {
      final alt = tr[code];
      if (alt is Map && alt['name'] != null) return alt['name'].toString();
    }
  }

  final id = line['product_id'];
  return fallback(id is int ? id : 0);
}

String? productTranslationField(
  Map<String, dynamic> line,
  AppLocale locale,
  String field,
) {
  final p = line['product'];
  if (p is! Map) return null;
  final tr = p['translations'];
  if (tr is! Map) return null;

  String? pick(Map? m) {
    if (m == null) return null;
    final v = m[field]?.toString().trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  final lang = tr[locale.languageCode];
  if (lang is Map) return pick(lang);
  for (final code in ['uz', 'ru', 'en']) {
    final alt = tr[code];
    if (alt is Map) {
      final v = pick(alt);
      if (v != null) return v;
    }
  }
  return null;
}

/// Mahsulot grammage (masalan «1 kg», «1 кг»).
String? productGrammageForLocale(Map<String, dynamic> line, AppLocale locale) =>
    productTranslationField(line, locale, 'grammage');
