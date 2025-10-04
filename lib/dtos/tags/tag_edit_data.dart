import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class TagEditData {
  final String? name;
  final String? description;
  final String? color;

  TagEditData({this.name, this.description, this.color});

  factory TagEditData.fromJson(Map<String, dynamic> json) {
    return TagEditData(
      name: json['name'],
      description: json['description'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': color,
    };
  }
}