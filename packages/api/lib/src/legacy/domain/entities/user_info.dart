import 'package:api/src/legacy/domain/entities/base_entity.dart';

class UserInfo extends BaseEntity {
  final int id;
  final String name;
  final String? email;
  final String? profileImage;
  final String accessToken;
  final String refreshToken;
  final String? permission;

  UserInfo({
    required this.id,
    required this.name,
    required this.accessToken,
    required this.refreshToken,
    this.email,
    this.profileImage,
    this.permission,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      permission: json['permission'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'permission': permission,
    };
  }
}
