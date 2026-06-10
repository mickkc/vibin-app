import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:dart_discord_presence/dart_discord_presence.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/utils/url_utils.dart';

class RpcUpdater {

  DiscordRPC? rpcInstance;

  static final instance = RpcUpdater();
  static final _settingsManager = getIt<SettingsManager>();

  StreamSubscription<MediaItem?>? _playingSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlaybackState>? _isPlayingSubscription;
  StreamSubscription<DiscordDisconnectedEvent>? _disconnectionSubscription;
  StreamSubscription<DiscordErrorEvent>? _errorSubscription;
  StreamSubscription<DiscordReadyEvent>? _readySubscription;
  bool? _lastIsPlaying;
  AudioManager? _audioManager;
  bool _isUpdating = false;

  final _connectedStreamController = StreamController<bool>.broadcast();
  Stream<bool> get connectedStream => _connectedStreamController.stream;

  bool get connected => rpcInstance != null && rpcInstance!.isInitialized && rpcInstance!.isConnected;

  /// Tries to connect to Discord, if enabled in the settings and not already
  /// connected. Otherwise this is a no-op.
  ///
  /// Also starts the disconnected, ready and error listeners if successfully
  /// connected.
  void start() async {

    if (rpcInstance != null && rpcInstance!.isInitialized && rpcInstance!.isConnected) return;

    if (!_settingsManager.get(Settings.enableDiscordRpc)) {
      logger.info("Discord RPC is disabled");
      return;
    }

    try {
      rpcInstance = DiscordRPC();
      DiscordRPC.ensureSupported();
      await rpcInstance!.initialize("1513945748260000048");
      _startConnectionListener(rpcInstance!);
      updateState();
    }
    catch (e, st) {
      if (e is DiscordConnectionException) {
        logger.handle(e, st, "Could not connect to discord client.");
      }
      else {
        logger.handle(e, st, "An unknown error occurred while connecting to Discord.");
      }
    }
    _connectedStreamController.add(rpcInstance!.isConnected);
  }

  void _startConnectionListener(DiscordRPC rpc) {
    _cancelConnectionListener();
    _disconnectionSubscription = rpcInstance!.onDisconnected.listen((data) {
      logger.error("Discord connection lost. Error code: ${data.errorCode}, Message: ${data.message}");
      _connectedStreamController.add(false);
    });
    _errorSubscription = rpcInstance!.onError.listen((error) {
      logger.error("Error in Discord connection. Error code: ${error.errorCode}, Message: ${error.message}");
    });
    _readySubscription = rpcInstance!.onReady.listen((event) {
      logger.info("Connected to discord account ${event.user.username}!");
      _connectedStreamController.add(true);
    });
  }

  void _cancelConnectionListener() {
    _disconnectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _readySubscription?.cancel();
  }

  /// Stops the connection to Discord, if it is active.
  void stop() async {
    final instance = rpcInstance;
    if (instance == null) return;
    _connectedStreamController.add(false);
    _cancelConnectionListener();
    await instance.dispose();
    // Only clear rpcInstance if start() hasn't replaced it with a new connection while awaiting dispose().
    if (identical(rpcInstance, instance)) {
      rpcInstance = null;
    }
  }

  /// Sets the [AudioManager] as the source for activity updates by (re)creating
  /// the currentMediaItem, seek and playbackState subscriptions, cancelling the
  /// old ones if there are any.
  void setAudioManager(AudioManager audioManager) {
    _audioManager = audioManager;
    _startAudioListener();
  }

  void _startAudioListener() {

    _cancelAudioListener();

    _playingSubscription = _audioManager?.currentMediaItemStream.listen((mediaItem) {
      logger.info("Sending new playing track to discord...");
      updateState();
    });

    _positionSubscription = _audioManager?.seekStream.listen((position) {
      logger.info("Sending new position to discord...");
      updateState();
    });

    _isPlayingSubscription = _audioManager?.playbackState.listen((state) {
      if (state.playing == _lastIsPlaying) return;
      logger.info("Sending new playback state to discord...");
      updateState();
      _lastIsPlaying = state.playing;
    });
  }

