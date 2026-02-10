import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:flutter/foundation.dart';

class ShortUrlModel {
  final String shortUrl;
  final String expiresAt;

  ShortUrlModel({
    required this.shortUrl,
    required this.expiresAt,
  });

  factory ShortUrlModel.fromJson(Map<String, dynamic> json) {
    try {
      return ShortUrlModel(
        shortUrl: json.requireString('shortUrl'),
        expiresAt: json.requireString('expiresAt'),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing ProjectModel:');
      debugPrint('JSON: $json');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'shortUrl': shortUrl,
      'expiresAt': expiresAt,
    };
  }
}
