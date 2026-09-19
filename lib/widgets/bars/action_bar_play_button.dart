import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibin_app/audio/audio_type.dart';
import 'package:vibin_app/audio/media_item_parser.dart';
import 'package:vibin_app/dtos/shuffle_state.dart';

import '../../audio/audio_manager.dart';
import '../../main.dart';
import '../play_button.dart';

/// Shows a play button for an item of type [audioType] with id [audioId].
///
/// - If the item is currently playing, a pause icon is displayed. Clicking it
///   pauses the playback.
/// - If the item is loaded, but the player is paused, a play icon is displayed.
///   Clicking it resumes the playback.
/// - If the item is not loaded, a play icon is displayed. Clicking it calls
///   [onPlay], which should start playing the item. The boolean parameter
///   indicates if the item's tracks should be shuffled before playing.
///
/// A shuffle button is also shown by default, but can be disabled by setting
/// [showShuffleButton] to false.
///
/// - If the shuffle mode is changed while the current item is loaded, the
///   shuffle state of the player is modified.
/// - If the shuffle mode is changed while the current item is not loaded,
///   the shuffle state of the player does not get modified. Instead, [shuffleState]
///   gets updated and the shuffle state only applies once the current item gets
///   played by pressing the play button.
///
/// When [shuffleState] is specified, [ShuffleState.isShuffling] gets updated
/// when shuffling gets enabled or disabled. This is so that the shuffle state
/// of the bar can be used in other places (i.e. clicking on a track in a
/// playlist).
class ActionBarPlayButton extends StatefulWidget {
  final AudioType audioType;
  final int audioId;
  final ShuffleState? shuffleState;
  final Function(bool) onPlay;
  final bool showShuffleButton;

  const ActionBarPlayButton({
    super.key,
    required this.audioType,
    required this.audioId,
    required this.onPlay,
    this.shuffleState,
    this.showShuffleButton = true
  });

  @override
  State<StatefulWidget> createState() => _ActionBarPlayButtonState();
}

class _ActionBarPlayButtonState extends State<ActionBarPlayButton> {
  final _audioManager = getIt<AudioManager>();
  late bool _isShuffleEnabled = _audioManager.isShuffling;

  void _playPause() {
    if (!_isCurrentLoaded()) {
      widget.onPlay(_isShuffleEnabled);
    } else {
      _audioManager.playPause();
    }
  }

  bool _isBuffering(PlayerState? state) {
    return state?.processingState == ProcessingState.buffering || state?.processingState == ProcessingState.loading;
  }

  bool _isCurrentLoaded() {
    if (widget.audioType == AudioType.tracks) {
      return _audioManager.getCurrentMediaItem()?.trackId == widget.audioId;
    }

    return _audioManager.currentAudioType != null &&
        _audioManager.currentAudioType!.audioType == widget.audioType &&
        _audioManager.currentAudioType!.id == widget.audioId;
  }

  void _toggleShuffle() {
    if (!widget.showShuffleButton) return;
    if (_isCurrentLoaded()) {
      _audioManager.toggleShuffle();
    }
    setState(() {
      _isShuffleEnabled = !_isShuffleEnabled;
    });
    widget.shuffleState?.isShuffling = _isShuffleEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StreamBuilder(
          stream: _audioManager.audioPlayer.playerStateStream,
          initialData: _audioManager.audioPlayer.playerState,
          builder: (context, state) {
            if (_isBuffering(state.data)) {
              return SizedBox(
                width: 48 + 12 * 2,
                height: 48 + 12 * 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }
            return PlayButton(
              isPlaying: (state.data?.playing ?? false) && _isCurrentLoaded(),
              onTap: _playPause,
            );
          },
        ),
        if (widget.showShuffleButton)
          IconButton(
            onPressed: _toggleShuffle,
            icon: Icon(
              Icons.shuffle,
              color: _isShuffleEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              size: 32
            ),
          )
      ],
    );
  }
}
