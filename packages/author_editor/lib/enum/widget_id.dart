enum WidgetId {
  none(''),
  slider('slider'),
  simpleSlider('simple-slider'),
  tab('tab'),
  tabbelow('tab_below'),
  arccodion('arccodion'),
  arccodionVert('arccodion_vert'),
  arccodionHorz('arccodion_horz'),
  toggle('toggle'),
  pageNumber('page-number'),
  toc('toc'),
  truefalse('question-truefalse'),
  truefalseleft('question-truefalse_left'),
  truefalseright('question-truefalse_right'),
  singlechoice('question-choice'),
  multichoice('question-choice'),
  resultbutton('question-result');

  final String name;
  const WidgetId(this.name);

  // factory constructor 방식
  factory WidgetId.fromString(String tag) {
    return WidgetId.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => WidgetId.none, // 기본값 지정 필요
    );
  }
}
