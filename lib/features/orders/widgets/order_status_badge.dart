import 'package:flutter/material.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/l10n/app_strings.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
    required this.l10n,
    this.compact = false,
  });

  final String status;
  final AppStrings l10n;
  final bool compact;

  static _BadgeStyle _styleFor(String status) {
    switch (normalizeOrderStatusCode(status)) {
      case 'created':
        return const _BadgeStyle(Color(0xFF1565C0), Color(0xFFE3F2FD));
      case 'confirmed':
        return const _BadgeStyle(Color(0xFF6A1B9A), Color(0xFFF3E5F5));
      case 'picking':
        return const _BadgeStyle(Color(0xFFE65100), Color(0xFFFFF3E0));
      case 'shipped':
        return const _BadgeStyle(AppTheme.primaryGreen, Color(0xFFE8F5E9));
      case 'delivered':
        return const _BadgeStyle(Color(0xFF00695C), Color(0xFFE0F2F1));
      case 'completed':
        return const _BadgeStyle(Color(0xFF2E7D32), Color(0xFFC8E6C9));
      case 'rejected':
      case 'cancelled':
        return const _BadgeStyle(AppTheme.priceRed, Color(0xFFFFEBEE));
      default:
        return const _BadgeStyle(Color(0xFF616161), Color(0xFFEEEEEE));
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);
    final label = l10n.statusDisplayName(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: style.foreground,
          height: 1.1,
        ),
      ),
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle(this.foreground, this.background);
  final Color foreground;
  final Color background;
}
