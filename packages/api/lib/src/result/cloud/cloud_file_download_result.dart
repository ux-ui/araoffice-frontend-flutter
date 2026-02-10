import 'package:api/src/model/cloud/cloud_file_model.dart';
import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';
import 'package:flutter/foundation.dart';

class CloudFileDownloadResult extends BaseResult {
  final CloudFileDownloadUrlResponse? downloadInfo;

  CloudFileDownloadResult({
    required super.statusCode,
    super.message,
    this.downloadInfo,
  });

  factory CloudFileDownloadResult.fromJson(Map<String, dynamic> json) {
    try {
      final data = json.requireObject('data', (json) => json);

      return CloudFileDownloadResult(
        message: json.requireString('message'),
        statusCode: json.optionalInt('statusCode'),
        downloadInfo: data.optionalObject(
          'downloadInfo',
          (json) => CloudFileDownloadUrlResponse.fromJson(json),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing CloudFileDownloadResult:');
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
      'data': {
        'downloadInfo': downloadInfo?.toJson(),
      },
    };
  }
}
