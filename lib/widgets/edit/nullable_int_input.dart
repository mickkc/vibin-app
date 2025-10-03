import 'package:flutter/material.dart';

class NullableIntInput extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  final String label;
  final String? hintText;

  const NullableIntInput({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.hintText
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value?.toString() ?? "");

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
      ),
      onChanged: (text) {
        if (text.isEmpty) {
          onChanged(null);
          return;
        }
        final intValue = int.tryParse(text);
        if (intValue != null) {
          onChanged(intValue);
        }
        else {
          controller.text = value?.toString() ?? "";
        }
      },
    );
  }
}