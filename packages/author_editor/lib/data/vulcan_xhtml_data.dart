class VulcanXhtmlData {
  final String title;
  final String projectId;
  final String fileName;
  final String publishType;
  final String? publishDate;
  final String? author;
  final bool showPageList;

  const VulcanXhtmlData({
    required this.title,
    required this.projectId,
    required this.fileName,
    required this.publishType,
    this.publishDate,
    this.author,
    this.showPageList = true,
  });

  // JSON으로부터 객체 생성
  factory VulcanXhtmlData.fromJson(Map<String, dynamic> json) {
    return VulcanXhtmlData(
      title: json['title'] as String,
      projectId: json['projectId'] as String,
      fileName: json['fileName'] as String,
      publishType: json['publishType'] as String,
      publishDate: json['publishDate'] as String?,
      author: json['author'] as String?,
      showPageList: json['showPageList'] as bool? ?? true,
    );
  }

  // 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'projectId': projectId,
      'fileName': fileName,
      'publishType': publishType,
      'publishDate': publishDate,
      'author': author,
      'showPageList': showPageList,
    };
  }

  VulcanXhtmlData copyWith({
    String? title,
    String? projectId,
    String? fileName,
    String? publishType,
    String? publishDate,
    String? author,
    bool? showPageList,
  }) {
    return VulcanXhtmlData(
      title: title ?? this.title,
      projectId: projectId ?? this.projectId,
      fileName: fileName ?? this.fileName,
      publishType: publishType ?? this.publishType,
      publishDate: publishDate ?? this.publishDate,
      author: author ?? this.author,
      showPageList: showPageList ?? this.showPageList,
    );
  }

  @override
  String toString() {
    return 'VulcanXhtmlData(title: $title, projectId: $projectId, fileName: $fileName, publishType: $publishType, publishDate: $publishDate, author: $author, showPageList: $showPageList)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VulcanXhtmlData &&
        other.title == title &&
        other.projectId == projectId &&
        other.fileName == fileName &&
        other.publishType == publishType &&
        other.publishDate == publishDate &&
        other.author == author &&
        other.showPageList == showPageList;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        projectId.hashCode ^
        fileName.hashCode ^
        publishType.hashCode ^
        publishDate.hashCode ^
        author.hashCode ^
        showPageList.hashCode;
  }
}
