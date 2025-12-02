import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/api/client_data.dart';
import 'package:vibin_app/audio/audio_type.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/album/album_data.dart';
import 'package:vibin_app/dtos/playlist/playlist.dart';
import 'package:vibin_app/dtos/playlist/playlist_data.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';

import '../settings/settings_manager.dart';

class AudioManager extends BaseAudioHandler with QueueHandler, SeekHandler {

  late final ApiManager _apiManager;
  late final AudioPlayer audioPlayer;
  late final ClientData _clientData;
  late final SettingsManager _settingsManager;

  CurrentAudioType? _currentAudioType;
  CurrentAudioType? get currentAudioType => _currentAudioType;

  // Manual queue management
  List<MediaItem> _queue = [];
  int _currentIndex = 0;
  bool _isShuffling = false;
  LoopMode _loopMode = LoopMode.off;

  // Shuffle state
  List<int> _shuffleIndices = [];
  int _shufflePosition = 0;

  // Track the currently loaded track ID to detect when we need to reload
  int? _currentlyLoadedTrackId;

  // Prevent concurrent track completion handling
  bool _isHandlingCompletion = false;

  // region Init

  AudioManager() {
    _apiManager = getIt<ApiManager>();
    _clientData = getIt<ClientData>();
    _settingsManager = getIt<SettingsManager>();

    audioPlayer = AudioPlayer(
      audioLoadConfiguration: AudioLoadConfiguration(
        androidLoadControl: AndroidLoadControl(
          minBufferDuration: const Duration(seconds: 20),
          maxBufferDuration: const Duration(seconds: 60),
          bufferForPlaybackDuration: const Duration(milliseconds: 1500),
          bufferForPlaybackAfterRebufferDuration: const Duration(seconds: 3),
          prioritizeTimeOverSizeThresholds: true
        )
      )
    );

    _initPlaybackEvents();
    _initPlayerCompletionListener();
  }

