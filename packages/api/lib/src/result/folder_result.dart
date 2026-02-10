import 'package:api/api.dart';
import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';
import 'package:flutter/foundation.dart';

class FolderResult extends BaseResult {
  final FolderModel? folder;

  FolderResult({
    required super.statusCode,
    super.message,
    this.folder,
  });

  factory FolderResult.fromJson(Map<String, dynamic> json) {
    try {
      final data = json.requireObject('data', (json) => json);
      String message = '';

      if (json['statusCode'] == 400) {
        message = data['data'] as String;
        return FolderResult(
          message: message,
          statusCode: json.optionalInt('statusCode'),
        );
      } else {
        message = json['message'] as String;
        return FolderResult(
          message: message,
          statusCode: json.optionalInt('statusCode'),
          folder: data.requireObject(
            'folder',
            (json) => FolderModel.fromJson(json),
          ),
        );
      }

      // return FolderResult(
      //   message: message,
      //   statusCode: json.optionalInt('statusCode'),
      //   folder: data.requireObject(
      //     'folder',
      //     (json) => FolderModel.fromJson(json),
      //   ),
      // );
    } catch (e, stackTrace) {
      debugPrint('Error parsing FolderResult:');
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
      'statusCode': statusCode,
      'folder': folder?.toJson(),
    };
  }
}
