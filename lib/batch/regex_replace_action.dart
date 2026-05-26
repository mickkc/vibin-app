import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/row_small_column.dart';

import 'batch_action_interface.dart';

class RegexReplaceAction implements BatchAction {
  final String actionType;
  final String name;
  String _oldRegex = "";
  String _newRegex = "";

  RegexReplaceAction(this.actionType, this.name);

  @override
  Widget build(BuildContext context) => _RegexReplaceWidget(this);

  @override
  Map<String, dynamic> dataToJson() => {
    "actionType": actionType,
    "data": {
      "old": _oldRegex,
      "new": _newRegex
    }
  };

  @override
  String getName(AppLocalizations lm) => name;
}

class _RegexReplaceWidget extends StatefulWidget {
  final RegexReplaceAction action;
  const _RegexReplaceWidget(this.action);

  @override
  State<_RegexReplaceWidget> createState() => _RegexReplaceWidgetState();
}

class _RegexReplaceWidgetState extends State<_RegexReplaceWidget> {

  late final TextEditingController _oldController;
  late final TextEditingController _newController;

  late final _lm = AppLocalizations.of(context)!;

  @override
  void initState() {
    _oldController = TextEditingController(text: widget.action._oldRegex);
    _newController = TextEditingController(text: widget.action._newRegex);
    super.initState();
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  RowSmallColumn(
      rowChildren: [
        Expanded(
          child: TextField(
            controller: _oldController,
            onChanged: (s) { widget.action._oldRegex = s; },
            decoration: InputDecoration(
              labelText: _lm.batch_edit_actions_regex_old,
              border: OutlineInputBorder()
            ),
          ),
        ),
        const Icon(Icons.arrow_forward),
        Expanded(
          child: TextField(
            controller: _newController,
            onChanged: (s) { widget.action._newRegex = s; },
            decoration: InputDecoration(
              labelText: _lm.batch_edit_actions_regex_new,
              border: OutlineInputBorder()
            ),
          ),
        )
      ],
      columnChildren: [
        TextField(
          controller: _oldController,
          onChanged: (s) { widget.action._oldRegex = s; },
          decoration: InputDecoration(
              labelText: _lm.batch_edit_actions_regex_old,
              border: OutlineInputBorder()
          ),
        ),
        const Icon(Icons.arrow_downward),
        TextField(
          controller: _newController,
          onChanged: (s) { widget.action._newRegex = s; },
          decoration: InputDecoration(
              labelText: _lm.batch_edit_actions_regex_new,
              border: OutlineInputBorder()
          ),
        )
      ]
    );
  }

}