import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safed_core/safed_core.dart';
import 'package:safed_prixod/core/app_providers.dart';
import 'package:safed_prixod/core/locale_provider.dart';
import 'package:safed_prixod/features/orders/order_format.dart';

final couriersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) {
  return ref.watch(staffOrdersApiProvider).fetchCouriers();
});

Future<void> showCourierSelectSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int orderId,
  required VoidCallback onDone,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _CourierSelectSheetBody(
      orderId: orderId,
      onDone: onDone,
    ),
  );
}

class _CourierSelectSheetBody extends ConsumerStatefulWidget {
  const _CourierSelectSheetBody({
    required this.orderId,
    required this.onDone,
  });

  final int orderId;
  final VoidCallback onDone;

  @override
  ConsumerState<_CourierSelectSheetBody> createState() =>
      _CourierSelectSheetBodyState();
}

class _CourierSelectSheetBodyState extends ConsumerState<_CourierSelectSheetBody> {
  int? _selectedId;
  bool _busy = false;

  String _courierLabel(Map<String, dynamic> c) {
    final first = c['first_name']?.toString().trim() ?? '';
    final last = c['last_name']?.toString().trim() ?? '';
    final name = [first, last].where((s) => s.isNotEmpty).join(' ');
    if (name.isNotEmpty) return name;
    return formatPhoneDisplay(c['phone']?.toString());
  }

  Future<void> _assign() async {
    final id = _selectedId;
    if (id == null || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(staffOrdersApiProvider).addCourier(widget.orderId, id);
      if (mounted) Navigator.pop(context);
      widget.onDone();
      ref.read(appToastProvider.notifier).success(
        ref.read(l10nProvider).statusChanged('shipped'),
      );
    } catch (e) {
      showApiError(ref, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final async = ref.watch(couriersProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.selectCourier,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(messageFromObject(e)),
            data: (list) {
              final available = list.where((c) => c['is_busy'] != true).toList();
              if (available.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.noCouriers, textAlign: TextAlign.center),
                );
              }
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: available.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final c = available[i];
                    final id = c['id'] as int?;
                    if (id == null) return const SizedBox.shrink();
                    final selected = _selectedId == id;
                    return Material(
                      color: selected
                          ? AppTheme.primaryGreen.withValues(alpha: 0.08)
                          : AppTheme.surfaceGrey,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => setState(() => _selectedId = id),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected
                                    ? AppTheme.primaryGreen
                                    : AppTheme.textSecondary,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _courierLabel(c),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      formatPhoneDisplay(c['phone']?.toString()),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: (_selectedId == null || _busy) ? null : _assign,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.assignCourier),
          ),
        ],
      ),
    );
  }
}
