import 'package:flutter/material.dart';

/// Common text field used across auth and task forms to keep visuals consistent.
class PrimaryTextField extends StatefulWidget {
  const PrimaryTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.onChanged,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final ValueChanged<String>? onChanged;

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          obscureText: widget.isPassword ? _obscure : false,
          style: const TextStyle(color: Colors.white),

          onChanged: widget.onChanged,

          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),

            filled: true,
            fillColor: const Color(0xFF151A24),

            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: Colors.white70)
                : null,

            suffixIcon: widget.isPassword
                ? IconButton(
              onPressed: () {
                setState(() => _obscure = !_obscure);
              },
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
            )
                : widget.suffixIcon,

            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
              BorderSide(color: Colors.white.withOpacity(0.15)),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
