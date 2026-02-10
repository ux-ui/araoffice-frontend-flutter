import 'package:get/get.dart';

enum OlStyleType {
  decimal('decimal'), // 1, 2, 3...
  decimalLeadingZero('decimal-leading-zero'), // 01, 02, 03...
  lowerRoman('lower-roman'), // i, ii, iii, iv...
  upperRoman('upper-roman'), // I, II, III, IV...
  lowerAlpha('lower-alpha'), // a, b, c...
  upperAlpha('upper-alpha'), // A, B, C...
  none('none'); // 기호 없음

  final String translationKey;
  const OlStyleType(this.translationKey);

  // 번역된 이름을 가져오는 getter
  String get name => translationKey.tr;

  // factory constructor 방식
  factory OlStyleType.fromString(String tag) {
    return OlStyleType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => OlStyleType.none, // 기본값 지정 필요
    );
  }

  // translationKey 값으로 OlStyleType을 찾는 함수
  factory OlStyleType.fromTranslationKey(String key) {
    return OlStyleType.values.firstWhere(
      (type) => type.translationKey == key,
      orElse: () => OlStyleType.none, // 일치하는 값이 없으면 none 반환
    );
  }
}
