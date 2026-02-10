import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class EditorHtmlStyle {
  final Map<String, String> _styleMap = {};

  EditorHtmlStyle(String? styleString) {
    if (styleString != null && styleString.isNotEmpty) {
      // debugPrint('Parsing style string: $styleString'); // 디버깅용

      final styles = styleString
          .split(';')
          .where((s) => s.isNotEmpty)
          .map((s) => s.trim().split(':'))
          .where((parts) => parts.length == 2)
          .map((parts) {
        final key = _camelCase(parts[0].trim());
        final value = parts[1].trim();
        // debugPrint('Parsed style: $key = $value'); // 디버깅용
        return MapEntry(key, value);
      });

      _styleMap.addEntries(styles);
      _parseColumnRule();
      _parseBorder();
      _parsePadding();

      // debugPrint('Final style map: $_styleMap'); // 디버깅용
    }
  }

  void _parseColumnRule() {
    final rule = _styleMap['columnRule'];
    if (rule != null) {
      final parts = rule.split(RegExp(r'(?<=\)) |(?<!\()\ (?![^(]*\))'));

      _styleMap.remove('columnRuleWidth');
      _styleMap.remove('columnRuleStyle');
      _styleMap.remove('columnRuleColor');

      for (final part in parts) {
        if (_isWidth(part)) {
          _styleMap['columnRuleWidth'] = part;
        } else if (_isStyle(part)) {
          _styleMap['columnRuleStyle'] = part;
        } else if (_isColor(part)) {
          _styleMap['columnRuleColor'] = part;
        }
      }
    }
  }

  void _parseBorder() {
    final border = _styleMap['border'];
    if (border != null) {
      final parts = border.split(RegExp(r'(?<=\)) |(?<!\()\ (?![^(]*\))'));

      _styleMap.remove('borderWidth');
      _styleMap.remove('borderStyle');
      _styleMap.remove('borderColor');

      for (final part in parts) {
        if (_isWidth(part)) {
          _styleMap['borderWidth'] = part;
        } else if (_isStyle(part)) {
          _styleMap['borderStyle'] = part;
        } else if (_isColor(part)) {
          _styleMap['borderColor'] = part;
        }
      }
    }
  }

  bool _isWidth(String value) {
    return RegExp(r'^(\d+(\.\d+)?(px|em|rem|%|pt|pc|in|cm|mm|ex|ch|vw|vh)?)$')
        .hasMatch(value);
  }

  bool _isStyle(String value) {
    final borderStyles = {
      'none',
      'hidden',
      'dotted',
      'dashed',
      'solid',
      'double',
      'groove',
      'ridge',
      'inset',
      'outset'
    };
    return borderStyles.contains(value);
  }

  bool _isColor(String value) {
    return value.startsWith('#') ||
        value.startsWith('rgb') ||
        value.startsWith('rgba') ||
        value.startsWith('hsl') ||
        value.startsWith('hsla') ||
        RegExp(r'^[a-zA-Z]+$').hasMatch(value);
  }

  String _camelCase(String text) {
    final words = text.split('-');
    final camelCase = words.first +
        words
            .skip(1)
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join('');
    return camelCase;
  }

  String _kebabCase(String text) {
    return text.replaceAllMapped(
        RegExp(r'[A-Z]'), (match) => '-${match.group(0)?.toLowerCase()}');
  }

  // Column properties
  String? get columnCount => _styleMap['columnCount'];
  String? get columnFill => _styleMap['columnFill'];
  String? get columnGap => _styleMap['columnGap'];
  String? get columnRule => _styleMap['columnRule'];
  String? get columnRuleColor => _styleMap['columnRuleColor'];
  String? get columnRuleStyle => _styleMap['columnRuleStyle'];
  String? get columnRuleWidth => _styleMap['columnRuleWidth'];
  String? get columnSpan => _styleMap['columnSpan'];
  String? get columnWidth => _styleMap['columnWidth'];
  String? get columns => _styleMap['columns'];

  set columnCount(String? value) => _updateStyle('columnCount', value);
  set columnFill(String? value) => _updateStyle('columnFill', value);
  set columnGap(String? value) => _updateStyle('columnGap', value);
  set columnRule(String? value) {
    _updateStyle('columnRule', value);
    if (value != null) {
      _parseColumnRule();
    } else {
      _styleMap.remove('columnRuleWidth');
      _styleMap.remove('columnRuleStyle');
      _styleMap.remove('columnRuleColor');
    }
  }

  set columnRuleColor(String? value) => _updateStyle('columnRuleColor', value);
  set columnRuleStyle(String? value) => _updateStyle('columnRuleStyle', value);
  set columnRuleWidth(String? value) => _updateStyle('columnRuleWidth', value);
  set columnSpan(String? value) => _updateStyle('columnSpan', value);
  set columnWidth(String? value) => _updateStyle('columnWidth', value);
  set columns(String? value) => _updateStyle('columns', value);

  // Common CSS properties
  String? get fontSize => _styleMap['fontSize'];
  String? get fontFamily => _styleMap['fontFamily'];
  String? get color => _styleMap['color'];
  String? get backgroundColor => _styleMap['backgroundColor'];

  // URL에서 경로만 추출하는 새로운 getter 추가
  String? get backgroundImage {
    final bgImage = _styleMap['backgroundImage'];
    if (bgImage == null) return null;

    // url("경로") 형식에서 경로만 추출
    final regExp = RegExp(r'url\((.*?)\)');
    final match = regExp.firstMatch(bgImage);

    if (match == null) return null;

    String path = match.group(1) ?? '';
    // 따옴표 제거
    path = path.trim().replaceAll('"', '').replaceAll("'", '');

    return path;
  }

  String? get backgroundRepeat => _styleMap['backgroundRepeat'];
  String? get backgroundSize => _styleMap['backgroundSize'];

  // background-size를 파싱하여 width와 height 분리
  String? get backgroundImageWidth {
    final bgSize = _styleMap['backgroundSize'];
    if (bgSize == null) return null;

    final parts = bgSize.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts[0] : null;
  }

  String? get backgroundImageHeight {
    final bgSize = _styleMap['backgroundSize'];
    if (bgSize == null) return null;

    final parts = bgSize.trim().split(RegExp(r'\s+'));
    return parts.length > 1 ? parts[1] : null;
  }

  String? get display => _styleMap['display'];
  String? get position => _styleMap['position'];
  String? get width => _styleMap['width'];
  String? get height => _styleMap['height'];
  String? get left => _styleMap['left'];
  String? get top => _styleMap['top'];
  String? get margin => _styleMap['margin'];
  String? get padding {
    final paddingValue = _styleMap['padding'];
    if (paddingValue == null) return '0';

    // padding 값이 공백으로 구분된 여러 값인지 확인
    final parts = paddingValue.trim().split(' ');
    final hasIndividualPadding = parts.length > 1;

    // 개별 속성이 설정되어 있으면 0 리턴
    if (hasIndividualPadding) {
      return '0';
    }

    // 그렇지 않으면 기존 padding 값 리턴
    return paddingValue;
  }

  String? get opacity => _styleMap['opacity'];

  // padding 개별 속성 getter들
  String? get paddingLeft => _styleMap['paddingLeft'];
  String? get paddingRight => _styleMap['paddingRight'];
  String? get paddingTop => _styleMap['paddingTop'];
  String? get paddingBottom => _styleMap['paddingBottom'];

  // margin 개별 속성 getter들
  String? get marginLeft => _styleMap['marginLeft'];
  String? get marginRight => _styleMap['marginRight'];
  String? get marginTop => _styleMap['marginTop'];
  String? get marginBottom => _styleMap['marginBottom'];

  // padding 값을 파싱하여 개별 속성으로 설정하는 메서드
  void _parsePadding() {
    final paddingValue = _styleMap['padding'];
    if (paddingValue == null) return;

    final parts = paddingValue.trim().split(' ');

    switch (parts.length) {
      case 1:
        // "5px" -> 모든 방향에 동일한 값 적용
        final value = parts[0];
        _styleMap['paddingTop'] = value;
        _styleMap['paddingRight'] = value;
        _styleMap['paddingBottom'] = value;
        _styleMap['paddingLeft'] = value;
        break;
      case 2:
        // "5px 10px" -> top/bottom, left/right
        final verticalValue = parts[0];
        final horizontalValue = parts[1];
        _styleMap['paddingTop'] = verticalValue;
        _styleMap['paddingRight'] = horizontalValue;
        _styleMap['paddingBottom'] = verticalValue;
        _styleMap['paddingLeft'] = horizontalValue;
        break;
      case 3:
        // "5px 10px 15px" -> top, left/right, bottom
        final topValue = parts[0];
        final horizontalValue = parts[1];
        final bottomValue = parts[2];
        _styleMap['paddingTop'] = topValue;
        _styleMap['paddingRight'] = horizontalValue;
        _styleMap['paddingBottom'] = bottomValue;
        _styleMap['paddingLeft'] = horizontalValue;
        break;
      case 4:
        // "5px 10px 15px 20px" -> top, right, bottom, left
        _styleMap['paddingTop'] = parts[0];
        _styleMap['paddingRight'] = parts[1];
        _styleMap['paddingBottom'] = parts[2];
        _styleMap['paddingLeft'] = parts[3];
        break;
    }
  }

  // padding setter 수정 - 값이 설정될 때 파싱 실행
  set padding(String? value) {
    _updateStyle('padding', value);
    if (value != null) {
      _parsePadding();
    } else {
      // padding이 null이면 개별 속성들도 제거
      _styleMap.remove('paddingTop');
      _styleMap.remove('paddingRight');
      _styleMap.remove('paddingBottom');
      _styleMap.remove('paddingLeft');
    }
  }

  // 개별 padding 속성 setter들
  set paddingLeft(String? value) => _updateStyle('paddingLeft', value);
  set paddingRight(String? value) => _updateStyle('paddingRight', value);
  set paddingTop(String? value) => _updateStyle('paddingTop', value);
  set paddingBottom(String? value) => _updateStyle('paddingBottom', value);

  // margin 값을 파싱하여 개별 속성으로 설정하는 메서드
  void _parseMargin() {
    final marginValue = _styleMap['margin'];
    if (marginValue == null) return;

    final parts = marginValue.trim().split(' ');

    switch (parts.length) {
      case 1:
        // "5px" -> 모든 방향에 동일한 값 적용
        final value = parts[0];
        _styleMap['marginTop'] = value;
        _styleMap['marginRight'] = value;
        _styleMap['marginBottom'] = value;
        _styleMap['marginLeft'] = value;
        break;
      case 2:
        // "5px 10px" -> top/bottom, left/right
        final verticalValue = parts[0];
        final horizontalValue = parts[1];
        _styleMap['marginTop'] = verticalValue;
        _styleMap['marginRight'] = horizontalValue;
        _styleMap['marginBottom'] = verticalValue;
        _styleMap['marginLeft'] = horizontalValue;
        break;
      case 3:
        // "5px 10px 15px" -> top, left/right, bottom
        final topValue = parts[0];
        final horizontalValue = parts[1];
        final bottomValue = parts[2];
        _styleMap['marginTop'] = topValue;
        _styleMap['marginRight'] = horizontalValue;
        _styleMap['marginBottom'] = bottomValue;
        _styleMap['marginLeft'] = horizontalValue;
        break;
      case 4:
        // "5px 10px 15px 20px" -> top, right, bottom, left
        _styleMap['marginTop'] = parts[0];
        _styleMap['marginRight'] = parts[1];
        _styleMap['marginBottom'] = parts[2];
        _styleMap['marginLeft'] = parts[3];
        break;
    }
  }

  // margin setter 수정 - 값이 설정될 때 파싱 실행
  set margin(String? value) {
    _updateStyle('margin', value);
    if (value != null) {
      _parseMargin();
    } else {
      // margin이 null이면 개별 속성들도 제거
      _styleMap.remove('marginTop');
      _styleMap.remove('marginRight');
      _styleMap.remove('marginBottom');
      _styleMap.remove('marginLeft');
    }
  }

  // 개별 margin 속성 setter들
  set marginLeft(String? value) => _updateStyle('marginLeft', value);
  set marginRight(String? value) => _updateStyle('marginRight', value);
  set marginTop(String? value) => _updateStyle('marginTop', value);
  set marginBottom(String? value) => _updateStyle('marginBottom', value);

  set fontSize(String? value) => _updateStyle('fontSize', value);
  set fontFamily(String? value) => _updateStyle('fontFamily', value);
  set color(String? value) => _updateStyle('color', value);
  set backgroundColor(String? value) => _updateStyle('backgroundColor', value);
  set backgroundSize(String? value) => _updateStyle('backgroundSize', value);
  set backgroundRepeat(String? value) =>
      _updateStyle('backgroundRepeat', value);
  set display(String? value) => _updateStyle('display', value);
  set position(String? value) => _updateStyle('position', value);
  set width(String? value) => _updateStyle('width', value);
  set height(String? value) => _updateStyle('height', value);
  set left(String? value) => _updateStyle('left', value);
  set top(String? value) => _updateStyle('top', value);

  // border 속성 getter/setter 추가
  String? get border => _styleMap['border'];
  String? get borderWidth => _styleMap['borderWidth'];
  String? get borderStyle => _styleMap['borderStyle'];
  String? get borderColor => _styleMap['borderColor'];

  set border(String? value) {
    _updateStyle('border', value);
    if (value != null) {
      _parseBorder();
    } else {
      _styleMap.remove('borderWidth');
      _styleMap.remove('borderStyle');
      _styleMap.remove('borderColor');
    }
  }

  set borderWidth(String? value) => _updateStyle('borderWidth', value);
  set borderStyle(String? value) => _updateStyle('borderStyle', value);
  set borderColor(String? value) => _updateStyle('borderColor', value);

  void _updateStyle(String property, String? value) {
    if (value == null) {
      _styleMap.remove(property);
    } else {
      _styleMap[property] = value;
    }
  }

  String? getProperty(String name) {
    return _styleMap[_camelCase(name)];
  }

  void setProperty(String name, String? value) {
    _updateStyle(_camelCase(name), value);
  }

  @override
  String toString() {
    return _styleMap.entries
        .map((entry) => '${_kebabCase(entry.key)}: ${entry.value}')
        .join('; ');
  }
}

