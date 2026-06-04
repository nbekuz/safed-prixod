import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safed_core/safed_core.dart';
import 'package:safed_prixod/core/app_providers.dart';
import 'package:safed_prixod/core/locale_provider.dart';
import 'package:safed_prixod/features/orders/order_format.dart';
import 'package:safed_prixod/features/orders/order_status_flow.dart';
import 'package:safed_prixod/features/orders/widgets/order_status_badge.dart';
import 'package:safed_prixod/l10n/app_strings.dart';

final activeOrdersProvider = FutureProvider.autoDispose<List<OrderDto>>((
  ref,
) async {
  final orders = await ref.watch(staffOrdersApiProvider).activeOrders();
  return sortOrdersByDeliverySlot(orders);
});

class PickingOrdersPage extends ConsumerWidget {
  const PickingOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final async = ref.watch(activeOrdersProvider);

    return SafedScaffold(
      appBar: AppBar(
        title: Text(l10n.activeOrdersTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(activeOrdersProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(tokenStorageProvider).clear();
              ref.read(accessTokenProvider.notifier).state = null;
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(messageFromObject(e))),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(child: Text(l10n.noActiveOrders));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(activeOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final o = orders[i];
                return _OrderListCard(
                  order: o,
                  l10n: l10n,
                  onTap: () => context.push('/orders/${o.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderListCard extends StatelessWidget {
  const _OrderListCard({
    required this.order,
    required this.l10n,
    required this.onTap,
  });

  final OrderDto order;
  final AppStrings l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final slotLine = formatDeliverySlotLine(
      timeStart: order.deliveryTimeStart,
      isoDate: order.deliveryDate,
    );
    final price = l10n.orderPrice(formatOrderAmount(order.estimatedTotal));
    final name = order.customerName.isNotEmpty ? order.customerName : '—';
    final compact = MediaQuery.sizeOf(context).width < 360;
    final statusBadge = OrderStatusBadge(
      status: order.status,
      l10n: l10n,
      compact: true,
    );

    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      slotLine,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!compact) ...[const SizedBox(width: 8), statusBadge],
                ],
              ),
              if (compact) ...[
                const SizedBox(height: 6),
                Align(alignment: Alignment.centerLeft, child: statusBadge),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        price,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                  ),
                ],
              ),
              if (compact) ...[
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
