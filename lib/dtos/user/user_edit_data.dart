import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UserEditData {
  final String? username;
  final String? displayName;
  final String? email;
  final bool? isAdmin;
  final bool? isActive;
  final String? profilePictureUrl;
  final String? oldPassword;
  final String? password;

  UserEditData({
    this.username,
    this.displayName,
    this.email,
    this.isAdmin,
    this.isActive,
    this.profilePictureUrl,
    this.oldPassword,
    this.password,
  });

  factory UserEditData.fromJson(Map<String, dynamic> json) {
    return UserEditData(
      username: json['username'],
      displayName: json['displayName'],
      email: json['email'],
      isAdmin: json['isAdmin'],
      isActive: json['isActive'],
      profilePictureUrl: json['profilePictureUrl'],
      oldPassword: json['oldPassword'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'displayName': displayName,
      'email': email,
      'isAdmin': isAdmin,
      'isActive': isActive,
      'profilePictureUrl': profilePictureUrl,
      'oldPassword': oldPassword,
      'password': password,
    };
  }
}