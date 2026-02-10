// lib/mixins/style_control_mixin.dart
import 'dart:js_interop';

import 'package:author_editor/extension/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

import '../engine/engines.dart';
import '../enum/enums.dart';

/// 스타일링 관련 기능을 관리하는 Mixin
mixin StyleControlMixin on GetxController {
  Editor? get editor;
  EditorHtmlNode? get currentNode;

  // Style properties
  final rxBorderWidth = 0.obs;
  final rxBorderColor = Rx<Color>(Colors.transparent);
  final rxBorderStyle = BorderStyleType.none.obs;

  // Table border properties
  final rxTableBorderWidth = 0.obs;
  final rxTableBorderColor = Rx<Color>(Colors.black);
  final rxTableBorderStyle = BorderStyleType.none.obs;

  final rxPadding = '0'.obs;
  final rxPaddingLeft = '0'.obs;
  final rxPaddingRight = '0'.obs;
  final rxPaddingTop = '0'.obs;
  final rxPaddingBottom = '0'.obs;

  // Margin properties
  final rxMargin = '0'.obs;
  final rxMarginLeft = '0'.obs;
  final rxMarginRight = '0'.obs;
  final rxMarginTop = '0'.obs;
  final rxMarginBottom = '0'.obs;

  final rxOpacity = '0'.obs;
  final rxWidth = 100.0.obs;
  final rxHeight = 100.0.obs;
  final rxBackgroundWidth = ''.obs;
  final rxBackgroundHeight = ''.obs;
  final rxLocationX = 0.0.obs;
  final rxLocationY = 0.0.obs;

  /// 테두리 스타일을 설정합니다
  /// 테이블과 일반 요소의 테두리 스타일을 구분하여 처리합니다
  /// [type]이 'table'인 경우 테이블 테두리 스타일을 적용합니다
  void setBorder({String? type}) {
    // 테이블 노드 찾기
    final tableNode = currentNode?.findParentTableNode();
    final web.Node? webNode = tableNode?.$1;

    if (type == 'table' && webNode != null) {
      // 테이블 테두리 스타일 적용
      final tableBorderStyle =
          '${rxTableBorderWidth.value}px ${rxTableBorderStyle.value.optionName} ${rxTableBorderColor.value.toRgbString()}';
      editor?.setStyle(webNode, 'border', tableBorderStyle);
    } else {
      // 일반 요소 또는 셀 테두리 스타일 적용
      final selectedCells = editor?.selectedCells().toDart;
      if (selectedCells?.isEmpty == true) {
        // 일반 요소에 테두리 적용
        final borderStyle =
            '${rxBorderWidth.value}px ${rxBorderStyle.value.optionName} ${rxBorderColor.value.toRgbString()}';
        editor?.setStyle(currentNode!.webNode, 'border', borderStyle);
      } else {
        // 선택된 셀들에 테두리 적용
        selectedCells?.forEach((cell) {
          final cellBorderStyle =
              '${rxBorderWidth.value}px ${rxBorderStyle.value.optionName} ${rxBorderColor.value.toRgbString()}';
          editor?.setStyle(cell, 'border', cellBorderStyle);
        });
      }
    }
  }

  /// 패딩을 설정합니다
  void setPadding(String value, {PaddingType? type}) {
    if (type == PaddingType.left) {
      rxPaddingLeft.value = value;
      editor?.setStyle(currentNode!.webNode, 'padding-left', '${value}px');
    } else if (type == PaddingType.right) {
      rxPaddingRight.value = value;
      editor?.setStyle(currentNode!.webNode, 'padding-right', '${value}px');
    } else if (type == PaddingType.top) {
      rxPaddingTop.value = value;
      editor?.setStyle(currentNode!.webNode, 'padding-top', '${value}px');
    } else if (type == PaddingType.bottom) {
      rxPaddingBottom.value = value;
      editor?.setStyle(currentNode!.webNode, 'padding-bottom', '${value}px');
    } else {
      // 모든 방향에 동일한 값 적용
      rxPadding.value = value;
      rxPaddingLeft.value = value;
      rxPaddingRight.value = value;
      rxPaddingTop.value = value;
      rxPaddingBottom.value = value;
      editor?.setStyle(currentNode!.webNode, 'padding', '${value}px');
    }
  }

  /// 마진을 설정합니다
  void setMargin(String value, {MarginType? type}) {
    if (type == MarginType.left) {
      rxMarginLeft.value = value;
      editor?.setStyle(currentNode!.webNode, 'margin-left', '${value}px');
    } else if (type == MarginType.right) {
      rxMarginRight.value = value;
      editor?.setStyle(currentNode!.webNode, 'margin-right', '${value}px');
    } else if (type == MarginType.top) {
      rxMarginTop.value = value;
      editor?.setStyle(currentNode!.webNode, 'margin-top', '${value}px');
    } else if (type == MarginType.bottom) {
      rxMarginBottom.value = value;
      editor?.setStyle(currentNode!.webNode, 'margin-bottom', '${value}px');
    } else {
      // 모든 방향에 동일한 값 적용
      rxMargin.value = value;
      rxMarginLeft.value = value;
      rxMarginRight.value = value;
      rxMarginTop.value = value;
      rxMarginBottom.value = value;
      editor?.setStyle(currentNode!.webNode, 'margin', '${value}px');
    }
  }

  /// 크기를 설정합니다
  void setSize({double? width, double? height}) {
    final selectedCells = editor?.selectedCells().toDart;

    if (selectedCells?.isEmpty == true) {
      if (width != null) {
        rxWidth.value = width;
        editor?.setStyle(currentNode!.webNode, 'width', '${width}px');
      }
      if (height != null) {
        rxHeight.value = height;
        editor?.setStyle(currentNode!.webNode, 'height', '${height}px');
      }
    } else {
      // 선택된 셀들에 크기 적용
      selectedCells?.forEach((cell) {
        if (width != null) {
          editor?.setStyle(cell, 'width', '${width}px');
        }
        if (height != null) {
          editor?.setStyle(cell, 'height', '${height}px');
        }
      });
    }
  }

  void setWidth({required String value, String? type}) {
    final selectedCells = editor?.selectedCells().toDart;
    if (selectedCells?.isEmpty == true) {
      editor?.setStyle(currentNode!.webNode, 'width', '${value}px');
    } else {
      selectedCells?.forEach((cell) {
        editor?.setStyle(cell, 'width', '${value}px');
      });
    }
  }

  void setHeight({required String value, String? type}) {
    final selectedCells = editor?.selectedCells().toDart;
    if (selectedCells?.isEmpty == true) {
      editor?.setStyle(currentNode!.webNode, 'height', '${value}px');
    } else {
      selectedCells?.forEach((cell) {
        editor?.setStyle(cell, 'height', '${value}px');
      });
    }
  }

  void setBackgroundSize(String width, String height) {
    final value = '${width}px ${height}px';
    final selectedCells = editor?.selectedCells().toDart;
    if (selectedCells?.isEmpty == true) {
      editor?.setStyle(currentNode!.webNode, 'background-size', value);
    } else {
      selectedCells?.forEach((cell) {
        editor?.setStyle(cell, 'background-size', value);
      });
    }
  }

  void setLeft(String value) =>
      editor?.setStyle(currentNode!.webNode, 'left', '${value}px');

  void setTop(String value) =>
      editor?.setStyle(currentNode!.webNode, 'top', '${value}px');

  /// 위치를 설정합니다
  void setPosition({double? x, double? y}) {
    if (x != null) {
      rxLocationX.value = x;
      editor?.setStyle(currentNode!.webNode, 'left', '${x}px');
    }
    if (y != null) {
      rxLocationY.value = y;
      editor?.setStyle(currentNode!.webNode, 'top', '${y}px');
    }
  }

  /// 투명도를 설정합니다
  void setOpacity(String value) {
    rxOpacity.value = value;
    editor?.setStyle(
        currentNode!.webNode, 'opacity', value.transparencyToOpacity());
  }

  /// 모든 스타일을 제거합니다
  void removeAllStyle() => editor?.removeAllStyle();
}
