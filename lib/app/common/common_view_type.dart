enum ViewType {
  none('none'),
  project('project'),
  template('template'),
  question('question'),
  setting('setting'),
  account('account'),
  plan('plan'),
  subscription('subscription'),
  resource('resource'),
  office('office'),

  // _____ guide ______
  guide('guide'),
  guideStart('guide-start');

  final String value;
  const ViewType(this.value);
}

extension ViewTypeExtension on String {
  ViewType toViewType() {
    // 빈 경로 처리
    if (isEmpty) return ViewType.project;

    // path에 포함된 ViewType 찾기
    return ViewType.values.firstWhere(
      (type) => contains('/${type.value}'),
      orElse: () => ViewType.project,
    );
  }
}
