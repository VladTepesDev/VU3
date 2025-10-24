import 'dart:ui';
import 'package:flutter/material.dart';

class GlassTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final double borderRadius;

  const GlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.borderRadius = 16,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: _isFocused 
                    ? const Color(0xFF1A1A1A).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.6),
                width: _isFocused ? 2 : 1.5,
              ),
            ),
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() => _isFocused = hasFocus);
              },
              child: TextFormField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                validator: widget.validator,
                onChanged: widget.onChanged,
                maxLines: widget.maxLines,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  labelText: widget.labelText,
                  hintStyle: TextStyle(
                    color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  labelStyle: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
