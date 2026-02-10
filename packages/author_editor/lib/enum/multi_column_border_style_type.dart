import 'package:get/get.dart';

enum BorderStyleType {
  none('border_style_none'),
  solid('solid'),
  dotted('dotted'),
  dashed('dashed'),
  double('double'),
  groove('groove'),
  ridge('ridge'),
  inset('inset'),
  outset('outset');

  final String translationKey;
  const BorderStyleType(this.translationKey);

  String get name => translationKey.tr;
  String get optionName => toString().split('.').last;

  factory BorderStyleType.fromString(String tag) {
    return BorderStyleType.values.firstWhere(
      (type) => type.optionName == tag,
      orElse: () => BorderStyleType.none, // 기본값 '선 없음'으로 설정
    );
  }
}
