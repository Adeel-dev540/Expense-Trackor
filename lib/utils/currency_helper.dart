class CurrencyHelper {
  CurrencyHelper._();

  static String format(double amount) {
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }

  static String formatWithoutDecimal(double amount) {
    return 'Rs. ${amount.toStringAsFixed(0)}';
  }

  static String formatWithSign(
      double amount, {
        required bool isCredit,
      }) {
    final sign = isCredit ? '+' : '-';

    return '$sign Rs. ${amount.toStringAsFixed(2)}';
  }
}