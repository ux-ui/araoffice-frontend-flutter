import 'package:flutter/foundation.dart';

import '../../api.dart';

class ProjectPageItem extends BaseModel {
  final String id;
  final String title;
  final String idref;
  final bool linear;
  final String href;
  final String thumbnail;
  final Map<String, dynamic>? properties;
  final DateTime createdAt;
  final DateTime modifiedAt;

  ProjectPageItem({
    required this.id,
    required this.title,
    required this.idref,
    required this.linear,
    required this.href,
    required this.thumbnail,
    this.properties,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory ProjectPageItem.fromJson(Map<String, dynamic> json) {
    try {
      return ProjectPageItem(
        id: json['id'] as String,
        title: json['title'] as String,
        idref: json['idref'] as String,
        linear: json['linear'] as bool,
        href: json['href'] as String,
        thumbnail: json['thumbnail'] as String,
        properties: json['properties'] != null
            ? Map<String, dynamic>.from(json['properties'])
            : null,
        createdAt: DateTime.parse(json['createdAt']),
        modifiedAt: DateTime.parse(json['modifiedAt']),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing ProjectModel:');
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
      'title': title,
      'idref': idref,
      'linear': linear,
      'href': href,
      'thumbnail': thumbnail,
      if (properties != null) 'properties': properties,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }

  ProjectPageItem copyWith({
    String? id,
    String? title,
    String? idref,
    bool? linear,
    String? href,
    String? thumbnail,
    Map<String, dynamic>? properties,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return ProjectPageItem(
      id: id ?? this.id,
      title: title ?? this.title,
      idref: idref ?? this.idref,
      linear: linear ?? this.linear,
      href: href ?? this.href,
      thumbnail: thumbnail ?? this.thumbnail,
      properties: properties ?? this.properties,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
