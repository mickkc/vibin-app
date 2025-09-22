import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../widgets/future_content.dart';

class RecommendedStartSection extends StatelessWidget {

  const RecommendedStartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final apiManager = getIt<ApiManager>();
    final recommended = apiManager.service.getTopListenedNonTrackItems(8, -1);

    return Column(
      spacing: 8,
      children: [
        SectionHeader(title: AppLocalizations.of(context)!.welcome_message),
        FutureContent(
          future: recommended,
          hasData: (d) => d.isNotEmpty,
          builder: (context, items) {
            final cols = (MediaQuery.sizeOf(context).width / 300.0).ceil().clamp(1, 4);
            return SizedBox(
              height: (items.length / cols).ceil() * 50 + ((items.length / cols).ceil() - 1) * 8,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 50
                ),
                itemCount: items.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () {
                        print("Tapped on ${item.value}");
                      },
                      child: Container(
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh),
                        height: 50,
                        child: Row(
                          spacing: 16,
                          children: [
                            NetworkImageWidget(
                              url: switch (item.key) {
                                "ALBUM" => "/api/albums/${item.value["id"]}/cover?quality=small",
                                "ARTIST" => "/api/artists/${item.value["id"]}/image?quality=small",
                                "PLAYLIST" => "/api/playlists/${item.value["id"]}/image?quality=small",
                                _ => "",
                              },
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            Text(
                                item.key == "ARTIST" || item.key == "PLAYLIST" ? item.value["name"] : item.value["title"],
                                style: Theme.of(context).textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              )
            );
          }
        ),
      ],
    );
  }
}