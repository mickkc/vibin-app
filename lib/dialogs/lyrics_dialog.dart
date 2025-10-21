import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart' hide ColorScheme;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/dtos/lyrics.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../dtos/color_scheme.dart';
import '../main.dart';
import '../settings/setting_definitions.dart';
import '../utils/lrc_parser.dart';

class LyricsDialog extends StatefulWidget {

  const LyricsDialog({super.key});

  static final ValueNotifier<LyricsDesign> lyricsDesignNotifier = ValueNotifier(LyricsDesign.dynamic);

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

  final _audioManager = getIt<AudioManager>();
  final _apiManager = getIt<ApiManager>();
  final _settingsManager = getIt<SettingsManager>();

  late MediaItem? _currentMediaItem = _audioManager.getCurrentMediaItem();
  late Future<Lyrics?> _lyricsFuture;

  StreamSubscription? _currentMediaItemSubscription;
  final _scrollController = ItemScrollController();

  int? _lastLyricIndex;

  Color getBackgroundColor(LyricsDesign lyricsDesign, ColorScheme? cs, ThemeData theme) {

    return switch (lyricsDesign) {
      LyricsDesign.system => theme.colorScheme.surfaceContainer,
      LyricsDesign.primary => theme.colorScheme.primaryContainer,
      LyricsDesign.dynamic => cs?.primary == null
          ? theme.colorScheme.primaryContainer
          : HexColor.fromHex(cs!.primary),
      LyricsDesign.dynamicDark => cs?.dark == null
          ? theme.colorScheme.primaryContainer
          : HexColor.fromHex(cs!.dark),
      LyricsDesign.dynamicLight => cs?.light == null
          ? theme.colorScheme.primaryContainer
          : HexColor.fromHex(cs!.light),
    };
  }

  Color getForegroundColor(LyricsDesign lyricsDesign, ColorScheme? cs, ThemeData theme) {
    return switch (lyricsDesign) {
      LyricsDesign.system => theme.colorScheme.onSurface,
      LyricsDesign.primary => theme.colorScheme.onPrimaryContainer,
      LyricsDesign.dynamic => cs?.primary == null
          ? theme.colorScheme.onPrimaryContainer
          : (HexColor.fromHex(cs!.primary).computeLuminance() < 0.5
            ? HexColor.fromHex(cs.light)
            : HexColor.fromHex(cs.dark)),
      LyricsDesign.dynamicDark => cs?.light == null ? theme.colorScheme.onPrimaryContainer : HexColor.fromHex(cs!.light),
      LyricsDesign.dynamicLight => cs?.dark == null ? theme.colorScheme.onPrimaryContainer : HexColor.fromHex(cs!.dark),
    }.withAlpha(200);
  }

  Color getAccentColor(LyricsDesign lyricsDesign, ColorScheme? cs, ThemeData theme) {
    return switch (lyricsDesign) {
      LyricsDesign.system => theme.colorScheme.primary,
      LyricsDesign.primary => theme.colorScheme.primary,
      LyricsDesign.dynamic => cs?.primary == null
          ? theme.colorScheme.primary
          : (HexColor.fromHex(cs!.primary).computeLuminance() < 0.5
          ? HexColor.fromHex(cs.light)
          : HexColor.fromHex(cs.dark)),
      LyricsDesign.dynamicDark => cs?.primary == null ? theme.colorScheme.primary : HexColor.fromHex(cs!.primary),
      LyricsDesign.dynamicLight => cs?.primary == null ? theme.colorScheme.primary : HexColor.fromHex(cs!.primary),
    };
  }

  void fetchLyrics() {
    final id = _currentMediaItem == null ? null : int.tryParse(_currentMediaItem!.id);
    setState(() {
      if (id == null) {
        _lyricsFuture = Future.value(null);
        return;
      }
      _lyricsFuture = _apiManager.service.getTrackLyrics(id);
    });
  }

  @override
  void initState() {
    super.initState();
    _currentMediaItemSubscription = _audioManager.currentMediaItemStream.listen((mediaItem) {
      if (mediaItem.id == _currentMediaItem?.id) {
        return;
      }
      setState(() {
        _currentMediaItem = mediaItem;
      });
      fetchLyrics();
    });

    final savedDesign = _settingsManager.get(Settings.lyricsDesign);
    if (LyricsDialog.lyricsDesignNotifier.value != savedDesign) {
      LyricsDialog.lyricsDesignNotifier.value = savedDesign;
    }

    fetchLyrics();
  }

  @override
  void dispose() {
    _currentMediaItemSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: ValueListenableBuilder(
        valueListenable: LyricsDialog.lyricsDesignNotifier,
        builder: (context, value, child) {
          return FutureContent(
            future: _lyricsFuture,
            builder: (context, data) {
              final theme = Theme.of(context);

              final backgroundColor = getBackgroundColor(value, data?.colorScheme, theme);
              final textColor = getForegroundColor(value, data?.colorScheme, theme);
              final accentColor = getAccentColor(value, data?.colorScheme, theme);

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

              var parsedLyrics = LrcParser.parseLyrics(data.lyrics!);

              if (!parsedLyrics.isSynced) {
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
                  stream: _audioManager.audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final positionMs = position.inMilliseconds;

                    // Find the closest lyric line that is less than or equal to the current position
                    int? currentIndex;
                    for (var (index, line) in parsedLyrics.lines.indexed) {
                      if (line.timestamp.inMilliseconds <= positionMs) {
                        currentIndex = index;
                      } else {
                        break;
                      }
                    }

                    if (currentIndex != null && currentIndex != _lastLyricIndex) {
                      _lastLyricIndex = currentIndex;
                      // Scroll to the current lyric line
                      if (_scrollController.isAttached) {
                        _scrollController.scrollTo(
                          index: currentIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: 0.5
                        );
                      }
                    }

                    return ScrollablePositionedList.builder(
                      physics: const ClampingScrollPhysics(),
                      itemCount: parsedLyrics.lines.length,
                      itemScrollController: _scrollController,
                      itemBuilder: (context, index) {
                        final line = parsedLyrics.lines.elementAt(index);
                        final isCurrent = index == currentIndex;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: InkWell(
                            onTap: () {
                              _audioManager.seek(line.timestamp);
                            },
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 150),
                              style: TextStyle(
                                color: isCurrent ? accentColor : textColor,
                                fontSize: isCurrent ? 18 : 16,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              ),
                              child: Text(
                                line.text,
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
          );
        }
      ),
    );
  }
}

enum LyricsDesign {
  system,
  primary,
  dynamic,
  dynamicDark,
  dynamicLight
}