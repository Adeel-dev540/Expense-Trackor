import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

//Signup
  Future<UserCredential>signup({
    required String email,
    required String password,
})async{
    final UserCredential userCredential =await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return userCredential;
  }

//Login
Future<UserCredential>login({
  required String email,
  required String password,
})async{
  final UserCredential userCredential =await _auth.signInWithEmailAndPassword(email: email, password: password);
  return userCredential;
}

//logout

  Future<void>logout()async{
    await _auth.signOut();
  }

  //Forgot password

Future<void>forgot({
    required String email,
})async{
    await _auth.sendPasswordResetEmail(email: email);
}




}


