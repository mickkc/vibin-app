import 'package:flutter/material.dart';

import 'colored_icon_button.dart';

class PlayButton extends StatelessWidget {
  final bool isPlaying;
  final Function() onTap;

  const PlayButton({
    super.key,
    required this.isPlaying,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return ColoredIconButton(
      icon: isPlaying ? Icons.pause : Icons.play_arrow,
      size: 48,
      backgroundColor: Theme.of(context).colorScheme.primary,
      iconColor: Theme.of(context).colorScheme.surface,
      onPressed: onTap
    );
  }
}