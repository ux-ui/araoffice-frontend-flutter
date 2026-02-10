import 'dart:ui';

enum LanguageType {
  korean,
  english,
  indonesia;

  String get name {
    switch (this) {
      case LanguageType.korean:
        return 'Korean';
      case LanguageType.english:
        return 'English';
      case LanguageType.indonesia:
        return 'Indonesia';
    }
  }

  Locale get locale {
    switch (this) {
      case LanguageType.korean:
        return const Locale('ko', 'KR');
      case LanguageType.english:
        return const Locale('en', 'US');
      case LanguageType.indonesia:
        return const Locale('id', 'ID');
    }
  }
}
