/// Buyurtma qatoridagi barcode ↔ line id.
Set<String> barcodesForLine(Map<String, dynamic> line) {
  final p = line['product'];
  if (p is! Map) return {};
  final list = p['barcodes'];
  if (list is! List) return {};
  final out = <String>{};
  for (final b in list) {
    if (b is Map) {
      final code = b['barcode']?.toString().trim();
      if (code != null && code.isNotEmpty) out.add(code);
    }
  }
  return out;
}

String normalizeBarcode(String raw) => raw.replaceAll(RegExp(r'\D'), '');

bool barcodesEqual(String a, String b) {
  final na = normalizeBarcode(a);
  final nb = normalizeBarcode(b);
  if (na.isEmpty || nb.isEmpty) return false;
  if (na == nb) return true;
  if (na.length == 13 && nb.length == 12 && na.startsWith('0') && na.substring(1) == nb) {
    return true;
  }
  if (nb.length == 13 && na.length == 12 && nb.startsWith('0') && nb.substring(1) == na) {
    return true;
  }
  return false;
}

/// Skanerlangan kod buyurtmadagi qaysi qatorga mos kelishini qaytaradi.
BarcodeMatch? matchBarcodeInOrder(
  List<Map<String, dynamic>> lines,
  String scanned,
) {
  final trimmed = scanned.trim();
  if (trimmed.isEmpty) return null;

  for (final line in lines) {
    final lineId = line['id'];
    if (lineId is! int) continue;
    for (final code in barcodesForLine(line)) {
      if (barcodesEqual(code, trimmed)) {
        return BarcodeMatch(lineId: lineId, barcode: code);
      }
    }
  }
  return null;
}

class BarcodeMatch {
  const BarcodeMatch({required this.lineId, required this.barcode});

  final int lineId;
  final String barcode;
}
