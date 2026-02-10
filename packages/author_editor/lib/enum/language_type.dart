import 'package:get/get.dart';

enum LanguageType {
  ko('ko'),
  en('en');

  final String translationKey;
  const LanguageType(this.translationKey);

  // 번역된 이름을 가져오는 getter
  String get name => translationKey.tr;
}

extension LanguageTypeExtension on LanguageType {
  static LanguageType? fromString(String tag) {
    try {
      return LanguageType.values.firstWhere(
        (type) => type.name == tag,
      );
    } catch (_) {
      return null;
    }
  }
}
