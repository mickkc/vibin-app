import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/nowplaying/now_playing_control_bar.dart';
import 'package:vibin_app/widgets/row_small_column.dart';
import 'package:vibin_app/widgets/track_info.dart';

import '../widgets/network_image.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const NowPlayingPage(),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(
        maxWidth: (MediaQuery.of(context).size.width * 0.9).clamp(600, 900)
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Wrap(
          runSpacing: 32,
          children: _currentMediaItem == null ? [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(AppLocalizations.of(context)!.now_playing_nothing),
            )
          ] : [
            RowSmallColumn(
              spacing: 32,
              rowChildren: [
                NetworkImageWidget(
                  url: "/api/tracks/${_currentMediaItem!.id}/cover?quality=original",
                  width: 200,
                  height: 200,
                ),
                Expanded(
                  child: TrackInfoView(
                    trackId: int.parse(_currentMediaItem!.id),
                    showMetadata: true
                  ),
                ),
              ],
              columnChildren: [
                NetworkImageWidget(
                  url: "/api/tracks/${_currentMediaItem!.id}/cover?quality=original",
                  width: width * 0.75,
                  height: width * 0.75,
                ),
                TrackInfoView(
                  trackId: int.parse(_currentMediaItem!.id),
                  showMetadata: false,
                ),
              ]
            ),
            NowPlayingControlBar(mediaItem: _currentMediaItem!)
          ]
        ),
      )
    );
  }
}