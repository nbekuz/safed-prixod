import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safed_core/safed_core.dart';
import 'package:safed_prixod/core/app_providers.dart';
import 'package:safed_prixod/core/locale_provider.dart';
import 'package:safed_prixod/features/orders/barcode_scan_page.dart';
import 'package:safed_prixod/features/orders/order_barcode_helpers.dart';
import 'package:safed_prixod/features/orders/picking_detail_page.dart';
import 'package:safed_prixod/features/orders/picking_orders_page.dart';
import 'package:safed_prixod/features/orders/widgets/courier_select_sheet.dart';
import 'package:safed_prixod/features/orders/widgets/order_product_tile.dart';
import 'package:safed_prixod/features/orders/widgets/picking_scan_quantity_sheet.dart';

class OrderCheckPage extends ConsumerStatefulWidget {
  const OrderCheckPage({super.key, required this.orderId});

  final int orderId;

  @override
  ConsumerState<OrderCheckPage> createState() => _OrderCheckPageState();
}

class _OrderCheckPageState extends ConsumerState<OrderCheckPage> {
  final _scannedLineIds = <int>{};
  bool _busy = false;

  Map<String, dynamic>? _lineById(
    List<Map<String, dynamic>> lines,
    int lineId,
  ) {
    for (final line in lines) {
      if (line['id'] == lineId) return line;
    }
    return null;
  }

  bool _allLinesScanned(
    List<Map<String, dynamic>> lines, {
    int? includingLineId,
  }) {
    final lineIds = lines.map((line) => line['id']).whereType<int>().toList();
    if (lineIds.isEmpty) return false;
    return lineIds.every(
      (id) => _scannedLineIds.contains(id) || id == includingLineId,
    );
  }

  Future<void> _openScanner(List<Map<String, dynamic>> lines) async {
    if (_busy || !mounted) return;
    if (_allLinesScanned(lines)) return;
    final code = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const BarcodeScanPage()));
    if (!mounted || code == null || code.isEmpty) return;
    await _onBarcode(code, lines);
  }

  Future<void> _resumeScanner(
    List<Map<String, dynamic>> lines, {
    required bool reopen,
  }) async {
    if (!mounted || !reopen || _busy) return;
    if (_allLinesScanned(lines)) return;
    await _openScanner(lines);
  }

  Future<void> _onBarcode(String code, List<Map<String, dynamic>> lines) async {
    final l10n = ref.read(l10nProvider);
    final locale = ref.read(localeProvider);
    final match = matchBarcodeInOrder(lines, code);

    if (match == null) {
      ref
          .read(appToastProvider.notifier)
          .warning(l10n.barcodeNotInOrder(normalizeBarcode(code)));
      await _resumeScanner(lines, reopen: true);
      return;
    }

    if (_scannedLineIds.contains(match.lineId)) {
      ref.read(appToastProvider.notifier).warning(l10n.barcodeAlreadyScanned);
      await _resumeScanner(lines, reopen: true);
      return;
    }

    final line = _lineById(lines, match.lineId);
    if (line == null) return;

    final payload = await showPickingScanQuantitySheet(
      context: context,
      line: line,
      locale: locale,
      l10n: l10n,
    );
    if (!mounted || payload == null) return;

    setState(() => _busy = true);
    var reopen = true;
    try {
      await ref
          .read(staffOrdersApiProvider)
          .scanBarcode(
            widget.orderId,
            barcode: match.barcode,
            quantity: payload.quantity,
            productUnit: payload.productUnit,
          );
      reopen = !_allLinesScanned(lines, includingLineId: match.lineId);
      setState(() => _scannedLineIds.add(match.lineId));
      ref.invalidate(pickingDetailProvider(widget.orderId));
      ref.read(appToastProvider.notifier).success(l10n.scanned(match.barcode));
    } catch (e) {
      showApiError(ref, e);
      reopen = false;
    } finally {
      if (mounted) setState(() => _busy = false);
      await _resumeScanner(lines, reopen: reopen);
    }
  }

  Future<void> _finishPicking(OrderDto order) async {
    final l10n = ref.read(l10nProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(l10n.confirmFinishPicking),
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
      if (order.status != 'picking') {
        await ref
            .read(staffOrdersApiProvider)
            .patchStatus(widget.orderId, 'picking');
        showApiSuccess(ref, l10n.statusChanged('picking'));
      }

      ref.invalidate(pickingDetailProvider(widget.orderId));
      ref.invalidate(activeOrdersProvider);
      if (!mounted) return;

      await showCourierSelectSheet(
        context: context,
        ref: ref,
        orderId: widget.orderId,
        onDone: () {
          ref.invalidate(activeOrdersProvider);
          if (context.mounted) context.go('/orders');
        },
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
    final locale = ref.watch(localeProvider);
    final async = ref.watch(pickingDetailProvider(widget.orderId));

    return SafedScaffold(
      appBar: AppBar(title: Text(l10n.checkProductsTitle(widget.orderId))),
      body: ColoredBox(
        color: AppTheme.surfaceGrey,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(messageFromObject(e))),
          data: (order) {
            final lines = order.orderProducts;
            final total = lines.length;
            final done = _scannedLineIds.length;
            final allScanned = _allLinesScanned(lines);

            return Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 340;
                    final scanButton = FilledButton.tonalIcon(
                      onPressed: (_busy || allScanned)
                          ? null
                          : () => _openScanner(lines),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(l10n.scanButton),
                    );

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: compact
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  l10n.scannedProgress(done, total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                scanButton,
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.scannedProgress(done, total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                scanButton,
                              ],
                            ),
                    );
                  },
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                    children: lines.map((line) {
                      final lineId = line['id'] as int?;
                      final scanned =
                          lineId != null && _scannedLineIds.contains(lineId);
                      return Stack(
                        children: [
                          OrderProductTile(
                            line: line,
                            locale: locale,
                            l10n: l10n,
                            readOnly: true,
                          ),
                          if (scanned)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Material(
                  elevation: 8,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: FilledButton(
                        onPressed: (allScanned && !_busy)
                            ? () => _finishPicking(order)
                            : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
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
                            : Text(l10n.finishPicking),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
