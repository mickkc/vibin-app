import 'dart:async';
import 'dart:convert';
import 'dart:math' hide log;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/audio/audio_type.dart';
import 'package:vibin_app/audio/media_item_parser.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/discord/rpc_updater.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/album/album_data.dart';
import 'package:vibin_app/dtos/playlist/playlist.dart';
import 'package:vibin_app/dtos/playlist/playlist_data.dart';
import 'package:vibin_app/dtos/streamable.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/dtos/ws_frame.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/utils/url_utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../settings/settings_manager.dart';

class AudioManager extends BaseAudioHandler with QueueHandler, SeekHandler {

  late final AuthState _authState = getIt<AuthState>();
  late final ApiManager _apiManager = getIt<ApiManager>();
  late AudioPlayer audioPlayer;
  late final SettingsManager _settingsManager = getIt<SettingsManager>();
  
  WebSocketChannel? _socketChannel;
  Timer? _webSocketPingTimer;
  Timer? _reconnectTimer;
  List<dynamic> _webSocketMessageQueue = [];

  // Stream subscriptions that need to be cancelled on dispose
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<dynamic>? _webSocketSubscription;

  CurrentAudioType? _currentAudioType;
  CurrentAudioType? get currentAudioType => _currentAudioType;

  final _currentAudioTypeController = StreamController<CurrentAudioType?>.broadcast();
  Stream<CurrentAudioType?> get currentAudioTypeStream => _currentAudioTypeController.stream;

  final _seekStreamController = StreamController<Duration>.broadcast();
  Stream<Duration> get seekStream => _seekStreamController.stream;

  // Manual queue management
  List<MediaItem> _queue = [];
  int _currentIndex = 0;
  bool _isShuffling = false;
  LoopMode _loopMode = LoopMode.off;

  // Shuffle state
  List<int> _shuffleIndices = [];
  int _shufflePosition = 0;

  // Track the currently loaded track ID and streamable to detect when we need to reload
  int? _currentlyLoadedTrackId;
  Streamable? _currentStreamable;

  // Offset added to just_audio's position when the backend serves a fresh transcode from ?start=X
  Duration _seekOffset = Duration.zero;

  Stream<Duration> get correctedPositionStream =>
      audioPlayer.positionStream.map((pos) => pos + _seekOffset);

  Duration get correctedPosition => audioPlayer.position + _seekOffset;

  // Prevent concurrent track completion handling
  bool _isHandlingCompletion = false;

  bool _isInitialized = false;

  double _volume = 1.0;
  double get volume => _volume;

  final _currentVolumeController = StreamController<double>.broadcast();
  Stream<double> get currentVolumeStream => _currentVolumeController.stream;

  // region Init

  AudioManager() {
    init();
    RpcUpdater.instance.setAudioManager(this);
  }

  void init() {
    if (_isInitialized) return;
    _initAudioPlayer();
    _initPlaybackEvents();
    _initPlayerCompletionListener();
    _isInitialized = true;
  }

  void _initAudioPlayer() {
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
  }

