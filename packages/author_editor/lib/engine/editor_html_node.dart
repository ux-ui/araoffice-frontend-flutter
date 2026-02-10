import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'editor_html_style.dart';

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

    final attributes = _getAttributes(node);

    // 이미지 노드인 경우 style에 width와 height 추가
    if (node is web.HTMLImageElement) {
      if (node.nodeName == 'img') {
        final styleAttr = attributes['style'] ?? '';
        if (!styleAttr.contains('width') || !styleAttr.contains('height')) {
          final width = node.naturalWidth;
          final height = node.naturalHeight;

          final existingStyle = styleAttr.isEmpty ? '' : '$styleAttr; ';
          attributes['style'] =
              '${existingStyle}width: ${width}px; height: ${height}px';
        }
      }
    }

    try {
      if (node is web.Element) {
        innerHTML = node.innerHTML.toString();
      }
    } catch (e) {
      //debugPrint('innnerHTML null : $e');
    }

    return EditorHtmlNode(
      nodeName: node.nodeName.toString(),
      nodeType: node.nodeType.toString(),
      textContent: node.textContent ?? '',
      innerHTML: innerHTML,
      attributes: attributes,
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

  /// 현재 노드의 상위 테이블 노드를 찾아서 (web.Node?, EditorHtmlNode?) 쌍으로 반환합니다.
  (web.Node?, EditorHtmlNode?) findParentTableNode() {
    EditorHtmlNode? currentNode = this;

    while (currentNode != null) {
      // 현재 노드가 테이블인지 확인
      if (currentNode.nodeName.toUpperCase() == 'TABLE') {
        // web.Element에서 style 속성을 직접 가져옵니다
        final element = currentNode.webNode as web.Element;
        final attributes = _getAttributes(currentNode.webNode);

        // style 속성이 포함된 새로운 attributes map을 생성
        if (element.getAttribute('style') != null) {
          attributes['style'] = element.getAttribute('style')!.toString();
        }

        // 새로운 EditorHtmlNode 인스턴스를 생성
        final tableEditorNode = EditorHtmlNode(
          nodeName: currentNode.nodeName,
          nodeType: currentNode.nodeType,
          textContent: currentNode.textContent,
          innerHTML: element.innerHTML.toString(),
          attributes: attributes,
          webNode: currentNode.webNode,
        );

        return (currentNode.webNode, tableEditorNode);
      }
      // 부모 노드로 이동
      currentNode = currentNode.getParentNode();
    }
    return (null, null);
  }

  /// 이 노드가 테이블의 셀(TD 또는 TH)인지 확인합니다.
  bool isTableCell() {
    final upperNodeName = nodeName.toUpperCase();
    return upperNodeName == 'TD' || upperNodeName == 'TH';
  }

  /// 현재 노드가 테이블의 행(TR)인지 확인합니다.
  bool isTableRow() {
    return nodeName.toUpperCase() == 'TR';
  }

  /// 현재 노드가 테이블인지 확인합니다.
  bool isTable() {
    return nodeName.toUpperCase() == 'TABLE';
  }

  @override
  String toString() {
    return 'EditorHtmlNode(nodeName: $nodeName, nodeType: $nodeType, textContent: $textContent, attributes: $attributes)';
  }
}
