import 'package:expense_trackor/widgets/Custom_feild.dart';
import 'package:expense_trackor/widgets/custom_button.dart';
import 'package:expense_trackor/widgets/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {

  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController= TextEditingController();

  final TextEditingController passwordController= TextEditingController();

  final _formKey =GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 30),child:Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 100,),
              Center(child: Text("Login", style: TextStyle(fontSize: 50,fontWeight: FontWeight.w600,color: Colors.black),)),
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
                },),
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
              Align(child: CustomTextButton(buttonHeading: "Forgot Password?", onPressed: (){Navigator.pushNamed(context, "/ForgotScreen");}),alignment: .topRight,),
              SizedBox(height: 30,),
              Consumer<AuthProvider>(builder: (context,provider,child){
                return CustomButton(

                    buttonHeading: provider.isLoading?"Loading...":"Login",
                    onPressed:provider.isLoading?null:()async{
                  if(!_formKey.currentState!.validate()){
                    return;
                  }
                  final error = await provider.login
                    (email: emailController.text.trim(),
                      password: passwordController.text);
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
                    '/DashboardScreen',
                  );
                });
              },),
              Row(children: [
                Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("or"),
                ),
                Expanded(child: Divider()),
              ],),
              Row(mainAxisAlignment: .center ,children: [
                Text("Don't have an account",),
                CustomTextButton(buttonHeading: "Signup?", onPressed: (){Navigator.pushNamed(context, "/SignupScreen");}),

              ],)
            ],
          ),
        ),),
      ),
    );
  }
}
