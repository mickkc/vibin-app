import 'package:flutter/material.dart';
import 'package:vibin_app/dialogs/tag_edit_dialog.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/overview/overview_header.dart';
import 'package:vibin_app/widgets/tag_widget.dart';

import '../../api/api_manager.dart';
import '../../main.dart';

class TagOverviewPage extends StatefulWidget {
  const TagOverviewPage({super.key});

  @override
  State<StatefulWidget> createState() => _TagOverviewPageState();
}

class _TagOverviewPageState extends State<TagOverviewPage> {

  String searchQuery = "";
  final ApiManager apiManager = getIt<ApiManager>();
  late Future<List<Tag>> tagsFuture = apiManager.service.getAllTags();

  void refreshTags() {
    setState(() {
      tagsFuture = apiManager.service.getAllTags();
    });
  }

  void editTag(Tag tag) {
    showDialog(
      context: context,
      builder: (context) {
        return TagEditDialog(
          onSave: (tag) {
            refreshTags();
          },
          onDelete: refreshTags,
          initialName: tag.name,
          initialDescription: tag.description,
          initialColor: tag.color,
          tagId: tag.id,
        );
      }
    );
  }

  void createTag() {
    showDialog(
      context: context,
      builder: (context) {
        return TagEditDialog(onSave: (tag) {
          refreshTags();
        });
      }
    );
  }

  List<Tag> getFilteredTags(List<Tag> tags) {
    if (searchQuery.isEmpty) {
      return tags;
    }
    return tags.where((tag) => tag.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    return Column(
      spacing: 16,
      mainAxisSize: MainAxisSize.min,
      children: [
        OverviewHeader(
          title: lm.tags,
          icon: Icons.sell,
          searchQuery: searchQuery,
          onSearchSubmitted: (value) {
            setState(() {
              searchQuery = value;
            });
          }
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                createTag();
              },
              icon: Icon(Icons.add),
              label: Text(lm.create_tag_title)
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: FutureContent(
            future: tagsFuture,
            hasData: (d) => getFilteredTags(d).isNotEmpty,
            builder: (context, tags) {
              final filteredTags = getFilteredTags(tags);
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filteredTags.map((tag) => Tooltip(
                  message: tag.description,
                  child: TagWidget(
                    tag: tag,
                    onTap: () {
                      editTag(tag);
                    },
                  )
                )).toList()
              );
            }
          ),
        )
      ],
    );
  }
}