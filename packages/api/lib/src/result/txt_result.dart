import 'package:api/api.dart';
import 'package:api/src/result/base_result.dart';
import 'package:author_editor/data/vulcan_txt_data.dart';

import '../model/utill/json_parser.dart';

class TxtResult extends BaseResult {
  final VulcanTxtData? txtInfo;

  TxtResult({
    required super.statusCode,
    super.message,
    this.txtInfo,
  });

  factory TxtResult.fromJson(Map<String, dynamic> json) {
    return TxtResult(
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
      txtInfo: json['txtInfo'] != null
          ? VulcanTxtData.fromJson(json['txtInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  factory TxtResult.fromApiResponseJson(ApiResponse response) {
    try {
      // response.data가 직접 TxtExportResponse 구조일 경우
      if (response.data is Map<String, dynamic>) {
        return TxtResult.fromJson(response.data as Map<String, dynamic>);
      }
      
      // 기존 JsonParser 방식
      final parser = JsonParser(response.data);
      return TxtResult(
        message: response.message,
        statusCode: response.statusCode,
        txtInfo: parser.parseOptionalObject(
          'txtInfo',
          (json) => VulcanTxtData.fromJson(json),
        ),
      );
    } catch (e) {
      throw FormatException(
          'Failed to parse TxtResult: ${e.toString()}');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'txtInfo': txtInfo?.toJson(),
    };
  }
}
