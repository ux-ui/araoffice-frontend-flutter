import 'package:api/src/model/model.dart';
import 'package:flutter/foundation.dart';

enum ContentType {
  project,
  folder;

  String get name => toString().split('.').last;

  static ContentType fromString(String? value) {
    if (value == null || value.isEmpty) return ContentType.folder;
    return ContentType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ContentType.folder,
    );
  }
}

class FolderContentModel extends BaseModel {
  final String id;
  final String name;
  final ContentType type;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String contentLength;
  final bool isOwner;
  FolderContentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.modifiedAt,
    required this.contentLength,
    required this.isOwner,
  });

  factory FolderContentModel.fromJson(Map<String, dynamic> json) {
    try {
      return FolderContentModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: ContentType.fromString(json['type'] as String?),
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
        contentLength: json['contentLength'] as String,
        isOwner: json['isOwner'] as bool,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing PageModel:');
      debugPrint('JSON: $json');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'modifiedAt': modifiedAt.toUtc().toIso8601String(),
      'contentLength': contentLength,
      'isOwner': isOwner,
    };
  }

  // 타입 체크를 위한 getter
  bool get isProject => type == ContentType.project;
  bool get isFolder => type == ContentType.folder;

  FolderContentModel copyWith({
    String? id,
    String? name,
    ContentType? type,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? contentLength,
    bool? isOwner,
  }) {
    return FolderContentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      contentLength: contentLength ?? this.contentLength,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderContentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          createdAt == other.createdAt &&
          modifiedAt == other.modifiedAt &&
          contentLength == contentLength &&
          isOwner == other.isOwner;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      createdAt.hashCode ^
      modifiedAt.hashCode ^
      contentLength.hashCode ^
      isOwner.hashCode;

  @override
  String toString() {
    return 'FolderContent{id: $id, name: $name, type: ${type.name}, '
        'createdAt: $createdAt, modifiedAt: $modifiedAt, '
        'contentLength: $contentLength, isOwner: $isOwner}';
  }
}
