// 공유 유형
enum ShareType {
  userId('userId'),
  email('email'),
  shareId('shareId');

  final String name;
  const ShareType(this.name);
}

extension ShareTypeExtension on ShareType {
  static ShareType fromString(String tag) {
    try {
      return ShareType.values.firstWhere(
        (type) => type.name == tag,
      );
    } catch (_) {
      return ShareType.userId;
    }
  }
}
