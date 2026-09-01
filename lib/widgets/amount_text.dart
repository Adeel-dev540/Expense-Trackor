import 'package:flutter/material.dart';
import '../utils/currency_helper.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final bool isCredit;
  final double fontSize;

  const AmountText({
    super.key,
    required this.amount,
    required this.isCredit,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrencyHelper.formatWithSign(amount, isCredit: isCredit),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: isCredit
            ? Colors.green
            : Colors.red,
      ),
    );
  }
}