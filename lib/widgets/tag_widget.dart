import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/utils/theme_generator.dart';

class TagWidget extends StatelessWidget {
  final Tag tag;
  final void Function()? onTap;
  final void Function()? onContextMenu;
  final VoidCallback? onNavigate;

  const TagWidget({
    super.key,
    required this.tag,
    this.onTap,
    this.onContextMenu,
    this.onNavigate,
  });

  void openTag(Tag tag, BuildContext context) {
    GoRouter.of(context).push("/tracks?advanced=true&search=%2B%22${tag.name}%22");
    onNavigate?.call();
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final color = ThemeGenerator.blendColors(
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      (10 - tag.importance) / 10.0
    );

    return InkWell(
      onTap: onTap ?? () => openTag(tag, context),
      onLongPress: onContextMenu,
      onSecondaryTap: onContextMenu,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Icon(Icons.sell, size: 16, color: color),
            Text(tag.name, style: TextStyle(color: color))
          ]
        )
      ),
    );
  }
}