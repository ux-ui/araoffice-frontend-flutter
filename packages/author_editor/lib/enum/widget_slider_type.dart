enum WidgetSliderType {
  slider('slider'),
  simpleSlider('simple-slider');

  final String name;
  const WidgetSliderType(this.name);

  // factory constructor 방식
  factory WidgetSliderType.fromString(String tag) {
    return WidgetSliderType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => WidgetSliderType.slider, // 기본값 지정 필요
    );
  }
}
