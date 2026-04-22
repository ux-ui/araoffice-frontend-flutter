typedef OnOpenCallback = void Function(int result);

typedef OnConvertCallback = void Function(
  int result,
  String fileName,
  int page,
  int total,
  String content,
);

mixin IframeMixin {
  /// 안전한 문자열 변환을 위한 헬퍼 함수
  String? safeStringConvert(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }
}
