import 'package:intl/intl.dart';

class FormatUtils {
  static final NumberFormat _moneyFormat = NumberFormat('#,##0.00', 'zh_CN');
  static final NumberFormat _moneyFormatSimple = NumberFormat('#,##0', 'zh_CN');

  static String formatMoney(double amount) {
    if (amount == amount.roundToDouble() && amount >= 100) {
      return '¥${_moneyFormatSimple.format(amount)}';
    }
    return '¥${_moneyFormat.format(amount)}';
  }

  static String formatNumber(double number) {
    if (number == number.roundToDouble()) {
      return number.round().toString();
    }
    return number.toStringAsFixed(1);
  }

  static String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  static String formatPercent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
}
