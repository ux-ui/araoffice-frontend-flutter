import 'package:xml/xml.dart';

import 'meta_data.dart';
import 'template_data.dart';

class TemplateInfo {
  final MetaData metaData;
  final List<TemplateData> templateDatas;

  TemplateInfo({
    required this.metaData,
    required this.templateDatas,
  });

  factory TemplateInfo.fromXml(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      final templateInfo = document.rootElement;

      final metadataElement = templateInfo.findElements('metadata').firstOrNull;
      final metaData = metadataElement != null
          ? MetaData.fromXmlElement(metadataElement)
          : MetaData();

      List<TemplateData> templatedatas;
      final templatedatasElement =
          templateInfo.findElements('templatedatas').firstOrNull;
      if (templatedatasElement != null) {
        templatedatas = templatedatasElement
            .findElements('templatedata')
            .map((child) => TemplateData.fromXmlElement(child))
            .toList();
      } else {
        final templatedataElement =
            templateInfo.findElements('templatedata').firstOrNull;
        templatedatas = templatedataElement != null
            ? [TemplateData.fromXmlElement(templatedataElement)]
            : <TemplateData>[];
      }

      return TemplateInfo(
        metaData: metaData,
        templateDatas: templatedatas,
      );
    } catch (e) {
      throw FormatException('Failed to parse TemplateInfo: $e');
    }
  }

  @override
  String toString() {
    final sb = StringBuffer();
    sb.writeln('$metaData');
    for (var data in templateDatas) {
      sb.writeln('$data');
    }
    return sb.toString();
  }
}
