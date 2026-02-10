// ignore_for_file: depend_on_referenced_packages

import 'package:api/src/legacy/domain/entities/base_entity.dart';
import 'package:path/path.dart' as p;

enum StorageFileType {
  content, // XHTML 컨텐츠 파일
  style, // CSS 스타일 파일
  image, // 이미지 파일
  font, // 폰트 파일
  audio, // 오디오 파일
  video, // 비디오 파일
  navigation, // NCX 또는 nav.xhtml 파일
  metadata, // OPF 파일
  other // 기타 파일
}

class StorageFile extends BaseEntity {
  final int id;
  final int userId;
  final String path;
  final StorageFileType fileType;

  final DateTime createdAt;
  final DateTime? updatedAt;

  StorageFile({
    required this.id,
    required this.userId,
    required this.path,
    required this.fileType,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'path': path,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'fileType': fileType.index,
    };
  }

  static StorageFile fromJson(Map<String, dynamic> json) {
    final storageFile = StorageFile(
      id: json['id'] as int,
      userId: json['userId'] as int,
      path: json['path'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      fileType: StorageFileType.values[json['fileType'] as int],
    );
    return storageFile;
  }

  factory StorageFile.empty() {
    return StorageFile(
      id: -1,
      userId: -1,
      path: '',
      createdAt: DateTime.now(),
      fileType: StorageFileType.other,
    );
  }

  StorageFile copyWith({
    int? id,
    int? userId,
    String? path,
    StorageFileType? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mimeType,
  }) {
    return StorageFile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      path: path ?? this.path,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static StorageFileType determineFileType(String name) {
    final extension = p.extension(name).substring(1).toLowerCase();
    final fileName = p.basename(name).toLowerCase();

    if (extension == 'xhtml' || extension == 'html' || extension == 'htm') {
      if (fileName == 'nav.xhtml' || fileName == 'toc.ncx') {
        return StorageFileType.navigation;
      }
      return StorageFileType.content;
    }

    switch (extension) {
      case 'css':
        return StorageFileType.style;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'svg':
        return StorageFileType.image;
      case 'ttf':
      case 'otf':
      case 'woff':
      case 'woff2':
        return StorageFileType.font;
      case 'mp3':
      case 'ogg':
      case 'wav':
        return StorageFileType.audio;
      case 'mp4':
      case 'webm':
      case 'ogv':
        return StorageFileType.video;
      case 'opf':
        return StorageFileType.metadata;
      default:
        return StorageFileType.other;
    }
  }
}
