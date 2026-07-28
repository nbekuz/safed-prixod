import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/core/catalog_providers.dart';
import 'package:safed_prixod/core/app_language.dart';

class PostsListPage extends ConsumerStatefulWidget {
  const PostsListPage({super.key});

  @override
  ConsumerState<PostsListPage> createState() => _PostsListPageState();
}

class _PostsListPageState extends ConsumerState<PostsListPage> {
  var _loading = false;
  List<Map<String, dynamic>> _rows = const [];
  bool? _activeFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await ref
          .read(adminPostsApiProvider)
          .list(isActive: _activeFilter);
      if (mounted) setState(() => _rows = rows);
    } catch (e) {
      showApiError(ref, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить пост?'),
        content: Text(postTitle(post, locale: kAppLanguageCode)),
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
      await ref.read(adminPostsApiProvider).delete(post['id'] as int);
      showApiSuccess(ref, 'Удалено');
      await _load();
    } catch (e) {
      showApiError(ref, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final horizontalPadding = compact ? 12.0 : 16.0;

    return SafedScaffold(
      appBar: AppBar(
        title: const Text('Посты'),
        actions: [
          PopupMenuButton<bool?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) {
              _activeFilter = v;
              _load();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: null, child: Text('Все')),
              PopupMenuItem(value: true, child: Text('Активные')),
              PopupMenuItem(value: false, child: Text('Неактивные')),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/posts/new');
          if (mounted) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading && _rows.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _rows.isEmpty
          ? const Center(child: Text('Нет постов'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: EdgeInsets.all(horizontalPadding),
                itemCount: _rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final p = _rows[i];
                  final id = p['id'] as int?;
                  final active = p['is_active'] == true;
                  return Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: compact ? 8 : 16,
                        vertical: compact ? 4 : 0,
                      ),
                      visualDensity: compact
                          ? VisualDensity.compact
                          : VisualDensity.standard,
                      leading: _PostThumbnail(imageUrl: postImageUrl(p)),
                      title: Text(
                        postTitle(p, locale: kAppLanguageCode),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${active ? 'Активный' : 'Неактивный'} · ${p['created_at']?.toString().split('T').first ?? ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (id == null) return;
                          if (v == 'edit') {
                            await context.push('/posts/$id/edit');
                            if (mounted) _load();
                          } else if (v == 'delete') {
                            await _confirmDelete(p);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Удалить'),
                          ),
                        ],
                      ),
                      onTap: id == null
                          ? null
                          : () => context.push('/posts/$id'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

String? postImageUrl(Map<String, dynamic> post) {
  final imgs = post['images'] ?? post['post_images'];
  if (imgs is! List) return null;
  for (final img in imgs) {
    if (img is Map) {
      final url = (img['image'] ?? img['url'] ?? img['file'])?.toString();
      if (url != null && url.isNotEmpty) return url;
    }
  }
  return null;
}

class _PostThumbnail extends StatelessWidget {
  const _PostThumbnail({this.imageUrl});

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
                errorBuilder: (_, __, ___) => const _PostThumbnailPlaceholder(),
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
            : const _PostThumbnailPlaceholder(),
      ),
    );
  }
}

class _PostThumbnailPlaceholder extends StatelessWidget {
  const _PostThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppTheme.surfaceGrey,
      child: Icon(
        Icons.article_outlined,
        color: AppTheme.textSecondary,
        size: 24,
      ),
    );
  }
}
