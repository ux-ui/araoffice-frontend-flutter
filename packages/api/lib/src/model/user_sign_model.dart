class UserSignUpModel {
  final String userId;
  final String displayName;
  final String password;
  final String passwordConfirm;
  final String email;
  final String? phone;
  final bool gender;
  final String birthDate;
  final bool isAdult;
  final bool isForeigner;
  final bool agreeTerms;
  final bool agreeMarketing;
  final bool agreePrivacy;

  UserSignUpModel({
    required this.userId,
    required this.displayName,
    required this.password,
    required this.passwordConfirm,
    required this.email,
    this.phone,
    required this.gender,
    required this.birthDate,
    required this.isAdult,
    required this.isForeigner,
    required this.agreeTerms,
    required this.agreeMarketing,
    required this.agreePrivacy,
  });
  factory UserSignUpModel.fromJson(Map<String, dynamic> json) =>
      UserSignUpModel(
        userId: json['userId'] as String,
        displayName: json['displayName'] as String,
        password: json['password'] as String,
        passwordConfirm: json['passwordConfirm'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        gender: json['gender'] as bool,
        birthDate: json['birthDate'] as String,
        isAdult: json['isAdult'] as bool,
        isForeigner: json['isForeigner'] as bool,
        agreeTerms: json['agreeTerms'] as bool,
        agreeMarketing: json['agreeMarketing'] as bool,
        agreePrivacy: json['agreePrivacy'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'email': email,
        'phone': phone,
        'gender': gender,
        'birthDate': birthDate,
        'isAdult': isAdult,
        'isForeigner': isForeigner,
        'agreeTerms': agreeTerms,
        'agreeMarketing': agreeMarketing,
        'agreePrivacy': agreePrivacy,
      };

  @override
  String toString() {
    return 'RegisterRequest('
        'userId: $userId, '
        'displayName: $displayName, '
        'password: $password, '
        'passwordConfirm: $passwordConfirm, '
        'email: $email, '
        'phone: $phone, '
        'gender: $gender, '
        'birthDate: $birthDate, '
        'isAdult: $isAdult, '
        'isForeigner: $isForeigner, '
        'agreeTerms: $agreeTerms, '
        'agreeMarketing: $agreeMarketing, '
        'agreePrivacy: $agreePrivacy)';
  }

  UserSignUpModel copyWith({
    String? userId,
    String? displayName,
    String? password,
    String? passwordConfirm,
    String? email,
    String? phone,
    bool? gender,
    String? birthDate,
    bool? isAdult,
    bool? isForeigner,
    bool? agreeTerms,
    bool? agreeMarketing,
    bool? agreePrivacy,
  }) {
    return UserSignUpModel(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      isAdult: isAdult ?? this.isAdult,
      isForeigner: isForeigner ?? this.isForeigner,
      agreeTerms: agreeTerms ?? this.agreeTerms,
      agreeMarketing: agreeMarketing ?? this.agreeMarketing,
      agreePrivacy: agreePrivacy ?? this.agreePrivacy,
    );
  }
}
