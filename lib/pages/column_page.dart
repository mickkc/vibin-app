import 'package:flutter/material.dart';

class ColumnPage extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final double? spacing;

  const ColumnPage({
    super.key,
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.spacing
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            spacing: spacing ?? 16,
            mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
            crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
            children: children,
          ),
        ),
      )
    );
  }
}