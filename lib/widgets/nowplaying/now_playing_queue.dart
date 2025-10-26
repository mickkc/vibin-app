import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/animated_spectrogram_icon.dart';
import 'package:vibin_app/widgets/network_image.dart';

class NowPlayingQueue extends StatefulWidget {
  final ScrollController? scrollController;
  final bool isBottomSheet;

  const NowPlayingQueue({
    super.key,
    this.scrollController,
    this.isBottomSheet = false,
  });

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return NowPlayingQueue(scrollController: scrollController, isBottomSheet: true);
          },
        );
      },
    );
  }

  @override
  State<NowPlayingQueue> createState() => _NowPlayingQueueState();
}

class _NowPlayingQueueState extends State<NowPlayingQueue> {

  late final _audioManager = getIt<AudioManager>();

  late int? _currentIndex = _audioManager.audioPlayer.currentIndex;
  late bool _isPlaying = _audioManager.isPlaying;

  late final StreamSubscription _sequenceSubscription;
  late final StreamSubscription _playingSubscription;

  _NowPlayingQueueState() {
    _sequenceSubscription = _audioManager.audioPlayer.sequenceStateStream.listen((event) {
      if (!mounted) return;
      if (event.currentIndex == _currentIndex) return;
      setState(() {
        _currentIndex = _audioManager.audioPlayer.currentIndex;
      });
    });

    _playingSubscription = _audioManager.audioPlayer.playingStream.listen((event) {
      if (!mounted) return;
      if (event == _isPlaying) return;
      setState(() {
        _isPlaying = event;
      });
    });
  }

  @override
  void dispose() {
    _sequenceSubscription.cancel();
    _playingSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: _audioManager.sequence.isEmpty
        ? Text(AppLocalizations.of(context)!.now_playing_nothing)
        : ReorderableListView.builder(
            scrollController: widget.scrollController,
            buildDefaultDragHandles: false,
            itemCount: _audioManager.sequence.length,
            itemBuilder: (context, index) {
              final source = _audioManager.sequence[index];
              final tag = source.tag;
              if (tag is! MediaItem) {
                return const SizedBox.shrink();
              }
              final isCurrent = _currentIndex == index;
              return ListTile(
                key: ValueKey(source.tag),
                leading: NetworkImageWidget(
                  url: tag.artUri.toString(),
                  width: 48,
                  height: 48
                ),
                title: Text(tag.title, maxLines: 1),
                subtitle: Text(tag.artist ?? '', maxLines: 1),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: isCurrent ? AnimatedSpectogramIcon(
                       size: 24,
                       color: Theme.of(context).colorScheme.primary,
                       isPlaying: _isPlaying,
                     ) : const Icon(Icons.drag_handle)
                ),
                onTap: () {
                  _audioManager.skipToQueueItem(index);
                  if (widget.isBottomSheet) Navigator.pop(context);
                },
              );
            },
            onReorder: (oldIndex, newIndex) {
              _audioManager.moveQueueItem(oldIndex, newIndex);
            },
          ),
    );
  }
}