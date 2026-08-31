import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryService {
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

  // Categories collection
  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('users').doc(_userId).collection('categories');

  // Add category
  Future<void> addCategory({
    required String name,
    required String type,
  }) async {
    await _categories.add({
      'name': name,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all categories
  Stream<QuerySnapshot<Map<String, dynamic>>> getCategories() {
    return _categories
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get categories by type
  Stream<QuerySnapshot<Map<String, dynamic>>> getCategoriesByType({
    required String type,
  }) {
    return _categories
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update category
  Future<void> updateCategory({
    required String categoryId,
    required String name,
    required String type,
  }) async {
    await _categories.doc(categoryId).update({
      'name': name,
      'type': type,
    });
  }

  // Delete category
  Future<void> deleteCategory({
    required String categoryId,
  }) async {
    await _categories.doc(categoryId).delete();
  }
}