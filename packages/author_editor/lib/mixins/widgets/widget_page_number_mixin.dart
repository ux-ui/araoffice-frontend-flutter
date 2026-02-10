import 'dart:js_interop';
import 'dart:ui';

import 'package:author_editor/engine/engines.dart';
import 'package:author_editor/extension/color_extension.dart';
import 'package:author_editor/extension/string_extension.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

mixin WidgetPageNumberMixin on GetxController {
  // Abstract getter for editor
  Editor? get editor;

  //글자
  final rxPageNumberSize = '12'.obs;
  final rxPageNumberColor = const Color(0xFF000000).obs;

  // 원본 설정값 저장용 변수들
  String? _originalPageNumberSize;
  Color? _originalPageNumberColor;

  void initPageNumber() {
    final selectedWidget = editor?.selectedWidget() as web.Node;

    // 현재 값 가져오기
    rxPageNumberSize.value =
        ((editor?.getWidgetProperty(selectedWidget, 'fontSize') as JSAny)
                as String)
            .replaceAll('px', '');
    rxPageNumberColor.value =
        ((editor?.getWidgetProperty(selectedWidget, 'fontColor') as JSAny)
                    as String)
                .toColor() ??
            const Color(0xFF000000);

    // 원본 값 저장
    _originalPageNumberSize = rxPageNumberSize.value;
    _originalPageNumberColor = rxPageNumberColor.value;
  }

  void setProperty(String name, dynamic value) {
    final selectedWidget = editor?.selectedWidget() as web.Node;

    // dynamic 값을 JS로 변환하는 로직 추가
    dynamic jsValue;
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

    editor?.setWidgetProperty(selectedWidget, name, jsValue);
  }

  void setPageNumberSize(String value) {
    rxPageNumberSize.value = value;
    setProperty('fontSize', '${rxPageNumberSize.value}px');
  }

  void setPageNumberColor(Color color) {
    rxPageNumberColor.value = color;
    setProperty('fontColor', rxPageNumberColor.value.toRgbString());
  }

  // 원래대로 되돌리기 함수
  void resetToOriginalSettings() {
    // UI 값 복원
    rxPageNumberSize.value = _originalPageNumberSize!;
    rxPageNumberColor.value = _originalPageNumberColor!;

    // 실제 위젯 속성 설정
    setProperty('fontSize', '${rxPageNumberSize.value}px');
    setProperty('fontColor', rxPageNumberColor.value.toRgbString());
  }

  void updatePageNumber(String value) {
    final widgets = editor?.getWidgets('page-number').toDart;

    widgets?.forEach((widget) {
      editor?.setWidgetProperty(widget, 'currentPage', value.toJS);
    });
  }
}
