enum ObjectType {
  backgroundImage('background_image'),
  bodyBackgroundImage('body_background_image'),
  image('image'),
  changeImage('change_image'),
  widget('widget'),
  table('table'),
  body('body');

  final String value;
  const ObjectType(this.value);

  // factory constructor 방식
  factory ObjectType.fromString(String tag) {
    return ObjectType.values.firstWhere(
      (type) => type.value == tag,
      orElse: () => ObjectType.image, // 기본값 지정 필요
    );
  }
}
