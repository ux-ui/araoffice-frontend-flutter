import 'package:author_editor/extension/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/editor_constants.dart';
import '../data/vulcan_shape_item_data.dart';
import '../engine/engines.dart';
import '../enum/enums.dart';

/// Shape 관련 기능을 관리하는 Mixin
mixin ShapeControlMixin on GetxController {
  Editor? get editor;
  EditorHtmlNode? get currentNode;

  // Shape properties
  final rxShapeBackgroundColor = Rx<Color>(Colors.black);
  final rxShapeLineColor = Rx<Color>(Colors.black);
  final rxShapeLineWidth = EditorConstants.defaultLineWidth.obs;
  final rxShapeLineHeadType = Rx<ShapeLineType?>(ShapeLineType.none);
  final rxShapeLineTailType = Rx<ShapeLineType?>(ShapeLineType.none);
  final rxShapeLineHeadTailSize = EditorConstants.defaultHeadTailSize.obs;

  /// 도형을 삽입합니다
  /// [type] 도형의 종류
  /// [index] 도형의 스타일 인덱스
  void insertShape(String type, int index) => editor?.insertShape(type, index);

  /// 도형의 배경색을 설정합니다
  void setShapeBackColor(Color color) {
    rxShapeBackgroundColor.value = color;
    editor?.setShapeBackColor(rxShapeBackgroundColor.value.toRgbString());
  }

  /// 도형의 선 색상을 설정합니다
  void setShapeLineColor(Color color) {
    rxShapeLineColor.value = color;
    editor?.setShapeLineColor(rxShapeLineColor.value.toRgbString());
  }

  /// 도형의 선 두께를 설정합니다
  void setShapeLineWidth(int value) {
    rxShapeLineWidth.value = value;
    editor?.setShapeLineWidth(rxShapeLineWidth.value);
  }

  /// 도형 선의 시작 부분 스타일을 설정합니다
  void setShapeLineHeadType(ShapeLineType type) {
    rxShapeLineHeadType.value = type;
    editor?.setShapeLineHeadType(type.name);
  }

  /// 도형 선의 끝 부분 스타일을 설정합니다
  void setShapeLineTailType(ShapeLineType type) {
    rxShapeLineTailType.value = type;
    editor?.setShapeLineTailType(type.name);
  }

  /// 도형 선의 시작/끝 부분 크기를 설정합니다
  void setShapeLineHeadTailSize(int value) {
    rxShapeLineHeadTailSize.value = value;
    editor?.setShapeLineHeadTailSize(rxShapeLineHeadTailSize.value);
  }

  void setShapeAttributes(EditorHtmlNode node) {
    if (node.nodeName == 'canvas') {
      final shapeSettings = node.attributes['data-ve-shape-setting'];
      if (shapeSettings != null) {
        final shapeData = VulcanShapeItemData.fromString(shapeSettings);
        // 배경색 설정
        rxShapeBackgroundColor.value =
            shapeData.fillColorValue ?? Colors.transparent;
        // 테두리 색상 설정
        rxShapeLineColor.value =
            shapeData.strokeColorValue ?? Colors.transparent;
        // 선 두께 설정
        rxShapeLineWidth.value = shapeData.lineWidthValue.toInt();
      }
    }
  }

  /// 도형의 초기 상태값을 설정합니다
  void resetShapeState() {
    rxShapeBackgroundColor.value = Colors.black;
    rxShapeLineColor.value = Colors.black;
    rxShapeLineWidth.value = EditorConstants.defaultLineWidth;
    rxShapeLineHeadType.value = ShapeLineType.none;
    rxShapeLineTailType.value = ShapeLineType.none;
    rxShapeLineHeadTailSize.value = EditorConstants.defaultHeadTailSize;
  }
}
