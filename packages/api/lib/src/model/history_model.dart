import 'package:api/src/model/model.dart';

class HistoryModel {
  final String message;
  final String createdAt;
  final UserModel user;

  HistoryModel({
    required this.message,
    required this.createdAt,
    required this.user,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      message: json['message'],
      createdAt: json['createdAt'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'createdAt': createdAt,
      'user': user.toJson(),
    };
  }
}
