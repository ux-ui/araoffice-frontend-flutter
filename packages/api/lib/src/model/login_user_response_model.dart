class LoginUserResponse {
  final int statusCode;
  final String message;
  final String accessToken;
  final String provider;
  final String providerId;
  final String userId;

  LoginUserResponse({
    required this.statusCode,
    required this.message,
    required this.accessToken,
    required this.provider,
    required this.providerId,
    required this.userId,
  });

  factory LoginUserResponse.fromJson(Map<String, dynamic> json) {
    return LoginUserResponse(
      statusCode: json['statusCode'],
      message: json['message'] as String,
      accessToken: json['accessToken'] as String,
      provider: json['provider'] as String,
      providerId: json['providerId'] as String,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'accessToken': accessToken,
      'provider': provider,
      'providerId': providerId,
      'userId': userId,
    };
  }
}
