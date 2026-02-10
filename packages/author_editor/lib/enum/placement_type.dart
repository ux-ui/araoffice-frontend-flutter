enum PlacementType {
  left('page-spread-left'),
  center('page-spread-center'),
  right('page-spread-right'),
  auto('');

  final String name;
  const PlacementType(this.name);

  // factory constructor 방식
  factory PlacementType.fromString(String tag) {
    return PlacementType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => PlacementType.auto, // 기본값 지정 필요
    );
  }
}