class EditorHtmlNode {
  final String nodeName;
  final String nodeType;
  final String textContent;
  final String innerHTML;
  final Map<String, String> attributes;
  final web.Node webNode;
  late final EditorHtmlStyle style;

  EditorHtmlNode({
    required this.nodeName,
    required this.nodeType,
    required this.textContent,
    required this.attributes,
    required this.innerHTML,
    required this.webNode,
  }) {
    style = EditorHtmlStyle(attributes['style']);
  }

  factory EditorHtmlNode.fromNode(web.Node node) {
    String innerHTML = '';

    try {
      if (node is web.Element) {
        innerHTML = node.innerHTML.toString();
      }
    } catch (e) {
      debugPrint('innnerHTML null : $e');
    }

    return EditorHtmlNode(
      nodeName: node.nodeName.toString(),
      nodeType: node.nodeType.toString(),
      textContent: node.textContent ?? '',
      innerHTML: innerHTML,
      attributes: _getAttributes(node),
      webNode: node,
    );
  }

  EditorHtmlNode copyWith({
    String? nodeName,
    String? nodeType,
    String? textContent,
    String? innerHTML,
    Map<String, String>? attributes,
    web.Node? webNode,
  }) {
    if (innerHTML != null && this.webNode is web.Element) {
      (this.webNode as web.Element).innerHTML = innerHTML.toJS;
    }

    return EditorHtmlNode(
      nodeName: nodeName ?? this.nodeName,
      nodeType: nodeType ?? this.nodeType,
      textContent: textContent ?? this.textContent,
      innerHTML: innerHTML ?? this.innerHTML,
      attributes: attributes ?? Map<String, String>.from(this.attributes),
      webNode: webNode ?? this.webNode,
    );
  }

