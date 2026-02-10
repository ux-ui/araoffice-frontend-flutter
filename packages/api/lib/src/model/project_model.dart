import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:flutter/foundation.dart';

import 'model.dart';

class ProjectModel {
  final String id;
  final String userId;
  final String name;
  final String templateId;
  final String displayName;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<PageModel>? pages;
  final String projectAuth;
  final List<UserModel>? sharedUsers;
  final bool isOwner;
  final String? startPageId;
  final bool hasCover;
  final bool hasToc;

  ProjectModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.displayName,
    required this.templateId,
    required this.createdAt,
    required this.modifiedAt,
    required this.pages,
    required this.projectAuth,
    required this.sharedUsers,
    required this.isOwner,
    this.startPageId,
    required this.hasCover,
    required this.hasToc,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProjectModel(
        id: json.requireString('id'),
        userId: json.requireString('userId'),
        name: json.requireString('name'),
        displayName: json.requireString('displayName'),
        templateId: json.requireString('templateId'),
        createdAt: json.requireDateTime('createdAt'),
        modifiedAt: json.requireDateTime('modifiedAt'),
        pages: json.requireList(
          'pages',
          (item) => PageModel.fromJson(item as Map<String, dynamic>),
        ),
        projectAuth: json.requireString('projectAuth'),
        sharedUsers: json.requireList(
          'sharedUsers',
          (item) => UserModel.fromJson(item as Map<String, dynamic>),
        ),
        isOwner: json.requireBool('isOwner'),
        startPageId: json.optionalString('startPageId'),
        hasCover: json.requireBool('hasCover'),
        hasToc: json.requireBool('hasToc'),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing ProjectModel:');
      debugPrint('JSON: $json');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'displayName': displayName,
      'templateId': templateId,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'pages': pages?.map((page) => page.toJson()).toList(),
      'projectAuth': projectAuth,
      'sharedUsers': sharedUsers?.map((user) => user.toJson()).toList(),
      'isOwner': isOwner,
      'startPageId': startPageId,
      'hasCover': hasCover,
      'hasToc': hasToc,
    };
  }

  List<Map<String, dynamic>>? toPageJson() {
    return pages?.map((page) => page.toJson()).toList();
  }
}
