class AutoLoginResult {
  final bool successful;
  final Object? error;
  final bool configured;

  const AutoLoginResult(this.successful, this.error, this.configured);

  static const AutoLoginResult success = AutoLoginResult(true, null, true);

  bool isError() => !successful && configured;
}