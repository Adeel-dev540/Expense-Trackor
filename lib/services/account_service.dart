import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
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

  // Accounts collection
  CollectionReference<Map<String, dynamic>> get _accounts =>
      _firestore.collection('users').doc(_userId).collection('accounts');

  // Add account
  Future<void> addAccount({
    required String name,
    required double balance,
  }) async {
    await _accounts.add({
      'name': name,
      'balance': balance,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all accounts
  Stream<QuerySnapshot<Map<String, dynamic>>> getAccounts() {
    return _accounts
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update account
  Future<void> updateAccount({
    required String accountId,
    required String name,
    required double balance,
  }) async {
    await _accounts.doc(accountId).update({
      'name': name,
      'balance': balance,
    });
  }

  // Delete account
  Future<void> deleteAccount({
    required String accountId,
  }) async {
    await _accounts.doc(accountId).delete();
  }
}