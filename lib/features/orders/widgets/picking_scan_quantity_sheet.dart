import 'package:flutter/material.dart';
import 'package:safed_core/safed_core.dart';
import 'package:safed_prixod/features/orders/order_line_helpers.dart';
import 'package:safed_prixod/features/orders/unit_helpers.dart';
import 'package:safed_prixod/l10n/app_locale.dart';
import 'package:safed_prixod/l10n/app_strings.dart';
import 'package:safed_prixod/l10n/product_name.dart';

class PickingScanPayload {
  const PickingScanPayload({
    required this.quantity,
    required this.productUnit,
  });

  final String quantity;
  final String productUnit;
}

Future<PickingScanPayload?> showPickingScanQuantitySheet({
  required BuildContext context,
  required Map<String, dynamic> line,
  required AppLocale locale,
  required AppStrings l10n,
}) {
  return showModalBottomSheet<PickingScanPayload>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _PickingScanQuantitySheetBody(
      line: line,
      locale: locale,
      l10n: l10n,
    ),
  );
}

class _PickingScanQuantitySheetBody extends StatefulWidget {
  const _PickingScanQuantitySheetBody({
    required this.line,
    required this.locale,
    required this.l10n,
  });

  final Map<String, dynamic> line;
  final AppLocale locale;
  final AppStrings l10n;

  @override
  State<_PickingScanQuantitySheetBody> createState() =>
      _PickingScanQuantitySheetBodyState();
}

class _PickingScanQuantitySheetBodyState
    extends State<_PickingScanQuantitySheetBody> {
  late final TextEditingController _qtyController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final defaultQty = formatQuantityNumber(
      widget.line['ordered_quantity'] ?? widget.line['quantity'],
    );
    _qtyController = TextEditingController(
      text: defaultQty == '—' ? '' : defaultQty,
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final qty = _qtyController.text.trim().replaceAll(',', '.');
    Navigator.pop(
      context,
      PickingScanPayload(
        quantity: qty,
        productUnit: productUnitApiFromLine(widget.line),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final name = productNameForLocale(
      widget.line,
      widget.locale,
      l10n.productFallback,
    );
    final qtySuffix = quantityFieldSuffix(widget.line, widget.locale);
    final orderedQty = formatOrderedQuantityShort(widget.line, widget.locale);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              orderedQty,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _qtyController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: l10n.quantity,
                suffixText: qtySuffix,
                isDense: true,
              ),
              validator: (v) {
                final raw = v?.trim().replaceAll(',', '.') ?? '';
                if (raw.isEmpty) return l10n.enterValidQuantity;
                final n = double.tryParse(raw);
                if (n == null || n <= 0) return l10n.enterValidQuantity;
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.saveQuantity),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.dialogNo),
            ),
          ],
        ),
      ),
    );
  }
}
