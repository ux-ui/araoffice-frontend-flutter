import 'package:get/get.dart';

enum UlStyleType {
  disc('disc'), // 채워진 원
  circle('circle'), // 빈 원
  square('square'), // 채워진 사각형
  none('none'); // 기호 없음

  final String translationKey;
  const UlStyleType(this.translationKey);

  // 번역된 이름을 가져오는 getter
  String get name => translationKey.tr;

  // factory constructor 방식
  factory UlStyleType.fromString(String tag) {
    return UlStyleType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => UlStyleType.none, // 기본값 지정 필요
    );
  }

  // translationKey 값으로 UlOlType을 찾는 함수
  factory UlStyleType.fromTranslationKey(String key) {
    return UlStyleType.values.firstWhere(
      (type) => type.translationKey == key,
      orElse: () => UlStyleType.none, // 일치하는 값이 없으면 none 반환
    );
  }
}
