import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  final String buttonHeading;
  final VoidCallback? onPressed;
  const CustomButton({
    super.key,
    required this.buttonHeading,
    required this.onPressed,

  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(onPressed: onPressed, child: Text(buttonHeading,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,),),style:
        ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
      ),),
    );
  }
}
