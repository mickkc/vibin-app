import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dialogs/create_widget_dialog.dart';
import 'package:vibin_app/dtos/widgets/shared_widget.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/column_page.dart';
import 'package:vibin_app/utils/dialogs.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../dialogs/widget_info_dialog.dart';
import '../../dtos/widgets/widget_type.dart';
import '../../l10n/app_localizations.dart';

class WidgetManagementPage extends StatefulWidget {
  const WidgetManagementPage({super.key});

  @override
  State<WidgetManagementPage> createState() => _WidgetManagementPageState();
}

class _WidgetManagementPageState extends State<WidgetManagementPage> {

  final _apiManager = getIt<ApiManager>();
  late Future<List<SharedWidget>> _sharedWidgetsFuture;

  @override
  void initState() {
    super.initState();
    _sharedWidgetsFuture = _apiManager.service.getSharedWidgets();
  }

  Future<void> _createWidget() async {
    await CreateWidgetDialog.show(context, (SharedWidget newWidget) {
      setState(() {
        _sharedWidgetsFuture = _apiManager.service.getSharedWidgets();
      });
    });
  }

  Future<void> _deleteWidget(String widgetId) async {

    final lm = AppLocalizations.of(context)!;

    final confirmed = await Dialogs.showConfirmDialog(context, lm.settings_widgets_delete, lm.settings_widgets_delete_confirmation);
    if (!confirmed) return;

    try {
      await _apiManager.service.deleteSharedWidget(widgetId);
      setState(() {
        _sharedWidgetsFuture = _apiManager.service.getSharedWidgets();
      });
    }
    catch (e, st) {
      log("Failed to delete widget $widgetId", error: e, stackTrace: st, level: Level.error.value);
      if (mounted) {
        ErrorHandler.showErrorDialog(context, lm.settings_widgets_delete_error, error: e, stackTrace: st);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return ColumnPage(
      children: [
        SettingsTitle(
          title: lm.settings_app_manage_widgets_title,
          subtitle: lm.settings_app_manage_widgets_description
        ),

        ElevatedButton.icon(
          onPressed: _createWidget,
          label: Text(lm.settings_widgets_create_title),
          icon: const Icon(Icons.add),
        ),

        FutureContent(
          future: _sharedWidgetsFuture,
          builder: (context, sharedWidgets) {
            return SuperListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sharedWidgets.length,
              itemBuilder: (context, index) {
                final widgetItem = sharedWidgets[index];
                return ListTile(
                  tileColor: widgetItem.bgColor != null ? Color(widgetItem.bgColor!) : null,
                  textColor: widgetItem.fgColor != null ? Color(widgetItem.fgColor!) : null,
                  iconColor: widgetItem.accentColor != null ? Color(widgetItem.accentColor!) : null,
                  leading: const Icon(Icons.widgets),
                  title: Text(widgetItem.id),
                  subtitle: Text(widgetItem.types.map((t) => WidgetType.translateFromString(t, lm)).join(", ")),
                  trailing: IconButton(
                    tooltip: lm.settings_widgets_delete,
                    onPressed: () => _deleteWidget(widgetItem.id),
                    icon: const Icon(Icons.delete)
                  ),
                  onTap: () => WidgetInfoDialog.show(context, widgetItem)
                );
              }
            );
          }
        )
      ]
    );
  }
}