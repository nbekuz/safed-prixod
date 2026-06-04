import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safed_core/safed_core.dart';
import 'package:safed_prixod/core/app_providers.dart';
import 'package:safed_prixod/core/locale_provider.dart';
import 'package:safed_prixod/features/orders/order_status_flow.dart';
import 'package:safed_prixod/features/orders/picking_orders_page.dart';
import 'package:safed_prixod/features/orders/widgets/order_detail_ui.dart';
import 'package:safed_prixod/features/orders/widgets/order_product_tile.dart';

final pickingDetailProvider = FutureProvider.autoDispose.family<OrderDto, int>((
  ref,
  id,
) {
  return ref.watch(staffOrdersApiProvider).fetchOrder(id);
});

class PickingDetailPage extends ConsumerStatefulWidget {
  const PickingDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  ConsumerState<PickingDetailPage> createState() => _PickingDetailPageState();
}

class _PickingDetailPageState extends ConsumerState<PickingDetailPage> {
  bool _busy = false;

  Future<void> _changeStatus(OrderStatusTransition t) async {
    if (t.openCheckPage || t.targetStatus == kCheckPageAction) {
      context.push('/orders/${widget.orderId}/check');
      return;
    }

    final l10n = ref.read(l10nProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          l10n.confirmStatusChange(t.label),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogNo),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.dialogYes),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(staffOrdersApiProvider)
          .patchStatus(widget.orderId, t.targetStatus);
      ref.invalidate(pickingDetailProvider(widget.orderId));
      ref.invalidate(activeOrdersProvider);
      showApiSuccess(ref, l10n.statusChanged(t.targetStatus));
    } catch (e) {
      showApiError(ref, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final locale = ref.watch(localeProvider);
    final async = ref.watch(pickingDetailProvider(widget.orderId));

    return SafedScaffold(
      appBar: AppBar(
        title: Text(
          l10n.orderDetailTitle(widget.orderId),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: ColoredBox(
        color: AppTheme.surfaceGrey,
        child: Column(
          children: [
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(messageFromObject(e))),
                data: (o) {
                  final productCount = o.orderProducts.length;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    children: [
                      OrderSummaryPanel(order: o, l10n: l10n),
                      const SizedBox(height: 12),
                      OrderStatusActions(
                        status: o.status,
                        l10n: l10n,
                        busy: _busy,
                        onAction: _changeStatus,
                      ),
                      if (productCount > 0) ...[
                        const SizedBox(height: 16),
                        SectionTitle(
                          l10n.productsSection,
                          trailing: Text(
                            '$productCount',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...o.orderProducts.map(
                          (line) => OrderProductTile(
                            line: line,
                            locale: locale,
                            l10n: l10n,
                            readOnly: true,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            if (_busy) const LinearProgressIndicator(minHeight: 2),
          ],
        ),
      ),
    );
  }
}
