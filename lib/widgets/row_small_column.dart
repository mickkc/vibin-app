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

enum RowColumn {
  row,
  column;
}

class RowSmallColumnBuilderV2 extends StatelessWidget {
  final List<Widget> Function(BuildContext, RowColumn) builder;
  final double spacing;
  final MainAxisAlignment rowMainAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final MainAxisSize rowMainAxisSize;
  final MainAxisAlignment columnMainAxisAlignment;
  final CrossAxisAlignment columnCrossAxisAlignment;
  final MainAxisSize columnMainAxisSize;
  final int breakpoint = 600;

  const RowSmallColumnBuilderV2({
    super.key,
    required this.builder,
    this.spacing = 8.0,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.rowMainAxisSize = MainAxisSize.min,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.center,
    this.columnMainAxisSize = MainAxisSize.min
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            mainAxisSize: columnMainAxisSize,
            mainAxisAlignment: columnMainAxisAlignment,
            crossAxisAlignment: columnCrossAxisAlignment,
            spacing: spacing,
            children: builder(context, RowColumn.column)
          );
        } else {
          return Row(
            mainAxisSize: rowMainAxisSize,
            mainAxisAlignment: rowMainAxisAlignment,
            crossAxisAlignment: rowCrossAxisAlignment,
            spacing: spacing,
            children: builder(context, RowColumn.row)
          );
        }
      },
    );
  }
}

class ConditionalExpanded extends StatelessWidget {
  final bool expanded;
  final Widget child;

  const ConditionalExpanded({
    super.key,
    required this.expanded,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return Expanded(child: child);
    }
    return child;
  }
}