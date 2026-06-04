import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safed_core/safed_core.dart';
import 'package:safed_prixod/core/catalog_providers.dart';
import 'package:safed_prixod/core/locale_provider.dart';

final productDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, id) {
      return ref.watch(adminProductsApiProvider).fetch(id);
    });

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.productId});

  final int productId;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> p,
  ) async {
    final locale = ref.read(localeProvider).languageCode;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mahsulot o\'chirilsinmi?'),
        content: Text(productTitle(p, locale: locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'O\'chirish',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminProductsApiProvider).delete(productId);
      showApiSuccess(ref, 'O\'chirildi');
      if (context.mounted) context.pop();
    } catch (e) {
      showApiError(ref, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;
    final async = ref.watch(productDetailProvider(productId));
    final compact = MediaQuery.sizeOf(context).width < 380;
    final horizontalPadding = compact ? 12.0 : 16.0;
    final imageSize = compact ? 150.0 : 180.0;

    return SafedScaffold(
      appBar: AppBar(
        title: Text('Mahsulot #$productId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/products/$productId/edit'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(messageFromObject(e))),
        data: (p) {
          final images = p['images'];
          final imageUrls = images is List
              ? images
                    .map(
                      (e) => e is Map
                          ? (e['image'] ?? e['url'])?.toString()
                          : null,
                    )
                    .whereType<String>()
                    .where((u) => u.isNotEmpty)
                    .toList()
              : <String>[];

          return ListView(
            padding: EdgeInsets.all(horizontalPadding),
            children: [
              if (imageUrls.isNotEmpty)
                SizedBox(
                  height: imageSize,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrls[i],
                        width: imageSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                productTitle(p, locale: locale),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _Row(
                'Kategoriya',
                localizedFromMap(p['category']?['name'], locale: locale),
              ),
              _Row('Narx', '${p['price'] ?? '—'} so\'m'),
              _Row('Chegirma', p['is_discount'] == true ? 'Ha' : 'Yo\'q'),
              _Row('Miqdor', '${p['quantity'] ?? 0}'),
              _Row('Tokcha', p['shelf_location']?.toString() ?? '—'),
              _Row('Faol', p['is_active'] == true ? 'Ha' : 'Yo\'q'),
              if (p['barcodes'] is List && (p['barcodes'] as List).isNotEmpty)
                _Row(
                  'Shtrix-kod',
                  (p['barcodes'] as List)
                      .map((b) => b is Map ? b['barcode'] : null)
                      .whereType<String>()
                      .join(', '),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/products/$productId/edit'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Tahrirlash'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _delete(context, ref, p),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'O\'chirish',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 320;
          final labelText = Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary),
          );
          final valueText = Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelText, const SizedBox(height: 2), valueText],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 110, child: labelText),
              Expanded(child: valueText),
            ],
          );
        },
      ),
    );
  }
}
