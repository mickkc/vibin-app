import 'package:flutter/material.dart';
import 'package:vibin_app/pages/column_page.dart';
import 'package:vibin_app/sections/related_section.dart';
import 'package:vibin_app/widgets/bars/track_action_bar.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/row_small_column.dart';
import 'package:vibin_app/widgets/track_info.dart';

class TrackInfoPage extends StatelessWidget {

  final int trackId;

  const TrackInfoPage({
    super.key,
    required this.trackId
  });

  @override
  Widget build(BuildContext context) {

    return ColumnPage(
      children: [
        RowSmallColumn(
          spacing: 32,
          mainAxisAlignment: MainAxisAlignment.start,
          rowChildren: [
            NetworkImageWidget(
              url: "/api/tracks/$trackId/cover?quality=medium",
              width: 200,
              height: 200,
            ),
            Expanded(child: TrackInfoView(trackId: trackId))
          ],
          columnChildren: [
            LayoutBuilder(
              builder: (context, constraints) {
                return NetworkImageWidget(
                  url: "/api/tracks/$trackId/cover?quality=large",
                  width: constraints.maxWidth * 0.75,
                  height: constraints.maxWidth * 0.75,
                );
              }
            ),
            TrackInfoView(trackId: trackId)
          ],
        ),
        TrackActionBar(trackId: trackId),
        Column(
          children: [
            RelatedSection(trackId: trackId)
          ],
        )
      ],
    );
  }
}