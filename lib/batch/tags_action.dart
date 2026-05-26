import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/edit/tag_search_bar.dart';
import '../widgets/tag_widget.dart';
import 'batch_action_interface.dart';

class TagsAction implements BatchAction {
  final List<Tag> _selectedTags = [];
  final bool remove;

  TagsAction(this.remove);

  @override
  String getName(AppLocalizations lm) => remove
      ? lm.batch_edit_actions_remove_tags
      : lm.batch_edit_actions_add_tags;

  @override
  Map<String, dynamic> dataToJson() => {
    "actionType": remove ? "REMOVE_TAGS" : "ADD_TAGS",
    "data": {
      "ids": _selectedTags.map((tag) => tag.id).toList()
    }
  };

  @override
  Widget build(BuildContext context) => _AddTagsWidget(action: this);
}

class _AddTagsWidget extends StatefulWidget {
  final TagsAction action;
  const _AddTagsWidget({required this.action});

  @override
  State<_AddTagsWidget> createState() => _AddTagsWidgetState();
}

class _AddTagsWidgetState extends State<_AddTagsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          children: widget.action._selectedTags.map((tag) => Tooltip(
            message: tag.description,
            child: TagWidget(
              tag: tag,
              onTap: () {
                setState(() {
                  widget.action._selectedTags.remove(tag);
                });
              },
            )
          )).toList(),
        ),
        TagSearchBar(
          ignoredTags: widget.action._selectedTags,
          onTagSelected: (tag) {
            setState(() {
              widget.action._selectedTags.add(tag);
            });
          },
        ),
      ],
    );
  }
}
