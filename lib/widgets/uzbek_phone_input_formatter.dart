import 'package:flutter/services.dart';

/// 9 raqam: yozishda (99)-123-45-67 ko‘rinishi.
class UzbekPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('998') && digits.length >= 11) {
      digits = digits.substring(3);
    }
    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }
    final formatted = _formatDigits(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _formatDigits(String d) {
    if (d.isEmpty) return '';
    final buf = StringBuffer('(');
    if (d.length <= 2) {
      buf.write(d);
      buf.write(')');
      return buf.toString();
    }
    buf.write(d.substring(0, 2));
    buf.write(')-');
    if (d.length <= 5) {
      buf.write(d.substring(2));
      return buf.toString();
    }
    buf.write(d.substring(2, 5));
    buf.write('-');
    if (d.length <= 7) {
      buf.write(d.substring(5));
      return buf.toString();
    }
    buf.write(d.substring(5, 7));
    buf.write('-');
    buf.write(d.substring(7));
    return buf.toString();
  }

  static String digitsOnly(String formatted) =>
      formatted.replaceAll(RegExp(r'\D'), '');
}
