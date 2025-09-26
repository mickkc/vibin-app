class MediaTokenResponse {
  final String mediaToken;

  MediaTokenResponse({required this.mediaToken});

  factory MediaTokenResponse.fromJson(Map<String, dynamic> json) {
    return MediaTokenResponse(
      mediaToken: json['mediaToken'],
    );
  }
}