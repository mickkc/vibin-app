import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/color_scheme.dart';

@JsonSerializable()
class Image {
  final String smallUrl;
  final String? mediumUrl;
  final String? largeUrl;
  final ColorScheme? colorScheme;

  Image({
    required this.smallUrl,
    this.mediumUrl,
    this.largeUrl,
    this.colorScheme,
  });

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      smallUrl: json['smallUrl'],
      mediumUrl: json['mediumUrl'],
      largeUrl: json['largeUrl'],
      colorScheme: json['colorScheme'] != null
          ? ColorScheme.fromJson(json['colorScheme'])
          : null,
    );
  }
}