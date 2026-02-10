import 'package:xml/xml.dart';

import 'template_info.dart';

class Template {
  final String path;
  final String name;
  final String description;
  final List<Template> children;
  TemplateInfo? _templateInfo;

  bool get haveChildElements => children.isNotEmpty;
  bool get haveTemplates => _templateInfo != null;
  bool get isTemplateDataLoaded => _templateInfo != null;
  TemplateInfo? get templateInfo => _templateInfo;

  Template({
    this.path = '',
    required this.name,
    required this.description,
    this.children = const [],
  }) : _templateInfo = null;

  factory Template.fromXmlElement(String parent, XmlElement element) {
    try {
      final name = element.getAttribute('name') ?? '';
      final description = element.getAttribute('description') ?? '';
      final path = '$parent/$name';

      final children = element
          .findElements('template')
          .map((child) => Template.fromXmlElement(path, child))
          .toList();

      return Template(
        path: path,
        name: name,
        description: description,
        children: children,
      );
    } catch (e) {
      throw FormatException('Failed to parse Template: $e');
    }
  }

  void templateInfoFromXml(String xmlString) {
    _templateInfo = TemplateInfo.fromXml(xmlString);
  }

  Template? getTemplateByName(String templateName) {
    if (name.compareTo(templateName) == 0) {
      return this;
    }
    for (var e in children) {
      final temp = e.getTemplateByName(templateName);
      if (temp != null) return temp;
    }
    return null;
  }

  @override
  String toString() {
    var string = 'Template(name: $name, description: $description';
    if (children.isNotEmpty) string += ', children: ${children.length}';
    string += ')';
    return string;
  }
}
