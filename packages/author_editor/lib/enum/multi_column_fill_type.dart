import 'package:get/get.dart';

enum MultiColumnFillType {
  auto('auto'),
  balance('balance');

  final String translationKey;
  const MultiColumnFillType(this.translationKey);

  // 번역된 이름을 가져오는 getter
  String get name => translationKey.tr;

  // CSS 클래스명으로 사용할 수 있는 형태
  String get optionName => toString().split('.').last;

  // factory constructor 방식
  factory MultiColumnFillType.fromString(String tag) {
    return MultiColumnFillType.values.firstWhere(
      (type) => type.optionName == tag,
      orElse: () => MultiColumnFillType.auto, // 기본값 지정 필요
    );
  }
}
