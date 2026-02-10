import 'package:xml/xml.dart';

extension XmlElementExtension on XmlElement {
  String nodeContent(String nodeName) {
    final elements = findElements(nodeName);
    if (elements.isEmpty) return '';
    final cdata = elements.first.findElements('![CDATA[');
    if (cdata.isNotEmpty) {
      return cdata.firstOrNull?.innerText.trim() ?? '';
    }
    return elements.firstOrNull?.innerText.trim() ?? '';
  }
}
