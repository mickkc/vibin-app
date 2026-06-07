import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/sort_order.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

class SortingDialog<C> extends StatefulWidget {
  final List<C> criteriaList;
  final C selectedCriteria;
  final (String, IconData) Function(C) labelGenerator;

  final SortOrder sortOrder;

  final Function(C, SortOrder) onSortingChanged;

  static void show<C>(
    BuildContext context,
    List<C> criteriaList,
    C criteria,
    (String, IconData) Function(C) labelGenerator,
    SortOrder sortOrder,
    final Function(C, SortOrder) onSortingChanged) {

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
        alignment: Alignment.topRight,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SortingDialog<C>(
              criteriaList: criteriaList,
              selectedCriteria: criteria,
              labelGenerator: labelGenerator,
              sortOrder: sortOrder,
              onSortingChanged: onSortingChanged
            ),
          ),
        );
      },
    );
  }

  SortingDialog({
    super.key,
    required this.criteriaList,
    required this.selectedCriteria,
    required this.labelGenerator,
    required this.sortOrder,
    required this.onSortingChanged
  });

  @override
  State<StatefulWidget> createState() {
    return _SortingDialogState<C>();
  }
}

class _SortingDialogState<C> extends State<SortingDialog<C>> {

  late var _selectedCriteria = widget.selectedCriteria;
  late var _selectedSortOrder = widget.sortOrder;

  late final _lm = AppLocalizations.of(context)!;

  Widget _cToWidget(C c) {
    final (title, icon) = widget.labelGenerator(c);
    return RadioListTile(
      value: c,
      title: Text(title),
      secondary: Icon(icon),
      controlAffinity: ListTileControlAffinity.trailing,
      dense: true,
    );
  }

  void _submit() {
    widget.onSortingChanged(_selectedCriteria, _selectedSortOrder);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              _lm.sort_by,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          RadioGroup<C>(
            onChanged: (c) => setState(() {
              if (c == null) return;
              _selectedCriteria = c;
            }),
            groupValue: _selectedCriteria,
            child: Column(
              spacing: 4.0,
              children: widget.criteriaList.map(_cToWidget).toList()
            )
          ),
          const Divider(),
          RadioGroup<SortOrder>(
            onChanged: (so) => setState(() {
              if (so == null) return;
              _selectedSortOrder = so;
            }),
            groupValue: _selectedSortOrder,
            child: Column(
              spacing: 4.0,
              children: [
                RadioListTile(
                  value: SortOrder.ASC,
                  title: Text(_lm.sort_order_asc),
                  secondary: const Icon(Icons.arrow_upward),
                  controlAffinity: ListTileControlAffinity.trailing,
                  dense: true,
                ),
                RadioListTile(
                  value: SortOrder.DESC,
                  title: Text(_lm.sort_order_desc),
                  secondary: Icon(Icons.arrow_downward),
                  controlAffinity: ListTileControlAffinity.trailing,
                  dense: true,
                )
              ]
            )
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton(
                onPressed: _submit,
                child: Text(_lm.dialog_finish)
              )
            ],
          )
        ],
      ),
    );
  }
}