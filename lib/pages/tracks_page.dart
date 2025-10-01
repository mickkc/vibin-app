import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/pagination/minimal_track_pagination.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/pagination_footer.dart';

import '../l10n/app_localizations.dart';

class TrackPage extends StatefulWidget {
  final int page;

  const TrackPage({
    super.key,
    this.page = 1
  });

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {

  ApiManager apiManager = getIt<ApiManager>();
  String searchQuery = "";
  late int page = widget.page;
  late Future<MinimalTrackPagination> currentPagination = fetch();

  void updatePage(int newPage) {
    setState(() {
      page = newPage;
      currentPagination = fetch();
    });
  }

  Future<MinimalTrackPagination> fetch() {
    return apiManager.service.searchTracks(searchQuery, true, page, 50);
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final cols = max((width / 200).floor(), 2);
    final widthPerCol = (width - ((cols - 1) * 8)) / cols;
    final height = (widthPerCol - 16) + 85;
    return Column(
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.library_music, size: 32),
                Text(
                  lm.tracks,
                  style: Theme.of(context).textTheme.headlineMedium
                ),
              ],
            ),
            SizedBox(
              width: width > 800 ? width / 3 : 200,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: lm.search,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.zero,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHigh
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  setState(() {
                    searchQuery = value;
                    page = 1;
                    currentPagination = fetch();
                  });
                }
              ),
            )
          ],
        ),
        FutureContent(
          future: currentPagination,
          builder: (context, pagination) {
            return Column(
              children: [
                SizedBox(
                  height: (pagination.items.length / cols).ceil() * height + ((pagination.items.length / cols).ceil() - 1) * 8,
                  child: Center(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: height,
                      ),
                      itemCount: pagination.items.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return EntityCard(entity: pagination.items[index], coverSize: widthPerCol - 16);
                      }
                    ),
                  ),
                ),
                PaginationFooter(
                    pagination: pagination,
                    onPageChanged: (newPage) => updatePage(newPage)
                )
              ],
            );
          }
        )
      ]
    );
  }
}