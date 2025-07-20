import 'package:flutter/material.dart';

class PasswordInputField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const PasswordInputField({
    super.key,
    required this.hintText,
    this.controller,
    this.borderRadius = 12.0,
    this.padding,
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
    final theme = Theme.of(context);
    
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
          filled: true,
          fillColor: theme.colorScheme.surface,
          prefixIcon: Icon(Icons.vpn_key, color: theme.colorScheme.onSurface),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: _toggleVisibility,
          ),
        ),
      ),
    );
  }
}
