import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool enabled;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.validator,
    this.onTap,
    this.readOnly = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused
              ? const Color(0xFF00FF88)
              : const Color(0xFF00FF88).withValues(alpha: 0.3),
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused ? [
            BoxShadow(
              color: const Color(0xFF00FF88).withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ] : null,
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText && _isObscured,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          validator: widget.validator,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: _isFocused
                ? const Color(0xFF00FF88)
                : Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isFocused
                  ? const Color(0xFF00FF88).withValues(alpha: 0.1)
                  : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                color: _isFocused
                  ? const Color(0xFF00FF88)
                  : Colors.black54,
                size: 20,
              ),
            ),
            suffixIcon: widget.obscureText ? IconButton(
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
              icon: Icon(
                _isObscured ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: Colors.black54,
              ),
            ) : null,
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ),
    );
  }
}
