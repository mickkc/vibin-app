import 'dart:async';

class DiscordRPC {
  final isInitialized = false;
  final isConnected = false;
  final onDisconnected = FakeStream<DiscordDisconnectedEvent>();
  final onError = FakeStream<DiscordErrorEvent>();
  final onReady = FakeStream<DiscordReadyEvent>();

  static final isAvailable = false;

  Future<void> initialize(String id) async {}

  static void ensureSupported() {}

  Future<void> dispose() async {}

  Future<void> clearPresence() async {}
  Future<void> setPresence(DiscordPresence presence) async {}
}

class DiscordConnectionException extends Error {}

class DiscordDisconnectedEvent {
  final errorCode = 404;
  final message = "";

}

class DiscordErrorEvent {
  final errorCode = 404;
  final message = "";
}

class DiscordReadyEvent {
  final user = FakeUser();
}

class FakeUser {
  final username = "";
}

class FakeStream<T> {
  StreamSubscription<T> listen(Function(T) callback) {
    return FakeStreamSubscription<T>();
  }
}

class DiscordAsset {
  static DiscordAsset fromUrl(String url, {String? text}) {
    return DiscordAsset();
  }
  static DiscordAsset fromKey(String key, {String? text}) {
      return DiscordAsset();
  }
}

class DiscordTimestamps {
  static DiscordTimestamps range(DateTime from, DateTime to) {
    return DiscordTimestamps();
  }
}

enum DiscordActivityType {
  listening
}

class DiscordPresence {
  final DiscordActivityType? type;
  final String? state;
  final String? details;
  final DiscordStatusDisplayType? statusDisplayType;
  final DiscordAsset? largeAsset;
  final DiscordAsset? smallAsset;
  final DiscordTimestamps? timestamps;

  DiscordPresence({
    this.type,
    this.state,
    this.details,
    this.statusDisplayType,
    this.largeAsset,
    this.smallAsset,
    this.timestamps
  });


}

enum DiscordStatusDisplayType {
  name, state, details
}

class FakeStreamSubscription<T> implements StreamSubscription<T> {
  @override
  Future<E> asFuture<E>([E? futureValue]) {
    return Future.value(null);
  }

  @override
  Future<void> cancel() async {}

  @override
  bool get isPaused => false;

  @override
  void onData(void Function(T data)? handleData) {}

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void onError(Function? handleError) {}

  @override
  void pause([Future<void>? resumeSignal]) {}

  @override
  void resume() {}
}