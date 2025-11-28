import 'package:flutter/material.dart';

/// Reusable filled button that stretches to its parent's width by default.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.margin,
    this.isSpinning = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsetsGeometry? margin;

  /// When true and [icon] is not null, the icon will rotate.
  final bool isSpinning;

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );

    final Widget content;
    if (icon == null) {
      content = ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      );
    } else {
      content = ElevatedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: isSpinning
            ? RotatingIcon(icon!)
            : Icon(icon, size: 20),
        label: Text(label),
      );
    }

    final width = fullWidth ? double.infinity : null;

    return Container(
      width: width,
      margin: margin,
      child: content,
    );
  }
}

/// Simple rotating icon used for loading states.
class RotatingIcon extends StatefulWidget {
  const RotatingIcon(this.icon, {super.key});

  final IconData icon;

  @override
  State<RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(widget.icon, size: 20),
    );
  }
}
