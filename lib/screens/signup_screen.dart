import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/Custom_feild.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_button.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController emailController= TextEditingController();
  final TextEditingController passwordController= TextEditingController();
  final TextEditingController confirmPasswordController= TextEditingController();
  final _formKey =GlobalKey<FormState>();
   SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 30),child:Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 100,),
              Center(child: Text("Signup", style: TextStyle(fontSize: 50,fontWeight: FontWeight.w600,color: Colors.black),)),
              SizedBox(height: 100,),
              CustomFeild(
                  label: "Email",
                  hintText: "Enter Your Email",
                  obscureText: false,
                  controller: emailController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Email is required";
                  }
        
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
                    return "Enter a valid email";
                  }
        
                  return null;
                },
              ),
              SizedBox(height: 20,),
              Consumer<AuthProvider>(builder: (context,provider, child){
                return CustomFeild(
                  obscureText: !provider.isPasswordVisible,

                  SuffixIcon: provider.isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,

                  SuffixOnPressed: () {
                    provider.togglePasswordVisibility();
                  },
                  label: "Password",
                  hintText: "******",
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }

                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }

                    return null;
                  },
                );
              }),
              SizedBox(height: 20,),
              Consumer<AuthProvider>(builder: (context,provider, child){
                return  CustomFeild(
                  obscureText: !provider.isConfirmPasswordVisible,

                  SuffixIcon: provider.isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,

                  SuffixOnPressed: () {
                    provider.toggleConfirmPasswordVisibility();
                  },
                  label: "Confirm Password",
                  hintText: "******",
                  controller: confirmPasswordController,
                  validator: (value) {
                    final password=passwordController.text;
                    final confirmPassword=confirmPasswordController.text;
                    if (value == null || value.isEmpty) {
                      return "Confirm password is required";
                    }

                    if (password != confirmPassword) {
                      return "Passwords do not match";
                    }

                    return null;
                  },
                );
              }),

              SizedBox(height: 30,),
              Consumer<AuthProvider>(builder: (context,provider, child){
                return CustomButton(
                    buttonHeading: provider.isLoading?"Creating...":"Signup", onPressed:provider.isLoading?null: ()async{

                  if(!_formKey.currentState!.validate()){
                    return;
                  }

                  final error = await provider.signup(email: emailController.text.trim(), password: passwordController.text);

                  if (!context.mounted) return;
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                      ),
                    );

                    return;
                  }

                  Navigator.pushReplacementNamed(
                    context,
                    '/HomeScreen',
                  );
                });
              }),
              Row(mainAxisAlignment: .center ,children: [
                Text("Already have an account",),
                CustomTextButton(buttonHeading: "Login?", onPressed: (){Navigator.pushNamed(context, "/LoginScreen");}),
        
              ],)
            ],
          ),
        ),),
      ),
    );
  }
}
