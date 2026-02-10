// lib/mixins/format_copy_paste_mixin.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../engine/engines.dart';

/// 서식 복사 & 붙여넣기 기능을 관리하는 Mixin
mixin FormatCopyPasteMixin on GetxController {
  Editor? get editor;

  /// 선택된 텍스트의 스타일을 복사합니다
  ///
  /// Returns: 복사 성공 여부
  bool copySelectedStyle() {
    if (editor == null) return false;

    try {
      return editor!.copySelectedStyle();
    } catch (e) {
      debugPrint('Error copying selected style: $e');
      return false;
    }
  }

  /// 복사된 텍스트 스타일을 가져옵니다
  ///
  /// Returns: 복사된 텍스트 스타일 정보
  JSTextStyle? getCopiedTextStyle() {
    if (editor == null) return null;

    try {
      return editor!.copiedTextStyle();
    } catch (e) {
      debugPrint('Error getting copied text style: $e');
      return null;
    }
  }

  /// 복사된 단락 스타일을 가져옵니다
  ///
  /// Returns: 복사된 단락 스타일 정보
  JSParagraphStyle? getCopiedParagraphStyle() {
    if (editor == null) return null;

    try {
      return editor!.copiedParagraphStyle();
    } catch (e) {
      debugPrint('Error getting copied paragraph style: $e');
      return null;
    }
  }

  /// 선택된 텍스트에 복사된 스타일을 붙여넣습니다
  ///
  /// [textStyle] 텍스트 스타일 붙여넣기 여부
  /// [paragraphStyle] 단락 스타일 붙여넣기 여부
  ///
  /// Returns: 붙여넣기 성공 여부
  bool pasteStyleToSelection({
    bool textStyle = true,
    bool paragraphStyle = true,
  }) {
    if (editor == null) return false;

    try {
      return editor!.pasteStyleToSelection(textStyle, paragraphStyle);
    } catch (e) {
      debugPrint('Error pasting style to selection: $e');
      return false;
    }
  }

  /// 텍스트 스타일만 선택된 영역에 붙여넣습니다
  ///
  /// Returns: 붙여넣기 성공 여부
  bool pasteTextStyleToSelection() {
    return pasteStyleToSelection(textStyle: true, paragraphStyle: false);
  }

  /// 단락 스타일만 선택된 영역에 붙여넣습니다
  ///
  /// Returns: 붙여넣기 성공 여부
  bool pasteParagraphStyleToSelection() {
    return pasteStyleToSelection(textStyle: false, paragraphStyle: true);
  }

  /// 스타일 붙여넣기가 가능한지 확인합니다
  ///
  /// Returns: 붙여넣기 가능 여부
  bool canPasteStyle() {
    if (editor == null) return false;

    try {
      return editor!.canPasteStyle();
    } catch (e) {
      debugPrint('Error checking if can paste style: $e');
      return false;
    }
  }

  /// 복사된 스타일을 지웁니다
  void clearCopiedStyle() {
    if (editor == null) return;

    try {
      editor!.clearCopiedStyle();
    } catch (e) {
      debugPrint('Error clearing copied style: $e');
    }
  }

  /// 스타일 복사 후 사용자에게 피드백을 제공합니다
  void showStyleCopiedFeedback() {
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      '스타일 복사',
      '선택된 영역의 스타일이 복사되었습니다.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 스타일 붙여넣기 후 사용자에게 피드백을 제공합니다
  void showStylePastedFeedback() {
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      '스타일 붙여넣기',
      '스타일이 적용되었습니다.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.blue.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 복사된 스타일 정보를 문자열로 반환합니다 (디버깅용)
  String getCopiedStyleInfo() {
    final textStyle = getCopiedTextStyle();
    final paragraphStyle = getCopiedParagraphStyle();

    return '''
복사된 스타일 정보:
- 텍스트 스타일: ${textStyle != null ? '있음' : '없음'}
- 단락 스타일: ${paragraphStyle != null ? '있음' : '없음'}
- 붙여넣기 가능: ${canPasteStyle() ? '가능' : '불가능'}
''';
  }

  /// 스타일 복사 & 붙여넣기 관련 단축키 처리
  void handleFormatCopyPasteShortcuts(
    KeyEvent event,
    bool isCtrlPressed,
    bool isShiftPressed,
    bool isAltPressed,
  ) {
    // Ctrl+Shift+C: 스타일 복사
    if (isCtrlPressed && isShiftPressed && event.logicalKey.keyLabel == 'C') {
      if (copySelectedStyle()) {
        showStyleCopiedFeedback();
      }
      return;
    }

    // Ctrl+Shift+V: 스타일 붙여넣기
    if (isCtrlPressed && isShiftPressed && event.logicalKey.keyLabel == 'V') {
      if (pasteStyleToSelection()) {
        showStylePastedFeedback();
      }
      return;
    }

    // Ctrl+Shift+Alt+V: 텍스트 스타일만 붙여넣기
    if (isCtrlPressed &&
        isShiftPressed &&
        isAltPressed &&
        event.logicalKey.keyLabel == 'V') {
      if (pasteTextStyleToSelection()) {
        showStylePastedFeedback();
      }
      return;
    }
  }
}
