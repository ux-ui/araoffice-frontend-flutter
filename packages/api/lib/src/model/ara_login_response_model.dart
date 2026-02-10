class AraLoginResponse {
  final int statusCode;
  final String message;
  final UserData data;
  final bool rememberMe;

  AraLoginResponse({
    required this.statusCode,
    required this.message,
    required this.data,
    required this.rememberMe,
  });

  factory AraLoginResponse.fromJson(Map<String, dynamic> json) {
    return AraLoginResponse(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: UserData.fromJson(json['data'] as Map<String, dynamic>),
      rememberMe: json['rememberMe'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data.toJson(),
      'rememberMe': rememberMe,
    };
  }
}

class UserData {
  final String userName;
  final String email;
  final String userId;
  final String uuid;
  final String birthDate;
  final String gender;
  final String phoneNumber;

  UserData({
    required this.userName,
    required this.email,
    required this.userId,
    required this.uuid,
    required this.birthDate,
    required this.gender,
    required this.phoneNumber,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userName: json['USER_NAME'] as String,
      email: json['email'] as String,
      userId: json['USER_ID'] as String,
      uuid: json['UUID'] as String,
      birthDate: json['birth'] as String,
      gender: json['gender'] as String,
      phoneNumber: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'email': email,
      'userId': userId,
      'uuid': uuid,
      'birthDate': birthDate,
      'gender': gender,
      'phoneNumber': phoneNumber,
    };
  }
}
