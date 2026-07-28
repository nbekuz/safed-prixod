import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/core/catalog_providers.dart';
import 'package:safed_prixod/core/app_language.dart';

class ProductsListPage extends ConsumerStatefulWidget {
  const ProductsListPage({super.key});

  @override
  ConsumerState<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends ConsumerState<ProductsListPage> {
  final _searchCtrl = TextEditingController();
  var _page = 1;
  static const _pageSize = 20;
  var _loading = false;
  var _total = 0;
  List<Map<String, dynamic>> _rows = const [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool resetPage = false}) async {
    if (resetPage) _page = 1;
    setState(() => _loading = true);
    try {
      final data = await ref
          .read(adminProductsApiProvider)
          .list(page: _page, pageSize: _pageSize, search: _searchCtrl.text);
      if (!mounted) return;
      setState(() {
        _rows = parseCatalogList(data);
        _total = catalogListCount(data, fallback: _rows.length);
      });
    } catch (e) {
      if (mounted) showApiError(ref, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> product) async {
    final title = productTitle(product, locale: kAppLanguageCode);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminProductsApiProvider).delete(product['id'] as int);
      showApiSuccess(ref, 'Удалено');
      await _load();
    } catch (e) {
      showApiError(ref, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxPage = (_total / _pageSize).ceil().clamp(1, 9999);
    final compact = MediaQuery.sizeOf(context).width < 380;
    final horizontalPadding = compact ? 12.0 : 16.0;

    return SafedScaffold(
      appBar: AppBar(
        title: const Text('Товары'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/products/new');
          if (mounted) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              12,
              horizontalPadding,
              8,
            ),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Поиск',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    _load(resetPage: true);
                  },
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _load(resetPage: true),
            ),
          ),
          Expanded(
            child: _loading && _rows.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _rows.isEmpty
                ? const Center(child: Text('Нет товаров'))
                : RefreshIndicator(
                    onRefresh: () => _load(),
                    child: ListView.separated(
                      padding: EdgeInsets.all(horizontalPadding),
                      itemCount: _rows.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final p = _rows[i];
                        final id = p['id'] as int?;
                        final price = p['price']?.toString() ?? '—';
                        return Card(
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: compact ? 8 : 16,
                              vertical: compact ? 4 : 0,
                            ),
                            visualDensity: compact
                                ? VisualDensity.compact
                                : VisualDensity.standard,
                            title: Text(
                              productTitle(p, locale: kAppLanguageCode),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${localizedFromMap(p['category']?['name'], locale: kAppLanguageCode)} · $price сум · кол-во: ${p['quantity'] ?? 0}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (id == null) return;
                                if (v == 'edit') {
                                  await context.push('/products/$id/edit');
                                  if (mounted) _load();
                                } else if (v == 'delete') {
                                  await _confirmDelete(p);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Редактировать'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Удалить'),
                                ),
                              ],
                            ),
                            leading: _ProductThumbnail(
                              imageUrl: productImageUrl(p),
                            ),
                            onTap: id == null
                                ? null
                                : () => context.push('/products/$id'),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          if (_total > _pageSize)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _page > 1 && !_loading
                        ? () {
                            _page--;
                            _load();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('$_page / $maxPage'),
                  IconButton(
                    onPressed: _page < maxPage && !_loading
                        ? () {
                            _page++;
                            _load();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String? productImageUrl(Map<String, dynamic> product) {
  final images = product['images'];
  if (images is! List) return null;
  for (final img in images) {
    if (img is Map) {
      final url = (img['image'] ?? img['url'])?.toString();
      if (url != null && url.isNotEmpty) return url;
    }
  }
  return null;
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 48,
        height: 48,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const _ProductThumbnailPlaceholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const ColoredBox(
                    color: AppTheme.surfaceGrey,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              )
            : const _ProductThumbnailPlaceholder(),
      ),
    );
  }
}

class _ProductThumbnailPlaceholder extends StatelessWidget {
  const _ProductThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppTheme.surfaceGrey,
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppTheme.textSecondary,
        size: 24,
      ),
    );
  }
}
