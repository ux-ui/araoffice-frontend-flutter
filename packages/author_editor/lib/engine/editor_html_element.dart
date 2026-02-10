import 'dart:js_interop';

import 'package:common_util/common_util.dart';
import 'package:web/web.dart' as web;

class EditorHtmlElement {
  final String tagName;
  final String id;
  final List<String> classNames;
  final Map<String, String> attributes;
  final Map<String, String> styles;

  EditorHtmlElement({
    required this.tagName,
    required this.id,
    required this.classNames,
    required this.attributes,
    required this.styles,
  });

  factory EditorHtmlElement.fromElement(web.Element element) {
    return EditorHtmlElement(
      tagName: element.tagName.toLowerCase(),
      id: element.id,
      classNames: element.className.split(' '),
      attributes: _getAttributes(element),
      styles: _getStyles(element),
    );
  }

  static Map<String, String> _getAttributes(web.Element element) {
    final attributes = <String, String>{};
    try {
      final jsAttributeNames = element.getAttributeNames();
      final attributeNames =
          (jsAttributeNames as JSArray).toDart.cast<String>();
      for (final name in attributeNames) {
        final value = element.getAttribute(name);
        if (value != null) {
          attributes[name] = value;
        }
      }
    } catch (e) {
      logger.e('Error getting attributes: $e');
    }
    return attributes;
  }

  static Map<String, String> _getStyles(web.Element element) {
    final styles = <String, String>{};
    try {
      final computedStyle = element.computedStyleMap();
      final cssProperties = _getCSSProperties();

      for (final property in cssProperties) {
        if (computedStyle.has(property)) {
          final value = computedStyle.get(property);
          if (value != null) {
            styles[property] = value.toString();
          }
        }
      }
    } catch (e) {
      logger.e('Error getting styles: $e');
    }
    return styles;
  }

  // Helper method to get a list of CSS properties
  static List<String> _getCSSProperties() {
    // This is a non-exhaustive list of common CSS properties
    // You might want to expand this list based on your needs
    return [
      'width', 'height', 'color', 'background-color', 'font-size',
      'font-family',
      'margin', 'padding', 'border', 'display', 'position', 'top', 'left',
      'right', 'bottom', 'z-index', 'opacity', 'transform', 'transition',
      'flex', 'grid', 'align-items', 'justify-content', 'text-align',
      // Add more properties as needed
    ];
  }

  @override
  String toString() {
    return 'EditorHtmlElement(tagName: $tagName, id: $id, classNames: $classNames, attributes: $attributes, styles: $styles)';
  }
}
