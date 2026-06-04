/// API sana (yyyy-MM-dd) → 23.05.2026
String formatDeliveryDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '';
  final parts = isoDate.split('-');
  if (parts.length != 3) return isoDate;
  final y = parts[0];
  final m = parts[1].padLeft(2, '0');
  final d = parts[2].padLeft(2, '0');
  return '$d.$m.$y';
}

/// 63075.70 → 63 076
String formatOrderAmount(String? raw) {
  if (raw == null || raw.isEmpty) return '—';
  final v = double.tryParse(raw.replaceAll(',', '.'));
  if (v == null) return raw;
  final n = v.round();
  final negative = n < 0;
  var s = (negative ? -n : n).toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return negative ? '-${buf.toString()}' : buf.toString();
}

String formatDeliverySlotLine({
  required String? timeStart,
  required String? isoDate,
}) {
  final time = (timeStart == null || timeStart.isEmpty) ? '—' : timeStart;
  final date = formatDeliveryDate(isoDate);
  if (date.isEmpty) return time;
  return '$time · $date';
}

/// 998900000000 → +998 (90) 000-00-00
String formatPhoneDisplay(String? raw) {
  if (raw == null || raw.isEmpty) return '—';
  var d = raw.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('998') && d.length >= 12) {
    d = d.substring(3, d.length.clamp(3, 12));
  }
  if (d.length > 9) d = d.substring(0, 9);
  if (d.length < 9) return '+998 $d';
  return '+998 (${d.substring(0, 2)}) ${d.substring(2, 5)}-${d.substring(5, 7)}-${d.substring(7)}';
}

Uri? phoneDialUri(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  if (digits.length == 9) digits = '998$digits';
  if (!digits.startsWith('998')) digits = '998$digits';
  if (digits.length < 12) return null;
  return Uri(scheme: 'tel', path: '+$digits');
}

String formatDeliveryTimeRange(String? start, String? end) {
  final s = start ?? '';
  final e = end ?? '';
  if (s.isEmpty && e.isEmpty) return '—';
  if (e.isEmpty) return s;
  if (s.isEmpty) return e;
  return '$s – $e';
}