  /// Initializes playback event listeners to update the playback state accordingly.
  void _initPlaybackEvents() {
    _playbackEventSubscription = audioPlayer.playbackEventStream.listen((event) {
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
        updatePosition: audioPlayer.position + _seekOffset,
        bufferedPosition: audioPlayer.bufferedPosition,
        speed: audioPlayer.speed,
        queueIndex: _currentIndex,
      ));
    });
  }

  void _startWebSocketReconnectTimer() {
    _reconnectTimer ??= Timer.periodic(const Duration(seconds: 10), (_) {
      _ensureWebSocketConnected();
    });
  }

  void _startWebSocketPingTimer() {
    _webSocketPingTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
      _sendWebSocket('ping');
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
    _playerStateSubscription = audioPlayer.playerStateStream.listen((state) {
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

    final trackId = _currentlyLoadedTrackId;
    _sendWebSocket("finished_track", data: {
      'trackId': trackId,
    });

    try {
      if (_loopMode == LoopMode.one) {
        // Replay current track
        await audioPlayer.seek(Duration.zero);
        play();
      } else if (hasNext) {
        // Play next track
        await skipToNext(notify: false);
      } else if (_loopMode == LoopMode.all && _queue.isNotEmpty) {
        // Loop back to beginning
        await playTrackAtIndex(0);
      }
      else {
        // No more tracks, stop playback
        await stop();
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

  /// Cleans up all resources and cancels all subscriptions.
  /// Should be called when logging out or disposing of the AudioManager.
  Future<void> cleanup() async {
    try {
      // Stop and clear queue
      await audioPlayer.stop();
      _queue.clear();
      _currentIndex = 0;
      _shuffleIndices.clear();
      _shufflePosition = 0;
      _currentlyLoadedTrackId = null;
      _currentStreamable = null;
      _seekOffset = Duration.zero;
      _updateMediaItem();
      sequenceStreamController.add([]);

      // Cancel stream subscriptions to prevent callbacks after disposal
      await _playbackEventSubscription?.cancel();
      _playbackEventSubscription = null;

      await _playerStateSubscription?.cancel();
      _playerStateSubscription = null;

      await _webSocketSubscription?.cancel();
      _webSocketSubscription = null;

      // Disconnect WebSocket and cancel timers
      await disconnectWebSocket();

      // Dispose player
      await audioPlayer.dispose();

      _isInitialized = false;
    } catch (e, st) {
      logger.handle(e, st, "Error during audio manager cleanup");
    }
  }

  // endregion

  // region WebSockets

  Future<void> _ensureWebSocketConnected() async {
    try {
      if (_socketChannel != null && _socketChannel!.closeCode == null) {
        return;
      }

      if (!_authState.loggedIn) {
        return;
      }

      _socketChannel = WebSocketChannel.connect(
        Uri.parse(_getWsUrl()),
      );

      await _socketChannel!.ready;

      _webSocketSubscription = _socketChannel!.stream.listen((msg) async {
        final frame = WsFrame.fromJson(json.decode(msg));
        switch (frame.type) {
          case "state":
            final state = frame.data["state"];
            switch (state) {
              case "PLAYING":
                await play();
                break;
              case "PAUSED":
                await pause();
                break;
              case "STOPPED":
                await stop();
                break;
              default:
                logger.warning("Invalid playback state: $state");
                break;
            }
            break;
          case "currentTrack":
            if (frame.data.containsKey("id")) {
              final trackId = frame.data["id"];
              final track = await _apiManager.service.getTrack(trackId);
              await playTrack(track);
            }
            else if (frame.data.containsKey("queueId")) {
              final queueId = frame.data["queueId"];
              await playTrackAtIndex(queueId);
            }
            else {
              logger.warning("Websocket message of type currentTrack was send without a track id or index.");
            }
            break;
          case "queue":
            await playFromQueueIds((frame.data["ids"] as List<dynamic>).map((i) => i as int).toList(),
              startId: frame.data["startId"],
              audioType: frame.data["audioType"],
              audioTypeId: frame.data["audioTypeId"],
              shuffle: frame.data["shuffle"]
            );
            break;
          case "shuffle":
            final shuffle = frame.data["state"];
            setShuffleMode(shuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none);
            break;
          case "repeat":
            final repeat = frame.data["state"];
            switch (repeat) {
              case "OFF":
                setRepeatMode(AudioServiceRepeatMode.none);
                break;
              case "CURRENT_TRACK":
                setRepeatMode(AudioServiceRepeatMode.one);
                break;
              case "ALL":
                setRepeatMode(AudioServiceRepeatMode.all);
                break;
              default:
                logger.warning("Invalid repeat mode: $repeat.");
                break;
            }
            break;
          case "volume":
            final volume = frame.data["volume"];
            await setVolume(volume);
            break;
          case "speed":
            final speed = frame.data["speed"];
            await setSpeed(speed);
            break;
          default:
            logger.warning("Invalid websocket message type: ${frame.type}");
            break;
        }

      }, onError: (error, stackTrace) {
        logger.handle(error, stackTrace, "Websocket error");
        _webSocketPingTimer?.cancel();
        _webSocketPingTimer = null;
        _socketChannel = null;
        _startWebSocketReconnectTimer();
      }, onDone: () {
        logger.warning("WebSocket connection closed");
        _webSocketPingTimer?.cancel();
        _webSocketPingTimer = null;
        _socketChannel = null;
        _startWebSocketReconnectTimer();
      });

      // Send any queued messages
      for (var message in _webSocketMessageQueue) {
        _socketChannel!.sink.add(jsonEncode(message));
      }

      _webSocketMessageQueue.clear();

      _startWebSocketPingTimer();
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    }
    catch (e, st) {
      logger.handle(e, st, "Error connecting to websocket");
      _socketChannel = null;
    }
  }

  Future<void> disconnectWebSocket() async {
    try {
      await _socketChannel?.sink.close();
    }
    catch (e, st) {
      logger.handle(e, st, "Error disconnecting websocket");
    }
    finally {
      _socketChannel = null;
      _webSocketPingTimer?.cancel();
      _webSocketPingTimer = null;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    }
  }

  void _sendWebSocket(String type, { dynamic data }) {

    try {
      final message = {
        'type': type,
        'data': data,
        'timestamp': (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).round(),
      };

      if (_socketChannel == null || _socketChannel!.closeCode != null) {
        _webSocketMessageQueue.add(message);
        _ensureWebSocketConnected();
        return;
      }

      _socketChannel!.sink.add(jsonEncode(message));
    }
    catch (e, st) {
      logger.handle(e, st, "Error sending websocket message");
    }
  }

  String _getWsUrl() {
    return UrlUtils.getWsUrl("ws/playback?token=${_apiManager.accessToken}");
  }

  // endregion

  // region Playback Controls

  @override Future<void> play() async {
    _sendWebSocket('play');
    // Do not await - Will wait until stopped / paused
    audioPlayer.play();
  }

  @override Future<void> pause() {
    _sendWebSocket('pause');
    return audioPlayer.pause();
  }

  @override
  Future<void> stop() async {
    await audioPlayer.stop();
    _queue.clear();
    _currentIndex = 0;
    _shuffleIndices.clear();
    _shufflePosition = 0;
    _updateMediaItem();
    sequenceStreamController.add([]);
    _sendWebSocket('stop');
    return super.stop();
  }

  @override
  Future<void> skipToNext({ bool notify = true }) async {
    if (_queue.isEmpty) return;

    if (notify) {
      _sendWebSocket('skipped_next', data: {
        'trackId': _queue[_currentIndex].id,
      });
    }

    // In loop one mode, restart current track
    if (_loopMode == LoopMode.one) {
      await audioPlayer.seek(Duration.zero);
      await play();
      return;
    }

    if (_isShuffling) {
      if (_shufflePosition < _shuffleIndices.length - 1) {
        _shufflePosition++;
        final nextIndex = _shuffleIndices[_shufflePosition];
        await playTrackAtIndex(nextIndex);
      } else if (_loopMode == LoopMode.all) {
        // Loop back to beginning in shuffle mode
        _shufflePosition = 0;
        final nextIndex = _shuffleIndices[_shufflePosition];
        await playTrackAtIndex(nextIndex);
      }
    } else {
      if (_currentIndex < _queue.length - 1) {
        await playTrackAtIndex(_currentIndex + 1);
      } else if (_loopMode == LoopMode.all) {
        // Loop back to beginning
        await playTrackAtIndex(0);
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;

    _sendWebSocket('skipped_prev', data: {
      'trackId': _queue[_currentIndex].id,
    });

    // In loop one mode, restart current track
    if (_loopMode == LoopMode.one) {
      await audioPlayer.seek(Duration.zero);
      await play();
      return;
    }

    // If more than 3 seconds into track, restart current track
    if (correctedPosition.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    if (_isShuffling) {
      if (_shufflePosition > 0) {
        _shufflePosition--;
        final prevIndex = _shuffleIndices[_shufflePosition];
        await playTrackAtIndex(prevIndex);
      } else if (_loopMode == LoopMode.all) {
        // Loop to end in shuffle mode
        _shufflePosition = _shuffleIndices.length - 1;
        final prevIndex = _shuffleIndices[_shufflePosition];
        await playTrackAtIndex(prevIndex);
      }
    } else {
      if (_currentIndex > 0) {
        await playTrackAtIndex(_currentIndex - 1);
      } else if (_loopMode == LoopMode.all) {
        // Loop to end
        await playTrackAtIndex(_queue.length - 1);
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

    await playTrackAtIndex(index);
  }

  @override
  Future<void> seek(Duration position) async {
    final trackId = _currentlyLoadedTrackId;
    final streamable = _currentStreamable;
    if (trackId == null || streamable == null) return;

    final item = getCurrentMediaItem();
    final source = AudioSource.uri(
      _getStreamUrl(trackId, streamable, position: position),
      tag: item,
      headers: {'Authorization': 'Bearer ${_apiManager.accessToken}'},
    );

    _seekOffset = position;
    final wasPlaying = audioPlayer.playing;
    try {
      if (kIsWeb) await audioPlayer.stop();
      await audioPlayer.setAudioSource(source);
      if (wasPlaying) await play();
    } catch (e, st) {
      logger.handle(e, st, "Error seeking to $position");
      return;
    }

    _seekStreamController.add(position);
  }

  bool get isPlaying => audioPlayer.playing;

  LoopMode get loopMode => _loopMode;
  set loopMode(LoopMode mode) {
    _loopMode = mode;
    loopModeStreamController.add(mode);
    _updatePlaybackState();
    _sendWebSocket("repeat", data: { "mode": mode.name });
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
    _sendWebSocket("shuffle", data: { "shuffle": value });
  }

  double get speed => audioPlayer.speed;
  set speed(double value) => setSpeed(value);

  Duration get position => correctedPosition;

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
  Future<void> playTrackAtIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;

    _currentIndex = index;
    final item = _queue[index];

    final trackId = item.trackId;
    if (trackId == null) return;

    final streamableList = await _getStreamablesFromIds([trackId]);
    if (streamableList.isEmpty) return;
    _currentStreamable = streamableList.single;
    final trackUri = _getStreamUrl(trackId, _currentStreamable!);

    // Update media item BEFORE loading the source (especially important for web)
    _updateMediaItem();

    final source = AudioSource.uri(
      trackUri,
      tag: item,
      headers: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      }
    );

    _currentlyLoadedTrackId = trackId;
    _seekOffset = Duration.zero;

    try {
      // Only pause on mobile, stop on web to clear cache
      if (kIsWeb) {
        await audioPlayer.stop();
      } else if (audioPlayer.playing) {
        await audioPlayer.pause();
      }

      // Reset "completed" state
      await audioPlayer.stop();

      await audioPlayer.setAudioSource(source);
      _sendWebSocket("started_track", data: {
        'trackId': trackId
      });

      _setActualVolume();

      await play();
    } catch (e, st) {
      logger.handle(e, st, "Error playing track at index $index");
    }
  }

  double _dbToMultiplier(double db) => pow(10, db / 20).toDouble();

  /// Toggles between play and pause states.
  Future<void> playPause() async {
    if (audioPlayer.playing) {
      await pause();
    } else {
      await play();
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
      repeatMode: switch (_loopMode) {
        LoopMode.off => AudioServiceRepeatMode.none,
        LoopMode.all => AudioServiceRepeatMode.all,
        LoopMode.one => AudioServiceRepeatMode.one,
      },
    ));
  }

  // endregion

  // region Volume controls

  /// Sets the volume to the specified level (0.0 to 1.0)
  Future<void> setVolume(double newVolume) async {
    _volume = newVolume.clamp(0.0, 1.0);
    _currentVolumeController.add(volume);
    _setActualVolume(newVolume: volume);
    _sendWebSocket("volume", data: { "volume": newVolume });
  }

  @override
  Future<void> setSpeed(double speed) async {
    await audioPlayer.setSpeed(speed);
    _sendWebSocket("speed", data: { "speed": speed });
  }

  /// Sets the actual volume on the audio player, applying normalization if enabled
  void _setActualVolume({double? newVolume}) {

    if (!_settingsManager.get(Settings.enableVolumeNormalization)) {
      audioPlayer.setVolume(newVolume ?? _volume);
      return;
    }

    final c = getCurrentMediaItem();
    if (c == null) {
      audioPlayer.setVolume(newVolume ?? _volume);
      return;
    }

    if (c.extras != null && c.extras!.containsKey('volumeOffset')) {
      final volOffset = c.extras!['volumeOffset'];
      if (volOffset is double) {
        final gainMultiplier = _dbToMultiplier(volOffset);
        final finalVolume = (newVolume ?? _volume) * gainMultiplier;
        audioPlayer.setVolume(finalVolume.clamp(0.0, 1.0));
      } else {
        audioPlayer.setVolume(newVolume ?? _volume);
      }
    } else {
      audioPlayer.setVolume(newVolume ?? _volume);
    }
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
    final position = correctedPosition;
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
        await playTrackAtIndex(_currentIndex);
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

    _sendWebSocket("queue", data: {
      "queue": getSequence().indexed.map((entry) => {
          "id": entry.$2.id,
          "pos": entry.$1,
          "trackId": int.tryParse(entry.$2.id.split("-").first)
        }).toList()
    });
  }

  /// Reloads the current track's audio source (used when queue changes affect current track)
  Future<void> _reloadCurrentTrack(bool wasPlaying, Duration position) async {
    if (_queue.isEmpty || _currentIndex < 0 || _currentIndex >= _queue.length) return;

    final item = _queue[_currentIndex];

    final trackId = item.trackId;
    if (trackId == null) return;

    // Check if we actually need to reload (track ID changed)
    if (_currentlyLoadedTrackId == trackId && !kIsWeb) {
      // Same track is loaded, just update UI
      _updateMediaItem();
      return;
    }

    final streamableList = await _getStreamablesFromIds([trackId]);
    if (streamableList.isEmpty) return;
    _currentStreamable = streamableList.single;
    // Use cache busting on web to force reload
    final trackUri = _getStreamUrl(trackId, _currentStreamable!, bustCache: true, position: position);

    _updateMediaItem();

    final source = AudioSource.uri(
      trackUri,
      tag: item,
      headers: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      }
    );

    _currentlyLoadedTrackId = trackId;
    _seekOffset = position;

    try {
      if (kIsWeb) {
        // On web, we need to fully stop to prevent caching issues
        await audioPlayer.stop();
        await audioPlayer.setAudioSource(source);
      } else {
        // On Android/iOS, just set the new source to avoid notification flicker
        await audioPlayer.setAudioSource(source);
      }

      if (wasPlaying) {
        await play();
      }
    } catch (e, st) {
      logger.handle(e, st, "Error reloading current track");
    }
  }

  // endregion

  // region Play Methods

  Future<void> playFromQueueIds(List<int> ids, { int? startId, int? audioTypeId, String? audioType, bool? shuffle }) async {

    AudioType? parsedType;

    if (shuffle != null) _isShuffling = shuffle;

    if (audioType != null) {
      parsedType = AudioType.values.firstWhere((at) => at.name.toLowerCase() == audioType.toLowerCase(), orElse: () => AudioType.unspecified);
      setAudioType(parsedType, audioTypeId);
    }

    final streamables = await _getStreamablesFromIds(ids);
    _queue = await Future.wait(streamables.map((track) => _buildMediaItem(track)));

    if (parsedType != null && parsedType != AudioType.unspecified && parsedType != AudioType.tracks) {
      _sendWebSocket("listen", data: {
        'type': parsedType.name,
        'id': audioTypeId
      });
    }

    if (_isShuffling && startId == null) {
      // Let shuffle order determine the starting track
      _shuffleIndices = List.generate(_queue.length, (i) => i);
      _shuffleIndices.shuffle();
      _shufflePosition = 0;
      await playTrackAtIndex(_shuffleIndices[0]);
    }
    else {
      // Either not shuffling, or have a preferred track
      final initialIndex = startId != null
          ? _queue.indexWhere((item) => item.trackId == startId)
          : 0;

      if (_isShuffling) {
        // Set current index before creating shuffle order
        // so the preferred track is moved to the front
        _currentIndex = initialIndex.clamp(0, _queue.length - 1);
        _createShuffleOrder();
      }

      await playTrackAtIndex(initialIndex.clamp(0, _queue.length - 1));
    }

    _updateQueue();
  }

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

    final streamables = await _getStreamablesFromIds(tracks.map((t) => t.id).toList());
    _queue = await Future.wait(streamables.map((track) => _buildMediaItem(track)));

    _sendWebSocket("listen", data: {
      'type': 'playlist',
      'id': data.playlist.id,
    });

    if (_isShuffling && preferredTrackId == null) {
      // Let shuffle order determine the starting track
      _shuffleIndices = List.generate(_queue.length, (i) => i);
      _shuffleIndices.shuffle();
      _shufflePosition = 0;
      await playTrackAtIndex(_shuffleIndices[0]);
    } else {
      // Either not shuffling, or have a preferred track
      final initialIndex = preferredTrackId != null
          ? _queue.indexWhere((item) => item.trackId == preferredTrackId)
          : 0;

      if (_isShuffling) {
        // Set current index before creating shuffle order
        // so the preferred track is moved to the front
        _currentIndex = initialIndex.clamp(0, _queue.length - 1);
        _createShuffleOrder();
      }

      await playTrackAtIndex(initialIndex.clamp(0, _queue.length - 1));
    }

    _updateQueue();
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

    final streamables = await _getStreamablesFromIds(tracks.map((t) => t.id).toList());
    _queue = await Future.wait(streamables.map((track) => _buildMediaItem(track)));

    _sendWebSocket("listen", data: {
      'type': 'album',
      'id': data.album.id,
    });

    if (_isShuffling && preferredTrackId == null) {
      // Let shuffle order determine the starting track
      _shuffleIndices = List.generate(_queue.length, (i) => i);
      _shuffleIndices.shuffle();
      _shufflePosition = 0;
      await playTrackAtIndex(_shuffleIndices[0]);
    } else {
      // Either not shuffling, or have a preferred track
      final initialIndex = preferredTrackId != null
          ? _queue.indexWhere((item) => item.trackId == preferredTrackId)
          : 0;

      if (_isShuffling) {
        // Set current index before creating shuffle order
        // so the preferred track is moved to the front
        _currentIndex = initialIndex.clamp(0, _queue.length - 1);
        _createShuffleOrder();
      }

      await playTrackAtIndex(initialIndex.clamp(0, _queue.length - 1));
    }

    _updateQueue();
  }

  // endregion

  // region Minimal Tracks

  /// Plays the specified minimal track, replacing the current queue.
  Future<void> playMinimalTrack(MinimalTrack track) async {
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    final streamable = await _getStreamablesFromIds([track.id]);
    if (streamable.isEmpty) return;

    _queue = [await _buildMediaItem(streamable.single)];
    _isShuffling = false;

    await playTrackAtIndex(0);
    _updateQueue();
  }

  /// Plays the specified minimal track within the provided queue of minimal tracks.
  Future<void> playMinimalTrackWithQueue(MinimalTrack track, List<MinimalTrack> queue) async {
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    final streamables = await _getStreamablesFromIds(queue.map((t) => t.id).toList());
    if (streamables.isEmpty) return;

    _queue = await Future.wait(streamables.map((track) => _buildMediaItem(track)));

    final initialIndex = _queue.indexWhere((item) => item.trackId == track.id);

    if (_isShuffling) {
      _createShuffleOrder();
    }

    await playTrackAtIndex(initialIndex.clamp(0, _queue.length - 1));
    _updateQueue();
  }

  // endregion

  // region Tracks

  /// Plays the specified track, replacing the current queue.
  Future<void> playTrack(Track track) async {
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    final streamable = await _getStreamablesFromIds([track.id]);
    if (streamable.isEmpty) return;

    _queue = [await _buildMediaItem(streamable.single)];
    _isShuffling = false;

    await playTrackAtIndex(0);
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
    final streamable = await _getStreamablesFromIds([track.id]);
    if (streamable.isEmpty) return;

    final item = await _buildMediaItem(streamable.single);

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
      await playTrackAtIndex(0);
    }
  }

  Future<List<Streamable>> _getStreamablesFromIds(List<int> ids) async {
    try {
      return await _apiManager.service.getStreams(ids.join(","));
    }
    catch (e, st) {
      logger.handle(e, st, "Error fetching streamables for IDs");
      return [];
    }
  }

  /// Adds the specified minimal track to the queue.
  Future<void> addMinimalTrackToQueue(MinimalTrack track, bool next) async {
    final streamable = await _getStreamablesFromIds([track.id]);
    if (streamable.isEmpty) return;

    final item = await _buildMediaItem(streamable.single);

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
      await playTrackAtIndex(0);
    }
  }

  /// Adds all tracks from the specified album to the queue.
  Future<void> addAlbumToQueue(Album album, bool next) async {
    final albumData = await _apiManager.service.getAlbum(album.id);

    if (albumData.tracks.isEmpty) {
      return;
    }

    final wasEmpty = _queue.isEmpty;

    final streamables = await _getStreamablesFromIds(albumData.tracks.map((t) => t.id).toList());
    final items = await Future.wait(streamables.map((track) => _buildMediaItem(track)));

    if (items.isEmpty) {
      return;
    }

    if (next && _queue.isNotEmpty) {
      _queue.insertAll(_currentIndex + 1, items);
    } else {
      _queue.addAll(items);
    }

    if (_isShuffling) {
      _createShuffleOrder();
    }

    _updateQueue();

    _sendWebSocket("listen", data: {
      'type': 'album',
      'id': album.id,
    });

    if (wasEmpty) {
      setAudioType(AudioType.album, album.id);
      await playTrackAtIndex(0);
    }
  }

  /// Adds all tracks from the specified playlist to the queue.
  Future<void> addPlaylistToQueue(Playlist playlist, bool next) async {
    final playlistData = await _apiManager.service.getPlaylist(playlist.id);

    if (playlistData.tracks.isEmpty) {
      return;
    }

    final wasEmpty = _queue.isEmpty;

    final streamables = await _getStreamablesFromIds(playlistData.tracks.map((t) => t.track.id).toList());
    final items = await Future.wait(streamables.map((track) => _buildMediaItem(track)));

    if (next && _queue.isNotEmpty) {
      _queue.insertAll(_currentIndex + 1, items);
    } else {
      _queue.addAll(items);
    }

    if (_isShuffling) {
      _createShuffleOrder();
    }

    _updateQueue();

    _sendWebSocket("listen", data: {
      'type': 'playlist',
      'id': playlist.id,
    });

    if (wasEmpty) {
      setAudioType(AudioType.playlist, playlist.id);
      await playTrackAtIndex(0);
    }

  }

  // endregion

  // region Helpers

  void setAudioType(AudioType type, int? id) {
    _currentAudioType = CurrentAudioType(audioType: type, id: id);
    _currentAudioTypeController.add(_currentAudioType);
  }

  /// Gets the current media item being played, or null if there is none.
  MediaItem? getCurrentMediaItem() {
    if (_queue.isEmpty || _currentIndex < 0 || _currentIndex >= _queue.length) {
      return null;
    }
    return _queue[_currentIndex];
  }

  MediaItem? getNextMediaItem() {
    if (!hasNext) return null;

    if (_isShuffling) {
      final nextIndex = _shuffleIndices[_shufflePosition + 1];
      return _queue[nextIndex];
    } else {
      return _queue[_currentIndex + 1];
    }
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

  /// Creates a MediaItem from a Track
  Future<MediaItem> _buildMediaItem(Streamable streamable) async {
    final artUri = await _getCoverUri(streamable);

    return MediaItem(
      id: "${streamable.trackId}-${Uuid().v4()}",
      title: streamable.title,
      album: streamable.album,
      artist: streamable.artist,
      duration: streamable.duration == null ? null : Duration(milliseconds: streamable.duration!),
      artUri: artUri,
      artHeaders: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      },
      extras: {
        'coverChecksum': streamable.coverChecksum,
        'coverSignature': streamable.coverSignature,
        'coverExpiration': streamable.coverExpiration,
        'trackSignature': streamable.streamSignature,
        'trackExpiration': streamable.streamExpiration,
        'volumeOffset': streamable.volumeOffset,
      }
    );
  }

  /// Gets the cover URI for the specified track, embedding as base64 if configured.
  Future<Uri> _getCoverUri(Streamable streamable) async {

    if (_settingsManager.get(Settings.embedImagesAsBase64)) {
      try {
        final bytes = await _apiManager.service.getTrackCover(
            streamable.trackId, _settingsManager.get(Settings.metadataImageSize).pixelSize
        );
        if (bytes.data.isNotEmpty) {
          return Uri.dataFromBytes(bytes.data, mimeType: "image/jpeg");
        }
      }
      catch (e, st) {
        logger.handle(e, st, "Failed to fetch and embed cover image for track ${streamable.title}");
      }
    }

    // TODO: Check if coverChecksum is null or expired, and return a default image URI if so.

    return Uri.parse(
        UrlUtils.getUrl(
            "api/images/by-checksum/${streamable.coverChecksum}"
            "?sig=${streamable.coverSignature}"
            "&exp=${streamable.coverExpiration}"
            "&quality=${_settingsManager.get(Settings.metadataImageSize).pixelSize}"));
  }

  /// Constructs the stream URL for the specified track ID and media token.
  /// If [bustCache] is true and running on web, adds a cache buster parameter.
  Uri _getStreamUrl(int trackId, Streamable streamable, {bool bustCache = false, Duration position = Duration.zero}) {
    var baseUrl = UrlUtils.getUrl(
            "api/streams/$trackId"
            "?sig=${streamable.streamSignature}"
            "&exp=${streamable.streamExpiration}");

    // Apply transcoding settings (if enabled)
    if (_settingsManager.get(Settings.enableTranscoding)) {
      baseUrl += "&format=${_settingsManager.get(Settings.preferredStreamingFormat).value}&bitrate=${_settingsManager.get(Settings.preferredStreamingBitrate)}";
    }
    else {
      baseUrl += "&format=original";
    }

    // Add cache buster for web to force reload
    if (bustCache && kIsWeb) {
      baseUrl += "&_cb=${DateTime.now().millisecondsSinceEpoch}";
    }

    if (position > Duration.zero) {
      baseUrl += "&start=${position.inSeconds}";
    }

    return Uri.parse(baseUrl);
  }

  // endregion
}