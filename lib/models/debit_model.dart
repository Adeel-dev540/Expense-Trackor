class DebitModel {
  final String id;
  final String userId;
  final String accountId;
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  DebitModel({
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
      'date': date,
    };
  }

  factory DebitModel.fromMap(Map<String, dynamic> map) {
    return DebitModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      accountId: map['accountId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      date: map['date']?.toDate() ?? DateTime.now(),
    );
  }
}