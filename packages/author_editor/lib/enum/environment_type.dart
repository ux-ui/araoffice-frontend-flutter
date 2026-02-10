enum EnvironmentType {
  private('private'),
  public('public');

  final String name;
  const EnvironmentType(this.name);
  factory EnvironmentType.fromString(String tag) {
    return EnvironmentType.values.firstWhere(
      (type) => type.name == tag.toLowerCase(),
      orElse: () => EnvironmentType.public, // 기본값 지정 필요
    );
  }
}
