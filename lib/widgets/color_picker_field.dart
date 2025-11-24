import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../l10n/app_localizations.dart';

class ColorPickerField extends StatefulWidget {

  final String title;
  final Color? color;
  final Function(Color?) colorChanged;

  const ColorPickerField({
    super.key,
    required this.title,
    required this.color,
    required this.colorChanged
  });

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {

  late Color pickerColor;

  @override
  void initState() {
    pickerColor = widget.color ?? Colors.transparent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final lm = AppLocalizations.of(context)!;

    return InkWell(
      child: Ink(
        decoration: BoxDecoration(
          image: widget.color == null ? DecorationImage(image: AssetImage("assets/images/checkerboard.png"), repeat: ImageRepeat.repeat) : null,
          color: widget.color ?? Colors.transparent,
          border: Border.all(color: theme.colorScheme.onSurface),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(color: widget.color != null ? widget.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black),
            )
          ),
        ),
      ),
      onTap: () {
        pickerColor = widget.color ?? Colors.transparent;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(widget.title),
            content: SingleChildScrollView(
              child: ColorPicker(
                enableAlpha: false,
                hexInputBar: true,
                pickerColor: widget.color ?? Colors.black,
                onColorChanged: (color) {
                  setState(() {
                    pickerColor = color;
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  widget.colorChanged(null);
                  Navigator.of(context).pop();
                },
                child: Text(lm.settings_widgets_color_clear)
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.colorChanged(pickerColor);
                },
                child: Text(lm.dialog_save)
              )
            ],
          )
        );
      }
    );
  }
}