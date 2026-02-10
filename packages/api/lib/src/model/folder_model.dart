// import 'package:api/src/model/model.dart';
// import 'package:api/src/model/utill/json_parser_extension.dart';
// import 'package:flutter/foundation.dart';

// class FolderModel extends BaseModel {
//   final String id;
//   final String folderName;
//   final String type;
//   final String? parentFolderNo;
//   final DateTime? createdAt;
//   final DateTime? modifiedAt;
//   final int contentLength;
//   final List<FolderContentModel> contents;

//   FolderModel({
//     required this.id,
//     required this.folderName,
//     required this.type,
//     required this.contentLength,
//     this.parentFolderNo,
//     this.createdAt,
//     this.modifiedAt,
//     List<FolderContentModel>? contents,
//   }) : contents = contents ?? [];

//   factory FolderModel.fromJson(Map<String, dynamic> json) {
//     try {
//       return FolderModel(
//         id: json.requireString('id'),
//         folderName: json.requireString('folderName'),
//         type: json.requireString('type'),
//         createdAt: json.optionalDateTime('createdAt'),
//         modifiedAt: json.optionalDateTime('modifiedAt'),
//         contentLength: json.requireInt('contentLength'),
//         contents: json.listWithDefault(
//           'contents',
//           (item) => FolderContentModel.fromJson(item as Map<String, dynamic>),
//         ),
//       );
//     } catch (e, stackTrace) {
//       debugPrint('Error parsing FolderModel:');
//       debugPrint('JSON: $json');
//       debugPrint('Error: $e');
//       debugPrint('Stack trace: $stackTrace');
//       rethrow;
//     }
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> json = {
//       'id': id,
//       'folderName': folderName,
//       'type': type,
//       'contentLength': contentLength,
//       'contents': contents.map((content) => content.toJson()).toList(),
//     };

//     if (createdAt != null) {
//       json['createdAt'] = createdAt!.toUtc().toIso8601String();
//     }
//     if (modifiedAt != null) {
//       json['modifiedAt'] = modifiedAt!.toUtc().toIso8601String();
//     }

//     return json;
//   }

//   FolderModel copyWith({
//     String? id,
//     String? folderName,
//     String? type,
//     DateTime? createdAt,
//     DateTime? modifiedAt,
//     int? contentLength,
//     List<FolderContentModel>? contents,
//   }) {
//     return FolderModel(
//       id: id ?? this.id,
//       folderName: folderName ?? this.folderName,
//       type: type ?? this.type,
//       createdAt: createdAt ?? this.createdAt,
//       modifiedAt: modifiedAt ?? this.modifiedAt,
//       contentLength: contentLength ?? this.contentLength,
//       contents: contents ?? List.from(this.contents),
//     );
//   }

//   @override
//   String toString() {
//     return 'Folder{id: $id, folderName: $folderName, type: $type, '
//         'createdAt: $createdAt, modifiedAt: $modifiedAt, '
//         'contentLength: $contentLength, contentsCount: ${contents.length}}';
//   }

//   // 편의 메서드들
//   List<FolderContentModel> get projects =>
//       contents.where((content) => content.isProject).toList();

//   List<FolderContentModel> get folders =>
//       contents.where((content) => content.isFolder).toList();

//   bool hasContent(String contentId) =>
//       contents.any((content) => content.id == contentId);

//   FolderContentModel? findContent(String contentId) {
//     try {
//       return contents.firstWhere(
//         (content) => content.id == contentId,
//       );
//     } catch (e) {
//       return null;
//     }
//   }
// }
import 'package:api/src/model/model.dart';
import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:flutter/foundation.dart';

class FolderModel extends BaseModel {
  final String id;
  final String folderName;
  final String type;
  final String? parentId;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final int contentLength;
  final List<FolderContentModel> contents;

  FolderModel({
    required this.id,
    required this.folderName,
    required this.type,
    required this.contentLength,
    this.parentId,
    this.createdAt,
    this.modifiedAt,
    List<FolderContentModel>? contents,
  }) : contents = contents ?? [];

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    try {
      return FolderModel(
        id: json.requireString('id'),
        folderName: json.requireString('folderName'),
        type: json.requireString('type'),
        parentId: json.optionalString('parentId'),
        createdAt: json.optionalDateTime('createdAt'),
        modifiedAt: json.optionalDateTime('modifiedAt'),
        contentLength: json.requireInt('contentLength'),
        contents: json.listWithDefault(
          'contents',
          (item) => FolderContentModel.fromJson(item as Map<String, dynamic>),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing FolderModel:');
      debugPrint('JSON: $json');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'folderName': folderName,
      'type': type,
      'parentId': parentId,
      'contentLength': contentLength,
      'contents': contents.map((content) => content.toJson()).toList(),
    };

    if (parentId != null) {
      json['parentId'] = parentId;
    }
    if (createdAt != null) {
      json['createdAt'] = createdAt!.toUtc().toIso8601String();
    }
    if (modifiedAt != null) {
      json['modifiedAt'] = modifiedAt!.toUtc().toIso8601String();
    }

    return json;
  }

  FolderModel copyWith({
    String? id,
    String? folderName,
    String? type,
    String? parentFolderNo,
    DateTime? createdAt,
    DateTime? modifiedAt,
    int? contentLength,
    List<FolderContentModel>? contents,
  }) {
    return FolderModel(
      id: id ?? this.id,
      folderName: folderName ?? this.folderName,
      type: type ?? this.type,
      parentId: parentFolderNo ?? parentId,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      contentLength: contentLength ?? this.contentLength,
      contents: contents ?? List.from(this.contents),
    );
  }

  @override
  String toString() {
    return 'Folder{id: $id, folderName: $folderName, type: $type, '
        'parentFolderNo: $parentId, createdAt: $createdAt, '
        'modifiedAt: $modifiedAt, contentLength: $contentLength, '
        'contentsCount: ${contents.length}}';
  }

  // 편의 메서드들
  List<FolderContentModel> get projects =>
      contents.where((content) => content.isProject).toList();

  List<FolderContentModel> get folders =>
      contents.where((content) => content.isFolder).toList();

  bool hasContent(String contentId) =>
      contents.any((content) => content.id == contentId);

  FolderContentModel? findContent(String contentId) {
    try {
      return contents.firstWhere(
        (content) => content.id == contentId,
      );
    } catch (e) {
      return null;
    }
  }
}
