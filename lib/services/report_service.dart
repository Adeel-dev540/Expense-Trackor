import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _transactions =>
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions');

  // Get all transactions
  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions() {
    return _transactions.snapshots();
  }

  // Get total credit
  Future<double> getTotalCredit() async {
    final snapshot = await _transactions
        .where('type', isEqualTo: 'credit')
        .get();

    double total = 0;

    for (final doc in snapshot.docs) {
      total += (doc.data()['amount'] as num).toDouble();
    }

    return total;
  }

  // Get total debit
  Future<double> getTotalDebit() async {
    final snapshot = await _transactions
        .where('type', isEqualTo: 'debit')
        .get();

    double total = 0;

    for (final doc in snapshot.docs) {
      total += (doc.data()['amount'] as num).toDouble();
    }

    return total;
  }

  // Get balance
  Future<double> getBalance() async {
    final credit = await getTotalCredit();
    final debit = await getTotalDebit();

    return credit - debit;
  }
}