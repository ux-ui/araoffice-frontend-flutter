/// 닉네임 생성 응답 모델
class NicknameResponse {
  final int statusCode;
  final String message;
  final String nickname;

  NicknameResponse({
    required this.statusCode,
    required this.message,
    required this.nickname,
  });

  factory NicknameResponse.fromJson(Map<String, dynamic> json) {
    return NicknameResponse(
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'message': message,
        'nickname': nickname,
      };
}

/// 닉네임 중복 확인 응답 모델
class NicknameDuplicateCheckResponse {
  final int statusCode;
  final String message;
  final bool isDuplicate;
  final String value;

  NicknameDuplicateCheckResponse({
    required this.statusCode,
    required this.message,
    required this.isDuplicate,
    required this.value,
  });

  factory NicknameDuplicateCheckResponse.fromJson(Map<String, dynamic> json) {
    return NicknameDuplicateCheckResponse(
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message'] as String? ?? '',
      isDuplicate: json['isDuplicate'] as bool? ?? false,
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'message': message,
        'isDuplicate': isDuplicate,
        'value': value,
      };
}

/// 닉네임 후보 목록 응답 모델
class NicknameCandidatesResponse {
  final int statusCode;
  final String message;
  final List<String> candidates;

  NicknameCandidatesResponse({
    required this.statusCode,
    required this.message,
    required this.candidates,
  });

  factory NicknameCandidatesResponse.fromJson(Map<String, dynamic> json) {
    return NicknameCandidatesResponse(
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message'] as String? ?? '',
      candidates: (json['candidates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'message': message,
        'candidates': candidates,
      };
}

