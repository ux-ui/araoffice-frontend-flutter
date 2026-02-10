import 'package:get/get.dart';

enum UlOlType {
  none('none'),
  ul('ul'), // 채워진 원
  ol('ol'); // 빈 원

  final String translationKey;
  const UlOlType(this.translationKey);

  // 번역된 이름을 가져오는 getter
  String get name => translationKey.tr;

  // factory constructor 방식
  factory UlOlType.fromString(String tag) {
    return UlOlType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => UlOlType.none, // 기본값 지정 필요
    );
  }

  // translationKey 값으로 UlOlType을 찾는 함수
  factory UlOlType.fromTranslationKey(String key) {
    return UlOlType.values.firstWhere(
      (type) => type.translationKey == key,
      orElse: () => UlOlType.none, // 일치하는 값이 없으면 none 반환
    );
  }
}
