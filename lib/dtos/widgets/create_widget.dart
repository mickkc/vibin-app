import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class CreateWidget {
  final List<String> types;
  final String? bgColor;
  final String? fgColor;
  final String? accentColor;

  CreateWidget({
    required this.types,
    this.bgColor,
    this.fgColor,
    this.accentColor,
  });

  factory CreateWidget.fromJson(Map<String, dynamic> json) {
    return CreateWidget(
      types: List<String>.from(json['types'] as List),
      bgColor: json['bgColor'] as String?,
      fgColor: json['fgColor'] as String?,
      accentColor: json['accentColor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'types': types,
      'bgColor': bgColor,
      'fgColor': fgColor,
      'accentColor': accentColor,
    };
  }
}