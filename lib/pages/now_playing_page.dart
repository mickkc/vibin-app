import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/dialogs/lyrics_dialog.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/sections/similar_tracks_section.dart';
import 'package:vibin_app/widgets/nowplaying/now_playing_control_bar.dart';
import 'package:vibin_app/widgets/track_info.dart';

import '../widgets/network_image.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const NowPlayingPage(),
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxWidth: (MediaQuery.of(context).size.width * 0.9).clamp(600, 900),
      ),
    );
  }

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {

  final _audioManager = getIt<AudioManager>();
  late MediaItem? _currentMediaItem = _audioManager.getCurrentMediaItem();

  late final StreamSubscription _currentMediaItemSubscription;

  _NowPlayingPageState() {
    _currentMediaItemSubscription = _audioManager.currentMediaItemStream.listen((mediaItem) {
      if (mediaItem?.id != _currentMediaItem?.id) {
        setState(() {
          _currentMediaItem = _audioManager.getCurrentMediaItem();
        });
      }
    });
  }

  @override
  void dispose() {
    _currentMediaItemSubscription.cancel();
    super.dispose();
  }

  void _close() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (_currentMediaItem == null) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(AppLocalizations.of(context)!.now_playing_nothing),
          );
        }

        if (isMobile) {
          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.8,
            maxChildSize: 0.95,
            snap: true,
            snapSizes: const [0.8, 0.95],
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 32,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NetworkImageWidget(
                        url: "/api/tracks/${_currentMediaItem!.id}/cover",
                        width: (constraints.maxWidth - 32) * 0.9,
                        height: (constraints.maxWidth - 32) * 0.9,
                      ),
                      TrackInfoView(
                        trackId: int.parse(_currentMediaItem!.id),
                        showMetadata: false,
                        onNavigate: _close,
                      ),
                      NowPlayingControlBar(mediaItem: _currentMediaItem!, onNavigate: _close),
                      Card(
                        clipBehavior: Clip.hardEdge,
                        shadowColor: Colors.black,
                        elevation: 4,
                        child: SizedBox(
                          height: 250,
                          child: LyricsDialog(),
                        ),
                      ),
                      SimilarTracksSection(trackId: int.parse(_currentMediaItem!.id)),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 32,
              children: [
                Row(
                  spacing: 32,
                  children: [
                    NetworkImageWidget(
                      url: "/api/tracks/${_currentMediaItem!.id}/cover?quality=256",
                      width: 200,
                      height: 200,
                    ),
                    Expanded(
                      child: TrackInfoView(
                        trackId: int.parse(_currentMediaItem!.id),
                        showMetadata: true,
                        onNavigate: _close,
                      ),
                    ),
                  ],
                ),
                NowPlayingControlBar(mediaItem: _currentMediaItem!, onNavigate: _close),
              ],
            ),
          );
        }
      },
    );
  }
}