  /// Initializes playback event listeners to update the playback state accordingly.
  void _initPlaybackEvents() {
    audioPlayer.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          audioPlayer.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[audioPlayer.processingState]!,
        playing: audioPlayer.playing,
        updatePosition: audioPlayer.position,
        bufferedPosition: audioPlayer.bufferedPosition,
        speed: audioPlayer.speed,
        queueIndex: _currentIndex,
      ));
    });
  }

  final currentMediaItemStreamController = StreamController<MediaItem?>.broadcast();

  /// A stream that emits the current media item whenever it changes or null if there is no current item.
  Stream<MediaItem?> get currentMediaItemStream => currentMediaItemStreamController.stream;

  final sequenceStreamController = StreamController<List<MediaItem>>.broadcast();

  /// A stream that emits the current sequence whenever it changes (queue modifications, shuffle changes, etc)
  Stream<List<MediaItem>> get sequenceStream => sequenceStreamController.stream;

  final loopModeStreamController = StreamController<LoopMode>.broadcast();

  /// A stream that emits the current loop mode whenever it changes
  Stream<LoopMode> get loopModeStream => loopModeStreamController.stream;

  final shuffleModeStreamController = StreamController<bool>.broadcast();

  /// A stream that emits the current shuffle mode whenever it changes
  Stream<bool> get shuffleModeStream => shuffleModeStreamController.stream;

  /// Listens for track completion to advance to next track
  void _initPlayerCompletionListener() {
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleTrackCompletion();
      }
    });
  }

  /// Handles what happens when a track finishes playing
  Future<void> _handleTrackCompletion() async {
    // Prevent concurrent completion handling (prevents skipping multiple tracks)
    if (_isHandlingCompletion) return;
    _isHandlingCompletion = true;

    try {
      if (_loopMode == LoopMode.one) {
        // Replay current track
        await audioPlayer.seek(Duration.zero);
        await audioPlayer.play();
      } else if (hasNext) {
        // Play next track
        await skipToNext();
      } else if (_loopMode == LoopMode.all && _queue.isNotEmpty) {
        // Loop back to beginning
        await _playTrackAtIndex(0);
      }
    } finally {
      _isHandlingCompletion = false;
    }
  }

  /// Initializes the background audio task for audio playback.
  static Future<AudioManager> initBackgroundTask() async {

    final settingsManager = getIt<SettingsManager>();

    return await AudioService.init(
      builder: () => AudioManager(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'de.mickkc.channel.audio',
        androidNotificationChannelName: 'Vibin Audio Playback',
        androidStopForegroundOnPause: false,
        androidNotificationIcon: "mipmap/ic_launcher_monochrome",
        notificationColor: settingsManager.get(Settings.accentColor),
      )
    );
  }

  // endregion

  // region Playback Controls

  @override Future<void> play() => audioPlayer.play();

  @override Future<void> pause() => audioPlayer.pause();

  @override
  Future<void> stop() async {
    await audioPlayer.stop();
    _queue.clear();
    _currentIndex = 0;
    _shuffleIndices.clear();
    _shufflePosition = 0;
    _updateMediaItem();
    sequenceStreamController.add([]);
    return super.stop();
  }

  @override
  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;

    // In loop one mode, restart current track
    if (_loopMode == LoopMode.one) {
      await audioPlayer.seek(Duration.zero);
      await audioPlayer.play();
      return;
    }

    if (_isShuffling) {
      if (_shufflePosition < _shuffleIndices.length - 1) {
        _shufflePosition++;
        final nextIndex = _shuffleIndices[_shufflePosition];
        await _playTrackAtIndex(nextIndex);
      } else if (_loopMode == LoopMode.all) {
        // Loop back to beginning in shuffle mode
        _shufflePosition = 0;
        final nextIndex = _shuffleIndices[_shufflePosition];
        await _playTrackAtIndex(nextIndex);
      }
    } else {
      if (_currentIndex < _queue.length - 1) {
        await _playTrackAtIndex(_currentIndex + 1);
      } else if (_loopMode == LoopMode.all) {
        // Loop back to beginning
        await _playTrackAtIndex(0);
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;

    // In loop one mode, restart current track
    if (_loopMode == LoopMode.one) {
      await audioPlayer.seek(Duration.zero);
      await audioPlayer.play();
      return;
    }

    // If more than 3 seconds into track, restart current track
    if (audioPlayer.position.inSeconds > 3) {
      await audioPlayer.seek(Duration.zero);
      return;
    }

    if (_isShuffling) {
      if (_shufflePosition > 0) {
        _shufflePosition--;
        final prevIndex = _shuffleIndices[_shufflePosition];
        await _playTrackAtIndex(prevIndex);
      } else if (_loopMode == LoopMode.all) {
        // Loop to end in shuffle mode
        _shufflePosition = _shuffleIndices.length - 1;
        final prevIndex = _shuffleIndices[_shufflePosition];
        await _playTrackAtIndex(prevIndex);
      }
    } else {
      if (_currentIndex > 0) {
        await _playTrackAtIndex(_currentIndex - 1);
      } else if (_loopMode == LoopMode.all) {
        // Loop to end
        await _playTrackAtIndex(_queue.length - 1);
      }
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _queue.length) return;

    if (_isShuffling) {
      // Find position in shuffle order
      _shufflePosition = _shuffleIndices.indexOf(index);
    }

    await _playTrackAtIndex(index);
  }

  @override Future<void> seek(Duration position) => audioPlayer.seek(position);

  bool get isPlaying => audioPlayer.playing;

  LoopMode get loopMode => _loopMode;
  set loopMode(LoopMode mode) {
    _loopMode = mode;
    loopModeStreamController.add(mode);
    _updatePlaybackState();
  }

  bool get isShuffling => _isShuffling;
  set isShuffling(bool value) {
    if (_isShuffling == value) return;

    _isShuffling = value;

    if (value) {
      _createShuffleOrder();
    }

    shuffleModeStreamController.add(value);
    sequenceStreamController.add(getSequence());
    _updatePlaybackState();
  }

  double get volume => audioPlayer.volume;
  set volume(double value) => audioPlayer.setVolume(value);

  double get speed => audioPlayer.speed;
  set speed(double value) => audioPlayer.setSpeed(value);

  Duration get position => audioPlayer.position;

  bool get hasNext {
    if (_queue.isEmpty) return false;

    if (_loopMode == LoopMode.all) return true;

    if (_isShuffling) {
      return _shufflePosition < _shuffleIndices.length - 1;
    }

    return _currentIndex < _queue.length - 1;
  }

  bool get hasPrevious {
    if (_queue.isEmpty) return false;

    if (_loopMode == LoopMode.all) return true;

    if (_isShuffling) {
      return _shufflePosition > 0;
    }

    return _currentIndex > 0;
  }

  /// Plays the track at the specified index
  Future<void> _playTrackAtIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;

    _currentIndex = index;
    final item = _queue[index];

    final trackId = int.parse(item.id);
    final mediaToken = await _clientData.getMediaToken();
    final trackUri = _getStreamUrl(trackId, mediaToken);

    // Update media item BEFORE loading the source (especially important for web)
    _updateMediaItem();

    final source = AudioSource.uri(
        trackUri,
        tag: item,
        headers: {
          'Authorization': 'Bearer ${_apiManager.accessToken}',
        }
    );

    try {
      // Only pause on mobile, stop on web to clear cache
      if (kIsWeb) {
        await audioPlayer.stop();
      } else if (audioPlayer.playing) {
        await audioPlayer.pause();
      }

      await audioPlayer.setAudioSource(source);
      _currentlyLoadedTrackId = trackId;
      await audioPlayer.play();
    } catch (e) {
      log("Error playing track at index $index: $e", error: e, level: Level.error.value);
    }
  }

  /// Toggles between play and pause states.
  Future<void> playPause() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  /// Toggles shuffle mode on or off.
  void toggleShuffle() {
    isShuffling = !_isShuffling;
  }

  /// Toggles repeat mode between off, all, and one.
  void toggleRepeat() {
    switch (_loopMode) {
      case LoopMode.off:
        loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        loopMode = LoopMode.off;
        break;
    }
  }

  /// Creates a shuffled order of indices
  void _createShuffleOrder() {
    _shuffleIndices = List.generate(_queue.length, (i) => i);

    // Keep current track at current position in shuffle
    final currentTrack = _currentIndex;
    _shuffleIndices.shuffle();

    // Move current track to beginning of shuffle order
    final currentPos = _shuffleIndices.indexOf(currentTrack);
    if (currentPos != 0) {
      _shuffleIndices.removeAt(currentPos);
      _shuffleIndices.insert(0, currentTrack);
    }

    _shufflePosition = 0;
  }

  /// Updates the current media item in the notification
  void _updateMediaItem() {
    final item = getCurrentMediaItem();
    mediaItem.add(item);
    currentMediaItemStreamController.add(item);
  }

  /// Updates the playback state
  void _updatePlaybackState() {
    playbackState.add(playbackState.value.copyWith(
      queueIndex: _currentIndex,
      shuffleMode: _isShuffling ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
      repeatMode: _loopMode == LoopMode.one
          ? AudioServiceRepeatMode.one
          : _loopMode == LoopMode.all
          ? AudioServiceRepeatMode.all
          : AudioServiceRepeatMode.none,
    ));
  }

  // endregion

  // region Queue Management

  /// Moves a queue item from oldIndex to newIndex, adjusting the current index as necessary.
  Future<void> moveQueueItem(int oldIndex, int newIndex) async {

    if (oldIndex < 0 || oldIndex >= _queue.length) return;
    if (newIndex < 0 || newIndex >= _queue.length) return;

    // Adjust newIndex if moving down the list
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final wasPlaying = audioPlayer.playing;
    final position = audioPlayer.position;
    final wasCurrentTrack = oldIndex == _currentIndex;

    final item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);

    // Update current index
    if (oldIndex == _currentIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex -= 1;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex += 1;
    }

    // Recreate shuffle order if shuffling
    if (_isShuffling) {
      _createShuffleOrder();
    }

    // Reload current track if it changed position
    if (wasCurrentTrack) {
      await _reloadCurrentTrack(wasPlaying, position);
    }

    _updateQueue();
  }

  /// Removes the queue item at the specified index
  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= _queue.length) return;

    _queue.removeAt(index);

    if (index < _currentIndex) {
      _currentIndex -= 1;
    } else if (index == _currentIndex) {
      // Current item removed
      if (_queue.isNotEmpty) {
        _currentIndex = _currentIndex.clamp(0, _queue.length - 1);
        await _playTrackAtIndex(_currentIndex);
      } else {
        await audioPlayer.stop();
      }
    }

    // Recreate shuffle order if shuffling
    if (_isShuffling && _queue.isNotEmpty) {
      _createShuffleOrder();
    }

    _updateQueue();
  }

  /// Updates the queue in audio_service
  void _updateQueue() {
    queue.add(_queue);
    _updatePlaybackState();
    sequenceStreamController.add(getSequence());

    if (_queue.isEmpty) {
      setAudioType(AudioType.unspecified, null);
    }
  }

  /// Reloads the current track's audio source (used when queue changes affect current track)
  Future<void> _reloadCurrentTrack(bool wasPlaying, Duration position) async {
    if (_queue.isEmpty || _currentIndex < 0 || _currentIndex >= _queue.length) return;

    final item = _queue[_currentIndex];
    final trackId = int.parse(item.id);

    // Check if we actually need to reload (track ID changed)
    if (_currentlyLoadedTrackId == trackId && !kIsWeb) {
      // Same track is loaded, just update UI
      _updateMediaItem();
      return;
    }

    final mediaToken = await _clientData.getMediaToken();
    // Use cache busting on web to force reload
    final trackUri = _getStreamUrl(trackId, mediaToken, bustCache: true);

    _updateMediaItem();

    final source = AudioSource.uri(
      trackUri,
      tag: item,
      headers: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      }
    );

    try {
      if (kIsWeb) {
        // On web, we need to fully stop to prevent caching issues
        await audioPlayer.stop();
        await audioPlayer.setAudioSource(source, initialPosition: position);
      } else {
        // On Android/iOS, just set the new source to avoid notification flicker
        await audioPlayer.setAudioSource(source, initialPosition: position);
      }

      _currentlyLoadedTrackId = trackId;

      if (wasPlaying) {
        await audioPlayer.play();
      }
    } catch (e) {
      log("Error reloading current track: $e", error: e, level: Level.error.value);
    }
  }

  // endregion

  // region Play Methods

  // region Playlists

  /// Plays the specified playlist, optionally shuffling the tracks.
  Future<void> playPlaylist(Playlist playlist, {bool? shuffle}) async {
    await audioPlayer.stop();
    final playlistData = await _apiManager.service.getPlaylist(playlist.id);

    if (playlistData.tracks.isEmpty) {
      return;
    }

    await playPlaylistData(playlistData, shuffle: shuffle);
  }

  /// Plays the specified playlist data, optionally starting from a preferred track and shuffling.
  Future<void> playPlaylistData(PlaylistData data, {int? preferredTrackId, bool? shuffle}) async {

    var tracks = data.tracks.map((i) => i.track).toList();

    if (tracks.isEmpty) {
      return;
    }

    if (shuffle != null) _isShuffling = shuffle;
    setAudioType(AudioType.playlist, data.playlist.id);

    final mediaToken = await _clientData.getMediaToken();
    _queue = await Future.wait(tracks.map((track) => _buildMediaItemFromMinimal(track, mediaToken)));

    final initialIndex = preferredTrackId != null
        ? _queue.indexWhere((item) => item.id == preferredTrackId.toString())
        : 0;

    if (_isShuffling) {
      _createShuffleOrder();
    }

    await _playTrackAtIndex(initialIndex.clamp(0, _queue.length - 1));
    _updateQueue();
    await _apiManager.service.reportPlaylistListen(data.playlist.id);
  }

  // endregion

  // region Albums

  /// Plays the specified album, optionally shuffling the tracks.
  Future<void> playAlbum(Album album, {bool? shuffle}) async {
    await audioPlayer.stop();
    final albumData = await _apiManager.service.getAlbum(album.id);

    if (albumData.tracks.isEmpty) {
      return;
    }

    await playAlbumData(albumData, shuffle: shuffle);
  }

  /// Plays the specified album data, optionally starting from a preferred track and shuffling.
  Future<void> playAlbumData(AlbumData data, {int? preferredTrackId, bool? shuffle}) async {
    var tracks = data.tracks;

    if (tracks.isEmpty) {
      return;
    }

    if (shuffle != null) _isShuffling = shuffle;
    setAudioType(AudioType.album, data.album.id);

    final mediaToken = await _clientData.getMediaToken();
    _queue = await Future.wait(tracks.map((track) => _buildMediaItem(track, mediaToken)));

    final initialIndex = preferredTrackId != null
        ? _queue.indexWhere((item) => item.id == preferredTrackId.toString())
        : 0;

    if (_isShuffling) {
      _createShuffleOrder();
    }

    await _playTrackAtIndex(initialIndex.clamp(0, _queue.length - 1));
    _updateQueue();
    await _apiManager.service.reportAlbumListen(data.album.id);
  }

  // endregion

  // region Minimal Tracks

  /// Plays the specified minimal track, replacing the current queue.
  Future<void> playMinimalTrack(MinimalTrack track) async {
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    final mediaToken = await _clientData.getMediaToken();
    _queue = [await _buildMediaItemFromMinimal(track, mediaToken)];
    _isShuffling = false;

    await _playTrackAtIndex(0);
    _updateQueue();
  }

  /// Plays the specified minimal track within the provided queue of minimal tracks.
  Future<void> playMinimalTrackWithQueue(MinimalTrack track, List<MinimalTrack> queue) async {
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    final mediaToken = await _clientData.getMediaToken();
    _queue = await Future.wait(queue.map((t) => _buildMediaItemFromMinimal(t, mediaToken)));

    final initialIndex = _queue.indexWhere((item) => item.id == track.id.toString());

    if (_isShuffling) {
      _createShuffleOrder();
    }

    await _playTrackAtIndex(initialIndex.clamp(0, _queue.length - 1));
    _updateQueue();
  }

  // endregion

  // region Tracks

  /// Plays the specified track, replacing the current queue.
  Future<void> playTrack(Track track) async {
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    final mediaToken = await _clientData.getMediaToken();
    _queue = [await _buildMediaItem(track, mediaToken)];
    _isShuffling = false;

    await _playTrackAtIndex(0);
    _updateQueue();
  }

  // endregion

  // endregion

  // region Add to Queue Methods

  /// Adds the track with the specified ID to the queue.
  Future<void> addTrackIdToQueue(int trackId, bool next) async {
    final track = await _apiManager.service.getTrack(trackId);
    return addTrackToQueue(track, next);
  }

  /// Adds the specified track to the queue.
  Future<void> addTrackToQueue(Track track, bool next) async {
    final mediaToken = await _clientData.getMediaToken();
    final item = await _buildMediaItem(track, mediaToken);

    final wasEmpty = _queue.isEmpty;

    if (next && _queue.isNotEmpty) {
      _queue.insert(_currentIndex + 1, item);
    } else {
      _queue.add(item);
    }

    setAudioType(AudioType.tracks, null);

    if (_isShuffling) {
      _createShuffleOrder();
    }

    _updateQueue();

    if (wasEmpty) {
      await _playTrackAtIndex(0);
    }
  }

  /// Adds the specified minimal track to the queue.
  Future<void> addMinimalTrackToQueue(MinimalTrack track, bool next) async {
    final mediaToken = await _clientData.getMediaToken();
    final item = await _buildMediaItemFromMinimal(track, mediaToken);

    final wasEmpty = _queue.isEmpty;

    if (next && _queue.isNotEmpty) {
      _queue.insert(_currentIndex + 1, item);
    } else {
      _queue.add(item);
    }

    setAudioType(AudioType.tracks, null);

    if (_isShuffling) {
      _createShuffleOrder();
    }

    _updateQueue();

    if (wasEmpty) {
      await _playTrackAtIndex(0);
    }
  }

  /// Adds all tracks from the specified album to the queue.
  Future<void> addAlbumToQueue(Album album, bool next) async {
    final albumData = await _apiManager.service.getAlbum(album.id);

    if (albumData.tracks.isEmpty) {
      return;
    }

    final wasEmpty = _queue.isEmpty;

    final mediaToken = await _clientData.getMediaToken();
    final items = await Future.wait(albumData.tracks.map((track) => _buildMediaItem(track, mediaToken)));

    if (next && _queue.isNotEmpty) {
      _queue.insertAll(_currentIndex + 1, items);
    } else {
      _queue.addAll(items);
    }

    if (_isShuffling) {
      _createShuffleOrder();
    }

    _updateQueue();

    if (wasEmpty) {
      setAudioType(AudioType.album, album.id);
      await _playTrackAtIndex(0);
    }

    _apiManager.service.reportAlbumListen(album.id);
  }

  /// Adds all tracks from the specified playlist to the queue.
  Future<void> addPlaylistToQueue(Playlist playlist, bool next) async {
    final playlistData = await _apiManager.service.getPlaylist(playlist.id);

    if (playlistData.tracks.isEmpty) {
      return;
    }

    final wasEmpty = _queue.isEmpty;

    final mediaToken = await _clientData.getMediaToken();
    final items = await Future.wait(playlistData.tracks.map((track) => _buildMediaItemFromMinimal(track.track, mediaToken)));

    if (next && _queue.isNotEmpty) {
      _queue.insertAll(_currentIndex + 1, items);
    } else {
      _queue.addAll(items);
    }

    if (_isShuffling) {
      _createShuffleOrder();
    }

    _updateQueue();

    if (wasEmpty) {
      setAudioType(AudioType.playlist, playlist.id);
      await _playTrackAtIndex(0);
    }

    _apiManager.service.reportPlaylistListen(playlist.id);
  }

  // endregion

  // region Helpers

  void setAudioType(AudioType type, int? id) {
    _currentAudioType = CurrentAudioType(audioType: type, id: id);
  }

  /// Gets the current media item being played, or null if there is none.
  MediaItem? getCurrentMediaItem() {
    if (_queue.isEmpty || _currentIndex < 0 || _currentIndex >= _queue.length) {
      return null;
    }
    return _queue[_currentIndex];
  }

  /// Gets the entire queue
  List<MediaItem> getQueue() => List.unmodifiable(_queue);

  /// Gets the current queue index
  int getCurrentIndex() => _currentIndex;

  /// Gets the current sequence (playback order respecting shuffle)
  List<MediaItem> getSequence() {
    if (_isShuffling && _shuffleIndices.isNotEmpty) {
      return _shuffleIndices.map((index) => _queue[index]).toList();
    }
    return List.unmodifiable(_queue);
  }

  /// Gets the current position in the sequence (respecting shuffle)
  int getSequencePosition() {
    if (_isShuffling) {
      return _shufflePosition;
    }
    return _currentIndex;
  }

  // endregion

  // region MediaItem Builders

  /// Creates a MediaItem from a MinimalTrack
  Future<MediaItem> _buildMediaItemFromMinimal(MinimalTrack track, String mediaToken) async {
    final artUri = await _getCoverUri(track.id, mediaToken);

    return MediaItem(
      id: track.id.toString(),
      title: track.title,
      album: track.album.name,
      artist: track.artists.map((a) => a.name).join(", "),
      duration: track.duration == null ? null : Duration(milliseconds: track.duration!),
      artUri: artUri,
      artHeaders: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      }
    );
  }

  /// Creates a MediaItem from a Track
  Future<MediaItem> _buildMediaItem(Track track, String mediaToken) async {
    final artUri = await _getCoverUri(track.id, mediaToken);

    return MediaItem(
      id: track.id.toString(),
      title: track.title,
      album: track.album.title,
      artist: track.artists.map((a) => a.name).join(", "),
      duration: track.duration == null ? null : Duration(milliseconds: track.duration!),
      artUri: artUri,
      artHeaders: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      }
    );
  }

  /// Gets the cover URI for the specified track, embedding as base64 if configured.
  Future<Uri> _getCoverUri(int trackId, String mediaToken) async {

    if (_settingsManager.get(Settings.embedImagesAsBase64)) {
      try {
        final bytes = await _apiManager.service.getTrackCover(
            trackId, _settingsManager.get(Settings.metadataImageSize).pixelSize
        );
        if (bytes.data.isNotEmpty) {
          return Uri.dataFromBytes(bytes.data, mimeType: "image/jpeg");
        }
      }
      catch (e) {
        log("Failed to fetch and embed cover image for track $trackId: $e", error: e, level: Level.error.value);
      }
    }

    return Uri.parse(
        "${_apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}"
            "/api/tracks/$trackId/cover"
            "?mediaToken=$mediaToken"
            "&quality=${_settingsManager.get(Settings.metadataImageSize).pixelSize}");
  }

  /// Constructs the stream URL for the specified track ID and media token.
  /// If [bustCache] is true and running on web, adds a cache buster parameter.
  Uri _getStreamUrl(int trackId, String mediaToken, {bool bustCache = false}) {
    final baseUrl = "${_apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}"
            "/api/tracks/$trackId/stream"
            "?mediaToken=$mediaToken";

        // Add cache buster for web to force reload
    if (bustCache && kIsWeb) {
      return Uri.parse("$baseUrl&_cb=${DateTime.now().millisecondsSinceEpoch}");
    }

    return Uri.parse(baseUrl);
  }

  // endregion
}