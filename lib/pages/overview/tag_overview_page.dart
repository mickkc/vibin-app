import 'package:flutter/material.dart';
import 'package:vibin_app/dialogs/tag_edit_dialog.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/pages/column_page.dart';
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

  String _searchQuery = "";
  final _apiManager = getIt<ApiManager>();
  late Future<List<Tag>> _tagsFuture = _apiManager.service.getAllTags(null, null);

  void refreshTags() {
    setState(() {
      _tagsFuture = _apiManager.service.getAllTags(_searchQuery, null);
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

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    return ColumnPage(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OverviewHeader(
          title: lm.tags,
          icon: Icons.sell,
          searchQuery: _searchQuery,
          onSearchSubmitted: (value) {
            setState(() {
              _searchQuery = value;
              refreshTags();
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
            future: _tagsFuture,
            hasData: (d) => d.isNotEmpty,
            builder: (context, tags) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: tags.map((tag) => Tooltip(
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