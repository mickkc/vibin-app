import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/user/user.dart';

@JsonSerializable()
class LoginResult {
  final bool success;
  final String token;
  final User user;
  final List<String> permissions;

  LoginResult({
    required this.success,
    required this.token,
    required this.user,
    required this.permissions,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      success: json['success'],
      token: json['token'],
      user: User.fromJson(json['user']),
      permissions: List<String>.from(json['permissions']),
    );
  }
}