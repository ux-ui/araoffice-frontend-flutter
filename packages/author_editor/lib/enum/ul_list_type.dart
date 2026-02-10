enum UlListType {
  // 기본 스타일 - 아라비아 숫자 계층
  listNumber('list-number'), // 기본 클래스

  // 한글/한자 마커 스타일
  listKorean('list-korean'), // 기본 클래스

  // 괄호 스타일
  listParen1('list-paren1'), // 1) 스타일
  listParen2('list-paren2'), // (1) 스타일

  // 기호 스타일
  listSymbol('list-symbol'); // 기호 스타일

  final String name;
  const UlListType(this.name);

  // index로 name 찾는 정적 메서드
  static String getNameFromIndex(int index) {
    if (index >= 0 && index < values.length) {
      return values[index].name;
    }
    return ''; // 또는 에러 처리
  }
}
