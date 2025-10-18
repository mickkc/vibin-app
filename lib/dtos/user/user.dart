import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/image.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String? displayName;
  final String description;
  final String? email;
  final bool isActive;
  final bool isAdmin;
  final int? lastLogin;
  final Image? profilePicture;
  final int createdAt;
  final int? updatedAt;

  User(
    this.id,
    this.username,
    this.displayName,
    this.description,
    this.email,
    this.isActive,
    this.isAdmin,
    this.lastLogin,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
  );

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['username'],
      json['displayName'],
      json['description'],
      json['email'],
      json['isActive'],
      json['isAdmin'],
      json['lastLogin'],
      json['profilePicture'] != null
          ? Image.fromJson(json['profilePicture'])
          : null,
      json['createdAt'],
      json['updatedAt'],
    );
  }
}