  static Map<String, String> _getAttributes(web.Node node) {
    final attributes = <String, String>{};
    try {
      if (node is web.Element) {
        final attributeList = node.attributes;
        for (var i = 0; i < attributeList.length; i++) {
          final attr = attributeList.item(i);
          if (attr != null) {
            attributes[attr.name] = attr.value;
          }
        }
      }
    } catch (e) {
      //debugPrint('속성 가져오기 오류: $e');
    }
    return attributes;
  }

  // void _updateDomStyle() {
  //   if (webNode is web.Element) {
  //     final styleString = style.toString();
  //     if (styleString.isNotEmpty) {
  //       (webNode as web.Element).setAttribute('style', styleString.toJS);
  //       attributes['style'] = styleString;
  //     } else {
  //       (webNode as web.Element).removeAttribute('style'.toJS);
  //       attributes.remove('style');
  //     }
  //   }
  // }

  List<EditorHtmlNode> getChildNodes() {
    List<EditorHtmlNode> children = [];
    final childNodes = webNode.childNodes;
    for (var i = 0; i < childNodes.length; i++) {
      final child = childNodes.item(i);
      if (child != null) {
        children.add(EditorHtmlNode.fromNode(child));
      }
    }
    return children;
  }

  EditorHtmlNode? getParentNode() {
    final parent = webNode.parentNode;
    if (parent != null) {
      return EditorHtmlNode.fromNode(parent);
    }
    return null;
  }

  EditorHtmlNode? getNextSibling() {
    final next = webNode.nextSibling;
    if (next != null) {
      return EditorHtmlNode.fromNode(next);
    }
    return null;
  }

  EditorHtmlNode? getPreviousSibling() {
    final prev = webNode.previousSibling;
    if (prev != null) {
      return EditorHtmlNode.fromNode(prev);
    }
    return null;
  }

  @override
  String toString() {
    return 'EditorHtmlNode(nodeName: $nodeName, nodeType: $nodeType, textContent: $textContent, attributes: $attributes)';
  }
}
