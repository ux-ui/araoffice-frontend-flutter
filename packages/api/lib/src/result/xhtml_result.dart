import 'package:api/api.dart';
import 'package:api/src/result/base_result.dart';
import 'package:author_editor/data/vulcan_xhtml_data.dart';

import '../model/utill/json_parser.dart';

class XhtmlResult extends BaseResult {
  final VulcanXhtmlData? xhtmlInfo;

  XhtmlResult({
    required super.statusCode,
    super.message,
    this.xhtmlInfo,
  });

  factory XhtmlResult.fromJson(Map<String, dynamic> json) {
    return XhtmlResult(
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
      xhtmlInfo: json['xhtmlInfo'] != null
          ? VulcanXhtmlData.fromJson(json['xhtmlInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  factory XhtmlResult.fromApiResponseJson(ApiResponse response) {
    try {
      // response.data가 직접 XhtmlExportResponse 구조일 경우
      if (response.data is Map<String, dynamic>) {
        return XhtmlResult.fromJson(response.data as Map<String, dynamic>);
      }
      
      // 기존 JsonParser 방식
      final parser = JsonParser(response.data);
      return XhtmlResult(
        message: response.message,
        statusCode: response.statusCode,
        xhtmlInfo: parser.parseOptionalObject(
          'xhtmlInfo',
          (json) => VulcanXhtmlData.fromJson(json),
        ),
      );
    } catch (e) {
      throw FormatException(
          'Failed to parse XhtmlResult: ${e.toString()}');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'xhtmlInfo': xhtmlInfo?.toJson(),
    };
  }
}
