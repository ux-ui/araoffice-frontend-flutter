// lib/mixins/text_editing_mixin.dart
import 'dart:js_interop';

import 'package:author_editor/extension/extensions.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

import '../constants/editor_constants.dart';
import '../constants/style_constants.dart';
import '../data/vulcan_font_data.dart';
import '../engine/engines.dart';
import '../enum/enums.dart';
import 'mixins.dart';

mixin TextEditingMixin on GetxController {
  // Abstract getter for editor
  Editor? get editor;
  WidgetSliderMixin get sliderMixin;

  // Text properties
  final rxFontData = VulcanFontData(
    family: 'default_font'.tr,
    name: 'default_font'.tr,
    installed: false,
    isSystemDefault: true,
  ).obs;
  final rxFontSize = EditorConstants.defaultFontSize.obs;
  final rxTextColor = StyleConstants.defaultTextColor.obs;
  final rxFontBackColor = StyleConstants.defaultBackgroundColor.obs;
  final rxTextDecorations = RxList<TextDecorationType>([]);
  final rxTextPosition = Rx<TextPositionType?>(null);
  final rxTextAlign = Rx<TextAlignType?>(null);
  final rxLineSpacing = ''.obs;
  final rxLinePaddingTop = '10'.obs;
  final rxLinePaddingBottom = '10'.obs;
  final rxLetterSpacing = ''.obs;
  final rxIndent = 0.obs;
  final rxFontWidth = '50'.obs;

  // Heading
  final rxHeading = Rx<HeadingType?>(null);
  final rxDisabledTextbox = false.obs;
  final rxDisabledOlList = false.obs;
  final rxDisabledUlList = false.obs;

  final rxObjectBackColor = Rx<Color>(Colors.transparent);
  final rxTableBackColor = Rx<Color>(Colors.transparent);
  final rxObjectBackRepeat = BackgroundRepeatType.repeat.obs;
  final rxTableBackRepeat = BackgroundRepeatType.repeat.obs;
  final rxObjectBackPosition = '0% 0%'.obs;
  final rxTableBackPosition = '0% 0%'.obs;

  final rxObjectBackImage = ''.obs;
  final rxTableBackImage = ''.obs;

  final rxBold = false.obs;
  final rxItalic = false.obs;
  final rxUnderline = false.obs;
  final rxOverline = false.obs;
  final rxStrike = false.obs;
  final rxSubScript = false.obs;
  final rxSuperScript = false.obs;
  final rxNeedToApplyTypingStyle = false.obs; // nullable인 경우에도 초기값 설정

  final rxEditorHtmlNode = Rx<EditorHtmlNode?>(null);
  final rxMultiSelectedNodes = <EditorHtmlNode?>[].obs;

  final rxPadding = '0'.obs;
  final rxOpacity = '0'.obs;

  String ulListClassName = 'list-number';

  // ______ multi_Column ____________
  final rxMultiColumnCount = 1.obs;
  final rxMultiColumnGap = 10.obs;
  final rxMultiColumnRuleWidth = 1.obs;
  final rxMultiColumnRuleColor = Rx<Color>(Colors.black);
  final rxMultiColumnFillOption = MultiColumnFillType.auto.obs;
  final rxMultiColumnRuleStyleOption = BorderStyleType.none.obs;

  final rxCanIndentList = false.obs;
  final rxListStyleIndex = 2.obs;
  final rxUlStyleType = UlStyleType.none.obs;
  final rxOlStyleType = OlStyleType.none.obs;

  TextBoxType isTextbox() {
    if (rxEditorHtmlNode.value == null) {
      return TextBoxType.defaultType;
    }

    final isTextbox = editor?.isTextbox(rxEditorHtmlNode.value!.webNode);
    return TextBoxType.fromString(isTextbox ?? TextBoxType.defaultType.value);
  }

  void checkIntentOutdentList() {
    final canIndentList = editor?.canIndentList() ?? false;
    final canOutdentList = editor?.canOutdentList() ?? false;
    rxCanIndentList.value = canIndentList || canOutdentList;
  }

  void getListStyle() {
    // 빈문자열 이면 <ol>, 값이 있으면 <ul>
    final listStyle = editor?.getListStyle();

    if (listStyle?.tagType == 'ul') {
      rxListStyleIndex.value = 0;
      rxDisabledUlList.value = true;
      rxDisabledOlList.value = false;
      rxUlStyleType.value = UlStyleType.fromTranslationKey(
          listStyle?.style ?? UlStyleType.none.name);
    } else if (listStyle?.tagType == 'ol') {
      rxListStyleIndex.value = 1;
      rxDisabledUlList.value = false;
      rxDisabledOlList.value = true;
      rxOlStyleType.value = OlStyleType.fromTranslationKey(
          listStyle?.style ?? OlStyleType.none.name);
    } else {
      rxListStyleIndex.value = 2;
      rxDisabledUlList.value = false;
      rxDisabledOlList.value = false;
    }
  }

  void setTextColor(Color color) {
    rxTextColor.value = color;
    editor?.applyTextColor(color.toRgbaString());
  }

  void setFontBackColor(Color color) {
    rxFontBackColor.value = color;
    editor?.applyBackColor(rxFontBackColor.value.toRgbaString());
    // debugPrint('setFontBackColor: ${rxFontBackColor.value}');
  }

  void setFontSize(String fontSize) {
    rxFontSize.value = fontSize;
    editor?.applyFontSize(fontSize);
  }

  void setTextAlign(String align) {
    // 테이블 노드 찾기
    final selectedCells = editor?.selectedCells().toDart;
    if (selectedCells?.isEmpty == true || selectedCells?.length == 1) {
      rxTextAlign.value = TextAlignTypeExtension.fromString(align);
      editor?.applyTextAlign(align);
    } else {
      selectedCells?.forEach((cell) {
        rxTextAlign.value = TextAlignTypeExtension.fromString(align);
        editor?.setStyle(cell, 'text-align', align);
      });
    }
  }

  void convertTextbox(TextBoxType type) {
    final value = type.value;
    editor?.convertTextbox(rxEditorHtmlNode.value!.webNode, value);
  }

  void disableList(int index) {
    rxListStyleIndex.value = index;
    if (index == 0) {
      rxDisabledUlList.value = true;
      rxDisabledOlList.value = false;
    } else if (index == 1) {
      rxDisabledUlList.value = false;
      rxDisabledOlList.value = true;
    } else if (index == 2) {
      rxDisabledUlList.value = false;
      rxDisabledOlList.value = false;
      editor?.unapplyList();
    }
  }

  void setLetterSpacing(String space) {
    rxLetterSpacing.value = space;
    editor?.applyLetterSpacing(space);
  }

  void setLineSpacing(String height) {
    rxLineSpacing.value = height;
    editor?.applyLineHeight(height);
  }

  void setIndentList(int value) {
    if (value == 0) {
      editor?.outdentList();
    } else {
      editor?.indentList();
    }
  }

  void setListClass(int value) {
    editor?.applyListClass(value);
  }

  void applyList(String type) {
    editor?.applyList(type);
  }

  /// 지정된 text decoration을 적용하고, 지정되지 않은 text decoration들은 제거합니다.
  /// bold, itealic, underline, overline, strikethrough
  void textDecorationToggle(List<TextDecorationType> types) {
    rxTextDecorations.value = types;
    _applyTextDecorations(types);
  }

  void setFontFamily(VulcanFontData font) {
    logger.d('[VulcanFontListData] setFontFamily: ${font.family}');
    rxFontData.value = font;
    if (font.isSystemDefault) {
      editor?.removeFontFamily();
    } else {
      editor?.applyFontFamily(font.family);
    }
  }

  void _applyTextDecorations(List<TextDecorationType> types) {
    final decorationActions = {
      TextDecorationType.bold: (bool apply) =>
          apply ? editor?.applyBold() : editor?.removeBold(),
      TextDecorationType.italic: (bool apply) =>
          apply ? editor?.applyItalic() : editor?.removeItalic(),
      TextDecorationType.underline: (bool apply) =>
          apply ? editor?.applyUnderline() : editor?.removeUnderline(),
      TextDecorationType.overline: (bool apply) =>
          apply ? editor?.applyOverline() : editor?.removeOverline(),
      TextDecorationType.strike: (bool apply) =>
          apply ? editor?.applyStrike() : editor?.removeStrike(),
    };

    for (final type in TextDecorationType.values) {
      decorationActions[type]?.call(types.contains(type));
    }
  }

  //________Text Box_________
  void insertTextbox(String type) => editor?.insertTextbox(type, '내용을 입력하세요.');
  void insertImage(String src, String type) {
    if (type == 'widget') {
      sliderMixin.changeSliderIcon(src);
    } else {
      editor?.insertImage(src);
    }
  }

  void insertVideo(String src) => editor?.insertVideo(src);
  void insertAudio(String src) => editor?.insertAudio(src);

  //- 기호문자표 기능에서 사용
  // 캐럿이 선택되어있으면 문자 삽입
  // 이외 선택은 객체(자동맞춤 텍스트박스)로 삽입
  void insertText(String text) => editor?.insertText(text);

  //______Text Box Attribute______

  void setObjectBackColor({required Color color, String? type}) {
    // 테이블 노드 찾기
    final tableNode = rxEditorHtmlNode.value?.findParentTableNode();
    final web.Node? webNode = tableNode?.$1;

    if (type == 'table' && webNode != null) {
      rxTableBackColor.value = color;
      // web.Node 타입의 테이블 노드를 얻게 됩니다
      debugPrint('Found table: ${webNode.nodeName}');
      editor?.setStyle(
          webNode, 'background-color', rxTableBackColor.value.toRgbaString());
    } else {
      /// cell 선택인지 여부에 따라 webNode를 달리한다.
      rxObjectBackColor.value = color;
      final selectedCells = editor?.selectedCells().toDart;
      if (selectedCells?.isEmpty == true) {
        editor?.setStyle(rxEditorHtmlNode.value!.webNode, 'background-color',
            rxObjectBackColor.value.toRgbaString());
      } else {
        selectedCells?.forEach((cell) {
          editor?.setStyle(
              cell, 'background-color', rxObjectBackColor.value.toRgbaString());
        });
      }
    }
  }

  void setObjectBackImage({required String path, String? type}) {
    // 테이블 노드 찾기
    final tableNode = rxEditorHtmlNode.value?.findParentTableNode();
    final web.Node? webNode = tableNode?.$1;

    if (type == 'table' && webNode != null) {
      rxTableBackImage.value = path;
      // web.Node 타입의 테이블 노드를 얻게 됩니다
      debugPrint('Found table: ${webNode.nodeName}');
      editor?.setStyle(webNode, 'background-image', rxTableBackImage.value);
    } else {
      /// cell 선택인지 여부에 따라 webNode를 달리한다.
      rxObjectBackImage.value = path;
      final selectedCells = editor?.selectedCells().toDart;
      if (selectedCells?.isEmpty == true) {
        editor?.setStyle(rxEditorHtmlNode.value!.webNode, 'background-image',
            'url(${rxObjectBackImage.value})');
      } else {
        selectedCells?.forEach((cell) {
          editor?.setStyle(
              cell, 'background-image', 'url(${rxObjectBackImage.value})');
        });
      }
    }
  }

  void setObjectBackRepeat(
      {required BackgroundRepeatType repeat, String? type}) {
    // 테이블 노드 찾기
    final tableNode = rxEditorHtmlNode.value?.findParentTableNode();
    final web.Node? webNode = tableNode?.$1;

    if (type == 'table' && webNode != null) {
      rxTableBackRepeat.value = repeat;
      // web.Node 타입의 테이블 노드를 얻게 됩니다
      debugPrint('Found table: ${webNode.nodeName}');
      editor?.setStyle(
          webNode, 'background-repeat', rxTableBackRepeat.value.name);
    } else {
      /// cell 선택인지 여부에 따라 webNode를 달리한다.
      rxObjectBackRepeat.value = repeat;
      final selectedCells = editor?.selectedCells().toDart;
      if (selectedCells?.isEmpty == true) {
        editor?.setStyle(rxEditorHtmlNode.value!.webNode, 'background-repeat',
            rxObjectBackRepeat.value.name);
      } else {
        selectedCells?.forEach((cell) {
          editor?.setStyle(
              cell, 'background-repeat', rxObjectBackRepeat.value.name);
        });
      }
    }
  }

  void setObjectBackPosition({required String position, String? type}) {
    // 테이블 노드 찾기
    final tableNode = rxEditorHtmlNode.value?.findParentTableNode();
    final web.Node? webNode = tableNode?.$1;

    if (type == 'table' && webNode != null) {
      rxTableBackPosition.value = position;
      // web.Node 타입의 테이블 노드를 얻게 됩니다
      debugPrint('Found table: ${webNode.nodeName}');
      editor?.setStyle(
          webNode, 'background-position', rxTableBackPosition.value);
    } else {
      /// cell 선택인지 여부에 따라 webNode를 달리한다.
      rxObjectBackPosition.value = position;
      final selectedCells = editor?.selectedCells().toDart;
      if (selectedCells?.isEmpty == true) {
        editor?.setStyle(rxEditorHtmlNode.value!.webNode, 'background-position',
            rxObjectBackPosition.value);
      } else {
        selectedCells?.forEach((cell) {
          editor?.setStyle(
              cell, 'background-position', rxObjectBackPosition.value);
        });
      }
    }
  }

  void focus() => editor?.focus();

  void setParagraphTag(String tagName) => editor?.replaceParagraphTag(tagName);

  void setTextPosition(TextPositionType? type) {
    if (type == null) {
      editor?.removeSubScript();
      editor?.removeSuperScript();
      return;
    }

    switch (type) {
      case TextPositionType.subscript:
        editor?.applySubScript();
      case TextPositionType.superscript:
        editor?.applySuperScript();
    }
  }

  void setTextStyle(int index) => editor?.applyTextClass(index);
  void setUlListStyle(int index) {
    final isInsideOrderedList = editor?.isInsideOrderedList();
    if (isInsideOrderedList == true) {
      ulListClassName = UlListType.getNameFromIndex(index);
      editor?.applyListStyle(ulListClassName);
    }
  }

  void setBorderRadius(String value) {
    final valuePX = '${value}px';
    editor?.setStyle(
        rxEditorHtmlNode.value!.webNode, 'border-top-left-radius', valuePX);
    editor?.setStyle(
        rxEditorHtmlNode.value!.webNode, 'border-top-right-radius', valuePX);
    editor?.setStyle(
        rxEditorHtmlNode.value!.webNode, 'border-bottom-right-radius', valuePX);
    editor?.setStyle(
        rxEditorHtmlNode.value!.webNode, 'border-bottom-left-radius', valuePX);
  }

  void setBorderPosition(BorderPositionType type) {
    /// cell 선택인지 여부에 따라 webNode를 달리한다.
    final selectedCells = editor?.selectedCells().toDart;
    if (selectedCells?.isNotEmpty == true) {
      selectedCells?.forEach((cell) {
        editor?.setStyle(cell, 'border-${type.name}', 'none');
      });
    }
  }

  void setPaddingLeft(int value) => editor?.applyPaddingLeft(value);
  void applyLinePadding(PaddingType type, String value) {
    var paragraphStyle = editor?.getSelectedParagraphStyle();
    final paddingTop = paragraphStyle?.paddingTop.replacePX();
    final paddingBottom = paragraphStyle?.paddingBottom.replacePX();

    // vulcan엔진에서 넘어오는 lineSpaciing 초기 설정값이 1.35임.
    if (rxLineSpacing.value == '1.35' &&
        paddingTop?.isEmpty == true &&
        paddingBottom?.isEmpty == true) {
      // lineHeight0으로 설정하고 padding을 조절해서 원래 값처럼 보이게 한다.
      editor?.applyLineHeight('0');
      editor?.applyLinePadding(PaddingType.top.name, 10);
      editor?.applyLinePadding(PaddingType.bottom.name, 10);
    }

    rxLinePaddingTop.value = value;
    editor?.applyLinePadding(type.name, int.tryParse(value) ?? 0);

    paragraphStyle = editor?.getSelectedParagraphStyle();
    final lineHeight = paragraphStyle?.lineHeight.replacePX();

    if (lineHeight != null && lineHeight.isNotEmpty) {
      rxLineSpacing.value = lineHeight;
    }
  }

  void removeLineAndPadding() {
    editor?.removeLinePadding(PaddingType.top.name);
    editor?.removeLinePadding(PaddingType.bottom.name);
    editor?.removeLineHeight();

    // 초기값 설정
    rxLineSpacing.value = '1.35';
    rxLinePaddingTop.value = '10';
  }

  void removeAllStyle() => editor?.removeAllStyle();

  void applyTextIndent(int range) => editor?.applyTextIndent(range);

  void removeTextIndent(int range) => editor?.removeTextIndent();

  void applyFontWidth(String fontWidth) {
    editor?.applyFontWidth(fontWidth);
  }

  //______Text Box Style align panel______

  /// 순서
  void setZindex(ZindexType type) => editor?.setZindex(type.name);

  /// 위치 정렬
  void alignSelectedNodes(TextAlignBothType type) =>
      editor?.alignSelectedNodes(type.name);

  /// 크기 맞추기
  void matchSizeOfSelectedNodes(TextAlignSizeType type) =>
      editor?.matchSizeOfSelectedNodes(type.name);

  /// 위치 배분
  void distributeSelectedNodes(bool horizontal) =>
      editor?.distributeSelectedNodes(horizontal);

  //______Text Box Design panel______
  void setTextBoxBGStyle(int index) => editor?.applyBackgroundClass(index);

  //______Text Box Style multi column panel______
  void setMultiColumn() {
    editor?.setMultiColumn(
      rxMultiColumnCount.value,
      rxMultiColumnFillOption.value.optionName,
      rxMultiColumnGap.value,
      rxMultiColumnRuleStyleOption.value.optionName,
      rxMultiColumnRuleWidth.value,
      rxMultiColumnRuleColor.value.toRgbString(),
    );
  }

  void removeMultiColumn() {
    editor?.removeMultiColumn();
    rxMultiColumnCount.value = 1;
    rxMultiColumnFillOption.value = MultiColumnFillType.auto;
    rxMultiColumnGap.value = 10;
    rxMultiColumnRuleStyleOption.value = BorderStyleType.none;
    rxMultiColumnRuleWidth.value = 1;
    rxMultiColumnRuleColor.value = Colors.black;
  }
}
