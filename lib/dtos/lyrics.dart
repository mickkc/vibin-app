
import 'color_scheme.dart';

class Lyrics {
  final String? lyrics;
  final ColorScheme? colorScheme;

  Lyrics({
    this.lyrics,
    this.colorScheme,
  });

  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      lyrics: json['lyrics'] as String?,
      colorScheme: json['colorScheme'] != null ? ColorScheme.fromJson(json['colorScheme']) : null
    );
  }
}