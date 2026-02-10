// lib/mixins/find_replace_mixin.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../engine/engines.dart';
import 'page_control_mixin.dart';

/// 찾기 & 바꾸기 기능을 관리하는 Mixin
mixin FindReplaceMixin on GetxController {
  Editor? get editor;

  /// PageControlMixin getter 추가
  PageControlMixin get pageController;

  // 찾기 & 바꾸기 상태 관리
  final rxSearchText = ''.obs;
  final rxReplaceText = ''.obs;
  final rxCaseSensitive = false.obs;
  final rxWholeWord = false.obs;
  final rxCurrentMatch = 0.obs;
  final rxTotalMatches = 0.obs;
  final rxIsSearching = false.obs;

  /// 지정된 텍스트와 일치하는 항목의 개수를 반환합니다
  ///
  /// [text] 찾을 텍스트
  /// [caseSensitive] 대소문자 구분 여부
  /// [wholeWord] 전체 단어 일치 여부
  ///
  /// Returns: 일치하는 항목의 개수
  int countMatches(String text, {bool? caseSensitive, bool? wholeWord}) {
    if (editor == null || text.isEmpty) return 0;

    final isCaseSensitive = caseSensitive ?? rxCaseSensitive.value;
    final isWholeWord = wholeWord ?? rxWholeWord.value;

    try {
      final count = editor!.countMatches(text, isCaseSensitive, isWholeWord);
      rxTotalMatches.value = count;
      return count;
    } catch (e) {
      debugPrint('Error counting matches: $e');
      return 0;
    }
  }

  /// 다음 일치하는 항목을 찾습니다
  ///
  /// [text] 찾을 텍스트
  /// [caseSensitive] 대소문자 구분 여부
  /// [wholeWord] 전체 단어 일치 여부
  ///
  /// Returns: 찾기 성공 여부
  bool findNext(String text, {bool? caseSensitive, bool? wholeWord}) {
    if (editor == null || text.isEmpty) return false;

    final isCaseSensitive = caseSensitive ?? rxCaseSensitive.value;
    final isWholeWord = wholeWord ?? rxWholeWord.value;

    try {
      final found = editor!.findNext(text, isCaseSensitive, isWholeWord);
      if (found) {
        rxCurrentMatch.value =
            (rxCurrentMatch.value % rxTotalMatches.value) + 1;
      }
      return found;
    } catch (e) {
      debugPrint('Error finding next: $e');
      return false;
    }
  }

  /// 이전 일치하는 항목을 찾습니다
  ///
  /// [text] 찾을 텍스트
  /// [caseSensitive] 대소문자 구분 여부
  /// [wholeWord] 전체 단어 일치 여부
  ///
  /// Returns: 찾기 성공 여부
  bool findPrevious(String text, {bool? caseSensitive, bool? wholeWord}) {
    if (editor == null || text.isEmpty) return false;

    final isCaseSensitive = caseSensitive ?? rxCaseSensitive.value;
    final isWholeWord = wholeWord ?? rxWholeWord.value;

    try {
      final found = editor!.findPrevious(text, isCaseSensitive, isWholeWord);
      if (found) {
        rxCurrentMatch.value = rxCurrentMatch.value > 1
            ? rxCurrentMatch.value - 1
            : rxTotalMatches.value;
      }
      return found;
    } catch (e) {
      debugPrint('Error finding previous: $e');
      return false;
    }
  }

  /// 현재 선택된 텍스트를 바꿉니다
  ///
  /// [from] 바꿀 텍스트
  /// [to] 바뀔 텍스트
  /// [caseSensitive] 대소문자 구분 여부
  /// [wholeWord] 전체 단어 일치 여부
  ///
  /// Returns: 바꾸기 성공 여부
  bool replaceSelectedText(
    String from,
    String to, {
    bool? caseSensitive,
    bool? wholeWord,
  }) {
    if (editor == null || from.isEmpty) return false;

    final isCaseSensitive = caseSensitive ?? rxCaseSensitive.value;
    final isWholeWord = wholeWord ?? rxWholeWord.value;

    try {
      return editor!
          .replaceSelectedText(from, to, isCaseSensitive, isWholeWord);
    } catch (e) {
      debugPrint('Error replacing selected text: $e');
      return false;
    }
  }

  /// 모든 일치하는 텍스트를 바꿉니다
  ///
  /// [from] 바꿀 텍스트
  /// [to] 바뀔 텍스트
  /// [caseSensitive] 대소문자 구분 여부
  /// [wholeWord] 전체 단어 일치 여부
  ///
  /// Returns: 바뀐 항목의 개수
  int replaceTextAll(
    String from,
    String to, {
    bool? caseSensitive,
    bool? wholeWord,
  }) {
    if (editor == null || from.isEmpty) return 0;

    final isCaseSensitive = caseSensitive ?? rxCaseSensitive.value;
    final isWholeWord = wholeWord ?? rxWholeWord.value;

    try {
      return editor!.replaceTextAll(from, to, isCaseSensitive, isWholeWord);
    } catch (e) {
      debugPrint('Error replacing all text: $e');
      return 0;
    }
  }

  /// 현재 선택된 텍스트가 찾는 텍스트와 일치하는지 확인합니다
  ///
  /// [text] 찾을 텍스트
  /// [caseSensitive] 대소문자 구분 여부
  /// [wholeWord] 전체 단어 일치 여부
  ///
  /// Returns: 일치 여부
  bool isCurrentSelectionMatch(
    String text, {
    bool? caseSensitive,
    bool? wholeWord,
  }) {
    if (editor == null || text.isEmpty) return false;

    final isCaseSensitive = caseSensitive ?? rxCaseSensitive.value;
    final isWholeWord = wholeWord ?? rxWholeWord.value;

    try {
      return editor!
          .isCurrentSelectionMatch(text, isCaseSensitive, isWholeWord);
    } catch (e) {
      debugPrint('Error checking current selection match: $e');
      return false;
    }
  }

  /// 찾기 작업을 시작합니다
  void startSearch(String text) {
    if (text.isEmpty) {
      stopSearch();
      return;
    }

    rxSearchText.value = text;
    rxIsSearching.value = true;
    rxCurrentMatch.value = 0;

    // 총 일치 개수 계산
    final totalMatches = countMatches(text);

    if (totalMatches > 0) {
      // 첫 번째 일치 항목으로 자동 이동
      findNext(text);
    }
    // 일치 항목이 없어도 상태는 유지하여 UI에서 표시될 수 있도록 함
  }

  /// 찾기 작업을 종료합니다
  void stopSearch() {
    rxSearchText.value = '';
    rxReplaceText.value = '';
    rxIsSearching.value = false;
    rxCurrentMatch.value = 0;
    rxTotalMatches.value = 0;
  }

  /// 현재 검색 상태로 다음 항목을 찾습니다
  void findNextWithCurrentSettings() {
    if (rxSearchText.value.isEmpty) return;

    if (findNext(rxSearchText.value)) {
      showCurrentMatchFeedback();
    } else {
      showNoMoreMatchesFeedback();
    }
  }

  /// 현재 검색 상태로 이전 항목을 찾습니다
  void findPreviousWithCurrentSettings() {
    if (rxSearchText.value.isEmpty) return;

    if (findPrevious(rxSearchText.value)) {
      showCurrentMatchFeedback();
    } else {
      showNoMoreMatchesFeedback();
    }
  }

  /// 현재 선택된 텍스트를 바꾸고 다음 항목을 찾습니다
  void replaceAndFindNext() {
    // if (rxSearchText.value.isEmpty || rxReplaceText.value.isEmpty) return;

    if (replaceSelectedText(rxSearchText.value, rxReplaceText.value)) {
      //페이지 내용 업데이트
      pageController.updatePageContent();

      // 총 일치 개수 업데이트
      rxTotalMatches.value = countMatches(rxSearchText.value);

      // 다음 항목 찾기
      if (rxTotalMatches.value > 0) {
        findNext(rxSearchText.value);
      } else {
        showAllReplacedFeedback();
      }
    }
  }

  /// 모든 텍스트를 바꿉니다
  void replaceAllText() {
    //if (rxSearchText.value.isEmpty || rxReplaceText.value.isEmpty) return;

    final replacedCount =
        replaceTextAll(rxSearchText.value, rxReplaceText.value);

    if (replacedCount > 0) {
      showReplaceAllFeedback(replacedCount);
      // 검색 상태 업데이트
      rxTotalMatches.value = 0;
      rxCurrentMatch.value = 0;

      //페이지 내용 업데이트
      pageController.updatePageContent();
    } else {
      showNoMatchFoundFeedback();
    }
  }

  /// 현재 일치 항목 피드백을 표시합니다
  void showCurrentMatchFeedback() {
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      '검색',
      '${rxCurrentMatch.value}/${rxTotalMatches.value}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.grey.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 일치 항목 없음 피드백을 표시합니다
  void showNoMatchFoundFeedback() {
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      '검색',
      '일치하는 항목을 찾을 수 없습니다.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.orange.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 더 이상 일치 항목 없음 피드백을 표시합니다
  void showNoMoreMatchesFeedback() {
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      '검색',
      '더 이상 일치하는 항목이 없습니다.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.grey.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 모든 바꾸기 완료 피드백을 표시합니다
  void showReplaceAllFeedback(int replacedCount) {
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      '바꾸기 완료',
      '$replacedCount개의 항목이 바뀌었습니다.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 모든 항목이 바뀜 피드백을 표시합니다
  void showAllReplacedFeedback() {
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      '바꾸기',
      '모든 항목이 바뀌었습니다.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 찾기 & 바꾸기 관련 단축키 처리
  void handleFindReplaceShortcuts(
    KeyEvent event,
    bool isCtrlPressed,
    bool isShiftPressed,
    bool isAltPressed,
  ) {
    // Ctrl+F: 찾기
    if (isCtrlPressed && event.logicalKey.keyLabel == 'F') {
      // 찾기 대화상자 열기 (구현 필요)
      return;
    }

    // Ctrl+H: 바꾸기
    if (isCtrlPressed && event.logicalKey.keyLabel == 'H') {
      // 바꾸기 대화상자 열기 (구현 필요)
      return;
    }

    // F3: 다음 찾기
    if (event.logicalKey.keyLabel == 'F3') {
      findNextWithCurrentSettings();
      return;
    }

    // Shift+F3: 이전 찾기
    if (isShiftPressed && event.logicalKey.keyLabel == 'F3') {
      findPreviousWithCurrentSettings();
      return;
    }

    // Escape: 검색 종료
    if (event.logicalKey.keyLabel == 'Escape' && rxIsSearching.value) {
      stopSearch();
      return;
    }
  }

  /// 검색 통계 정보를 반환합니다
  String getSearchStatistics() {
    return '''
검색 통계:
- 검색 중: ${rxIsSearching.value ? '예' : '아니오'}
- 검색어: "${rxSearchText.value}"
- 바꿀 텍스트: "${rxReplaceText.value}"
- 현재 위치: ${rxCurrentMatch.value}/${rxTotalMatches.value}
- 대소문자 구분: ${rxCaseSensitive.value ? '예' : '아니오'}
- 전체 단어 일치: ${rxWholeWord.value ? '예' : '아니오'}
''';
  }
}
