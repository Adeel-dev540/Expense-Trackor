import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get  currentUser => _auth.currentUser;


  //Create user profile

Future<void>createUserProfile({
    required String name,
    required String email,
    required String phone
})async{
  final User? user =_auth.currentUser;

  if(user==null){
    throw Exception('User is not logged in');
  }

  await  _firestore.collection("users").doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
  });

}

// Get user profile
Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final docRef = _firestore.collection("users").doc(user.uid);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      final defaultName = user.email?.split('@').first ?? 'User';
      final formattedName = defaultName.isNotEmpty
          ? defaultName[0].toUpperCase() + defaultName.substring(1)
          : 'User';

      await docRef.set({
        'uid': user.uid,
        'name': formattedName,
        'email': user.email ?? '',
        'phone': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return await docRef.get();
    }

    return docSnap;
  }

// Update user profile
  Future<void> updateUserProfile({
    required String name,
    required String phone,
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'phone': phone,
      'email': user.email ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Delete user profile
  Future<void> deleteUserProfile() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore.collection('users').doc(user.uid).delete();
  }

}