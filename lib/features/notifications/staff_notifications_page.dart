import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/core/app_providers.dart';

final staffNotificationsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(notificationsApiProvider).list(audience: 'staff');
});

class StaffNotificationsPage extends ConsumerWidget {
  const StaffNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(staffNotificationsProvider);
    return SafedScaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(messageFromObject(e))),
        data: (data) {
          final results = data['results'];
          final items = results is List
              ? results
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const Center(child: Text('Нет уведомлений'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(staffNotificationsProvider),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(items[i]['title']?.toString() ?? ''),
                subtitle: Text(items[i]['body']?.toString() ?? ''),
              ),
            ),
          );
        },
      ),
    );
  }
}
