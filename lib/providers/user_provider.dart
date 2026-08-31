import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;

  Future<bool> createUserProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _userService.createUserProfile(
        name: name,
        email: email,
        phone: phone,
      );

      await getUserProfile();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getUserProfile() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _userService.getUserProfile();

      if (snapshot.exists) {
        _userData = snapshot.data();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserProfile({
    required String name,
    required String phone,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _userService.updateUserProfile(
        name: name,
        phone: phone,
      );

      await getUserProfile();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUserProfile() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _userService.deleteUserProfile();

      _userData = null;

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
}