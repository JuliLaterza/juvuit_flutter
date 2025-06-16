import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class PasswordInputField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final Color labelColor;
  final Color textColor;
  final Color iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color fillColor;

  const PasswordInputField({
    super.key,
    required this.hintText,
    this.controller,
    this.labelColor = AppColors.darkGray,
    this.textColor = AppColors.black,
    this.iconColor = AppColors.gray,
    this.borderRadius = 8.0,
    this.padding,
    required this.fillColor,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        style: TextStyle(color: widget.textColor),
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelStyle: TextStyle(color: widget.labelColor),
          filled: true,
          fillColor: widget.fillColor, // ← acá el cambio importante
          prefixIcon: Icon(Icons.vpn_key, color: widget.iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: widget.iconColor,
            ),
            onPressed: _toggleVisibility,
          ),
        ),
      ),
    );
  }
}
