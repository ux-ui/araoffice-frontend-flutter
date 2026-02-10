import 'package:author_editor/extension/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../engine/engines.dart';

mixin BodyControlMixin on GetxController {
  Editor? get editor;
  EditorHtmlNode? get currentNode;

  // body 배경색 조회/설정
  final rxBodyBackColor = Rx<Color>(Colors.transparent);

  // body 배경이미지 경로 조회/설정
  final rxBodyBackImageUrl = ''.obs;

  // body 배경이미지 크기 조회/설정
  final rxBodyBackImageWidth = ''.obs;
  final rxBodyBackImageHeight = ''.obs;

  // body 배경이미지 위치 조회/설정
  final rxBodyBackImagePosition = ''.obs;

  // body 배경이미지 반복 조회/설정
  final rxBodyBackImageRepeat = ''.obs;

  void initBodyPanel() {
    rxBodyBackColor.value =
        editor?.getBodyBackColor().toColor() ?? Colors.transparent;
    rxBodyBackImageUrl.value = editor?.getBodyBackImageUrl() ?? '';
    final size = editor?.getBodyBackImageSize() ?? '';
    if (size.isEmpty) {
      rxBodyBackImageWidth.value = '';
      rxBodyBackImageHeight.value = '';
    } else {
      final slitSize = size.split(' ');
      rxBodyBackImageWidth.value = slitSize[0].replaceAll('px', '');
      rxBodyBackImageHeight.value = slitSize[1].replaceAll('px', '');
    }

    rxBodyBackImagePosition.value = editor?.getBodyBackImagePosition() ?? '';
    rxBodyBackImageRepeat.value = editor?.getBodyBackImageRepeat() ?? '';
  }

  void setBodyBackColor(Color color) {
    rxBodyBackColor.value = color;
    editor?.setBodyBackColor(color.toRgbaString());
  }

  void setBodyBackImageUrl(String value) {
    rxBodyBackImageUrl.value = value;
    editor?.setBodyBackImageUrl(value);
  }

  void setBodyBackImageSize(String width, String height) {
    final value = '${width}px ${height}px';
    rxBodyBackImageWidth.value = width;
    rxBodyBackImageHeight.value = height;
    editor?.setBodyBackImageSize(value);
  }

  void setBodyBackImagePosition(String value) {
    rxBodyBackImagePosition.value = value;
    editor?.setBodyBackImagePosition(value);
  }

  void setBodyBackImageRepeat(String value) {
    rxBodyBackImageRepeat.value = value;
    editor?.setBodyBackImageRepeat(value);
  }
}
