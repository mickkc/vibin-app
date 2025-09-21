import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/tag.dart';
import 'package:vibin_app/extensions.dart';

class TagWidget extends StatelessWidget {
  final Tag tag;
  final void Function()? onTap;

  const TagWidget({super.key, required this.tag, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = HexColor.fromHex(tag.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Icon(Icons.sell, size: 16, color: color),
            Text(tag.name, style: TextStyle(color: color))
          ]
        )
      )
    );
  }
}