import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/tag_widget.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart';

class TagSearchBar extends StatefulWidget {
  final List<Tag> ignoredTags;
  final Function(Tag) onTagSelected;

  const TagSearchBar({super.key, required this.ignoredTags, required this.onTagSelected});

  @override
  State<TagSearchBar> createState() => _TagSearchBarState();

}

class _TagSearchBarState extends State<TagSearchBar> {
  
  final _searchController = TextEditingController();

  final _apiManager = getIt<ApiManager>();
  late final _lm = AppLocalizations.of(context)!;

  Timer? _searchDebounce;

  late Future<List<Tag>> _tagsFuture;

  void refreshTags() {
    _tagsFuture = _apiManager.service.getAllTags(_searchController.text, null);
  }

  @override
  void initState() {
    super.initState();
    refreshTags();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: _lm.search,
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            )
          ),
          onChanged: (value) {
            if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
            _searchDebounce = Timer(const Duration(milliseconds: 300), () {
              setState(() {
                refreshTags();
              });
            });
          },
        ),
        FutureContent(
          future: _tagsFuture,
          builder: (context, tags) {
            final filteredTags = tags.where((tag) => !widget.ignoredTags.any((ignored) => ignored.id == tag.id)).toList();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: filteredTags.map(
                  (tag) => TagWidget(tag: tag, onTap: () => widget.onTagSelected(tag))
                ).toList(),
              ),
            );
          },
        )
      ],
    );
  }
}