  void _cancelAudioListener() {
    _playingSubscription?.cancel();
    _positionSubscription?.cancel();
    _isPlayingSubscription?.cancel();
  }

  /// Formats the template, replacing placeholders with their actual value.
  ///
  /// If the formatted template turns out to be empty after replacing, null is
  /// returned to hide the field in Discord.
  String? _formatTemplate(String template, MediaItem mediaItem) {
    final filledTemplate = template
      .replaceAll("{title}", mediaItem.title)
      .replaceAll("{album}", mediaItem.album ?? "")
      .replaceAll("{artists}", mediaItem.artist ?? "")
      .replaceAll("{state}", _audioManager!.isPlaying ? "Playing" : "Paused")
      .replaceAll("{queue}", "${_audioManager!.getSequencePosition() + 1} / ${_audioManager!.getSequence().length}");

    if (filledTemplate.isEmpty) return null;
    return filledTemplate;
  }

  /// Resolves a URL Discord can use for the cover image.
  ///
  /// `mediaItem.artUri` may be a `data:` URI when "Embed images as Base64"
  /// is enabled, which Discord can't load as an external asset, so fallback
  /// to the http(s) url in that case.
  ///
  /// If there is not image associated wit the MediaItem, null is returned to
  /// use the default image set inside the Discord app.
  String? _resolveArtUrl(MediaItem mediaItem) {
    final artUri = mediaItem.artUri;
    if (artUri != null && artUri.scheme != "data") return artUri.toString();

    final checksum = mediaItem.extras?['coverChecksum'];
    if (checksum == null) return null;

    return UrlUtils.getUrl(
      "api/images/by-checksum/$checksum"
      "?sig=${mediaItem.extras?['coverSignature']}"
      "&exp=${mediaItem.extras?['coverExpiration']}");
  }

  /// Updates the Discord activity based on the current [_audioManager].
  ///
  /// If there is no connection, this is a no-op.
  /// If there is no audio manager, the presence gets cleared.
  /// If there is no current media item, the presence gets cleared.
  void updateState() async {
    if (_isUpdating) return;
    try {
      _isUpdating = true;

      if (rpcInstance == null) {
        logger.warning("Discord RPC Instance is null!");
        return;
      }
      if (!rpcInstance!.isInitialized) {
        logger.warning("Discord RPC Instance is not initialized!");
        return;
      }
      if (!rpcInstance!.isConnected) {
        logger.warning("Discord RPC Instance is not connected!");
        return;
      }
      final mediaItem = _audioManager?.getCurrentMediaItem();
      if (mediaItem == null) {
        await rpcInstance!.clearPresence();
      }
      else {
        final artUrl = _resolveArtUrl(mediaItem);
        await rpcInstance!.setPresence(DiscordPresence(
          type: DiscordActivityType.listening,
          state: _formatTemplate(_settingsManager.get(Settings.stateTemplate), mediaItem),
          details: _formatTemplate(_settingsManager.get(Settings.detailTemplate), mediaItem),
          statusDisplayType: _settingsManager.get(Settings.displayType),
          largeAsset: artUrl != null ? DiscordAsset.fromUrl(artUrl,
            text: _formatTemplate(_settingsManager.get(Settings.largeAssetTemplate), mediaItem)) : null,
          smallAsset: _audioManager!.isPlaying ? null : DiscordAsset.fromKey("paused",
            text: _formatTemplate(_settingsManager.get(Settings.smallAssetTemplate), mediaItem)),
          timestamps: _audioManager!.isPlaying ? DiscordTimestamps.range(
            DateTime.now().subtract(_audioManager!.correctedPosition),
            DateTime.now().subtract(_audioManager!.correctedPosition).add(mediaItem.duration ?? Duration.zero)
          ) : null,
        ));
      }
    }
    catch (e, st) {
      logger.handle(e, st, "Error updating Discord presence.");
    }
    finally {
      _isUpdating = false;
    }

  }
}