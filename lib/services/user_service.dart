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

//Get user profile
Future<DocumentSnapshot<Map<String, dynamic>>>getUserProfile()async{
    final User? user =_auth.currentUser;

    if(user==null){
      throw Exception('User is not logged in');
    }

    return await _firestore.collection("users").doc(user.uid).get();
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

    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
      'phone': phone,
    });
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