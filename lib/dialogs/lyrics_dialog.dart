import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/dtos/lyrics.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../main.dart';

class LyricsDialog extends StatefulWidget {

  const LyricsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          height: 600,
          child: LyricsDialog(),
        ),
      )
    );
  }

  @override
  State<LyricsDialog> createState() => _LyricsDialogState();
}

class _LyricsDialogState extends State<LyricsDialog> {

  final AudioManager audioManager = getIt<AudioManager>();
  final ApiManager apiManager = getIt<ApiManager>();

  late MediaItem? currentMediaItem = audioManager.getCurrentMediaItem();
  late Future<Lyrics?> lyricsFuture;

  StreamSubscription? currentMediaItemSubscription;
  final ItemScrollController scrollController = ItemScrollController();

  int? lastLyricTime;

  void fetchLyrics() {
    final id = currentMediaItem == null ? null : int.tryParse(currentMediaItem!.id);
    setState(() {
      if (id == null) {
        lyricsFuture = Future.value(null);
        return;
      }
      lyricsFuture = apiManager.service.getTrackLyrics(id);
    });
  }

  @override
  void initState() {
    super.initState();
    currentMediaItemSubscription = audioManager.audioPlayer.sequenceStateStream.listen((mediaItem) {
      final mediaItem = audioManager.getCurrentMediaItem();
      if (mediaItem?.id == currentMediaItem?.id) {
        return;
      }
      setState(() {
        currentMediaItem = mediaItem;
      });
      fetchLyrics();
    });
    fetchLyrics();
  }

  @override
  void dispose() {
    currentMediaItemSubscription?.cancel();
    super.dispose();
  }

  Map<int, String> parseLyrics(String rawLyrics) {
    final Map<int, String> lyricsMap = {};
    final lines = rawLyrics.split('\n');
    final timeRegExp = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]');

    for (var line in lines) {
      final match = timeRegExp.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!.padRight(3, '0'));
        final totalMilliseconds = (minutes * 60 + seconds) * 1000 + milliseconds;
        final lyricText = line.replaceAll(timeRegExp, '').trim();
        lyricsMap[totalMilliseconds] = lyricText;
      }
    }

    return lyricsMap;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: FutureContent(
        future: lyricsFuture,
        builder: (context, data) {

          final theme = Theme.of(context);

          final backgroundColor = data?.colorScheme?.primary == null
              ? theme.colorScheme.primary
              : HexColor.fromHex(data!.colorScheme!.primary);

          final textColor = data?.colorScheme?.dark == null
              ? theme.colorScheme.onPrimary
              : backgroundColor.computeLuminance() > 0.5
                ? HexColor.fromHex(data!.colorScheme!.dark)
                : HexColor.fromHex(data!.colorScheme!.light);

          if (data?.lyrics == null || data!.lyrics!.isEmpty) {
            return Container(
              color: backgroundColor,
              child: Center(
                child: Text(
                    "No lyrics available",
                    style: TextStyle(color: textColor, fontSize: 18)
                ),
              ),
            );
          }

          var parsedLyrics = parseLyrics(data.lyrics!);
          final lyricTimestamps = parsedLyrics.keys.toList();

          if (parsedLyrics.isEmpty) {
            final lines = data.lyrics!.split('\n');

            return Container(
              color: backgroundColor,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      lines[index],
                      style: TextStyle(color: textColor, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              ),
            );
          }

          return Container(
            color: backgroundColor,
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder(
              stream: audioManager.audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final positionMs = position.inMilliseconds;

                // Find the closest lyric line that is less than or equal to the current position
                int? currentLyric;
                for (var entry in parsedLyrics.entries) {
                  if (entry.key <= positionMs) {
                    currentLyric = entry.key;
                  } else {
                    break;
                  }
                }

                if (currentLyric != null && currentLyric != lastLyricTime) {
                  lastLyricTime = currentLyric;
                  // Scroll to the current lyric line
                  final index = lyricTimestamps.indexOf(currentLyric);
                  if (index != -1 && scrollController.isAttached) {
                    scrollController.scrollTo(
                      index: index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: 0.5
                    );
                  }
                }

                return ScrollablePositionedList.builder(
                  itemCount: parsedLyrics.length,
                  itemScrollController: scrollController,
                  itemBuilder: (context, index) {
                    final entry = parsedLyrics.entries.elementAt(index);
                    final isCurrent = entry.key == currentLyric;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: InkWell(
                        onTap: () {
                          audioManager.audioPlayer.seek(Duration(milliseconds: entry.key));
                        },
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            color: isCurrent ? textColor : textColor.withAlpha(150),
                            fontSize: isCurrent ? 18 : 16,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                );
              },
            )
          );
        }
      ),
    );
  }
}