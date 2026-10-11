import 'package:flutter/material.dart';
import 'package:vibin_app/widgets/row_small_column.dart';

class BaseSettingWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? description;
  final Function(BuildContext, RowColumn) child;
  final double? rowWidgetWidth;

  const BaseSettingWidget({
    super.key,
    this.icon,
    required this.title,
    this.description,
    required this.child,
    this.rowWidgetWidth
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.all(8),
              child: Icon(icon, color: ColorScheme.of(context).onSurfaceVariant),
            ),

          Expanded(
            child: RowSmallColumnBuilderV2(
              columnCrossAxisAlignment: CrossAxisAlignment.stretch,
              rowMainAxisSize: MainAxisSize.max,
              builder: (context, rowCol) {
                return [
                  ConditionalExpanded(
                    expanded: rowCol == RowColumn.row,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 16),
                        ),
                        if (description != null)
                          Text(
                            description!,
                            style: TextStyle(color: ColorScheme.of(context).onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),

                  if (rowCol == RowColumn.row)
                    SizedBox(width: rowWidgetWidth, child: child(context, rowCol))
                  else
                    child(context, rowCol)
                ];
              }
            ),
          )
        ],
      ),
    );
  }
}