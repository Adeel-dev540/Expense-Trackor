import 'package:flutter/material.dart';

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
      '${isCredit ? '+' : '-'} Rs. ${amount.toStringAsFixed(2)}',
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