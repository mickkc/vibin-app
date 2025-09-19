import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/color_scheme.dart';

@JsonSerializable()
class Image {
  final String originalUrl;
  final String smallUrl;
  final String? largeUrl;
  final ColorScheme? colorScheme;

  Image({
    required this.originalUrl,
    required this.smallUrl,
    this.largeUrl,
    this.colorScheme,
  });

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      originalUrl: json['originalUrl'],
      smallUrl: json['smallUrl'],
      largeUrl: json['largeUrl'],
      colorScheme: json['colorScheme'] != null
          ? ColorScheme.fromJson(json['colorScheme'])
          : null,
    );
  }
}