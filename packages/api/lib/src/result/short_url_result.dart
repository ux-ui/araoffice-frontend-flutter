import 'package:api/api.dart';
import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';
import 'package:flutter/foundation.dart';

class ShortUrlResult extends BaseResult {
  final ShortUrlModel? shortUrl;

  ShortUrlResult({
    required super.statusCode,
    super.message,
    this.shortUrl,
  });

  factory ShortUrlResult.fromJson(Map<String, dynamic> json) {
    try {
      final data = json.requireObject('data', (json) => json);

      return ShortUrlResult(
        message: json.requireString('message'),
        statusCode: json.optionalInt('statusCode'), // statusCode로 변경
        shortUrl: data.requireObject(
          'shortUrl', // data 안에서 project를 찾도록 변경
          (json) => ShortUrlModel.fromJson(json),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing ProjectResult:');
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
      'data': {
        'shortUrl': shortUrl?.toJson(),
      },
    };
  }
}
