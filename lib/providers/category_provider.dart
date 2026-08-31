import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  bool _isLoading = false;
  String? _errorMessage;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _categories = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get categories =>
      _categories;

  void startListening() {
    _subscription?.cancel();

    _subscription = _categoryService.getCategories().listen(
          (snapshot) {
        _categories = snapshot.docs;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> addCategory({
    required String name,
    required String type,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _categoryService.addCategory(
        name: name,
        type: type,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCategory({
    required String categoryId,
    required String name,
    required String type,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _categoryService.updateCategory(
        categoryId: categoryId,
        name: name,
        type: type,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCategory({
    required String categoryId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _categoryService.deleteCategory(
        categoryId: categoryId,
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