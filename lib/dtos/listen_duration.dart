import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ListenDuration {
  final int duration;

  ListenDuration({
    required this.duration
  });

  factory ListenDuration.fromJson(Map<String, dynamic> json) {
    return ListenDuration(
      duration: json['duration'],
    );
  }
}