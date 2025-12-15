import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart' hide ColorScheme;
import 'package:super_sliver_list/super_sliver_list.dart';
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LyricsDialog(),
          ),
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
  StreamSubscription? _positionSubscription;

  final _listController = ListController();
  final _scrollController = ScrollController();

  int? _currentLyricIndex;
  int? _lastPositionMs;
  ParsedLyrics? _parsedLyrics;

  Color _getBackgroundColor(LyricsDesign lyricsDesign, ColorScheme? cs, ThemeData theme) {

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

  Color _getForegroundColor(LyricsDesign lyricsDesign, ColorScheme? cs, ThemeData theme) {
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

  Color _getAccentColor(LyricsDesign lyricsDesign, ColorScheme? cs, ThemeData theme) {
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

  void _setupPositionListener() {
    _positionSubscription?.cancel();
    _positionSubscription = _audioManager.audioPlayer.positionStream.listen((position) {
      if (_parsedLyrics == null || !_parsedLyrics!.isSynced) {
        return;
      }

      final positionMs = position.inMilliseconds;

      if (positionMs == _lastPositionMs) {
        return;
      }
      _lastPositionMs = positionMs;

      // Find the closest lyric line that is less than or equal to the current position
      int? newIndex;
      for (var (index, line) in _parsedLyrics!.lines.indexed) {
        if (line.timestamp.inMilliseconds <= positionMs) {
          newIndex = index;
        } else {
          break;
        }
      }

      if (newIndex != _currentLyricIndex) {

        setState(() {
          _currentLyricIndex = newIndex;
        });

        // Scroll to the current lyric line
        if (newIndex != null && _scrollController.hasClients && _listController.isAttached) {
          _listController.animateToItem(
            index: newIndex,
            scrollController: _scrollController,
            duration: (_) => const Duration(milliseconds: 300),
            curve: (_) => Curves.easeInOut,
            alignment: 0.5
          );
        }
      }
    });
  }

  void _fetchLyrics() {
    final id = _currentMediaItem == null ? null : int.tryParse(_currentMediaItem!.id);
    setState(() {
      if (id == null) {
        _lyricsFuture = Future.value(null);
        return;
      }
      _lyricsFuture = _apiManager.service.getTrackLyrics(id).then((lyrics) {
        _parsedLyrics = lyrics.lyrics == null ? null : LrcParser.parseLyrics(lyrics.lyrics!);
        _currentLyricIndex = null;
        _setupPositionListener();
        return lyrics;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _currentMediaItemSubscription = _audioManager.currentMediaItemStream.listen((mediaItem) {
      if (mediaItem?.id == _currentMediaItem?.id) {
        return;
      }
      setState(() {
        _currentMediaItem = mediaItem;
      });
      _fetchLyrics();
    });

    final savedDesign = _settingsManager.get(Settings.lyricsDesign);
    if (LyricsDialog.lyricsDesignNotifier.value != savedDesign) {
      LyricsDialog.lyricsDesignNotifier.value = savedDesign;
    }

    _fetchLyrics();
  }

  @override
  void dispose() {
    _currentMediaItemSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LyricsDialog.lyricsDesignNotifier,
      builder: (context, value, child) {
        return FutureContent(
          future: _lyricsFuture,
          builder: (context, data) {
            final theme = Theme.of(context);

            final backgroundColor = _getBackgroundColor(value, data?.colorScheme, theme);
            final textColor = _getForegroundColor(value, data?.colorScheme, theme);
            final accentColor = _getAccentColor(value, data?.colorScheme, theme);

            if (_parsedLyrics == null || _parsedLyrics!.lines.isEmpty) {
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

            if (!_parsedLyrics!.isSynced) {

              return Container(
                color: backgroundColor,
                child: SuperListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _parsedLyrics!.lines.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        _parsedLyrics!.lines[index].text,
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
              child: ScrollConfiguration(
                behavior: const ScrollBehavior()
                    .copyWith(overscroll: false, scrollbars: false),
                child: SuperListView.builder(
                  physics: const ClampingScrollPhysics(),
                  itemCount: _parsedLyrics!.lines.length,
                  controller: _scrollController,
                  listController: _listController,
                  itemBuilder: (context, index) {
                    final line = _parsedLyrics!.lines.elementAt(index);
                    final isCurrent = index == _currentLyricIndex;
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
                ),
              )
            );
          }
        );
      }
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