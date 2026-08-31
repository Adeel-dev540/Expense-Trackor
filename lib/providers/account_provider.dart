import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _accountService = AccountService();

  bool _isLoading = false;
  String? _errorMessage;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _accounts = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get accounts =>
      _accounts;

  void startListening() {
    _subscription?.cancel();

    _subscription = _accountService.getAccounts().listen(
          (snapshot) {
        _accounts = snapshot.docs;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> addAccount({
    required String name,
    required double balance,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _accountService.addAccount(
        name: name,
        balance: balance,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAccount({
    required String accountId,
    required String name,
    required double balance,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _accountService.updateAccount(
        accountId: accountId,
        name: name,
        balance: balance,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount({
    required String accountId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _accountService.deleteAccount(
        accountId: accountId,
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