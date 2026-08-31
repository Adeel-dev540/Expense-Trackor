import 'package:cloud_firestore/cloud_firestore.dart';

class CreditModel {
  final String id;
  final String userId;
  final String accountId;
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  CreditModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'accountId': accountId,
      'amount': amount,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date),
    };
  }

  factory CreditModel.fromMap(Map<String, dynamic> map) {
    final date = map['date'];

    return CreditModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      accountId: map['accountId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      date: date is Timestamp
          ? date.toDate()
          : DateTime.now(),
    );
  }
}