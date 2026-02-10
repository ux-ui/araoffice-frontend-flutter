class VulcanUserData {
  final String? displayName;
  final String? email;
  final String? profileImage;
  final String? userId;
  final bool? isOwner;

  VulcanUserData({
    this.displayName,
    this.email,
    this.profileImage,
    this.userId,
    this.isOwner,
  });

  factory VulcanUserData.fromJson(Map<String, dynamic> json) {
    return VulcanUserData(
      displayName: json['displayName'],
      email: json['email'],
      profileImage: json['profileImage'],
      userId: json['userId'],
      isOwner: json['isOwner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'profileImage': profileImage,
      'userId': userId,
      'isOwner': isOwner,
    };
  }

  VulcanUserData copyWith({
    String? displayName,
    String? email,
    String? profileImage,
    String? userId,
    bool? isOwner,
  }) {
    return VulcanUserData(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      userId: userId ?? this.userId,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  @override
  String toString() {
    return 'VulcanUserData(displayName: $displayName, email: $email, profileImage: $profileImage, userId: $userId, isOwner: $isOwner)';
  }
}
