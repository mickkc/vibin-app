import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final welcomeMessage = apiManager.service.getWelcomeMessage();

    return Column(
      spacing: 8,
      children: [
        FutureContent(
          future: welcomeMessage,
          builder: (context, message) {
            return SectionHeader(
              title: message.isNotEmpty ? message : AppLocalizations.of(context)!.welcome_message,
              maxLines: 3,
            );
          }
        ),
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
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      final id = item.value["id"];
                      final route =  switch (item.key) {
                        "ALBUM" => "/albums/$id",
                        "ARTIST" => "/artists/$id",
                        "PLAYLIST" => "/playlists/$id",
                        _ => "/",
                      };
                      GoRouter.of(context).push(route);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        ),
                        child: SizedBox(
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
                              Flexible(
                                child: Text(
                                    item.key == "ARTIST" || item.key == "PLAYLIST" ? item.value["name"] : item.value["title"],
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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