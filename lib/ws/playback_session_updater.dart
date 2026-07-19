import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/audio/audio_type.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/api_manager.dart';
import '../auth/auth_state.dart';
import '../dtos/ws_frame.dart';
import '../main.dart';
import '../utils/url_utils.dart';

class PlaybackSessionUpdater {

  late final AuthState _authState = getIt<AuthState>();
  late final ApiManager _apiManager = getIt<ApiManager>();

  final AudioManager _audioManager;
  Timer? _webSocketPingTimer;
  Timer? _reconnectTimer;
  WebSocketChannel? _socketChannel;
  final List<dynamic> _webSocketMessageQueue = [];

  StreamSubscription<dynamic>? _webSocketSubscription;

  PlaybackSessionUpdater(this._audioManager);


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

  Future<void> cleanup() async {
    await _webSocketSubscription?.cancel();
    _webSocketSubscription = null;
  }

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
        await _handleFrame(frame);
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

  Future<void> _handleFrame(WsFrame frame) async {
    switch (frame.type) {
      case "state":
        final state = frame.data["state"];
        switch (state) {
          case "PLAYING":
            await _audioManager.play();
            break;
          case "PAUSED":
            await _audioManager.pause();
            break;
          case "STOPPED":
            await _audioManager.stop();
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
          await _audioManager.playTrack(track);
        }
        else if (frame.data.containsKey("queueId")) {
          final queueId = frame.data["queueId"];
          await _audioManager.playTrackAtIndex(queueId);
        }
        else {
          logger.warning("Websocket message of type currentTrack was send without a track id or index.");
        }
        break;
      case "queue":
        await _audioManager.playFromQueueIds((frame.data["ids"] as List<dynamic>).map((i) => i as int).toList(),
            startId: frame.data["startId"],
            audioType: frame.data["audioType"],
            audioTypeId: frame.data["audioTypeId"],
            shuffle: frame.data["shuffle"]
        );
        break;
      case "shuffle":
        final shuffle = frame.data["state"];
        _audioManager.setShuffleMode(shuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none);
        break;
      case "repeat":
        final repeat = frame.data["state"];
        switch (repeat) {
          case "OFF":
            _audioManager.setRepeatMode(AudioServiceRepeatMode.none);
            break;
          case "CURRENT_TRACK":
            _audioManager.setRepeatMode(AudioServiceRepeatMode.one);
            break;
          case "ALL":
            _audioManager.setRepeatMode(AudioServiceRepeatMode.all);
            break;
          default:
            logger.warning("Invalid repeat mode: $repeat.");
            break;
        }
        break;
      case "volume":
        final volume = frame.data["volume"];
        await _audioManager.setVolume(volume);
        break;
      case "speed":
        final speed = frame.data["speed"];
        await _audioManager.setSpeed(speed);
        break;
      case "update":
        updateAll();
        break;
      default:
        logger.warning("Invalid websocket message type: ${frame.type}");
        break;
    }
  }

  Future<void> disconnectWebSocket() async {
    try {
      await _webSocketSubscription?.cancel();
      _webSocketSubscription = null;
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

  void trackFinished(int? trackId) => _sendWebSocket("finished_track", data: {
    'trackId': trackId,
  });

  void skippedNext(int? skippedTrackId) => _sendWebSocket('skipped_next', data: {
    'trackId': skippedTrackId,
  });

  void skippedPrevious(int? skippedTrackId) => _sendWebSocket('skipped_prev', data: {
    'trackId': skippedTrackId,
  });

  void startedTrack(int? trackId) => _sendWebSocket("started_track", data: {
    'trackId': trackId
  });

  void played() => _sendWebSocket("play");
  void paused() => _sendWebSocket("pause");
  void stopped() => _sendWebSocket("stop");
  void buffering() => _sendWebSocket("buffering");

  void repeatModeChanged(LoopMode mode) => _sendWebSocket("repeat", data: { "mode": mode.name });
  void shuffleModeChanged(bool mode) =>  _sendWebSocket("shuffle", data: { "shuffle": mode });
  void volumeChanged(double volume) => _sendWebSocket("volume", data: { "volume": volume });
  void speedChanged(double speed) => _sendWebSocket("speed", data: { "speed": speed });

  void queueChanged(List<MediaItem> sequence) => _sendWebSocket("queue", data: {
    "queue": sequence.indexed.map((entry) => {
      "id": entry.$2.id,
      "pos": entry.$1,
      "trackId": int.tryParse(entry.$2.id.split("-").first)
    }).toList()
  });

  void recordListen(AudioType type, int? id) => _sendWebSocket("listen", data: {
    'type': type.name,
    'id': id
  });

  void updateAll() {
    queueChanged(_audioManager.getSequence());
    final currentMediaItem = _audioManager.getCurrentMediaItem();
    startedTrack(currentMediaItem != null ? _audioManager.getTrackIdFromMediaItem(currentMediaItem) : null);

    if (_audioManager.playbackState.value.processingState == AudioProcessingState.buffering) {
      buffering();
    }
    else if (_audioManager.playbackState.value.processingState == AudioProcessingState.idle) {
      stopped();
    }
    else {
      if (_audioManager.playbackState.value.playing) {
        played();
      }
      else {
        paused();
      }
    }

    repeatModeChanged(_audioManager.loopMode);
    shuffleModeChanged(_audioManager.isShuffling);
    volumeChanged(_audioManager.volume);
    speedChanged(_audioManager.speed);
  }
}