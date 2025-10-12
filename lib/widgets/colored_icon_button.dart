import 'package:flutter/material.dart';

class ColoredIconButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color? iconColor;
  final VoidCallback onPressed;
  final double? size;
  final EdgeInsetsGeometry padding;
  final String? tooltip;

  const ColoredIconButton({
    super.key,
    required this.icon,
    required this.backgroundColor,
    this.iconColor,
    required this.onPressed,
    this.size,
    this.padding = const EdgeInsets.all(4.0),
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? IconTheme.of(context).size ?? 24.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: Container(
        color: backgroundColor,
        child: Padding(
          padding: padding,
          child: IconButton(
            onPressed: onPressed,
            tooltip: tooltip,
            icon: Icon(icon, size: size, color: iconColor),
          )
        ),
      ),
    );
  }
}