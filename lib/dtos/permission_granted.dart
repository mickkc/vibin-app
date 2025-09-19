import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class PermissionGranted {
  final bool granted;

  PermissionGranted({required this.granted});

  factory PermissionGranted.fromJson(Map<String, dynamic> json) {
    return PermissionGranted(
      granted: json['granted'],
    );
  }
}