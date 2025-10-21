import 'dart:developer';

import 'package:dbus/dbus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/main.dart';

class MprisPlayer extends DBusObject {
  late AudioManager audioManager;

  MprisPlayer() : super(DBusObjectPath("/org/mpris/MediaPlayer2")) {
    audioManager = getIt<AudioManager>();
    subscribeToAudioPlayer();
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    log("DBus: GetAllProperties called for interface: $interface");
    if (interface == "org.mpris.MediaPlayer2.Player") {
      return DBusGetAllPropertiesResponse({
        "PlaybackStatus": DBusString(audioManager.isPlaying ? "Playing" : "Paused"),
        "LoopStatus": DBusString(fromLoopMode(audioManager.loopMode)),
        "Rate": DBusDouble(audioManager.speed),
        "Shuffle": DBusBoolean(audioManager.isShuffling),
        "Metadata": getCurrentTrackMetadata(),
        "Volume": DBusDouble(audioManager.volume),
        "Position": DBusInt64(audioManager.position.inMicroseconds),
        "MinimumRate": DBusDouble(0.25),
        "MaximumRate": DBusDouble(2.0),
        "CanGoNext": DBusBoolean(audioManager.hasNext),
        "CanGoPrevious": DBusBoolean(audioManager.hasPrevious),
        "CanPlay": DBusBoolean(true),
        "CanPause": DBusBoolean(true),
        "CanSeek": DBusBoolean(true),
        "CanControl": DBusBoolean(true)
      });
    }
    else if (interface == "org.mpris.MediaPlayer2") {
      return DBusGetAllPropertiesResponse({
        "CanQuit": DBusBoolean(false),
        "CanRaise": DBusBoolean(false),
        "HasTrackList": DBusBoolean(false),
        "Identity": DBusString("vibin"),
        "DesktopEntry": DBusString("vibin"),
        "SupportedUriSchemes": DBusArray.string(["file"]),
        "SupportedMimeTypes": DBusArray.string(["audio/mpeg", "audio/flac", "audio/wav", "audio/ogg", "application/ogg", "audio/aac"])
      });
    }
    return DBusGetAllPropertiesResponse({});
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    log("DBus: MethodCall received: ${methodCall.interface}.${methodCall.name} with values: ${methodCall.values}");
    if (methodCall.interface == "org.mpris.MediaPlayer2") {
      switch (methodCall.name) {
        case "Raise":
          return DBusMethodSuccessResponse();
        case "Quit":
          audioManager.stop();
          return DBusMethodSuccessResponse();
      }
    }
    else if (methodCall.interface == "org.mpris.MediaPlayer2.Player") {
      switch (methodCall.name) {
        case "Next":
          await audioManager.skipToNext();
          return DBusMethodSuccessResponse();
        case "Previous":
          await audioManager.skipToPrevious();
          return DBusMethodSuccessResponse();
        case "Pause":
          await audioManager.pause();
          return DBusMethodSuccessResponse();
        case "PlayPause":
          await audioManager.playPause();
          return DBusMethodSuccessResponse();
        case "Stop":
          await audioManager.stop();
          return DBusMethodSuccessResponse();
        case "Play":
          await audioManager.play();
          return DBusMethodSuccessResponse();
        case "Seek":
        {
          final int offset = methodCall.values[0].asInt64();
          final currentPosition = audioManager.position;
          final newPosition = currentPosition + Duration(microseconds: offset);
          await audioManager.seek(newPosition);
          return DBusMethodSuccessResponse();
        }
        case "SetPosition":
        {
          final DBusObjectPath trackIdPath = methodCall.values[0].asObjectPath();
          final int position = methodCall.values[1].asInt64();
          final currentMediaItem = audioManager.getCurrentMediaItem();
          if (currentMediaItem != null && currentMediaItem.id == (trackIdPath.value.split("/").last)) {
            await audioManager.seek(Duration(microseconds: position));
            return DBusMethodSuccessResponse();
          } else {
            return DBusMethodErrorResponse("Track ID does not match current track.");
          }
        }
      }
    }

    return DBusMethodErrorResponse.unknownMethod();
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    log("DBus: GetProperty called: $interface.$name");
    if (interface == "org.mpris.MediaPlayer2") {
      switch (name) {
        case "CanQuit":
          return DBusGetPropertyResponse(DBusBoolean(false));
        case "CanRaise":
          return DBusGetPropertyResponse(DBusBoolean(false));
        case "HasTrackList":
          return DBusGetPropertyResponse(DBusBoolean(false));
        case "Identity":
          return DBusGetPropertyResponse(DBusString("vibin"));
        case "DesktopEntry":
          return DBusGetPropertyResponse(DBusString("vibin"));
        case "SupportedUriSchemes":
          return DBusGetPropertyResponse(DBusArray.string(["file"]));
        case "SupportedMimeTypes":
          return DBusGetPropertyResponse(DBusArray.string(["audio/mpeg", "audio/flac", "audio/wav", "audio/ogg", "application/ogg", "audio/aac"]));
      }
    }

    else if (interface == "org.mpris.MediaPlayer2.Player") {
      switch (name) {
        case "PlaybackStatus":
          return DBusGetPropertyResponse(DBusString(audioManager.isPlaying ? "Playing" : "Paused"));
        case "LoopStatus":
          return DBusGetPropertyResponse(DBusString(fromLoopMode(audioManager.loopMode)));
        case "Rate":
          return DBusGetPropertyResponse(DBusDouble(audioManager.speed));
        case "Shuffle":
          return DBusGetPropertyResponse(DBusBoolean(audioManager.isShuffling));
        case "Metadata":
          return DBusGetPropertyResponse(getCurrentTrackMetadata());
        case "Volume":
          return DBusGetPropertyResponse(DBusDouble(audioManager.volume));
        case "Position":
          return DBusGetPropertyResponse(DBusInt64(audioManager.position.inMicroseconds));
        case "MinimumRate":
          return DBusGetPropertyResponse(DBusDouble(0.25));
        case "MaximumRate":
          return DBusGetPropertyResponse(DBusDouble(2.0));
        case "CanGoNext":
          return DBusGetPropertyResponse(DBusBoolean(audioManager.hasNext));
        case "CanGoPrevious":
          return DBusGetPropertyResponse(DBusBoolean(audioManager.hasPrevious));
        case "CanPlay":
        case "CanPause":
        case "CanSeek":
        case "CanControl":
          return DBusGetPropertyResponse(DBusBoolean(true));
      }
    }

    return DBusGetPropertyResponse(DBusVariant(DBusString("")));
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async {
    log("DBus: SetProperty called: $interface.$name to value: $value");
    if (interface == "org.mpris.MediaPlayer2.Player") {
      switch (name) {
        case "LoopStatus":
          final loopStatus = value.asString();
          switch (loopStatus) {
            case "None":
              audioManager.loopMode = LoopMode.off;
              return DBusMethodSuccessResponse();
            case "Track":
              audioManager.loopMode = LoopMode.one;
              return DBusMethodSuccessResponse();
            case "Playlist":
              audioManager.loopMode = LoopMode.all;
              return DBusMethodSuccessResponse();
            default:
              return DBusMethodErrorResponse("Invalid LoopStatus value.");
          }
        case "Rate":
          final rate = value.asDouble();
          audioManager.speed = rate;
          return DBusMethodSuccessResponse();
        case "Shuffle":
          final shuffle = value.asBoolean();
          audioManager.isShuffling = shuffle;
          return DBusMethodSuccessResponse();
        case "Volume":
          final volume = value.asDouble();
          audioManager.volume = volume;
          return DBusMethodSuccessResponse();
      }
    }
    return Future.value(DBusMethodErrorResponse.unknownProperty());
  }

  DBusDict getCurrentTrackMetadata() {
    final currentMediaItem = audioManager.getCurrentMediaItem();
    if (currentMediaItem != null) {
      return DBusDict.stringVariant({
        "mpris:trackid": DBusObjectPath("/org/mpris/MediaPlayer2/Track/${currentMediaItem.id}"),
        "mpris:length": DBusInt64(audioManager.audioPlayer.duration?.inMicroseconds ?? 0),
        "mpris:artUrl": DBusString(currentMediaItem.artUri.toString()),
        "mpris:album": DBusString(currentMediaItem.album ?? ""),
        "mpris:artist": DBusArray.string(currentMediaItem.artist?.split(", ") ?? []),
        "mpris:title": DBusString(currentMediaItem.title),
        "xesam:title": DBusString(currentMediaItem.title),
        "xesam:artist": DBusArray.string(currentMediaItem.artist?.split(", ") ?? []),
        "xesam:album": DBusString(currentMediaItem.album ?? ""),
      });
    } else {
      return DBusDict.stringVariant({
        "mpris:trackid": DBusObjectPath("/org/mpris/MediaPlayer2/Track/0"),
        "mpris:length": DBusInt64(0),
        "mpris:artUrl": DBusString(""),
        "xesam:title": DBusString("Idle"),
        "xesam:artist": DBusArray.string(["Vibin"]),
        "xesam:album": DBusString(""),
      });
    }
  }

  void subscribeToAudioPlayer() {
    audioManager.audioPlayer.currentIndexStream.listen((_) {
      emitPropertiesChanged("org.mpris.MediaPlayer2.Player", changedProperties: {
        "Metadata": getCurrentTrackMetadata(),
        "Position": DBusInt64(audioManager.position.inMicroseconds),
      });
    });
    audioManager.audioPlayer.playingStream.listen((playing) {
      emitPropertiesChanged("org.mpris.MediaPlayer2.Player", changedProperties: {
        "PlaybackStatus": DBusString(playing ? "Playing" : "Paused"),
      });
    });
    audioManager.audioPlayer.shuffleModeEnabledStream.listen((shuffle) {
      emitPropertiesChanged("org.mpris.MediaPlayer2.Player", changedProperties: {
        "Shuffle": DBusBoolean(shuffle),
      });
    });
    audioManager.audioPlayer.loopModeStream.listen((loopMode) {
      emitPropertiesChanged("org.mpris.MediaPlayer2.Player", changedProperties: {
        "LoopStatus": DBusString(fromLoopMode(loopMode)),
      });
    });
    audioManager.audioPlayer.positionStream.listen((position) {
      emitPropertiesChanged("org.mpris.MediaPlayer2.Player", changedProperties: {
        "Position": DBusInt64(position.inMicroseconds),
      });
    });
    audioManager.audioPlayer.speedStream.listen((rate) {
      emitPropertiesChanged("org.mpris.MediaPlayer2.Player", changedProperties: {
        "Rate": DBusDouble(rate),
      });
    });
    audioManager.audioPlayer.volumeStream.listen((volume) {
      emitPropertiesChanged("org.mpris.MediaPlayer2.Player", changedProperties: {
        "Volume": DBusDouble(volume),
      });
    });
  }

  String fromLoopMode(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return "None";
      case LoopMode.all:
        return "Playlist";
      case LoopMode.one:
        return "Track";
    }
  }
}