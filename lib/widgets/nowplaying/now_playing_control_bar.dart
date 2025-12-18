import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/audio/media_item_parser.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/glance_page.dart';
import 'package:vibin_app/widgets/colored_icon_button.dart';
import 'package:vibin_app/widgets/nowplaying/audio_progress_slider.dart';
import 'package:vibin_app/widgets/nowplaying/controls/play_pause_toggle.dart';
import 'package:vibin_app/widgets/nowplaying/controls/repeat_toggle.dart';
import 'package:vibin_app/widgets/nowplaying/controls/shuffle_toggle.dart';
import 'package:vibin_app/widgets/nowplaying/now_playing_queue.dart';

import '../../l10n/app_localizations.dart';
import 'controls/speed_slider.dart';
import 'controls/volume_slider.dart';

class NowPlayingControlBar extends StatefulWidget {

  final MediaItem mediaItem;
  final VoidCallback? onNavigate;

  const NowPlayingControlBar({
    super.key,
    required this.mediaItem,
    this.onNavigate
  });

  @override
  State<NowPlayingControlBar> createState() => _NowPlayingControlBarState();
}

class _NowPlayingControlBarState extends State<NowPlayingControlBar> {

  final _audioManager = getIt<AudioManager>();

  void _showMobileDialog() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VolumeSlider(),
              const SpeedSlider()
            ],
          ),
        );
      }
    );
  }

  void _showQueue() {
    NowPlayingQueue.show(context);
  }

  void _openCurrentTrack() {
    widget.onNavigate?.call();
    GoRouter.of(context).push('/tracks/${widget.mediaItem.trackId}');
  }

  void _openGlanceView() {
    GlancePage.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final lm = AppLocalizations.of(context)!;

    return Column(
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: const RepeatToggle(showTooltip: false)
            ),
            ColoredIconButton(
              icon: Icons.skip_previous,
              backgroundColor: th.colorScheme.secondary,
              iconColor: th.colorScheme.onSecondary,
              onPressed: _audioManager.skipToPrevious
            ),
            PlayPauseToggle(
              backgroundColor: th.colorScheme.primary,
              iconColor: th.colorScheme.onPrimary,
              size: 32,
              showTooltip: false,
            ),
            ColoredIconButton(
              icon: Icons.skip_next,
              backgroundColor: th.colorScheme.secondary,
              iconColor: th.colorScheme.onSecondary,
              onPressed: _audioManager.skipToNext
            ),
            Expanded(
              child: const ShuffleToggle(showTooltip: false)
            )
          ],
        ),
        const AudioProgressSlider(),

        if (isMobile) ... [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _showMobileDialog,
                  label: Text(lm.now_plying_advanced_controls),
                  icon: const Icon(Icons.settings)
                ),
                ElevatedButton.icon(
                  onPressed: _showQueue,
                  label: Text(lm.now_playing_queue),
                  icon: const Icon(Icons.queue_music)
                ),
                ElevatedButton.icon(
                  onPressed: _openCurrentTrack,
                  label: Text(lm.track_actions_goto_track),
                  icon: const Icon(Icons.open_in_new)
                ),
              ],
            )
          )
        ]
        else ... [
          Row(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const VolumeSlider()
              ),
              ElevatedButton.icon(
                onPressed: _showQueue,
                label: Text(lm.now_playing_queue),
                icon: const Icon(Icons.queue_music)
              ),
              ElevatedButton.icon(
                onPressed: _openCurrentTrack,
                label: Text(lm.track_actions_goto_track),
                icon: const Icon(Icons.open_in_new)
              ),
              ElevatedButton.icon(
                onPressed: _openGlanceView,
                label: Text(lm.track_actions_glance_view),
                icon: const Icon(Icons.remove_red_eye)
              ),
              Expanded(
                child: const SpeedSlider()
              )
            ],
          )
        ]
      ],
    );
  }
}
