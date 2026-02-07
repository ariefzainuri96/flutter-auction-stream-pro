import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  final String dialCode;

  PhoneNumberFormatter({required this.dialCode});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limit to max 16 digits
    if (digits.length > 16) {
      digits = digits.substring(0, 16);
    }

    final StringBuffer buffer = StringBuffer();

    if (dialCode == '+1') {
      // Format for US/Canada: 000 000 0000
      for (int i = 0; i < digits.length && i < 10; i++) {
        if (i == 3 || i == 6) buffer.write(' ');
        buffer.write(digits[i]);
      }
    } else {
      for (int i = 0; i < digits.length; i++) {
        buffer.write(digits[i]);
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
