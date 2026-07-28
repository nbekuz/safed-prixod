import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/l10n/app_strings.dart';

/// PATCH /orders/{id}/status/ — ombor (prixod) uchun ruxsat etilgan o'tishlar.
class OrderStatusTransition {
  const OrderStatusTransition({
    required this.targetStatus,
    required this.label,
    this.primary = false,
    this.destructive = false,
    this.openCheckPage = false,
  });

  final String targetStatus;
  final String label;
  final bool primary;
  final bool destructive;
  final bool openCheckPage;
}


/// Check sahifasiga o‘tish (status PATCH qilinmaydi).
const kCheckPageAction = '_open_check';

List<OrderStatusTransition> orderStatusTransitions(
  String currentStatus,
  AppStrings l10n,
) {
  switch (normalizeOrderStatusCode(currentStatus)) {
    case 'created':
      return [
        OrderStatusTransition(
          targetStatus: 'confirmed',
          label: l10n.actionConfirmOrder,
          primary: true,
        ),
        OrderStatusTransition(
          targetStatus: 'rejected',
          label: l10n.actionRejectOrder,
          destructive: true,
        ),
        OrderStatusTransition(
          targetStatus: 'cancelled',
          label: l10n.actionCancelOrder,
          destructive: true,
        ),
      ];
    case 'confirmed':
      return [
        OrderStatusTransition(
          targetStatus: kCheckPageAction,
          label: l10n.actionStartPicking,
          primary: true,
          openCheckPage: true,
        ),
      ];
    case 'picking':
      return [
        OrderStatusTransition(
          targetStatus: kCheckPageAction,
          label: l10n.finishPicking,
          primary: true,
          openCheckPage: true,
        ),
      ];
    default:
      return const [];
  }
}

List<OrderDto> sortOrdersByDeliverySlot(List<OrderDto> orders) {
  final copy = [...orders];
  copy.sort((a, b) {
    final ka = a.deliverySortAt;
    final kb = b.deliverySortAt;
    if (ka == null && kb == null) return a.id.compareTo(b.id);
    if (ka == null) return 1;
    if (kb == null) return -1;
    final c = ka.compareTo(kb);
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  return copy;
}
