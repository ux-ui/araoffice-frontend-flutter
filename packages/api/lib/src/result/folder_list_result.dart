import 'package:api/src/model/model.dart';
import 'package:api/src/result/base_result.dart';
import 'package:flutter/foundation.dart';

class FolderListResult extends BaseResult {
  final List<FolderModel>? folders;

  FolderListResult({
    required super.statusCode,
    super.message,
    this.folders,
  });

  factory FolderListResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    try {
      return FolderListResult(
        message: json['message'] as String,
        statusCode: json['statusCode'] as int?, // statusCode로 변경
        folders: (data['folders'] as List<dynamic>?)
            ?.map((folder) =>
                FolderModel.fromJson(folder as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing FolderListModel:');
      debugPrint('JSON: $json');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode, // statusCode로 변경
      'folders': folders?.map((folder) => folder.toJson()).toList(),
    };
  }

  bool hasFolder(String id) =>
      folders?.any((folder) => folder.id == id) ?? false;
}
