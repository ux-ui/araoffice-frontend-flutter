enum GuideViewType {
  none('none'),
  guideStart('guide-start'),
  guideDownload('guide-download');

  final String value;
  const GuideViewType(this.value);
}

extension ViewTypeExtension on String {
  GuideViewType toGuideViewType() {
    // 빈 경로 처리
    if (isEmpty) return GuideViewType.guideStart;

    // path에 포함된 ViewType 찾기
    return GuideViewType.values.firstWhere(
      (type) => contains('/${type.value}'),
      orElse: () => GuideViewType.guideStart,
    );
  }
}
