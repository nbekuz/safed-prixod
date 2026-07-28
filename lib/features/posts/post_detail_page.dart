import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/core/catalog_providers.dart';
import 'package:safed_prixod/core/app_language.dart';

final postDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, id) {
      return ref.watch(adminPostsApiProvider).fetch(id);
    });

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  List<String> _imageUrls(Map<String, dynamic> post) {
    final imgs = post['images'] ?? post['post_images'];
    if (imgs is! List) return const [];
    return imgs
        .map(
          (e) => e is Map
              ? (e['image'] ?? e['url'] ?? e['file'])?.toString()
              : null,
        )
        .whereType<String>()
        .where((u) => u.isNotEmpty)
        .toList();
  }

  String _content(Map<String, dynamic> post) {
    final tr = post['translations'];
    if (tr is Map) {
      for (final code in [kAppLanguageCode, 'ru', 'uz', 'en']) {
        final block = tr[code];
        if (block is Map) {
          final c = block['content']?.toString().trim();
          if (c != null && c.isNotEmpty) return c;
        }
      }
    }
    return '';
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> p,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить пост?'),
        content: Text(postTitle(p, locale: kAppLanguageCode)),
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
      await ref.read(adminPostsApiProvider).delete(postId);
      showApiSuccess(ref, 'Удалено');
      if (context.mounted) context.pop();
    } catch (e) {
      showApiError(ref, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(postDetailProvider(postId));
    final compact = MediaQuery.sizeOf(context).width < 380;
    final horizontalPadding = compact ? 12.0 : 16.0;
    final imageSize = compact ? 140.0 : 160.0;

    return SafedScaffold(
      appBar: AppBar(
        title: Text('Пост #$postId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/posts/$postId/edit'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(messageFromObject(e))),
        data: (p) {
          final urls = _imageUrls(p);
          return ListView(
            padding: EdgeInsets.all(horizontalPadding),
            children: [
              Text(
                postTitle(p, locale: kAppLanguageCode),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${p['is_active'] == true ? 'Активный' : 'Неактивный'} · ${p['created_at']?.toString().split('T').first ?? ''}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              if (urls.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: imageSize,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: urls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        urls[i],
                        width: imageSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(_content(p)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/posts/$postId/edit'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
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
                    'Удалить',
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
