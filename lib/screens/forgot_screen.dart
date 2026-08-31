import 'package:expense_trackor/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/Custom_feild.dart';
import '../widgets/custom_button.dart';

class ForgotScreen extends StatelessWidget {
  final TextEditingController emailController= TextEditingController();
  final _formKey = GlobalKey<FormState>();
   ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 30),child:Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 100,),
              Center(child: Text("Reset Password", style: TextStyle(fontSize: 40,fontWeight: FontWeight.w600,color: Colors.black),)),
              SizedBox(height: 100,),
              CustomFeild(label: "Email", hintText: "Enter Your Email", obscureText: false, controller: emailController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Email is required";
                  }
        
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
                    return "Enter a valid email";
                  }
        
                  return null;
                },),
              SizedBox(height: 40,),

              Consumer<AuthProvider>(builder: (context,provider,child){
                return CustomButton(
                  buttonHeading: provider.isLoading
                      ? 'Sending...'
                      : 'Change password',

                  onPressed: provider.isLoading
                      ? null
                      : () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    final error = await provider.forgot(
                      email: emailController.text.trim(),
                    );

                    if (!context.mounted) return;

                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                        ),
                      );

                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset email sent. Check your Email inbox or spam email.',
                        ),
                      ),
                    );

                    emailController.clear();
                  },
                );
              }),
        
            ],
          ),
        ),),
      ),
    );
  }
}
