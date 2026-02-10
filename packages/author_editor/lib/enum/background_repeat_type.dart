enum BackgroundRepeatType {
  noRepeat('no-repeat'),
  repeat('repeat'),
  repeatX('repeat-x'),
  repeatY('repeat-y');

  final String name;
  const BackgroundRepeatType(this.name);

  // factory constructor 방식
  factory BackgroundRepeatType.fromString(String tag) {
    return BackgroundRepeatType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => BackgroundRepeatType.repeat, // 기본값 지정 필요
    );
  }
}
