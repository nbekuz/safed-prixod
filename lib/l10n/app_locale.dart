import 'package:flutter/material.dart';

/// Supported app languages (Uzbek default, Russian).
enum AppLocale {
  uz('uz', "O'zbek"),
  ru('ru', 'Русский');

  const AppLocale(this.languageCode, this.label);

  final String languageCode;
  final String label;

  Locale get flutterLocale => Locale(languageCode);

  static AppLocale fromCode(String? code) {
    if (code == null) return uz;
    return AppLocale.values.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => uz,
    );
  }

  static const supportedLocales = [
    Locale('uz'),
    Locale('ru'),
  ];
}
