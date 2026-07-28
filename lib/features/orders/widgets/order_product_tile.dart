import 'package:flutter/material.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/l10n/app_strings.dart';
import 'package:safed_prixod/l10n/product_name.dart';
import 'package:safed_prixod/features/orders/order_line_helpers.dart';

class OrderProductTile extends StatelessWidget {
  const OrderProductTile({
    super.key,
    required this.line,
    required this.l10n,
    this.readOnly = false,
    this.canEditQty = false,
    this.busy = false,
    this.onSaveQty,
  });

  final Map<String, dynamic> line;
  final AppStrings l10n;
  final bool readOnly;
  final bool canEditQty;
  final bool busy;
  final void Function(int lineId, String qty)? onSaveQty;

  @override
  Widget build(BuildContext context) {
    final lineId = line['id'] as int?;
    final shelf = shelfLocationFromLine(line);
    final name = productNameForLocale(line, l10n.productFallback);
    final qtySuffix = quantityFieldSuffix(line);
    final orderedQty = formatOrderedQuantityShort(line);
    final hasShelf = shelf != null && shelf.isNotEmpty;
    final qtyValue = formatQuantityNumber(line['quantity']);
    final showEdit =
        !readOnly && canEditQty && lineId != null && onSaveQty != null;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final shelfMaxWidth = screenWidth < 360 ? 96.0 : 140.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: shelfMaxWidth),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hasShelf
                        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                        : AppTheme.surfaceGrey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hasShelf ? shelf : l10n.shelfNotSet,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: hasShelf
                          ? AppTheme.primaryGreen
                          : AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            orderedQty,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          if (showEdit) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: qtyValue,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: l10n.quantity,
                      suffixText: qtySuffix,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onFieldSubmitted: (v) => onSaveQty!(lineId, v),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: busy ? null : () => onSaveQty!(lineId, qtyValue),
                  icon: const Icon(Icons.check_circle_outline, size: 22),
                  color: AppTheme.primaryGreen,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
