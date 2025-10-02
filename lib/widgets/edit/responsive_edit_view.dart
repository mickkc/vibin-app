import 'package:flutter/material.dart';
import 'package:vibin_app/widgets/row_small_column.dart';

class ResponsiveEditView extends StatelessWidget {
  
  final String title;
  final List<Widget> children;
  final List<Widget> actions;
  final Widget? imageEditWidget;
  final double imageEditWidgetWidth;
  
  const ResponsiveEditView({
    super.key,
    required this.title,
    required this.children,
    required this.actions,
    this.imageEditWidget,
    this.imageEditWidgetWidth = 256,
  });

  Widget actionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: actions,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Column(
      spacing: 16,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium,
        ),
        RowSmallColumn(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          rowChildren: [
            if (imageEditWidget != null)
              SizedBox(
                width: imageEditWidgetWidth,
                child: Center(
                  child: imageEditWidget,
                ),
              ),
            VerticalDivider(),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  ...children,
                  Divider(),
                  actionsRow()
                ]
              ),
            )
          ],
          columnChildren: [
            if (imageEditWidget != null)
              SizedBox(
                width: width,
                child: Center(
                  child: imageEditWidget,
                ),
              ),
            ...children,
            Divider(),
            actionsRow()
          ]
        )
      ]
    );
  }
}