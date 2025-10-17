import 'package:flutter/cupertino.dart';

class RowSmallColumn extends StatelessWidget {
  final List<Widget> rowChildren;
  final List<Widget> columnChildren;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final int breakpoint = 600;

  const RowSmallColumn({
    super.key,
    required this.rowChildren,
    required this.columnChildren,
    this.spacing = 8.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            spacing: spacing,
            children: columnChildren
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            spacing: spacing,
            children: rowChildren
          );
        }
      },
    );
  }
}

class RowSmallColumnBuilder extends StatelessWidget {
  final List<Widget> Function(BuildContext, BoxConstraints) rowBuilder;
  final List<Widget> Function(BuildContext, BoxConstraints) columnBuilder;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final int breakpoint = 600;

  const RowSmallColumnBuilder({
    super.key,
    required this.rowBuilder,
    required this.columnBuilder,
    this.spacing = 8.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            spacing: spacing,
            children: columnBuilder(context, constraints)
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            spacing: spacing,
            children: rowBuilder(context, constraints)
          );
        }
      },
    );
  }
}