enum MarginType {
  none(''),
  left('margin-left'),
  right('margin-right'),
  top('margin-top'),
  bottom('margin-bottom');

  final String name;
  const MarginType(this.name);

  // factory constructor 방식
  factory MarginType.fromString(String tag) {
    return MarginType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => MarginType.none, // 기본값 지정 필요
    );
  }
}
