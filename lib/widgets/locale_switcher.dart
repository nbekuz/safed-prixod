import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safed_core/safed_core.dart';
import 'package:safed_prixod/core/locale_provider.dart';
import 'package:safed_prixod/l10n/app_locale.dart';

/// Compact language picker (UZ / RU) for login and other screens.
class LocaleSwitcher extends ConsumerWidget {
  const LocaleSwitcher({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);

    if (compact) {
      return SegmentedButton<AppLocale>(
        segments: [
          for (final locale in AppLocale.values)
            ButtonSegment(
              value: locale,
              label: Text(locale.label, style: const TextStyle(fontSize: 13)),
            ),
        ],
        selected: {current},
        onSelectionChanged: (selected) {
          final locale = selected.first;
          ref.read(localeProvider.notifier).setLocale(locale);
          ref.read(staffLocaleProvider.notifier).setLocale(
            Locale(locale.languageCode),
          );
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final locale in AppLocale.values) ...[
              if (locale != AppLocale.uz) const SizedBox(width: 4),
              Expanded(
                child: _LocaleTile(
                  locale: locale,
                  selected: current == locale,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(locale);
                    ref.read(staffLocaleProvider.notifier).setLocale(
                      Locale(locale.languageCode),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LocaleTile extends StatelessWidget {
  const _LocaleTile({
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final AppLocale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      elevation: selected ? 1 : 0,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            locale.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppTheme.primaryGreen : AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
