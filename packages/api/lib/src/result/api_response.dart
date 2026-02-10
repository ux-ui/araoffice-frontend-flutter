import 'package:dio/dio.dart';

class ApiResponse {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ApiResponse(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }

  factory ApiResponse.fromResponse(Response response) {
    return ApiResponse(
      statusCode: response.statusCode ?? 500,
      message: response.statusMessage ?? '',
      data: response.data,
    );
  }

  bool get isSuccessful => statusCode == 200;
  bool get isError => !isSuccessful;

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data,
    };
  }
}
