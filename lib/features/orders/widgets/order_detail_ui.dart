import 'package:flutter/material.dart';
import 'package:safed_core/safed_core.dart';
import 'package:safed_prixod/features/orders/order_format.dart';
import 'package:safed_prixod/features/orders/order_status_flow.dart';
import 'package:safed_prixod/l10n/app_strings.dart';
import 'package:safed_prixod/features/orders/widgets/order_status_badge.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderSummaryPanel extends StatelessWidget {
  const OrderSummaryPanel({super.key, required this.order, required this.l10n});

  final OrderDto order;
  final AppStrings l10n;

  @override
  Widget build(BuildContext context) {
    final dateFmt = formatDeliveryDate(order.deliveryDate);
    final timeRange = formatDeliveryTimeRange(
      order.deliveryTimeStart,
      order.deliveryTimeEnd,
    );
    final initials = _initials(order.customerName);
    final compact = MediaQuery.sizeOf(context).width < 360;
    final deliveryInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deliveryTimeLabel,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          timeRange,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        if (dateFmt.isNotEmpty)
          Text(
            dateFmt,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
      ],
    );
    final statusBadge = OrderStatusBadge(status: order.status, l10n: l10n);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGrey,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      deliveryInfo,
                      const SizedBox(height: 8),
                      statusBadge,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: deliveryInfo),
                      const SizedBox(width: 8),
                      statusBadge,
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                if (order.customerName.isNotEmpty)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryGreen.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryGreen,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (order.customerPhone != null)
                              InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () => _launchPhone(order.customerPhone),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    formatPhoneDisplay(order.customerPhone),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.primaryGreen,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (order.address != null && order.address!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _MetaTile(
                    icon: Icons.location_on_outlined,
                    text: order.address!,
                  ),
                ],
                const SizedBox(height: 10),
                if (compact)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (order.paymentType != null)
                        _MetaTile(
                          icon: Icons.payments_outlined,
                          text: l10n.paymentTypeLabel(order.paymentType!),
                          compact: true,
                        ),
                      if (order.estimatedTotal != null) ...[
                        if (order.paymentType != null)
                          const SizedBox(height: 6),
                        Text(
                          l10n.orderPrice(
                            formatOrderAmount(order.estimatedTotal),
                          ),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Row(
                    children: [
                      if (order.paymentType != null)
                        Expanded(
                          child: _MetaTile(
                            icon: Icons.payments_outlined,
                            text: l10n.paymentTypeLabel(order.paymentType!),
                            compact: true,
                          ),
                        ),
                      if (order.estimatedTotal != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.orderPrice(
                              formatOrderAmount(order.estimatedTotal),
                            ),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ],
                  ),
                if (order.comment != null && order.comment!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _MetaTile(
                    icon: Icons.chat_bubble_outline,
                    text: order.comment!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _launchPhone(String? raw) async {
    final uri = phoneDialUri(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.icon,
    required this.text,
    this.compact = false,
  });

  final IconData icon;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: compact ? 16 : 18, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: compact ? 13 : 14,
              color: compact ? Colors.black87 : AppTheme.textSecondary,
              fontWeight: compact ? FontWeight.w500 : FontWeight.normal,
            ),
            maxLines: compact ? 1 : 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class OrderStatusActions extends StatelessWidget {
  const OrderStatusActions({
    super.key,
    required this.status,
    required this.l10n,
    required this.busy,
    required this.onAction,
  });

  final String status;
  final AppStrings l10n;
  final bool busy;
  final void Function(OrderStatusTransition t) onAction;

  static const _radius = 10.0;

  @override
  Widget build(BuildContext context) {
    final transitions = orderStatusTransitions(status, l10n);
    if (transitions.isEmpty) return const SizedBox.shrink();

    final primary = transitions.where((t) => t.primary).toList();
    final destructive = transitions.where((t) => t.destructive).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...primary.map(
            (t) => FilledButton(
              onPressed: busy ? null : () => onAction(t),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radius),
                ),
              ),
              child: Text(
                t.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (primary.isNotEmpty && destructive.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Divider(color: AppTheme.borderLight)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    l10n.orLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: AppTheme.borderLight)),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (destructive.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final stackButtons = constraints.maxWidth < 330;
                if (stackButtons) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < destructive.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        _DestructiveActionButton(
                          transition: destructive[i],
                          busy: busy,
                          onPressed: () => onAction(destructive[i]),
                        ),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    for (var i = 0; i < destructive.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _DestructiveActionButton(
                          transition: destructive[i],
                          busy: busy,
                          onPressed: () => onAction(destructive[i]),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DestructiveActionButton extends StatelessWidget {
  const _DestructiveActionButton({
    required this.transition,
    required this.busy,
    required this.onPressed,
  });

  final OrderStatusTransition transition;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = transition.targetStatus == 'rejected'
        ? Icons.block_outlined
        : Icons.cancel_outlined;

    return OutlinedButton(
      onPressed: busy ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.priceRed,
        backgroundColor: AppTheme.priceRed.withValues(alpha: 0.05),
        side: BorderSide(color: AppTheme.priceRed.withValues(alpha: 0.45)),
        minimumSize: const Size.fromHeight(42),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OrderStatusActions._radius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              transition.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
