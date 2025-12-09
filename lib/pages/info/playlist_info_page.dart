import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/playlist/playlist_data.dart';
import 'package:vibin_app/dtos/shuffle_state.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/widgets/bars/playlist_action_bar.dart';
import 'package:vibin_app/widgets/date_footer.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/sliver_future_content.dart';
import 'package:vibin_app/widgets/icon_text.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/row_small_column.dart';
import 'package:vibin_app/widgets/tracklist/playlist_track_list.dart';

import '../../api/api_manager.dart';
import '../../audio/audio_manager.dart';
import '../../auth/auth_state.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

class PlaylistInfoPage extends StatefulWidget {

  final int playlistId;

  const PlaylistInfoPage({
    super.key,
    required this.playlistId
  });

  @override
  State<PlaylistInfoPage> createState() => _PlaylistInfoPageState();
}

class _PlaylistInfoPageState extends State<PlaylistInfoPage> {

  Widget _playlistInfo(BuildContext context, Future<PlaylistData> playlistDataFuture) {

    final lm = AppLocalizations.of(context)!;
    final authState = getIt<AuthState>();

    return FutureContent(
      future: playlistDataFuture,
      builder: (context, data) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              data.playlist.name,
              style: Theme.of(context).textTheme.headlineMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1
            ),
            if (data.playlist.description.isNotEmpty) ... [
              Text(
                data.playlist.description,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            ],
            IconText(
              icon: Icons.person,
              text: data.playlist.owner.displayName ?? data.playlist.owner.username,
              onTap: authState.hasPermission(PermissionType.viewUsers) ? () {
                GoRouter.of(context).push('/users/${data.playlist.owner.id}');
              } : null,
            ),
            if (data.playlist.collaborators.isNotEmpty) ... [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.start,
                children: [
                  Icon(Icons.group),
                  for (var collaborator in data.playlist.collaborators) ... [
                    InkWell(
                      onTap: authState.hasPermission(PermissionType.viewUsers) ? () {
                        GoRouter.of(context).push('/users/${collaborator.id}');
                      } : null,
                      child: Text(
                        collaborator.displayName ?? collaborator.username,
                        style: TextStyle(
                          color: authState.hasPermission(PermissionType.viewUsers) ? Theme.of(context).colorScheme.primary : null
                        ),
                      ),
                    ),
                    if (collaborator != data.playlist.collaborators.last)
                      const Text("•")
                  ]
                ]
              )
            ],
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                IconText(icon: Icons.library_music, text: "${data.tracks.length} ${lm.tracks}"),
                IconText(icon: Icons.access_time, text: getTotalDurationString(data.tracks.map((e) => e.track))),
                IconText(
                    icon: data.playlist.public ? Icons.public : Icons.lock,
                    text: data.playlist.public ? lm.playlists_public : lm.playlists_private
                )
              ],
            )
          ],
        );
      }
    );
  }

  final _apiManager = getIt<ApiManager>();
  final _audioManager = getIt<AudioManager>();
  late Future<PlaylistData> _playlistDataFuture = _apiManager.service.getPlaylist(widget.playlistId);
  final _shuffleState = ShuffleState(isShuffling: false);

  @override
  Widget build(BuildContext context) {

    return Material(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(0.0),
            sliver: SliverToBoxAdapter(
              child: RowSmallColumnBuilder(
                spacing: 32,
                mainAxisAlignment: MainAxisAlignment.start,
                columnBuilder: (context, constraints) {
                  return [
                    NetworkImageWidget(
                      url: "/api/playlists/${widget.playlistId}/image",
                      width: constraints.maxWidth * 0.75,
                      height: constraints.maxWidth * 0.75
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: _playlistInfo(context, _playlistDataFuture)
                    )
                  ];
                },
                rowBuilder: (context, constraints) {
                  return [
                    NetworkImageWidget(
                      url: "/api/playlists/${widget.playlistId}/image?quality=256",
                      width: 200,
                      height: 200
                    ),
                    Expanded(
                      child: _playlistInfo(context, _playlistDataFuture)
                    )
                  ];
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            sliver: SliverToBoxAdapter(
              child: FutureContent(
                future: _playlistDataFuture,
                builder: (context, data) {
                  return PlaylistActionBar(
                    playlistData: data,
                    shuffleState: _shuffleState,
                    onUpdate: (data) {
                      setState(() {
                        _playlistDataFuture = Future.value(data);
                      });
                    }
                  );
                }
              ),
            ),
          ),

          SliverFutureContent(
            future: _playlistDataFuture,
            builder: (context, data) {
              return PlaylistTrackList(
                tracks: data.tracks,
                playlistId: widget.playlistId,
                onTrackTapped: (track) {
                  _audioManager.playPlaylistData(
                    data,
                    preferredTrackId: track.id,
                    shuffle: _shuffleState.isShuffling
                  );
                }
              );
            }
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
          ),

          SliverToBoxAdapter(
            child: FutureContent(
              future: _playlistDataFuture,
              builder: (context, data) {
                return DateFooter(
                  createdAt: data.playlist.createdAt,
                  updatedAt: data.playlist.updatedAt,
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}