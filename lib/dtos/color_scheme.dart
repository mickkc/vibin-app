import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ColorScheme {
  final String primary;
  final String light;
  final String dark;

  ColorScheme({
    required this.primary,
    required this.light,
    required this.dark,
  });

  factory ColorScheme.fromJson(Map<String, dynamic> json) {
    return ColorScheme(
      primary: json['primary'],
      light: json['light'],
      dark: json['dark'],
    );
  }
}