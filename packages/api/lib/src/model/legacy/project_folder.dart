import '../base_model.dart';

class ProjectFolder extends BaseModel {
  final int id;
  final String name;
  final DateTime createdAt;

  final DateTime? updatedAt;
  final String? description;
  final int? parentId;

  ProjectFolder({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
    this.description,
    this.parentId,
  });

  factory ProjectFolder.fromJson(Map<String, dynamic> json) {
    return ProjectFolder(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      description: json['description'] as String?,
      parentId: json['parentId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'description': description,
      'parentId': parentId,
    };
  }
}
