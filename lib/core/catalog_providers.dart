import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safed_core/safed_core.dart';
import 'package:safed_prixod/core/app_providers.dart';

final adminProductsApiProvider = Provider<AdminProductsApiService>(
  (ref) => AdminProductsApiService(ref.watch(dioProvider)),
);

final adminPostsApiProvider = Provider<AdminPostsApiService>(
  (ref) => AdminPostsApiService(ref.watch(dioProvider)),
);

final catalogMetaApiProvider = Provider<CatalogMetaApiService>(
  (ref) => CatalogMetaApiService(ref.watch(dioProvider)),
);

final leafCategoriesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) async {
  final tree = await ref.watch(catalogMetaApiProvider).categories();
  return flattenLeafCategories(tree);
});

final badgesListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) async {
  return ref.watch(catalogMetaApiProvider).badges();
});

final unitsListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) async {
  return ref.watch(catalogMetaApiProvider).units();
});
