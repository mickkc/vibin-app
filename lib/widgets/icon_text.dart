import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  final Color? color;

  const IconText({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Icon(
          icon,
          color: color,
        ),
        Flexible(
          child: onTap == null ? Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: color == null ? null : TextStyle(color: color),
          ) : InkWell(
            onTap: onTap,
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}