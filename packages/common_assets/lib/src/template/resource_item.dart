import 'package:xml/xml.dart';

import 'node_extension.dart';

class ResourceItem {
  final String image;
  final String css;
  final String script;
  final String video;
  final String audio;
  final String font;
  final String etc;

  ResourceItem({
    this.image = '',
    this.css = '',
    this.script = '',
    this.video = '',
    this.audio = '',
    this.font = '',
    this.etc = '',
  });

  factory ResourceItem.fromXmlElement(XmlElement element) {
    try {
      return ResourceItem(
        image: element.nodeContent('image'),
        css: element.nodeContent('css'),
        script: element.nodeContent('script'),
        video: element.nodeContent('video'),
        audio: element.nodeContent('audio'),
        font: element.nodeContent('font'),
        etc: element.nodeContent('etc'),
      );
    } catch (e) {
      throw FormatException('Failed to parse ResourceItem: $e');
    }
  }

  @override
  String toString() {
    return 'ResourceItem(image: $image, css: $css, script: $script, video: $video, audio: $audio, font: $font, etc: $etc)';
  }
}
