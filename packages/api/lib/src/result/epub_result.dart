import 'package:api/api.dart';
import 'package:api/src/result/base_result.dart';
import 'package:author_editor/data/vulcan_epub_data.dart';

import '../model/utill/json_parser.dart';

class EpubResult extends BaseResult {
  final VulcanEpubData? epubInfo;

  EpubResult({
    required super.statusCode,
    super.message,
    this.epubInfo,
  });

  factory EpubResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return EpubResult(
        message: json['message'] as String,
        statusCode: json['statusCode'] as int?, // statusCode로 변경
        epubInfo: data['epubInfo'] != null
            ? VulcanEpubData.fromJson(data['epubInfo'] as Map<String, dynamic>)
            : null,
      );
    } else {
      return EpubResult(
        message: json['message'] as String,
        statusCode: json['statusCode'] as int?,
        epubInfo: null,
      );
    }
  }

  factory EpubResult.fromApiResponseJson(ApiResponse response) {
    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final parser = JsonParser(data);
        return EpubResult(
          message: response.message,
          statusCode: response.statusCode,
          epubInfo: parser.parseOptionalObject(
            'epubInfo',
            (json) => VulcanEpubData.fromJson(json),
          ),
        );
      } else {
        return EpubResult(
          message: response.message,
          statusCode: response.statusCode,
          epubInfo: null,
        );
      }
    } catch (e) {
      throw FormatException(
          'Failed to parse ProjectFolderResult: ${e.toString()}');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': {
        'epubInfo': epubInfo?.toJson(),
      },
    };
  }
}
