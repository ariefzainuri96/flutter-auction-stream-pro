import 'package:intl/intl.dart';

class NumberFormatter {
  static String formatCurrencyNumber(num? number) {
    NumberFormat formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );

    return formatter.format(number ?? 0);
  }

  static String formatNumber(num? number) {
    NumberFormat formatter = NumberFormat('###,###', 'en_US');

    return formatter.format(number ?? 0);
  }
}
