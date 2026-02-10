// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vulcan_txt_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VulcanTxtData _$VulcanTxtDataFromJson(Map<String, dynamic> json) =>
    VulcanTxtData(
      title: json['title'] as String,
      projectId: json['projectId'] as String,
      fileName: json['fileName'] as String,
      encoding: json['encoding'] as String? ?? 'UTF-8',
      lineSeparator: json['lineSeparator'] as String? ?? '\n',
      publishType: json['publishType'] as String,
      publishDate: json['publishDate'] as String?,
      author: json['author'] as String?,
    );

Map<String, dynamic> _$VulcanTxtDataToJson(VulcanTxtData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'projectId': instance.projectId,
      'fileName': instance.fileName,
      'encoding': instance.encoding,
      'lineSeparator': instance.lineSeparator,
      'publishType': instance.publishType,
      'publishDate': instance.publishDate,
      'author': instance.author,
    };
