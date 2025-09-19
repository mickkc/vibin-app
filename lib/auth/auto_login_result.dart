class AutoLoginResult {
  final bool successful;
  final String message;
  final bool configured;

  const AutoLoginResult._(this.successful, this.message, this.configured);
  const AutoLoginResult(this.successful, this.message, this.configured);

  static const AutoLoginResult success = AutoLoginResult._(true, "Auto-login successful", true);

  bool isError() => !successful &&configured;
}