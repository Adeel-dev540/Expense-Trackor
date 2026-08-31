import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's UID
  String get _userId {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return user.uid;
  }

  // Transactions collection
  CollectionReference<Map<String, dynamic>> get _transactions =>
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions');

  // Add Credit
  Future<void> addCredit({
    required String accountId,
    required String categoryId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    await _transactions.add({
      'type': 'credit',
      'accountId': accountId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Add Debit
  Future<void> addDebit({
    required String accountId,
    required String categoryId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    await _transactions.add({
      'type': 'debit',
      'accountId': accountId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Add Transfer
  Future<void> addTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    final WriteBatch batch = _firestore.batch();

    final DocumentReference<Map<String, dynamic>> transactionRef =
    _transactions.doc();

    batch.set(transactionRef, {
      'type': 'transfer',
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Get all transactions
  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions() {
    return _transactions
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get transactions by type
  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactionsByType({
    required String type,
  }) {
    return _transactions
        .where('type', isEqualTo: type)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Update transaction
  Future<void> updateTransaction({
    required String transactionId,
    required Map<String, dynamic> data,
  }) async {
    await _transactions.doc(transactionId).update(data);
  }

  // Delete transaction
  Future<void> deleteTransaction({
    required String transactionId,
  }) async {
    await _transactions.doc(transactionId).delete();
  }
}