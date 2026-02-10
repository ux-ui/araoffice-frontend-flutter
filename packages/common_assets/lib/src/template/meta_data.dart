import 'package:xml/xml.dart';

import 'node_extension.dart';

class MetaData {
  final String copyright;
  final String creator;
  final String generator;
  final String date;

  MetaData({
    this.copyright = '',
    this.creator = '',
    this.generator = '',
    this.date = '',
  });

  factory MetaData.fromXmlElement(XmlElement element) {
    try {
      return MetaData(
        copyright: element.nodeContent('copyright'),
        creator: element.nodeContent('creator'),
        generator: element.nodeContent('generator'),
        date: element.nodeContent('date'),
      );
    } catch (e) {
      throw FormatException('Failed to parse MetaData: $e');
    }
  }

  @override
  String toString() {
    return 'MetaData(copyright: $copyright, creator: $creator, generator: $generator, date: $date)';
  }
}
