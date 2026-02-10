import 'package:api/src/model/model.dart';

class ExportHistoryModel {
  final String message;
  final String docType;
  final String docName;
  final String createdAt;
  final UserModel user;

  ExportHistoryModel({
    required this.message,
    required this.docType,
    required this.docName,
    required this.createdAt,
    required this.user,
  });

  factory ExportHistoryModel.fromJson(Map<String, dynamic> json) {
    return ExportHistoryModel(
      message: json['message'],
      docType: json['docType'],
      docName: json['docName'],
      createdAt: json['createdAt'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'docType': docType,
      'docName': docName,
      'createdAt': createdAt,
      'user': user.toJson(),
    };
  }
}
