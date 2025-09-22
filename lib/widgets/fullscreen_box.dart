import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullScreenBox extends StatelessWidget {
  final Widget child;
  const FullScreenBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    final availableHeight = size.height - padding.top - padding.bottom - kToolbarHeight - kBottomNavigationBarHeight;
    final availableWidth = size.width - padding.left - padding.right;

    return SizedBox(
      width: availableWidth,
      height: availableHeight,
      child: child,
    );
  }
}