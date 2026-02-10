class UserListInfo {
  final String userId;
  final String displayName;

  UserListInfo({
    required this.userId,
    required this.displayName,
  });

  factory UserListInfo.fromJson(Map<String, dynamic> json) {
    return UserListInfo(
      userId: json['id'] as String,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': userId,
        'displayName': displayName,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserListInfo &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}
