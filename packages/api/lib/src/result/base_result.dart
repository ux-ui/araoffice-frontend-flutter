class BaseResult {
  final int? statusCode;
  final String? message;

  BaseResult({
    this.statusCode,
    this.message,
  });

  factory BaseResult.fromJson(Map<String, dynamic> json) {
    return BaseResult(
      statusCode: json['statusCode'] as int?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
    };
  }
}
