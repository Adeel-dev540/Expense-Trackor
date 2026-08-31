import 'package:flutter/material.dart';

class DateHelper {
  DateHelper._();

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  static String formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  static String monthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[date.month - 1];
  }

  static String shortMonthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[date.month - 1];
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class DateHelperDemoScreen extends StatelessWidget {
  DateHelperDemoScreen({super.key});

  // Example date
  final DateTime transactionDate = DateTime(2026, 10, 31, 18, 40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Helper Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. formatDate()
            const Text(
              'formatDate()',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              DateHelper.formatDate(transactionDate),
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 25),

            // 2. formatDateTime()
            const Text(
              'formatDateTime()',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              DateHelper.formatDateTime(transactionDate),
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 25),

            // 3. monthName()
            const Text(
              'monthName()',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              DateHelper.monthName(transactionDate),
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 25),

            // 4. shortMonthName()
            const Text(
              'shortMonthName()',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              DateHelper.shortMonthName(transactionDate),
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 25),

            // 5. isToday()
            const Text(
              'isToday()',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              DateHelper.isToday(transactionDate)
                  ? 'This transaction is Today'
                  : 'This transaction is not Today',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}