import 'package:get/get.dart';

// 문자열에서 %로 둘러싸인 부분을 찾아 다국어 처리하는 함수
String processTranslation(String text) {
  // 정규 표현식을 사용하여 %로 둘러싸인 모든 부분 찾기
  final regex = RegExp(r'%([^%]+)%');
  final matches = regex.allMatches(text);

  // 매치된 부분이 없으면 원래 문자열 반환
  if (matches.isEmpty) {
    return text;
  }

  // 매치된 부분들을 번역하여 치환
  String result = text;
  for (var match in matches) {
    final key = match.group(1);
    if (key != null) {
      final translated = key.tr;
      result = result.replaceFirst('%$key%', translated);
    }
  }

  return result;
}

// 페이지 번호를 추적하기 위한 클래스
class Counter {
  int value;
  Counter(this.value);
}
