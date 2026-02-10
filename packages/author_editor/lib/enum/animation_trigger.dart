enum AnimationTriggerType {
  click('click'),
  load('load'),
  all('all');

  final String name;
  const AnimationTriggerType(this.name);

  // factory constructor 방식
  factory AnimationTriggerType.fromString(String tag) {
    return AnimationTriggerType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => AnimationTriggerType.click, // 기본값 지정 필요
    );
  }
}
