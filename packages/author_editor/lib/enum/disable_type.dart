enum DisableType {
  enable('enable'),
  disable('disable');

  final String name;
  const DisableType(this.name);

  // factory constructor 방식
  factory DisableType.fromString(String tag) {
    return DisableType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => DisableType.enable, // 기본값 지정 필요
    );
  }
}
