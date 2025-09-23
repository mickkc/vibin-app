import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/pagination/minimal_track_pagination.dart';
import 'package:vibin_app/l10n/app_localizations_de.dart';
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
  late int page = widget.page;
  late Future<MinimalTrackPagination> currentPagination = fetch();

  void updatePage(int newPage) {
    setState(() {
      page = newPage;
      currentPagination = fetch();
    });
  }

  Future<MinimalTrackPagination> fetch() {
    return apiManager.service.getTracks(page, null);
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    final cols = max((MediaQuery.of(context).size.width / 200).floor(), 2);
    final widthPerCol = (MediaQuery.of(context).size.width - ((cols - 1) * 8)) / cols;
    final height = (widthPerCol - 16) + 85;
    return Column(
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.library_music, size: 32),
            Text(
              lm.tracks,
              style: Theme.of(context).textTheme.headlineMedium
            ),
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
                      scrollDirection: Axis.vertical,
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