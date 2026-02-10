import 'package:get/get.dart';

enum PublishType {
  test('test_publish'),
  official('official_publish');

  final String translationKey;
  const PublishType(this.translationKey);

  // 번역된 이름을 가져오는 getter
  String get name => translationKey.tr;

  // java 명으로 사용할 수 있는 형태
  String get javaEnum =>
      translationKey.replaceAll('_publish', '').toUpperCase();

  // factory constructor 방식
  factory PublishType.fromString(String tag) {
    return PublishType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => PublishType.test, // 기본값 지정 필요
    );
  }
}
