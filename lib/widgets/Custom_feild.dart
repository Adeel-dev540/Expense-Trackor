import 'package:flutter/material.dart';
class CustomFeild extends StatelessWidget {
 final String label;
 final String hintText;
 final bool obscureText;
 final IconData? SuffixIcon;
 final VoidCallback? SuffixOnPressed;
 final TextEditingController? controller;
 final String? Function(String?)? validator;
  const CustomFeild({
    super.key,
    required this.label,
    required this.hintText,
    required this.obscureText,
    this.controller,
    this.validator,
    this.SuffixIcon,
    this.SuffixOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text( label, style: TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.w600),),
        SizedBox(height: 15,),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          decoration: InputDecoration(
            suffixIcon: SuffixIcon != null
                ? IconButton(
              onPressed: SuffixOnPressed,
              icon: Icon(
                SuffixIcon,
                size: 20,
                color: Colors.grey.shade600,
              ),
            )
                : null,
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 4,vertical: 2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.green.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
