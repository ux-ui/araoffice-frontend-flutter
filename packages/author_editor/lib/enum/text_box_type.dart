import 'package:get/get.dart';

enum TextBoxType {
  defaultType('default'),
  center('center'),
  autofit('autofit'),
  vertical('vertical'),
  verticalCenter('verticalCenter'),
  verticalAutofit('verticalAutofit');

  final String translationKey;
  const TextBoxType(this.translationKey);

  // 번역된 이름을 가져오는 getter
  String get name => translationKey.tr;
  String get value => translationKey;

  // factory constructor 방식
  factory TextBoxType.fromString(String tag) {
    return TextBoxType.values.firstWhere(
      (type) => type.value == tag,
      orElse: () => TextBoxType.defaultType, // 기본값 지정 필요
    );
  }
}
