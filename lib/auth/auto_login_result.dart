class AutoLoginResult {
  final bool successful;
  final String message;
  final bool configured;

  const AutoLoginResult(this.successful, this.message, this.configured);

  static const AutoLoginResult success = AutoLoginResult(true, "Auto-login successful", true);

  bool isError() => !successful &&configured;
}