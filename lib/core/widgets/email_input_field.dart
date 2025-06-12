import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class EmailInputField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final Color labelColor;
  final Color textColor;
  final Color iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const EmailInputField({
    super.key,
    required this.labelText,
    this.controller,
    this.labelColor = AppColors.darkGray,
    this.textColor = AppColors.black,
    this.iconColor = AppColors.black,
    this.borderRadius = 8.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: labelColor),
          prefixIcon: Icon(Icons.mail, color: iconColor),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
