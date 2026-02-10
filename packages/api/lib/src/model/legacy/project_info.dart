import '../base_model.dart';
import 'storage_file.dart';

class ProjectInfo extends BaseModel {
  final int id;
  final int userId;

  final DateTime createdAt;
  final String name;
  final DateTime? updatedAt;
  final String? description;
  final String? thumbnail;
  final int? folderId;

  /// 페이지 정보
  /// !! 해당 내용은 상세 정보 요청 응답에만 포함됨
  final List<StorageFile> pages;

  /// 페이지 정보를 제외한 모든 파일 정보 (이미지, 폰트, 스타일, 비디오 등)
  /// !! 해당 내용은 상세 정보 요청 응답에만 포함됨
  final List<StorageFile> resources;

  /// 편집 설정 정보 (edition_config.json 파일 내용)
  /// !! 해당 내용은 상세 정보 요청 응답에만 포함됨
  final Map<String, dynamic> editingConfig;

  /// 작성자 설정 (author_config.json 파일 내용)
  /// !! 해당 내용은 상세 정보 요청 응답에만 포함됨
  final Map<String, dynamic> authorConfig;

  ProjectInfo({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    this.updatedAt,
    this.description,
    this.thumbnail,
    this.folderId,
    List<StorageFile>? pages,
    List<StorageFile>? resources,
    Map<String, dynamic>? editingConfig,
    Map<String, dynamic>? authorConfig,
  })  : pages = pages ?? [],
        resources = resources ?? [],
        editingConfig = editingConfig ?? {},
        authorConfig = authorConfig ?? {};

  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    return ProjectInfo(
      id: json['id'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']),
      description: json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      folderId: json['folderId'],
      pages: _parseListFromJson(json['pages']),
      resources: _parseListFromJson(json['resources']),
      editingConfig: _parseEditingConfig(json['editingConfig']),
      authorConfig: _parseEditingConfig(json['authorConfig']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (description != null) 'description': description,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (folderId != null) 'folderId': folderId,
      'pages': pages.map((e) => e.toJson()).toList(),
      'resources': resources.map((e) => e.toJson()).toList(),
      'editingConfig': editingConfig,
      'authorConfig': authorConfig,
    };
  }

  ProjectInfo copyWith({
    int? id,
    int? userId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    String? thumbnail,
    int? folderId,
    List<StorageFile>? pages,
    List<StorageFile>? resources,
    Map<String, dynamic>? editingConfig,
    Map<String, dynamic>? authorConfig,
  }) =>
      ProjectInfo(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        description: description ?? this.description,
        thumbnail: thumbnail ?? this.thumbnail,
        folderId: folderId ?? this.folderId,
        pages: pages ?? this.pages,
        resources: resources ?? this.resources,
        editingConfig: editingConfig ?? this.editingConfig,
        authorConfig: authorConfig ?? this.authorConfig,
      );

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static List<StorageFile> _parseListFromJson(dynamic json) {
    if (json is! List) return [];
    return json
        .whereType<Map<String, dynamic>>()
        .map((e) => StorageFile.fromJson(e))
        .toList();
  }

  static Map<String, dynamic> _parseEditingConfig(dynamic json) {
    if (json is! Map<String, dynamic>) return {};
    return json;
  }
}
