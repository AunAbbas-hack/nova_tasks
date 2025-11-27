import 'package:flutter/material.dart';

/// Reusable filled button that stretches to its parent's width by default.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.margin,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );

    final content = icon == null
        ? ElevatedButton(onPressed: onPressed, style: style, child: Text(label))
        : ElevatedButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon, size: 20),
            label: Text(label),
          );

    final width = fullWidth ? double.infinity : null;

    return Container(width: width, margin: margin, child: content);
  }
}
