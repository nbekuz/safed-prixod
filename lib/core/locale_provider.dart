import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safed_prixod/l10n/app_locale.dart';
import 'package:safed_prixod/l10n/app_strings.dart';

const _localeKey = 'app_locale';

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  return LocaleNotifier();
});

final l10nProvider = Provider<AppStrings>((ref) {
  return AppStrings.of(ref.watch(localeProvider));
});

class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier() : super(AppLocale.uz);

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppLocale.fromCode(prefs.getString(_localeKey));
  }

  Future<void> setLocale(AppLocale locale) async {
    if (state == locale) return;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}
