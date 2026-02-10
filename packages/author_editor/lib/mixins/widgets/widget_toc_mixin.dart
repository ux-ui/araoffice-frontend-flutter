import 'dart:js_interop';
import 'dart:ui';

import 'package:author_editor/engine/engines.dart';
import 'package:author_editor/extension/color_extension.dart';
import 'package:common_util/common_util.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

mixin WidgetTocMixin on GetxController {
  // Abstract getter for editor
  Editor? get editor;

  // 목차 텍스트
  final rxTocText = ''.obs;
  final rxTextSize = '12'.obs;
  final rxTextColor = const Color(0xFF000000).obs;

  // 페이지 번호
  final rxPageNumber = ''.obs;
  final rxPageNumberSize = '12'.obs;
  final rxPageNumberColor = const Color(0xFF000000).obs;

  // 점 표시
  final rxIsDotsVisible = true.obs;
  final rxDotsStyle = ''.obs;
  final rxDotsColor = const Color(0xFF000000).obs;

  // 패딩 (충돌 방지를 위해 이름 변경 및 타입 변경)
  final rxTocPaddingTop = 0.obs;
  final rxTocPaddingRight = 0.obs;
  final rxTocPaddingBottom = 0.obs;
  final rxTocPaddingLeft = 0.obs;

  // 테두리 (충돌 방지를 위해 이름 변경 및 타입 변경)
  final rxTocBorderColor = const Color(0xFF000000).obs;
  final rxTocBorderWidth = 0.obs;
  final rxTocBorderRadius = 0.obs;

  // 배경색
  final rxBackgroundColor = const Color(0xFFFFFFFF).obs;

  // 새로 추가된 속성들
  final rxTocItemCount = 1.obs; // 목차 항목 수
  final rxTocListType = 'none'.obs; // 목록 유형 (none, ul, ol)
  final rxTocListStyleType = 'disc'.obs; // 목록 스타일
  final rxTocItemSpacing = 0.obs; // 항목 간격
  final rxSelectedTocItemIndex = 0.obs; // 선택된 항목 인덱스
  final rxSelectedTocItemLevel = 0.obs; // 선택된 항목 레벨
  final rxTocIndentSize = 20.obs; // 들여쓰기 크기

  // TOC 제목 관련 속성 추가
  final rxHasTocTitle = false.obs; // 제목 표시 여부

  final rxTocJson = ''.obs; // 목차를 json 형식으로 저장, treeListWidget에서 업데이트되면 여기에 저장

  // 원본 설정값 저장용 변수들
  String? _originalTocText;
  String? _originalTextSize;
  Color? _originalTextColor;
  String? _originalPageNumber;
  String? _originalPageNumberSize;
  Color? _originalPageNumberColor;
  bool? _originalIsDotsVisible;
  String? _originalDotsStyle;
  Color? _originalDotsColor;
  int? _originalTocPaddingTop;
  int? _originalTocPaddingRight;
  int? _originalTocPaddingBottom;
  int? _originalTocPaddingLeft;
  Color? _originalTocBorderColor;
  int? _originalTocBorderWidth;
  int? _originalTocBorderRadius;
  Color? _originalBackgroundColor;
  // 새로 추가된 원본 값들
  int? _originalTocItemCount;
  String? _originalTocListType;
  String? _originalTocListStyleType;
  int? _originalTocItemSpacing;
  int? _originalSelectedTocItemIndex;
  int? _originalSelectedTocItemLevel;
  int? _originalTocIndentSize;
  // TOC 제목 원본 값들
  bool? _originalHasTocTitle;

  void initToc() {
    if (editor == null) return;

    final selectedWidget = editor?.selectedWidget() as web.Node?;
    if (selectedWidget == null) return;

    try {
      // 기본값 설정으로 초기화 문제 방지
      rxTocItemCount.value = 1;
      rxTocListType.value = 'none';
      rxTocListStyleType.value = 'disc';
      rxTocItemSpacing.value = 0;
      rxSelectedTocItemIndex.value = 0;
      rxSelectedTocItemLevel.value = 0;
      rxTocIndentSize.value = 20;
      rxHasTocTitle.value = false;

      // 현재 값 가져오기 - 안전하게 처리
      final tocText = editor?.getWidgetProperty(selectedWidget, 'tocText');
      if (tocText != null) {
        final dynamic dynamicTocText = tocText;
        if (dynamicTocText is String) {
          rxTocText.value = dynamicTocText;
        }
      }

      // TextSize 가져오기
      final textSize = editor?.getWidgetProperty(selectedWidget, 'textSize');
      if (textSize != null) {
        final dynamic dynamicTextSize = textSize;
        if (dynamicTextSize is String) {
          rxTextSize.value = dynamicTextSize.replaceAll('px', '');
        }
      }

      // 새로 추가된 속성 값 가져오기
      final tocItemCount =
          editor?.getWidgetProperty(selectedWidget, 'tocItemCount');
      if (tocItemCount != null) {
        final dynamic dynamicTocItemCount = tocItemCount;
        if (dynamicTocItemCount is int) {
          rxTocItemCount.value = dynamicTocItemCount;
        } else if (dynamicTocItemCount is num) {
          rxTocItemCount.value = dynamicTocItemCount.toInt();
        }
      }

      final listType = editor?.getWidgetProperty(selectedWidget, 'listType');
      if (listType != null) {
        final dynamic dynamicListType = listType;
        if (dynamicListType is String) {
          rxTocListType.value = dynamicListType;
        }
      }

      final listStyleType =
          editor?.getWidgetProperty(selectedWidget, 'listStyleType');
      if (listStyleType != null) {
        final dynamic dynamicListStyleType = listStyleType;
        if (dynamicListStyleType is String) {
          rxTocListStyleType.value =
              dynamicListStyleType.isEmpty ? 'disc' : dynamicListStyleType;
        }
      }

      final itemSpacing =
          editor?.getWidgetProperty(selectedWidget, 'itemSpacing');
      if (itemSpacing != null) {
        final dynamic dynamicItemSpacing = itemSpacing;
        if (dynamicItemSpacing is String) {
          rxTocItemSpacing.value =
              int.tryParse(dynamicItemSpacing.replaceAll('px', '')) ?? 0;
        } else if (dynamicItemSpacing is int) {
          rxTocItemSpacing.value = dynamicItemSpacing;
        } else if (dynamicItemSpacing is num) {
          rxTocItemSpacing.value = dynamicItemSpacing.toInt();
        }
      }

      final selectedItemLevel =
          editor?.getWidgetProperty(selectedWidget, 'selectedItemLevel');
      if (selectedItemLevel != null) {
        final dynamic dynamicSelectedItemLevel = selectedItemLevel;
        if (dynamicSelectedItemLevel is int) {
          rxSelectedTocItemLevel.value = dynamicSelectedItemLevel;
        } else if (dynamicSelectedItemLevel is num) {
          rxSelectedTocItemLevel.value = dynamicSelectedItemLevel.toInt();
        }
      }

      final indentSize =
          editor?.getWidgetProperty(selectedWidget, 'indentSize');
      if (indentSize != null) {
        final dynamic dynamicIndentSize = indentSize;
        if (dynamicIndentSize is String) {
          rxTocIndentSize.value =
              int.tryParse(dynamicIndentSize.replaceAll('px', '')) ?? 20;
        } else if (dynamicIndentSize is int) {
          rxTocIndentSize.value = dynamicIndentSize;
        } else if (dynamicIndentSize is num) {
          rxTocIndentSize.value = dynamicIndentSize.toInt();
        }
      }

      // TOC 제목 관련 속성 초기화
      final hasTocTitle =
          editor?.getWidgetProperty(selectedWidget, 'hasTocTitle');
      if (hasTocTitle != null) {
        final dynamic dynamicHasTocTitle = hasTocTitle;
        if (dynamicHasTocTitle is bool) {
          rxHasTocTitle.value = dynamicHasTocTitle;
        }
      }

      // 원본 값 저장
      _originalTocText = rxTocText.value;
      _originalTextSize = rxTextSize.value;
      _originalTextColor = rxTextColor.value;
      _originalPageNumber = rxPageNumber.value;
      _originalPageNumberSize = rxPageNumberSize.value;
      _originalPageNumberColor = rxPageNumberColor.value;
      _originalIsDotsVisible = rxIsDotsVisible.value;
      _originalDotsStyle = rxDotsStyle.value;
      _originalDotsColor = rxDotsColor.value;
      _originalTocPaddingTop = rxTocPaddingTop.value;
      _originalTocPaddingRight = rxTocPaddingRight.value;
      _originalTocPaddingBottom = rxTocPaddingBottom.value;
      _originalTocPaddingLeft = rxTocPaddingLeft.value;
      _originalTocBorderColor = rxTocBorderColor.value;
      _originalTocBorderWidth = rxTocBorderWidth.value;
      _originalTocBorderRadius = rxTocBorderRadius.value;
      _originalBackgroundColor = rxBackgroundColor.value;

      // 새로 추가된 원본 값 저장
      _originalTocItemCount = rxTocItemCount.value;
      _originalTocListType = rxTocListType.value;
      _originalTocListStyleType = rxTocListStyleType.value;
      _originalTocItemSpacing = rxTocItemSpacing.value;
      _originalSelectedTocItemIndex = rxSelectedTocItemIndex.value;
      _originalSelectedTocItemLevel = rxSelectedTocItemLevel.value;
      _originalTocIndentSize = rxTocIndentSize.value;

      // TOC 제목 원본 값 저장
      _originalHasTocTitle = rxHasTocTitle.value;
    } catch (e) {
      logger.e('TOC 위젯 초기화 오류: $e');
      // 오류 발생 시 기본값 설정
      resetToDefaultValues();
    }
  }

  void setProperty(String name, dynamic value) {
    if (editor == null) return;

    final selectedWidget = editor?.selectedWidget() as web.Node?;
    if (selectedWidget == null) return;

    if (value == null) {
      logger.e('경고: $name 속성에 null 값이 전달되었습니다.');
      return;
    }

    // dynamic 값을 JS로 변환하는 로직 추가
    dynamic jsValue;
    try {
      if (value is String) {
        jsValue = value.toJS;
      } else if (value is bool) {
        jsValue = value.toJS;
      } else if (value is num) {
        jsValue = value.toJS;
      } else {
        // 다른 타입에 대한 처리 로직
        jsValue = value.toString().toJS;
      }
    } catch (e) {
      logger.e('속성 설정 중 오류 발생: $name, 값: $value, 오류: $e');
    }

    editor?.setWidgetProperty(selectedWidget, name, jsValue);
  }

  // 텍스트 크기 설정
  void setTocTextSize(String value) {
    rxTextSize.value = value;
    setProperty('textSize', '${rxTextSize.value}px');
  }

  // 텍스트 색상 설정
  void setTocTextColor(Color color) {
    rxTextColor.value = color;
    setProperty('textColor', rxTextColor.value.toRgbString());
  }

  // 페이지 번호 설정
  void setPageNumber(String value) {
    rxPageNumber.value = value;
    setProperty('pageNumber', rxPageNumber.value);
  }

  // 페이지 번호 크기 설정
  void setPageNumberSize(String value) {
    rxPageNumberSize.value = value;
    setProperty('pageNumberSize', '${rxPageNumberSize.value}px');
  }

  // 페이지 번호 색상 설정
  void setPageNumberColor(Color color) {
    rxPageNumberColor.value = color;
    setProperty('pageNumberColor', rxPageNumberColor.value.toRgbString());
  }

  // 점 표시 토글
  void toggleDotsVisible() {
    rxIsDotsVisible.value = !rxIsDotsVisible.value;
    setProperty('isDotsVisible', rxIsDotsVisible.value);
  }

  // 점 표시 설정
  void setIsDotsVisible(bool value) {
    rxIsDotsVisible.value = value;
    setProperty('isDotsVisible', rxIsDotsVisible.value);
  }

  // 점 스타일 설정
  void setDotsStyle(String value) {
    rxDotsStyle.value = value;
    setProperty('dotsStyle', rxDotsStyle.value);
  }

  // 점 색상 설정
  void setDotsColor(Color color) {
    rxDotsColor.value = color;
    setProperty('dotsColor', rxDotsColor.value.toRgbString());
  }

  // 패딩 상단 설정 (int 타입으로 변경)
  void setTocPaddingTop(int value) {
    rxTocPaddingTop.value = value;
    setProperty('paddingTop', '${rxTocPaddingTop.value}px');
  }

  // 패딩 오른쪽 설정 (int 타입으로 변경)
  void setTocPaddingRight(int value) {
    rxTocPaddingRight.value = value;
    setProperty('paddingRight', '${rxTocPaddingRight.value}px');
  }

  // 패딩 하단 설정 (int 타입으로 변경)
  void setTocPaddingBottom(int value) {
    rxTocPaddingBottom.value = value;
    setProperty('paddingBottom', '${rxTocPaddingBottom.value}px');
  }

  // 패딩 왼쪽 설정 (int 타입으로 변경)
  void setTocPaddingLeft(int value) {
    rxTocPaddingLeft.value = value;
    setProperty('paddingLeft', '${rxTocPaddingLeft.value}px');
  }

  // 테두리 색상 설정
  void setTocBorderColor(Color color) {
    rxTocBorderColor.value = color;
    setProperty('borderColor', rxTocBorderColor.value.toRgbString());
  }

  // 테두리 두께 설정 (int 타입으로 변경)
  void setTocBorderWidth(int value) {
    rxTocBorderWidth.value = value;
    setProperty('borderWidth', '${rxTocBorderWidth.value}px');
  }

  // 간단하게 호환성을 위해 메서드 이름 추가
  void setBorderWidth(int value) {
    setTocBorderWidth(value);
  }

  // 테두리 모서리 라운드 설정 (int 타입으로 변경)
  void setTocBorderRadius(int value) {
    rxTocBorderRadius.value = value;
    setProperty('borderRadius', '${rxTocBorderRadius.value}px');
  }

  // 배경색 설정
  void setBackgroundColor(Color color) {
    rxBackgroundColor.value = color;
    setProperty('backgroundColor', rxBackgroundColor.value.toRgbString());
  }

  // 목차 항목 수 설정
  void setTocItemCount(int count) {
    rxTocItemCount.value = count;
    setProperty('tocItemCount', count);
  }

  // 목록 유형 설정
  void setTocListType(String? listType) {
    if (listType == null || listType.isEmpty) {
      logger.e('Warning: 목록 유형이 null이거나 비어 있습니다.');
      return;
    }

    setProperty('listType', listType.toJS);
    rxTocListType.value = listType;
  }

  // 목록 스타일 설정
  void setTocListStyleType(String? styleType) {
    if (styleType == null || styleType.isEmpty) {
      logger.e('Warning: 목록 스타일이 null이거나 비어 있습니다.');
      return;
    }
    setProperty('listStyleType', styleType);
    rxTocListStyleType.value = styleType;
  }

  // 항목 간격 설정
  void setTocItemSpacing(int spacing) {
    //rxTocItemSpacing.value = spacing;
    setProperty('itemSpacing', '${spacing}px');
  }

  // 목차 항목 선택
  void selectTocItem(int index) {
    rxSelectedTocItemIndex.value = index;
    setProperty('selectItem', index);

    // 선택 후 선택된 항목의 레벨 업데이트
    Future.delayed(const Duration(milliseconds: 100), () {
      final selectedWidget = editor?.selectedWidget() as web.Node;
      final level =
          editor?.getWidgetProperty(selectedWidget, 'selectedItemLevel');
      if (level != null) {
        final dynamic dynamicLevel = level;
        if (dynamicLevel is int) {
          rxSelectedTocItemLevel.value = dynamicLevel;
        } else if (dynamicLevel is num) {
          rxSelectedTocItemLevel.value = dynamicLevel.toInt();
        }
      }
    });
  }

  // 선택된 항목 들여쓰기
  void increaseSelectedItemLevel() {
    setProperty('increaseItemLevel', true);
    // if (result != null) {
    //   final dynamic dynamicResult = result;
    //   if (dynamicResult is int) {
    //     rxSelectedTocItemLevel.value = dynamicResult;
    //   } else if (dynamicResult is num) {
    //     rxSelectedTocItemLevel.value = dynamicResult.toInt();
    //   }
    // }
  }

  // 선택된 항목 내어쓰기
  void decreaseSelectedItemLevel() {
    setProperty('decreaseItemLevel', true);
    // if (result != null) {
    //   final dynamic dynamicResult = result;
    //   if (dynamicResult is int) {
    //     rxSelectedTocItemLevel.value = dynamicResult;
    //   } else if (dynamicResult is num) {
    //     rxSelectedTocItemLevel.value = dynamicResult.toInt();
    //   }
    // }
  }

  // 들여쓰기 크기 설정
  void setTocIndentSize(int size) {
    //rxTocIndentSize.value = size;
    setProperty('indentSize', '${size}px');
  }

  // TOC 제목 관련 설정 함수들
  // 제목 표시/숨기기
  void toggleTocTitle() {
    rxHasTocTitle.value = !rxHasTocTitle.value;
    setProperty('hasTocTitle', rxHasTocTitle.value);
  }

  // 제목 표시 설정
  void setHasTocTitle(bool value) {
    rxHasTocTitle.value = value;
    setProperty('hasTocTitle', value);
  }

  //treeWidget 목차 업데이트
  void updateTreeWidgetTocFromJson(Function()? onStart, Function()? onFinish) {
    onStart?.call();
    setProperty('setTocFromJson', rxTocJson.value);

    // 위젯 속성이 변경된 후 UI 업데이트
    Future.delayed(const Duration(milliseconds: 300), () {
      initToc(); // 속성 변경 후 모든 값 다시 로드
      onFinish?.call();
    });
  }

  // 예제 데이터로 목차 설정
  void setTreeWidgetTocExampleData() {
    final selectedWidget = editor?.selectedWidget() as web.Node;
    editor?.setWidgetProperty(selectedWidget, 'setTocExampleData', true.toJS);

    // 위젯 속성이 변경된 후 UI 업데이트
    Future.delayed(const Duration(milliseconds: 300), () {
      initToc(); // 속성 변경 후 모든 값 다시 로드
    });
  }

  /// 목차를 업데이트합니다.
  /// 목차를 json 형식으로 저장, treeListWidget에서 업데이트되면 여기에 저장
  void updateTreeWidgetTocJson(String tocJson) {
    rxTocJson.value = tocJson;
  }

  // 오류 발생 시 기본값으로 초기화하는 메소드
  void resetToDefaultValues() {
    rxTocText.value = '';
    rxTextSize.value = '12';
    rxTextColor.value = const Color(0xFF000000);
    rxPageNumber.value = '';
    rxPageNumberSize.value = '12';
    rxPageNumberColor.value = const Color(0xFF000000);
    rxIsDotsVisible.value = true;
    rxDotsStyle.value = 'dotted';
    rxDotsColor.value = const Color(0xFF000000);
    rxTocPaddingTop.value = 0;
    rxTocPaddingRight.value = 0;
    rxTocPaddingBottom.value = 0;
    rxTocPaddingLeft.value = 0;
    rxTocBorderColor.value = const Color(0xFF000000);
    rxTocBorderWidth.value = 0;
    rxTocBorderRadius.value = 0;
    rxBackgroundColor.value = const Color(0xFFFFFFFF);
    rxTocItemCount.value = 1;
    rxTocListType.value = 'none';
    rxTocListStyleType.value = 'disc';
    rxTocItemSpacing.value = 0;
    rxSelectedTocItemIndex.value = 0;
    rxSelectedTocItemLevel.value = 0;
    rxTocIndentSize.value = 20;
    rxHasTocTitle.value = false;
  }

  // 원래대로 되돌리기 함수
  void resetToOriginalSettings() {
    if (_originalTocText == null) return; // 저장된 값이 없으면 실행하지 않음

    try {
      // UI 값 복원
      rxTocText.value = _originalTocText!;
      rxTextSize.value = _originalTextSize!;
      rxTextColor.value = _originalTextColor ?? const Color(0xFF000000);
      rxPageNumber.value = _originalPageNumber!;
      rxPageNumberSize.value = _originalPageNumberSize!;
      rxPageNumberColor.value =
          _originalPageNumberColor ?? const Color(0xFF000000);
      rxIsDotsVisible.value = _originalIsDotsVisible!;
      rxDotsStyle.value = _originalDotsStyle!;
      rxDotsColor.value = _originalDotsColor ?? const Color(0xFF000000);
      rxTocPaddingTop.value = _originalTocPaddingTop!;
      rxTocPaddingRight.value = _originalTocPaddingRight!;
      rxTocPaddingBottom.value = _originalTocPaddingBottom!;
      rxTocPaddingLeft.value = _originalTocPaddingLeft!;
      rxTocBorderColor.value =
          _originalTocBorderColor ?? const Color(0xFF000000);
      rxTocBorderWidth.value = _originalTocBorderWidth!;
      rxTocBorderRadius.value = _originalTocBorderRadius!;
      rxBackgroundColor.value =
          _originalBackgroundColor ?? const Color(0xFFFFFFFF);

      // 새로 추가된 UI 값 복원
      rxTocItemCount.value = _originalTocItemCount!;
      rxTocListType.value = _originalTocListType!;
      rxTocListStyleType.value = _originalTocListStyleType!;
      rxTocItemSpacing.value = _originalTocItemSpacing!;
      rxSelectedTocItemIndex.value = _originalSelectedTocItemIndex!;
      rxSelectedTocItemLevel.value = _originalSelectedTocItemLevel!;
      rxTocIndentSize.value = _originalTocIndentSize!;

      // TOC 제목 UI 값 복원
      rxHasTocTitle.value = _originalHasTocTitle ?? false;

      // 실제 위젯 속성 설정 (setProperty 함수를 통해 모두 안전하게 처리)
      setProperty('tocText', rxTocText.value);
      setProperty('textSize', '${rxTextSize.value}px');
      setProperty('textColor', rxTextColor.value.toRgbString());
      setProperty('pageNumber', rxPageNumber.value);
      setProperty('pageNumberSize', '${rxPageNumberSize.value}px');
      setProperty('pageNumberColor', rxPageNumberColor.value.toRgbString());
      setProperty('isDotsVisible', rxIsDotsVisible.value);
      setProperty('dotsStyle', rxDotsStyle.value);
      setProperty('dotsColor', rxDotsColor.value.toRgbString());
      setProperty('paddingTop', '${rxTocPaddingTop.value}px');
      setProperty('paddingRight', '${rxTocPaddingRight.value}px');
      setProperty('paddingBottom', '${rxTocPaddingBottom.value}px');
      setProperty('paddingLeft', '${rxTocPaddingLeft.value}px');
      setProperty('borderColor', rxTocBorderColor.value.toRgbString());
      setProperty('borderWidth', '${rxTocBorderWidth.value}px');
      setProperty('borderRadius', '${rxTocBorderRadius.value}px');
      setProperty('backgroundColor', rxBackgroundColor.value.toRgbString());

      // 새로 추가된 속성 설정
      setProperty('tocItemCount', rxTocItemCount.value);
      setProperty('listType', rxTocListType.value);
      setProperty('listStyleType', rxTocListStyleType.value);
      setProperty('itemSpacing', '${rxTocItemSpacing.value}px');
      setProperty('selectItem', rxSelectedTocItemIndex.value);
      setProperty('indentSize', '${rxTocIndentSize.value}px');

      // TOC 제목 속성 설정
      setProperty('hasTocTitle', rxHasTocTitle.value);
    } catch (e) {
      //print('원래 설정으로 되돌리기 중 오류 발생: $e');
      resetToDefaultValues();
    }
  }
}
