class FavoriteCheckResponse {
  final bool isFavorite;
  final int? place;

  FavoriteCheckResponse({required this.isFavorite, this.place});

  factory FavoriteCheckResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteCheckResponse(
      isFavorite: json['isFavorite'],
      place: json['place'],
    );
  }
}