import 'package:get/get.dart';

enum TextAlignType {
  left('left'),
  center('center'),
  right('right'),
  justify('justify');

  final String translationKey;
  const TextAlignType(this.translationKey);

  // 번역된 이름을 가져오는 getter
  String get name => translationKey.tr;
}

extension TextAlignTypeExtension on TextAlignType {
  static TextAlignType? fromString(String tag) {
    // 빈 문자열이거나 null인 경우 left를 반환
    if (tag.isEmpty) {
      return TextAlignType.left;
    }

    try {
      return TextAlignType.values.firstWhere(
        (type) => type.name == tag,
      );
    } catch (_) {
      return null;
    }
  }
}
