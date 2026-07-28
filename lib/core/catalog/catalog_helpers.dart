import 'package:safed_prixod/core/app_language.dart';

String localizedFromMap(dynamic map, {String? locale}) {
  final lang = locale ?? kAppLanguageCode;
  if (map == null) return '—';
  if (map is String) return map;
  if (map is! Map) return map.toString();

  String? pick(dynamic block) {
    if (block is Map) {
      final name = block['name'] ?? block['title'] ?? block['label'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }
    if (block is String && block.trim().isNotEmpty) return block;
    return null;
  }

  final preferred = pick(map[lang]);
  if (preferred != null) return preferred;

  for (final code in ['ru', 'uz', 'en']) {
    final alt = pick(map[code]);
    if (alt != null) return alt;
  }

  for (final value in map.values) {
    final v = pick(value);
    if (v != null) return v;
  }

  return '—';
}

String productTitle(Map<String, dynamic> product, {required String locale}) {
  final tr = product['translations'];
  if (tr is Map) {
    final block = tr[locale];
    if (block is Map && block['name'] != null) {
      return block['name'].toString();
    }
    for (final code in ['ru', 'uz', 'en']) {
      final alt = tr[code];
      if (alt is Map && alt['name'] != null) return alt['name'].toString();
    }
  }
  return product['name']?.toString() ?? 'Товар #${product['id']}';
}

String postTitle(Map<String, dynamic> post, {required String locale}) {
  final tr = post['translations'];
  if (tr is Map) {
    final block = tr[locale];
    if (block is Map && block['title'] != null) {
      return block['title'].toString();
    }
    for (final code in ['ru', 'uz', 'en']) {
      final alt = tr[code];
      if (alt is Map && alt['title'] != null) return alt['title'].toString();
    }
  }
  return post['title']?.toString() ?? 'Пост #${post['id']}';
}

List<Map<String, dynamic>> parseCatalogList(Map<String, dynamic> data) {
  final results = data['results'];
  if (results is List) {
    return results
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  return const [];
}

int catalogListCount(Map<String, dynamic> data, {required int fallback}) {
  final count = data['count'];
  if (count is int) return count;
  if (count is String) return int.tryParse(count) ?? fallback;
  return fallback;
}

List<Map<String, dynamic>> flattenLeafCategories(List<dynamic> tree) {
  final out = <Map<String, dynamic>>[];
  void walk(List<dynamic> nodes, int depth) {
    for (final node in nodes) {
      if (node is! Map) continue;
      final map = Map<String, dynamic>.from(node);
      final children = map['child_category'];
      final hasChildren = children is List && children.isNotEmpty;
      if (!hasChildren) {
        final prefix = depth > 0 ? '— ' * depth : '';
        out.add({
          'id': map['id'],
          'label': '$prefix${localizedFromMap(map['name'])}',
        });
      } else {
        walk(children, depth + 1);
      }
    }
  }

  walk(tree, 0);
  return out;
}
