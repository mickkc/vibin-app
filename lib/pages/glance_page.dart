import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:vibin_app/audio/media_item_parser.dart';
import 'package:vibin_app/widgets/clock_widget.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/now_playing_source_widget.dart';
import 'package:vibin_app/widgets/nowplaying/audio_progress_slider.dart';
import 'package:vibin_app/widgets/nowplaying/controls/play_pause_toggle.dart';

import '../api/api_manager.dart';
import '../audio/audio_manager.dart';
import '../main.dart';

class GlancePage extends StatefulWidget {

  const GlancePage({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlancePage(),
          )
        );
      }
    );
  }

  @override
  State<GlancePage> createState() => _GlancePageState();
}

class _GlancePageState extends State<GlancePage> {

  late StreamSubscription<MediaItem?> _currentMediaItemSubscription;
  final audioManager = getIt<AudioManager>();
  final apiManager = getIt<ApiManager>();
  late MediaItem? _currentMediaItem = audioManager.getCurrentMediaItem();
  late MediaItem? _nextMediaItem = audioManager.getNextMediaItem();
  final controller = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    FullScreen.setFullScreen(true, systemUiMode: SystemUiMode.leanBack);
    _currentMediaItemSubscription = audioManager.currentMediaItemStream.listen((mediaItem) {
      if (mediaItem?.id != _currentMediaItem?.id) {
        setState(() {
          _currentMediaItem = audioManager.getCurrentMediaItem();
          final sequence = audioManager.getSequence();
          final index = sequence.indexWhere((item) => item.id == _currentMediaItem?.id);
          if (index != -1) controller.animateToPage(index);
          _nextMediaItem = audioManager.getNextMediaItem();
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _currentMediaItemSubscription.cancel();
    FullScreen.setFullScreen(false);
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Column(
      spacing: 32,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const NowPlayingSourceWidget(),
            ClockWidget(
              textStyle: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          ],
        ),
        Expanded(
          child: StreamBuilder(
            stream: audioManager.sequenceStream,
            initialData: audioManager.getSequence(),
            builder: (context, snapshot) {
              final sequence = snapshot.data ?? [];

              return ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent
                    ],
                    stops: [0.0, 0.1, 0.9, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: CarouselSlider(
                  carouselController: controller,
                  options: CarouselOptions(
                    initialPage: sequence.indexWhere((item) => item.id == _currentMediaItem?.id),
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    scrollDirection: Axis.horizontal,
                    enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                    aspectRatio: 1.1,
                    onPageChanged: (page, reason) {
                      if (reason != CarouselPageChangedReason.manual) return;
                      audioManager.playTrackAtIndex(page);
                    },
                  ),
                  items: sequence.map((item) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: NetworkImageWidget(
                                  url: "/api/tracks/${item.trackId}/cover",
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                item.title,
                                style: theme.textTheme.headlineLarge,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                item.artist ?? "",
                                style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                    );
                  }).toList()
                ),
              );
            },
          )
        ),
        SizedBox(
          width: 900,
          child: Row(
            spacing: 16,
            children: [
              const PlayPauseToggle(),
              Expanded(
                child: const AudioProgressSlider()
              )
            ],
          ),
        ),

        if (_nextMediaItem != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Opacity(
                opacity: 0.6,
                child: IconButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.exit_to_app),
                ),
              ),
              Row(
                spacing: 8.0,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _nextMediaItem?.title ?? "No track playing",
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        _nextMediaItem?.artist ?? "",
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.end,
                      )
                    ],
                  ),
                  NetworkImageWidget(
                    url: "/api/tracks/${_nextMediaItem!.trackId}/cover?quality=64",
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
          ),
      ]
    );
  }
}