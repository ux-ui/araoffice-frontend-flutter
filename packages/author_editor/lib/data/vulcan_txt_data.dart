import 'package:json_annotation/json_annotation.dart';

part 'vulcan_txt_data.g.dart';

@JsonSerializable()
class VulcanTxtData {
  final String title;
  final String projectId;
  final String fileName;
  final String? encoding;
  final String? lineSeparator;
  final String publishType;
  final String? publishDate;
  final String? author;

  const VulcanTxtData({
    required this.title,
    required this.projectId,
    required this.fileName,
    this.encoding = 'UTF-8',
    this.lineSeparator = '\n',
    required this.publishType,
    this.publishDate,
    this.author,
  });

  factory VulcanTxtData.fromJson(Map<String, dynamic> json) =>
      _$VulcanTxtDataFromJson(json);

  Map<String, dynamic> toJson() => _$VulcanTxtDataToJson(this);

  VulcanTxtData copyWith({
    String? title,
    String? projectId,
    String? fileName,
    String? encoding,
    String? lineSeparator,
    String? publishType,
    String? publishDate,
    String? author,
  }) {
    return VulcanTxtData(
      title: title ?? this.title,
      projectId: projectId ?? this.projectId,
      fileName: fileName ?? this.fileName,
      encoding: encoding ?? this.encoding,
      lineSeparator: lineSeparator ?? this.lineSeparator,
      publishType: publishType ?? this.publishType,
      publishDate: publishDate ?? this.publishDate,
      author: author ?? this.author,
    );
  }

  @override
  String toString() {
    return 'VulcanTxtData(title: $title, projectId: $projectId, fileName: $fileName, encoding: $encoding, lineSeparator: $lineSeparator, publishType: $publishType, publishDate: $publishDate, author: $author)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VulcanTxtData &&
        other.title == title &&
        other.projectId == projectId &&
        other.fileName == fileName &&
        other.encoding == encoding &&
        other.lineSeparator == lineSeparator &&
        other.publishType == publishType &&
        other.publishDate == publishDate &&
        other.author == author;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        projectId.hashCode ^
        fileName.hashCode ^
        encoding.hashCode ^
        lineSeparator.hashCode ^
        publishType.hashCode ^
        publishDate.hashCode ^
        author.hashCode;
  }
}
