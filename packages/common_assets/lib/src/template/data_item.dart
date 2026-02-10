import 'package:xml/xml.dart';

import 'node_extension.dart';

class DataItem {
  final String name;
  final String content;

  DataItem({
    this.name = '',
    this.content = '',
  });

  factory DataItem.fromXmlElement(XmlElement element) {
    try {
      return DataItem(
        name: element.nodeContent('name'),
        content: element.nodeContent('content'),
      );
    } catch (e) {
      throw FormatException('Failed to parse DataItem: $e');
    }
  }

  @override
  String toString() {
    return 'MetaData(name: $name, content: $content)';
  }
}
