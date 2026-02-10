import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

import 'template.dart';

class Templates {
  final String path;
  final String type;
  final String name;
  final String description;
  final List<Template> children;

  Templates({
    this.path = '',
    required this.type,
    required this.name,
    required this.description,
    this.children = const [],
  });

  factory Templates.empty() => Templates(type: '', name: '', description: '');

  factory Templates.fromXmlElement(String parent, XmlElement element) {
    try {
      final type = element.getAttribute('type') ?? '';
      final name = element.getAttribute('name') ?? '';
      final description = element.getAttribute('description') ?? '';
      final path = '$parent/$name';

      final children = element
          .findElements('template')
          .map((child) => Template.fromXmlElement(path, child))
          .toList();

      final templates = Templates(
        path: path,
        type: type,
        name: name,
        description: description,
        children: children,
      );

      return templates;
    } catch (e) {
      throw FormatException('Failed to parse Templates: $e');
    }
  }

  @override
  String toString() {
    return 'Templates(type: $type, name: $name, description: $description), children: ${children.length}';
  }

  void debug() {
    debugPrint('Type: $type, $description');
    for (var category in children) {
      debugPrint('Category: $category)');
      if (category.templateInfo != null) {
        // debugPrint('${category.templateInfo}');
        category.templateInfo?.templateDatas.forEach((e) {
          debugPrint('    - $e');
        });
      }
      for (var subCategory in category.children) {
        debugPrint('  - $subCategory');
        if (subCategory.templateInfo != null) {
          // debugPrint('${subCategory.templateInfo}');
          subCategory.templateInfo?.templateDatas.forEach((e) {
            debugPrint('    - $e');
          });
        }
      }
    }
  }
}
