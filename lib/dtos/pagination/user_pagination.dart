import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/user/user.dart';

@JsonSerializable()
class UserPagination {

  final List<User> items;
  final int total;
  final int pageSize;
  final int currentPage;

  UserPagination({
    required this.items,
    required this.total,
    required this.pageSize,
    required this.currentPage,
  });

  factory UserPagination.fromJson(Map<String, dynamic> json) {
    return UserPagination(
      items: (json['items'] as List<dynamic>)
          .map((userJson) => User.fromJson(userJson))
          .toList(),
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
      total: json['total'],
    );
  }
}