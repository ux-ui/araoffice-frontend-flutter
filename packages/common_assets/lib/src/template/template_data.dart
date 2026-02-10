import 'package:xml/xml.dart';

import 'data_item.dart';
import 'node_extension.dart';
import 'resource_item.dart';

class TemplateData {
  final String title;
  final String? keyword;
  final String description;
  final String? category;
  final String? templateFile;
  final String coverFile;
  final String? clipartFile;
  final String? dataFile;
  final List<String>? thumbnails;
  final DataItem? data;
  final DataItem? dataScript;
  final ResourceItem? resource;

  TemplateData({
    required this.title,
    this.keyword,
    required this.description,
    this.category,
    this.templateFile,
    required this.coverFile,
    this.clipartFile,
    this.dataFile,
    this.thumbnails,
    this.data,
    this.dataScript,
    this.resource,
  });

  factory TemplateData.fromXmlElement(XmlElement element) {
    try {
      final thumbnailsElement = element.findElements('thumbnails').firstOrNull;
      final thumbnails = thumbnailsElement
          ?.findElements('thumbnailfile')
          .map((e) => e.innerText)
          .toList();

      final dataElement = element.findElements('data').firstOrNull;
      final data =
          dataElement != null ? DataItem.fromXmlElement(dataElement) : null;

      final dataScriptElement = element.findElements('data_script').firstOrNull;
      final dataScript = dataScriptElement != null
          ? DataItem.fromXmlElement(dataScriptElement)
          : null;

      final resourceElement = element.findElements('resource').firstOrNull;
      final resource = resourceElement != null
          ? ResourceItem.fromXmlElement(resourceElement)
          : null;

      return TemplateData(
        title: element.nodeContent('title'),
        keyword: element.nodeContent('keyword'),
        description: element.nodeContent('description'),
        category: element.nodeContent('category'),
        templateFile: element.nodeContent('templateFile'),
        coverFile: element.nodeContent('coverfile'),
        clipartFile: element.nodeContent('clipartfile'),
        dataFile: element.nodeContent('dataFile'),
        thumbnails: thumbnails,
        data: data,
        dataScript: dataScript,
        resource: resource,
      );
    } catch (e) {
      throw FormatException('Failed to parse TemplateData: $e');
    }
  }

  factory TemplateData.book({
    required String title,
    required String description,
    required String category,
    required String templateFile,
    required String coverFile,
    required List<String> thumbnails,
    required DataItem data,
  }) {
    return TemplateData(
      title: title,
      description: description,
      category: category,
      templateFile: templateFile,
      coverFile: coverFile,
      thumbnails: thumbnails,
      data: data,
    );
  }

  factory TemplateData.clipArt({
    required String title,
    required String keyword,
    required String description,
    required String coverFile,
    required String clipartFile,
  }) {
    return TemplateData(
      title: title,
      keyword: keyword,
      description: description,
      coverFile: coverFile,
      clipartFile: clipartFile,
    );
  }

  factory TemplateData.formula({
    required String title,
    required String description,
    required String templateFile,
    required String coverFile,
    required List<String> thumbnails,
    required DataItem data,
    required DataItem dataScript,
    required ResourceItem resource,
  }) {
    return TemplateData(
      title: title,
      description: description,
      templateFile: templateFile,
      coverFile: coverFile,
      thumbnails: thumbnails,
      data: data,
      dataScript: dataScript,
      resource: resource,
    );
  }

  factory TemplateData.layer({
    required String title,
    required String keyword,
    required String description,
    required String coverFile,
    required String dataFile,
  }) {
    return TemplateData(
      title: title,
      keyword: keyword,
      description: description,
      coverFile: coverFile,
      dataFile: dataFile,
    );
  }

  factory TemplateData.page({
    required String title,
    required String description,
    required String templateFile,
    required String coverFile,
    required List<String> thumbnails,
    required DataItem data,
    required DataItem dataScript,
    required ResourceItem resource,
  }) {
    return TemplateData(
      title: title,
      description: description,
      templateFile: templateFile,
      coverFile: coverFile,
      thumbnails: thumbnails,
      data: data,
      dataScript: dataScript,
      resource: resource,
    );
  }

  @override
  String toString() {
    return 'TemplateData(title: $title, description: $description, clipartFile: $clipartFile)';
  }
}
