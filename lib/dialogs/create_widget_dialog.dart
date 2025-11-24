import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dtos/widgets/create_widget.dart';
import 'package:vibin_app/dtos/widgets/shared_widget.dart';
import 'package:vibin_app/dtos/widgets/widget_type.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/utils/dialogs.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/utils/theme_generator.dart';
import 'package:vibin_app/widgets/color_picker_field.dart';

import '../api/api_manager.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class CreateWidgetDialog extends StatefulWidget {

  final Function(SharedWidget) onCreate;

  const CreateWidgetDialog({
    super.key,
    required this.onCreate
  });

  static Future<void> show(BuildContext context, Function(SharedWidget) onCreate) {
    return showDialog(
      context: context,
      builder: (context) => CreateWidgetDialog(onCreate: onCreate)
    );
  }

  @override
  State<CreateWidgetDialog> createState() => _CreateWidgetDialogState();
}

class _CreateWidgetDialogState extends State<CreateWidgetDialog> {

  final _apiManager = getIt<ApiManager>();

  final List<WidgetType> _selectedTypes = [];

  Color? _backgroundColor;
  Color? _foregroundColor;
  Color? _accentColor;



  Future<void> _save() async {

    final lm = AppLocalizations.of(context)!;

    if (_selectedTypes.isEmpty) {
      await Dialogs.showInfoDialog(context, lm.settings_widgets_error_no_types_selected);
      return;
    }

    try {
      final newWidget = CreateWidget(
        types: _selectedTypes.map((e) => e.value).toList(),
        bgColor: _backgroundColor?.toHex(leadingHashSign: false),
        fgColor: _foregroundColor?.toHex(leadingHashSign: false),
        accentColor: _accentColor?.toHex(leadingHashSign: false)
      );

      final created = await _apiManager.service.createSharedWidget(newWidget);

      widget.onCreate(created);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
    catch (e, st) {
      log("Error creating widget", error: e, stackTrace: st, level: Level.error.value);
      if (!mounted) return;
      await ErrorHandler.showErrorDialog(context, lm.settings_widgets_create_error, error: e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;

    final availableTypes = WidgetType.values.where((type) => !_selectedTypes.contains(type));

    return AlertDialog(
      title: Text(lm.settings_widgets_create_title),
      constraints: BoxConstraints(
        maxWidth: width * 0.8,
        minWidth: width * 0.8
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [

            if (_selectedTypes.isNotEmpty) ... [
              Text(lm.settings_widgets_selected),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedTypes.map((type) {
                  return Chip(
                    label: Text(WidgetType.translateWidgetTypeToName(type, lm)),
                    onDeleted: () {
                      setState(() {
                        _selectedTypes.remove(type);
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            if (availableTypes.isNotEmpty) ... [
              Text(lm.settings_widgets_select),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableTypes.map((type) {
                  return ActionChip(
                    label: Text(WidgetType.translateWidgetTypeToName(type, lm)),
                    onPressed: () {
                      setState(() {
                        _selectedTypes.add(type);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const Divider(),
            Text(lm.settings_widgets_colors),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8.0,
              children: [
                Expanded(
                  child: ColorPickerField(
                    title: lm.settings_widgets_color_background,
                    color: _backgroundColor,
                    colorChanged: (color) => setState(() {
                      _backgroundColor = color;
                    })
                  ),
                ),
                Expanded(
                  child: ColorPickerField(
                    title: lm.settings_widgets_color_foreground,
                    color: _foregroundColor,
                    colorChanged: (color) => setState(() {
                      _foregroundColor = color;
                    })
                  ),
                ),
                Expanded(
                  child: ColorPickerField(
                    title: lm.settings_widgets_color_accent,
                    color: _accentColor,
                    colorChanged: (color) => setState(() {
                      _accentColor = color;
                    })
                  ),
                ),
              ],
            ),

            Container(
              color: _backgroundColor ?? Color(0xFF1D2021),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Card(
                    color: ThemeGenerator.blendColors(_backgroundColor ?? Color(0xFF1D2021), _accentColor ?? Color(0xFF689D6A), 0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            lm.settings_widgets_preview_title,
                            style: TextStyle(
                              color: _foregroundColor ?? Color(0xFFEBDBB2),
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            lm.settings_widgets_preview_subtitle,
                            style: TextStyle(
                              color: (_foregroundColor ?? Color(0xFFEBDBB2)).withAlpha(0xaa),
                              fontSize: 15,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 1,
                            children: [
                              for (var i = 0; i < 10; i++)
                                Container(
                                  color: ThemeGenerator.blendColors(_backgroundColor ?? Color(0xFF1D2021), _accentColor ?? Color(0xFF689D6A), i / 10.0),
                                  width: 25,
                                  height: 25,
                                )
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 1,
                            children: [
                              for (var i = 0; i < 10; i++)
                                Container(
                                  color: ThemeGenerator.blendColors(_accentColor ?? Color(0xFF689D6A), _foregroundColor ?? Color(0xFFEBDBB2), i / 10.0),
                                  width: 25,
                                  height: 25,
                                )
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor ?? Color(0xFF689D6A),
                            ),
                            onPressed: () {},
                            child: Text(
                              lm.settings_widgets_preview_button,
                              style: TextStyle(
                                color: _backgroundColor ?? Color(0xFF1D2021)
                              ),
                            ),
                          )
                        ],
                      )
                    )
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(lm.dialog_cancel)
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(lm.dialog_save)
        )
      ],
    );
  }
}