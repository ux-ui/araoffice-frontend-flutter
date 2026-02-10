class VulcanWidgetData {
  final String? widgetType;
  final String widgetPath;
  final String markup;
  final List<String> jsFiles;
  final List<String> cssFiles;

  VulcanWidgetData({
    this.widgetType,
    required this.widgetPath,
    required this.markup,
    required this.jsFiles,
    required this.cssFiles,
  });

  // JSON으로부터 모델 생성
  factory VulcanWidgetData.fromJson(Map<String, dynamic> json) {
    return VulcanWidgetData(
      widgetType: json['widgetId'] as String?,
      widgetPath: json['widgetPath'] as String,
      markup: json['markup'] as String,
      jsFiles: json['jsFiles'] as List<String>,
      cssFiles: json['cssFiles'] as List<String>,
    );
  }

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'widgetId': widgetType ?? '',
      'widgetPath': widgetPath,
      'markup': markup,
      'jsFiles': jsFiles,
      'cssFiles': cssFiles,
    };
  }

  // 복사본 생성을 위한 메서드
  VulcanWidgetData copyWith({
    String? widgetId,
    String? widgetPath,
    String? markup,
    List<String>? jsFiles,
    List<String>? cssFiles,
  }) {
    return VulcanWidgetData(
      widgetType: widgetId ?? widgetType,
      widgetPath: widgetPath ?? this.widgetPath,
      markup: markup ?? this.markup,
      jsFiles: jsFiles ?? this.jsFiles,
      cssFiles: cssFiles ?? this.cssFiles,
    );
  }

  @override
  String toString() {
    return 'VulcanWidgetData(widgetPath: $widgetPath, markup: $markup, jsFiles: $jsFiles, cssFiles: $cssFiles)';
  }
}
