import 'package:flutter/material.dart';

/// 에디터에서 사용되는 모든 FocusNode를 관리하는 믹스인
mixin FocusNodeMixin {
  final FocusNode focusHyperLinkNode = FocusNode();
  final FocusNode focusLineSpacingNode = FocusNode();
  final FocusNode focusLinePaddingTopNode = FocusNode();
  final FocusNode focusLinePaddingBottomNode = FocusNode();
  final FocusNode focusLetterSpacingNode = FocusNode();
  final FocusNode focusFontWidthNode = FocusNode();
  final FocusNode focusFontSizeNode = FocusNode();
  final FocusNode focusTableBorderWidthNode = FocusNode();
  final FocusNode focusTableRowCountNode = FocusNode();
  final FocusNode focusTableColumnCountNode = FocusNode();
  final FocusNode focusCellBorderWidthNode = FocusNode();
  final FocusNode focusCellWidthNode = FocusNode();
  final FocusNode focusCellHeightNode = FocusNode();
  final FocusNode focusTableWidthNode = FocusNode();
  final FocusNode focusTableHeightNode = FocusNode();
  final FocusNode focusWidgetTocItemSpacingNode = FocusNode();
  final FocusNode focusWidgetTocIndentSizeNode = FocusNode();

  final FocusNode focusDocumentWidthNode = FocusNode();
  final FocusNode focusDocumentHeightNode = FocusNode();

  final FocusNode focusBackgroundWidthNode = FocusNode();
  final FocusNode focusBackgroundHeightNode = FocusNode();

  // 찾기 & 바꾸기 관련 FocusNode
  final FocusNode focusFindSearchNode = FocusNode();
  final FocusNode focusReplaceSearchNode = FocusNode();
  final FocusNode focusReplaceTextNode = FocusNode();

  final FocusNode focusUploadImageNode = FocusNode();
  final FocusNode focusUploadVideoNode = FocusNode();
  final FocusNode focusUploadAudioNode = FocusNode();

  final FocusNode focusWidthNode = FocusNode();
  final FocusNode focusHeightNode = FocusNode();

  final FocusNode focusImageWidthNode = FocusNode();
  final FocusNode focusImageHeightNode = FocusNode();
  final FocusNode focusImageXNode = FocusNode();
  final FocusNode focusImageYNode = FocusNode();

  final FocusNode focusTableCalculationPrefixNode = FocusNode();
  final FocusNode focusTableCalculationSuffixNode = FocusNode();

  /// 모든 FocusNode를 해제합니다.
  void disposeFocusNodes() {
    focusHyperLinkNode.dispose();
    focusLineSpacingNode.dispose();
    focusLinePaddingTopNode.dispose();
    focusLinePaddingBottomNode.dispose();
    focusLetterSpacingNode.dispose();
    focusFontWidthNode.dispose();
    focusFontSizeNode.dispose();
    focusTableBorderWidthNode.dispose();
    focusTableRowCountNode.dispose();
    focusTableColumnCountNode.dispose();
    focusCellBorderWidthNode.dispose();
    focusCellWidthNode.dispose();
    focusCellHeightNode.dispose();
    focusTableWidthNode.dispose();
    focusTableHeightNode.dispose();
    focusWidgetTocItemSpacingNode.dispose();
    focusWidgetTocIndentSizeNode.dispose();

    // 찾기 & 바꾸기 관련 FocusNode 해제
    focusFindSearchNode.dispose();
    focusReplaceSearchNode.dispose();
    focusReplaceTextNode.dispose();

    focusDocumentWidthNode.dispose();
    focusDocumentHeightNode.dispose();

    focusBackgroundWidthNode.dispose();
    focusBackgroundHeightNode.dispose();

    focusWidthNode.dispose();
    focusHeightNode.dispose();

    focusImageWidthNode.dispose();
    focusImageHeightNode.dispose();
    focusImageXNode.dispose();
    focusImageYNode.dispose();

    focusTableCalculationPrefixNode.dispose();
    focusTableCalculationSuffixNode.dispose();
  }

  /// 모든 FocusNode를 초기화합니다.
  void unfocusAllNodes() {
    focusHyperLinkNode.unfocus();
    focusLineSpacingNode.unfocus();
    focusLinePaddingTopNode.unfocus();
    focusLinePaddingBottomNode.unfocus();
    focusLetterSpacingNode.unfocus();
    focusFontWidthNode.unfocus();
    focusFontSizeNode.unfocus();
    focusTableBorderWidthNode.unfocus();
    focusTableRowCountNode.unfocus();
    focusTableColumnCountNode.unfocus();
    focusCellBorderWidthNode.unfocus();
    focusCellWidthNode.unfocus();
    focusCellHeightNode.unfocus();
    focusTableWidthNode.unfocus();
    focusTableHeightNode.unfocus();
    focusWidgetTocItemSpacingNode.unfocus();
    focusWidgetTocIndentSizeNode.unfocus();

    // 찾기 & 바꾸기 관련 FocusNode 초기화
    focusFindSearchNode.unfocus();
    focusReplaceSearchNode.unfocus();
    focusReplaceTextNode.unfocus();

    focusUploadImageNode.unfocus();
    focusUploadVideoNode.unfocus();
    focusUploadAudioNode.unfocus();

    focusDocumentWidthNode.unfocus();
    focusDocumentHeightNode.unfocus();

    focusBackgroundWidthNode.unfocus();
    focusBackgroundHeightNode.unfocus();

    focusWidthNode.unfocus();
    focusHeightNode.unfocus();

    focusImageWidthNode.unfocus();
    focusImageHeightNode.unfocus();
    focusImageXNode.unfocus();
    focusImageYNode.unfocus();

    focusTableCalculationPrefixNode.unfocus();
    focusTableCalculationSuffixNode.unfocus();
  }
}
