import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safed_prixod/l10n/app_strings.dart';
import 'package:safed_prixod/l10n/app_strings_ru.dart';

final l10nProvider = Provider<AppStrings>((ref) => AppStringsRu());
