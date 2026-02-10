class VulcanEpubData {
  String? projectId; // 프로젝트 ID
  String? title; // 전자책제목
  String? author; // 저자
  DateTime? publishDate; // 발행일
  String? language; // 언어
  String? publisher; // 출판사
  String? copyright; // 저작권
  String? location; // 저장위치
  bool? isIncludeFont; // 글꼴포함 체크
  String? publishType; // 출판유형

  VulcanEpubData({
    this.title,
    this.author,
    this.publishDate,
    this.language,
    this.publisher,
    this.copyright,
    this.location,
    this.isIncludeFont,
    this.projectId,
    this.publishType,
  });

  // JSON으로부터 객체 생성
  factory VulcanEpubData.fromJson(Map<String, dynamic> json) {
    return VulcanEpubData(
      title: json['title'],
      author: json['author'],
      publishDate: json['publishDate'] != null
          ? DateTime.parse(json['publishDate'])
          : null,
      language: json['language'],
      publisher: json['publisher'],
      copyright: json['copyright'],
      location: json['location'],
      isIncludeFont: json['isFontIncluded'],
      projectId: json['projectId'],
      publishType: json['publishType'],
    );
  }

  // 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'title': title,
      'author': author,
      'publishDate': publishDate?.toIso8601String(),
      'language': language,
      'publisher': publisher,
      'copyright': copyright,
      'location': location,
      'isIncludeFont': isIncludeFont,
      'publishType': publishType,
    };
  }

  // 객체 복사본 생성
  VulcanEpubData copyWith({
    String? title,
    String? author,
    DateTime? publishDate,
    String? language,
    String? publisher,
    String? copyright,
    String? location,
    bool? isFontIncluded,
    String? projectId,
    String? publishType,
  }) {
    return VulcanEpubData(
      title: title ?? this.title,
      author: author ?? this.author,
      publishDate: publishDate ?? this.publishDate,
      language: language ?? this.language,
      publisher: publisher ?? this.publisher,
      copyright: copyright ?? this.copyright,
      location: location ?? this.location,
      isIncludeFont: isFontIncluded ?? isIncludeFont,
      projectId: projectId ?? this.projectId,
      publishType: publishType ?? this.publishType,
    );
  }

  @override
  String toString() {
    return 'EBook{title: $title, author: $author, publishDate: $publishDate, '
        'language: $language, publisher: $publisher, copyright: $copyright, '
        'location: $location, isIncludeFont: $isIncludeFont, '
        'projectId: $projectId, publishType: $publishType}';
  }
}
