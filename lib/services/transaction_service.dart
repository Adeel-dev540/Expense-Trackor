import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/currency_helper.dart';

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
    final DocumentReference<Map<String, dynamic>> accountRef =
        _firestore.collection('users').doc(_userId).collection('accounts').doc(accountId);

    await _firestore.runTransaction((transaction) async {
      final accountSnapshot = await transaction.get(accountRef);
      if (!accountSnapshot.exists) {
        throw Exception('Account does not exist');
      }
      final double currentBalance = (accountSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;

      final DocumentReference<Map<String, dynamic>> transactionRef = _transactions.doc();
      transaction.set(transactionRef, {
        'type': 'credit',
        'accountId': accountId,
        'categoryId': categoryId,
        'amount': amount,
        'description': description,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(accountRef, {
        'balance': currentBalance + amount,
      });
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
    final DocumentReference<Map<String, dynamic>> accountRef =
        _firestore.collection('users').doc(_userId).collection('accounts').doc(accountId);

    await _firestore.runTransaction((transaction) async {
      final accountSnapshot = await transaction.get(accountRef);
      if (!accountSnapshot.exists) {
        throw Exception('Account does not exist');
      }
      final double currentBalance = (accountSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;

      if (currentBalance < amount) {
        throw Exception(
          'Insufficient balance. Available balance is ${CurrencyHelper.format(currentBalance)}',
        );
      }

      final DocumentReference<Map<String, dynamic>> transactionRef = _transactions.doc();
      transaction.set(transactionRef, {
        'type': 'debit',
        'accountId': accountId,
        'categoryId': categoryId,
        'amount': amount,
        'description': description,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(accountRef, {
        'balance': currentBalance - amount,
      });
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
    final DocumentReference<Map<String, dynamic>> fromAccountRef =
        _firestore.collection('users').doc(_userId).collection('accounts').doc(fromAccountId);
    final DocumentReference<Map<String, dynamic>> toAccountRef =
        _firestore.collection('users').doc(_userId).collection('accounts').doc(toAccountId);

    await _firestore.runTransaction((transaction) async {
      final fromSnapshot = await transaction.get(fromAccountRef);
      if (!fromSnapshot.exists) {
        throw Exception('Source account does not exist');
      }
      final double fromBalance = (fromSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;

      if (fromBalance < amount) {
        throw Exception(
          'Insufficient balance in source account. Available balance is ${CurrencyHelper.format(fromBalance)}',
        );
      }

      final toSnapshot = await transaction.get(toAccountRef);
      if (!toSnapshot.exists) {
        throw Exception('Destination account does not exist');
      }
      final double toBalance = (toSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;

      final DocumentReference<Map<String, dynamic>> transactionRef = _transactions.doc();
      transaction.set(transactionRef, {
        'type': 'transfer',
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        'description': description,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(fromAccountRef, {'balance': fromBalance - amount});
      transaction.update(toAccountRef, {'balance': toBalance + amount});
    });
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

  // Update transaction with balance reconciliation
  Future<void> updateTransaction({
    required String transactionId,
    required String categoryId,
    required double newAmount,
    required String description,
    required DateTime date,
  }) async {
    final DocumentReference<Map<String, dynamic>> txRef =
        _transactions.doc(transactionId);

    await _firestore.runTransaction((transaction) async {
      final txSnapshot = await transaction.get(txRef);
      if (!txSnapshot.exists) {
        throw Exception('Transaction not found');
      }

      final data = txSnapshot.data()!;
      final String type = data['type']?.toString() ?? '';
      final double oldAmount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final double delta = newAmount - oldAmount;

      if (delta != 0) {
        if (type == 'credit') {
          final String? accountId = data['accountId']?.toString();
          if (accountId != null) {
            final accountRef = _firestore
                .collection('users')
                .doc(_userId)
                .collection('accounts')
                .doc(accountId);
            final accountSnap = await transaction.get(accountRef);
            if (accountSnap.exists) {
              final double currentBalance =
                  (accountSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
              transaction.update(accountRef, {
                'balance': currentBalance + delta,
              });
            }
          }
        } else if (type == 'debit') {
          final String? accountId = data['accountId']?.toString();
          if (accountId != null) {
            final accountRef = _firestore
                .collection('users')
                .doc(_userId)
                .collection('accounts')
                .doc(accountId);
            final accountSnap = await transaction.get(accountRef);
            if (accountSnap.exists) {
              final double currentBalance =
                  (accountSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
              if (delta > 0 && currentBalance < delta) {
                throw Exception(
                  'Insufficient balance in account. Available: ${CurrencyHelper.format(currentBalance)}',
                );
              }
              transaction.update(accountRef, {
                'balance': currentBalance - delta,
              });
            }
          }
        } else if (type == 'transfer') {
          final String? fromAccountId = data['fromAccountId']?.toString();
          final String? toAccountId = data['toAccountId']?.toString();

          if (fromAccountId != null) {
            final fromRef = _firestore
                .collection('users')
                .doc(_userId)
                .collection('accounts')
                .doc(fromAccountId);
            final fromSnap = await transaction.get(fromRef);
            if (fromSnap.exists) {
              final double fromBal =
                  (fromSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
              if (delta > 0 && fromBal < delta) {
                throw Exception(
                  'Insufficient balance in source account. Available: ${CurrencyHelper.format(fromBal)}',
                );
              }
              transaction.update(fromRef, {'balance': fromBal - delta});
            }
          }

          if (toAccountId != null) {
            final toRef = _firestore
                .collection('users')
                .doc(_userId)
                .collection('accounts')
                .doc(toAccountId);
            final toSnap = await transaction.get(toRef);
            if (toSnap.exists) {
              final double toBal =
                  (toSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
              transaction.update(toRef, {'balance': toBal + delta});
            }
          }
        }
      }

      transaction.update(txRef, {
        'categoryId': categoryId,
        'amount': newAmount,
        'description': description,
        'date': Timestamp.fromDate(date),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Delete transaction and reverse account balance
  Future<void> deleteTransaction({
    required String transactionId,
  }) async {
    final DocumentReference<Map<String, dynamic>> txRef =
        _transactions.doc(transactionId);

    await _firestore.runTransaction((transaction) async {
      final txSnapshot = await transaction.get(txRef);
      if (!txSnapshot.exists) {
        throw Exception('Transaction not found');
      }

      final data = txSnapshot.data()!;
      final String type = data['type']?.toString() ?? '';
      final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

      if (type == 'credit') {
        final String? accountId = data['accountId']?.toString();
        if (accountId != null) {
          final accountRef = _firestore
              .collection('users')
              .doc(_userId)
              .collection('accounts')
              .doc(accountId);
          final accountSnap = await transaction.get(accountRef);
          if (accountSnap.exists) {
            final double currentBalance =
                (accountSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
            transaction.update(accountRef, {
              'balance': currentBalance - amount,
            });
          }
        }
      } else if (type == 'debit') {
        final String? accountId = data['accountId']?.toString();
        if (accountId != null) {
          final accountRef = _firestore
              .collection('users')
              .doc(_userId)
              .collection('accounts')
              .doc(accountId);
          final accountSnap = await transaction.get(accountRef);
          if (accountSnap.exists) {
            final double currentBalance =
                (accountSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
            transaction.update(accountRef, {
              'balance': currentBalance + amount,
            });
          }
        }
      } else if (type == 'transfer') {
        final String? fromAccountId = data['fromAccountId']?.toString();
        final String? toAccountId = data['toAccountId']?.toString();

        if (fromAccountId != null) {
          final fromRef = _firestore
              .collection('users')
              .doc(_userId)
              .collection('accounts')
              .doc(fromAccountId);
          final fromSnap = await transaction.get(fromRef);
          if (fromSnap.exists) {
            final double fromBal =
                (fromSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
            transaction.update(fromRef, {'balance': fromBal + amount});
          }
        }

        if (toAccountId != null) {
          final toRef = _firestore
              .collection('users')
              .doc(_userId)
              .collection('accounts')
              .doc(toAccountId);
          final toSnap = await transaction.get(toRef);
          if (toSnap.exists) {
            final double toBal =
                (toSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
            transaction.update(toRef, {'balance': toBal - amount});
          }
        }
      }

      transaction.delete(txRef);
    });
  }
}