import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/user/user.dart';

@JsonSerializable()
class Playlist {
  final int id;
  final String name;
  final String description;
  final bool public;
  final List<User> collaborators;
  final String? vibedef;
  final User owner;
  final int createdAt;
  final int? updatedAt;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.public,
    required this.collaborators,
    this.vibedef,
    required this.owner,
    required this.createdAt,
    this.updatedAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      public: json['public'],
      collaborators: (json['collaborators'] as List<dynamic>)
          .map((userJson) => User.fromJson(userJson))
          .toList(),
      vibedef: json['vibedef'],
      owner: User.fromJson(json['owner']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}