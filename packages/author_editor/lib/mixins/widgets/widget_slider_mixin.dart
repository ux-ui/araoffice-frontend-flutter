import 'dart:js_interop';
import 'dart:ui';

import 'package:author_editor/engine/engines.dart';
import 'package:author_editor/extension/color_extension.dart';
import 'package:author_editor/extension/string_extension.dart';
import 'package:common_util/common_util.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

mixin WidgetSliderMixin on GetxController {
  // Abstract getter for editor
  Editor? get editor;

  // 레이어 정보 표시
  final rxIsSliderIndicatorVisible = true.obs;
  final rxSliderIndicatorPosition = 'top'.obs; // top, bottom

  // 슬라이더 번호
  final rxIsSliderNumberVisible = true.obs;
  final rxSliderNumberSize = '12'.obs;
  final rxSliderNumberColor = const Color(0xFF000000).obs;

  // 슬라이더 기호
  final rxIsSliderSymbolVisible = true.obs;
  final rxSliderSymbolSize = '12'.obs;
  final rxSliderSymbolColor = const Color(0xFF000000).obs;
  final rxIsSliderSymbolSape = true.obs;

  // 슬라이더 아이콘
  final rxSliderIconSize = '12'.obs;
  final rxSliderNextIconPath = ''.obs;
  final rxSliderNextHoverIconPath = ''.obs;
  final rxSliderPrevIconPath = ''.obs;
  final rxSliderPrevHoverIconPath = ''.obs;

  // 슬라이더 아이콘 위치
  // prevIconPath , prevHoverIconPath, nextIconPath, nextHoverIconPath
  final rxSliderIconLocation = 'prevIconPath'.obs;

  // 원본 설정값 저장용 변수들
  bool? _originalIsSliderIndicatorVisible;
  String? _originalSliderIndicatorPosition;
  bool? _originalIsSliderNumberVisible;
  String? _originalSliderNumberSize;
  Color? _originalSliderNumberColor;
  bool? _originalIsSliderSymbolVisible;
  String? _originalSliderSymbolSize;
  Color? _originalSliderSymbolColor;
  bool? _originalIsSliderSymbolSape;
  String? _originalSliderIconSize;
  String? _originalSliderPrevIconPath;
  String? _originalSliderPrevHoverIconPath;
  String? _originalSliderNextIconPath;
  String? _originalSliderNextHoverIconPath;

  void initSlider() {
    final selectedWidget = editor?.selectedWidget() as web.Node;

    // 현재 값 가져오기

    // simple slider 일 경우 사용하지 않음.
    try {
      rxIsSliderIndicatorVisible.value = (editor?.getWidgetProperty(
          selectedWidget, 'isIndicatorVisible') as JSAny) as bool;
      rxSliderIndicatorPosition.value = (editor?.getWidgetProperty(
          selectedWidget, 'indicatorPosition') as JSAny) as String;
    } catch (e) {
      logger.i(
          'simple slider에서는 사용하지 않는 속성 입니다.(isIndicatorVisible, indicatorPosition)');
    }

    rxIsSliderNumberVisible.value =
        (editor?.getWidgetProperty(selectedWidget, 'isNumberVisible') as JSAny)
            as bool;
    rxSliderNumberSize.value =
        ((editor?.getWidgetProperty(selectedWidget, 'numberSize') as JSAny)
                as String)
            .replaceAll('px', '');
    rxSliderNumberColor.value =
        ((editor?.getWidgetProperty(selectedWidget, 'numberColor') as JSAny)
                    as String)
                .toColor() ??
            const Color(0xFF000000);

    // 슬라이더 기호
    rxIsSliderSymbolVisible.value =
        (editor?.getWidgetProperty(selectedWidget, 'isThumbVisible') as JSAny)
            as bool;
    rxSliderSymbolSize.value =
        ((editor?.getWidgetProperty(selectedWidget, 'thumbSize') as JSAny)
                as String)
            .replaceAll('px', '');
    rxSliderSymbolColor.value =
        ((editor?.getWidgetProperty(selectedWidget, 'thumbColor') as JSAny)
                    as String)
                .toColor() ??
            const Color(0xFF000000);
    rxIsSliderSymbolSape.value =
        (editor?.getWidgetProperty(selectedWidget, 'isThumbCircle') as JSAny)
            as bool;

    final prevIconPath =
        editor?.getWidgetProperty(selectedWidget, 'prevIconPath') as JSAny;
    final prevHoverIconPath =
        editor?.getWidgetProperty(selectedWidget, 'prevHoverIconPath') as JSAny;
    final nextIconPath =
        editor?.getWidgetProperty(selectedWidget, 'nextIconPath') as JSAny;
    final nextHoverIconPath =
        editor?.getWidgetProperty(selectedWidget, 'nextHoverIconPath') as JSAny;

    rxSliderPrevIconPath.value = prevIconPath.toString();
    rxSliderPrevHoverIconPath.value = prevHoverIconPath.toString();
    rxSliderNextIconPath.value = nextIconPath.toString();
    rxSliderNextHoverIconPath.value = nextHoverIconPath.toString();

    // 원본 값 저장
    _originalIsSliderIndicatorVisible = rxIsSliderIndicatorVisible.value;
    _originalSliderIndicatorPosition = rxSliderIndicatorPosition.value;
    _originalIsSliderNumberVisible = rxIsSliderNumberVisible.value;
    _originalSliderNumberSize = rxSliderNumberSize.value;
    _originalSliderNumberColor = rxSliderNumberColor.value;
    _originalIsSliderSymbolVisible = rxIsSliderSymbolVisible.value;
    _originalSliderSymbolSize = rxSliderSymbolSize.value;
    _originalSliderSymbolColor = rxSliderSymbolColor.value;
    _originalIsSliderSymbolSape = rxIsSliderSymbolSape.value;
    _originalSliderIconSize = rxSliderIconSize.value;
    _originalSliderPrevIconPath = rxSliderPrevIconPath.value;
    _originalSliderPrevHoverIconPath = rxSliderPrevHoverIconPath.value;
    _originalSliderNextIconPath = rxSliderNextIconPath.value;
    _originalSliderNextHoverIconPath = rxSliderNextHoverIconPath.value;
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

  void toggleSliderIndicator() {
    rxIsSliderIndicatorVisible.value = !rxIsSliderIndicatorVisible.value;
    setProperty('isIndicatorVisible', rxIsSliderIndicatorVisible.value);
  }

  void toggleSliderIndicatorPosition(int index) {
    rxSliderIndicatorPosition.value = index == 0 ? 'top' : 'bottom';
    setProperty('indicatorPosition', rxSliderIndicatorPosition.value);
  }

  void toggleSliderNumber() {
    rxIsSliderNumberVisible.value = !rxIsSliderNumberVisible.value;
    setProperty('isNumberVisible', rxIsSliderNumberVisible.value);
  }

  void setSliderNumberSize(String value) {
    rxSliderNumberSize.value = value;
    setProperty('numberSize', '${rxSliderNumberSize.value}px');
  }

  void setSliderNumberColor(Color color) {
    rxSliderNumberColor.value = color;
    setProperty('numberColor', rxSliderNumberColor.value.toRgbString());
  }

  void toggleSliderSymbol() {
    rxIsSliderSymbolVisible.value = !rxIsSliderSymbolVisible.value;
    setProperty('isThumbVisible', rxIsSliderSymbolVisible.value);
  }

  void setSliderSymbolSize(String value) {
    rxSliderSymbolSize.value = value;
    setProperty('thumbSize', '${rxSliderSymbolSize.value}px');
  }

  void setSliderSymbolColor(Color color) {
    rxSliderSymbolColor.value = color;
    setProperty('thumbColor', rxSliderSymbolColor.value.toRgbString());
  }

  void toggleSliderSymbolShape(int index) {
    rxIsSliderSymbolSape.value = index == 0;
    setProperty('isThumbCircle', rxIsSliderSymbolSape.value);
  }

  void setSliderIconSize(String value) {
    rxSliderIconSize.value = value;
    setProperty('iconSize', '${rxSliderIconSize.value}px');
  }

  void changeSliderIcon(String value) {
    switch (rxSliderIconLocation.value) {
      case 'prevIconPath':
        rxSliderPrevIconPath.value = value;
        break;
      case 'prevHoverIconPath':
        rxSliderPrevHoverIconPath.value = value;
        break;
      case 'nextIconPath':
        rxSliderNextIconPath.value = value;
        break;
      case 'nextHoverIconPath':
        rxSliderNextHoverIconPath.value = value;
        break;
    }

    setProperty(rxSliderIconLocation.value, value);
  }

  void changeSliderIconLocation(String value) {
    rxSliderIconLocation.value = value;
  }

  // 원래대로 되돌리기 함수
  void resetToSliderOriginalSettings() {
    if (_originalIsSliderNumberVisible == null) return; // 저장된 값이 없으면 실행하지 않음

    // UI 값 복원
    rxIsSliderIndicatorVisible.value = _originalIsSliderIndicatorVisible!;
    rxSliderIndicatorPosition.value = _originalSliderIndicatorPosition!;
    rxIsSliderNumberVisible.value = _originalIsSliderNumberVisible!;
    rxSliderNumberSize.value = _originalSliderNumberSize!;
    rxSliderNumberColor.value = _originalSliderNumberColor!;
    rxIsSliderSymbolVisible.value = _originalIsSliderSymbolVisible!;
    rxSliderSymbolSize.value = _originalSliderSymbolSize!;
    rxSliderSymbolColor.value = _originalSliderSymbolColor!;
    rxIsSliderSymbolSape.value = _originalIsSliderSymbolSape!;
    rxSliderIconSize.value = _originalSliderIconSize!;
    rxSliderPrevIconPath.value = _originalSliderPrevIconPath!;
    rxSliderPrevHoverIconPath.value = _originalSliderPrevHoverIconPath!;
    rxSliderNextIconPath.value = _originalSliderNextIconPath!;
    rxSliderNextHoverIconPath.value = _originalSliderNextHoverIconPath!;

    // 실제 위젯 속성 설정
    setProperty('isIndicatorVisible', rxIsSliderIndicatorVisible.value);
    setProperty('indicatorPosition', rxSliderIndicatorPosition.value);
    setProperty('isNumberVisible', rxIsSliderNumberVisible.value);
    setProperty('numberSize', '${rxSliderNumberSize.value}px');
    setProperty('numberColor', rxSliderNumberColor.value.toRgbString());
    setProperty('isThumbVisible', rxIsSliderSymbolVisible.value);
    setProperty('thumbSize', '${rxSliderSymbolSize.value}px');
    setProperty('thumbColor', rxSliderSymbolColor.value.toRgbString());
    setProperty('isThumbCircle', rxIsSliderSymbolSape.value);
    setProperty('iconSize', '${rxSliderIconSize.value}px');
    setProperty('prevIconPath', rxSliderPrevIconPath.value);
    setProperty('prevHoverIconPath', rxSliderPrevHoverIconPath.value);
    setProperty('nextIconPath', rxSliderNextIconPath.value);
    setProperty('nextHoverIconPath', rxSliderNextHoverIconPath.value);

    Future.delayed(const Duration(milliseconds: 100), () {
      update();
    });
  }
}
