import 'package:flutter/foundation.dart';

import 'user_model.dart';
import 'utill/json_parser.dart';

class PageModel {
  final String id;
  final String? parentId;
  final String title;
  final String idref;
  final bool linear;
  final String href;
  final String thumbnail;
  final String type;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final Map<String, dynamic>? properties;
  final UserModel? editorUser;

  PageModel({
    required this.id,
    this.parentId,
    required this.title,
    required this.idref,
    required this.linear,
    required this.href,
    required this.thumbnail,
    required this.type,
    required this.createdAt,
    required this.modifiedAt,
    this.properties,
    this.editorUser,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    try {
      final parser = JsonParser(json);

      return PageModel(
        id: parser.parseRequiredString('id'),
        parentId: parser.parseOptionalString('parentId'),
        title: parser.parseRequiredString('title'),
        idref: parser.parseRequiredString('idref'),
        linear: parser.parseRequiredBool('linear'),
        href: parser.parseRequiredString('href'),
        thumbnail: parser.parseRequiredString('thumbnail'),
        type: parser.parseRequiredString('type'),
        createdAt: parser.parseRequiredDateTime('createdAt'),
        modifiedAt: parser.parseRequiredDateTime('modifiedAt'),
        properties: parser.parseOptionalMap('properties'),
        editorUser: parser.parseOptionalObject(
            'editorUser', (json) => UserModel.fromJson(json)),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing PageModel:');
      debugPrint('JSON: $json');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'title': title,
      'idref': idref,
      'linear': linear,
      'href': href,
      'thumbnail': thumbnail,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'properties': properties,
      'editorUser': editorUser?.toJson(),
    };
  }
}
