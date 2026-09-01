class CurrencyHelper {
  CurrencyHelper._();

  /// Formats raw amount with commas and 2 decimals: e.g. 1000000.5 -> "1,000,000.50"
  static String formatAmountOnly(double amount) {
    final bool isNegative = amount < 0;
    final double absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(2).split('.');

    String integerPart = parts[0];
    final String decimalPart = parts[1];

    integerPart = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );

    return '${isNegative ? '-' : ''}$integerPart.$decimalPart';
  }

  /// Formats amount with "Rs." prefix and commas: e.g. 12500.50 -> "Rs. 12,500.50"
  static String format(double amount) {
    if (amount < 0) {
      return '-Rs. ${formatAmountOnly(amount.abs())}';
    }
    return 'Rs. ${formatAmountOnly(amount)}';
  }

  /// Formats amount without decimal places: e.g. 12500 -> "Rs. 12,500"
  static String formatWithoutDecimal(double amount) {
    final bool isNegative = amount < 0;
    final double absAmount = amount.abs();
    String integerPart = absAmount.toStringAsFixed(0);

    integerPart = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );

    final prefix = isNegative ? '-Rs. ' : 'Rs. ';
    return '$prefix$integerPart';
  }

  /// Formats amount with explicit +/- sign: e.g. "+ Rs. 1,000.00" or "- Rs. 500.00"
  static String formatWithSign(
    double amount, {
    required bool isCredit,
  }) {
    final sign = isCredit ? '+' : '-';
    return '$sign Rs. ${formatAmountOnly(amount.abs())}';
  }
}