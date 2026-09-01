import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService =
  TransactionService();

  bool _isLoading = false;
  String? _errorMessage;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _transactions = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _subscription;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get transactions =>
      _transactions;

  void startListening() {
    _subscription?.cancel();

    _subscription = _transactionService.getTransactions().listen(
          (snapshot) {
        _transactions = snapshot.docs;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> addCredit({
    required String accountId,
    required String categoryId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _transactionService.addCredit(
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        description: description,
        date: date,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addDebit({
    required String accountId,
    required String categoryId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _transactionService.addDebit(
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        description: description,
        date: date,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _transactionService.addTransfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        description: description,
        date: date,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTransaction({
    required String transactionId,
    required String categoryId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _transactionService.updateTransaction(
        transactionId: transactionId,
        categoryId: categoryId,
        newAmount: amount,
        description: description,
        date: date,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTransaction({
    required String transactionId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _transactionService.deleteTransaction(
        transactionId: transactionId,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}