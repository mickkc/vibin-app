class TotpStatus {
  final String status;
  final String? secret;

  TotpStatus({
    required this.status,
    this.secret,
  });

  factory TotpStatus.fromJson(Map<String, dynamic> json) {
    return TotpStatus(
      status: json['status'],
      secret: json['secret']
    );
  }
}