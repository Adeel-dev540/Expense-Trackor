class TransferModel {
  final String id;
  final String userId;
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final String description;
  final DateTime date;

  TransferModel({
    required this.id,
    required this.userId,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      'description': description,
      'date': date,
    };
  }

  factory TransferModel.fromMap(Map<String, dynamic> map) {
    return TransferModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fromAccountId: map['fromAccountId'] ?? '',
      toAccountId: map['toAccountId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      date: map['date']?.toDate() ?? DateTime.now(),
    );
  }
}