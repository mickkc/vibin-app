import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class IdName {
  final int id;
  final String name;

  IdName({
    required this.id,
    required this.name,
  });

  factory IdName.fromJson(Map<String, dynamic> json) {
    return IdName(
      id: json['id'],
      name: json['name'],
    );
  }
}