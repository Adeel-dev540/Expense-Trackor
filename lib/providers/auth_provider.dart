import 'package:expense_trackor/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthProvider extends ChangeNotifier {

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool get isLoading=>_isLoading;

   void setLoading(bool value){
     _isLoading=value;
     notifyListeners();
   }
//SIGNUP

   Future<String?>? signup({
     required String email,
     required String password,
})async{
     try{
       setLoading(true);

       await _authService.signup(email: email, password: password);
       return null;

     }on FirebaseAuthException
     catch(e){
       if (e.code == 'email-already-in-use') {
         return 'This email is already registered';
       }

       if (e.code == 'invalid-email') {
         return 'Please enter a valid email';
       }

       if (e.code == 'weak-password') {
         return 'Password is too weak';
       }

       return 'Signup failed. Please try again';
     }
     finally{
       setLoading(false);
     }
   }

//LOGIN

   Future<String?>? login({
     required String email,
     required String password,
})async{
     try{
       setLoading(true);
       await _authService.login(email: email, password: password);
       return null;
     }on FirebaseAuthException
     catch(e){
       if (e.code == 'user-not-found') {
         return 'No account found with this email';
       }

       if (e.code == 'wrong-password') {
         return 'Incorrect password';
       }

       if (e.code == 'invalid-email') {
         return 'Please enter a valid email';
       }

       return 'Login failed. Please try again';
     }
     finally{
       setLoading(false);
     }
   }
//FORGOT

Future<String?>?forgot({
    required String email,
})async{

     try{
       setLoading(true);

       await _authService.forgot(email: email);
       return null;
     }on FirebaseAuthException catch (e) {
       if (e.code == 'user-not-found') {
         return 'No account found with this email';
       }

       if (e.code == 'invalid-email') {
         return 'Please enter a valid email';
       }

       return 'Failed to send password reset email';
     }
     finally{
       setLoading(false);
     }
}

//LOGOUT
Future<void> logout() async {
     try{
       setLoading(true);
       await _authService.logout();
     }
     catch(e){
       debugPrint('Logout error: $e');
     }
     finally{
       setLoading(false);
     }
}


  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

}