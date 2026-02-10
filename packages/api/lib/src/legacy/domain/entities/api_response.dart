class ApiResponse {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;

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

  bool get isSuccessful => statusCode == 200;
  bool get isError => !isSuccessful || data == null;
}