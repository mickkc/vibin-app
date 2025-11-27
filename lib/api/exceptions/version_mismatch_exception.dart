class VersionMismatchException implements Exception {
  final String serverVersion;
  final String appVersion;

  VersionMismatchException({
    required this.serverVersion,
    required this.appVersion,
  });

  @override
  String toString() {
    return 'VersionMismatchException: Server version \'$serverVersion\' does not match app version \'$appVersion\'.';
  }
}
