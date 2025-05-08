import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Function(String) onChanged;
  final Widget? suffixIcon;

  const CustomInput({
    Key? key,
    required this.hintText,
    this.obscureText = false,
    required this.onChanged,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: onChanged,
    );
  }
}
