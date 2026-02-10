/// User 모델
///
/// - [isMarketingAgree] 마케팅 동의 여부
/// - [isPersonalInfoAgree] 사용자 정보 활용 동의 여부
/// - [provider] 로그인 타입: ara, ara_ebook, kakao, naver, naver_works, brity_works, google, mois
/// - [environment] private, public
/// - [customer] ara mois gov, msit, mdfs
/// - [shareId] 공유 ID
class UserModel {
  final String? userId;
  final String? displayName;
  final String? email;
  final String? profileImage;
  final bool? isEditable;
  final bool? isOwner;
  final bool? isMarketingAgree;
  final bool? isPersonalInfoAgree;
  final String? provider;
  final String? environment;
  final String? customer;
  final String? shareId;

  UserModel({
    this.userId,
    this.displayName,
    this.email,
    this.profileImage = 'defaultProfileImage.png',
    this.isEditable,
    this.isOwner,
    this.isMarketingAgree,
    this.isPersonalInfoAgree,
    this.provider,
    this.environment,
    this.customer,
    this.shareId,
  });

  // JSON으로부터 User 객체 생성
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String?,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
      isEditable: json['isEditable'] as bool?,
      isOwner: json['isOwner'] as bool?,
      isMarketingAgree: json['isMarketingAgree'] as bool?,
      isPersonalInfoAgree: json['isPersonalInfoAgree'] as bool?,
      provider: json['provider'] as String?,
      environment: json['environment'] as String?,
      customer: json['customer'] as String?,
      shareId: json['shareId'] as String?,
    );
  }

  // User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'profileImage': profileImage,
      'isEditable': isEditable,
      'isOwner': isOwner,
      'isMarketingAgree': isMarketingAgree,
      'isPersonalInfoAgree': isPersonalInfoAgree,
      'provider': provider,
      'environment': environment,
      'customer': customer,
      'shareId': shareId,
    };
  }

  // 객체 복사본 생성 (데이터 갱신 시 유용)
  UserModel copyWith({
    String? userId,
    String? displayName,
    String? email,
    String? profileImage,
    bool? isEditable,
    bool? isOwner,
    bool? isMarketingAgree,
    bool? isPersonalInfoAgree,
    String? provider,
    String? environment,
    String? customer,
    String? shareId,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      isEditable: isEditable ?? this.isEditable,
      isOwner: isOwner ?? this.isOwner,
      isMarketingAgree: isMarketingAgree ?? this.isMarketingAgree,
      isPersonalInfoAgree: isPersonalInfoAgree ?? this.isPersonalInfoAgree,
      provider: provider ?? this.provider,
      environment: environment ?? this.environment,
      customer: customer ?? this.customer,
      shareId: shareId ?? this.shareId,
    );
  }
}
