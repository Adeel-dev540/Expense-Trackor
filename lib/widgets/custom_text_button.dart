import 'package:flutter/material.dart';
class CustomTextButton extends StatelessWidget {
  final String buttonHeading;
  final VoidCallback onPressed;
  const CustomTextButton({
    super.key,
    required this.buttonHeading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: Text(buttonHeading,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.green),));
  }
}
