enum VulcanEditorDisplayType {
  create('create'),
  editor('editor'),
  unauthorized('unauthorized');

  final String name;
  const VulcanEditorDisplayType(this.name);

  // factory constructor 방식
  factory VulcanEditorDisplayType.fromString(String tag) {
    return VulcanEditorDisplayType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => VulcanEditorDisplayType.unauthorized, // 기본값 지정 필요
      // orElse: () => VulcanEditorDisplayType.create, // 기본값 지정 필요
    );
  }
}
