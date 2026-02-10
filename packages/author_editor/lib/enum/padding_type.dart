enum PaddingType {
  none(''),
  left('padding-left'),
  right('padding-right'),
  top('padding-top'),
  bottom('padding-bottom');

  final String name;
  const PaddingType(this.name);

  // factory constructor 방식
  factory PaddingType.fromString(String tag) {
    return PaddingType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => PaddingType.none, // 기본값 지정 필요
    );
  }
}
