// lib/mixins/media_control_mixin.dart
import 'package:author_editor/extension/extensions.dart';
import 'package:get/get.dart';

import '../engine/engines.dart';
import '../enum/enums.dart';

/// 비디오/오디오 관련 기능을 관리하는 Mixin
mixin MediaControlMixin on GetxController {
  Editor? get editor;
  EditorHtmlNode? get currentNode;

  // Media properties
  final rxMediaControls = false.obs;
  final rxMediaAutoPlay = false.obs;
  final rxMediaLoop = false.obs;
  final rxMediaMuted = false.obs;

  final rxShowCaption = false.obs;
  final rxCaptionPosition = 'top'.obs;
  final rxCaptionAlignment = 'left'.obs;

  /// 미디어 요소의 속성을 설정합니다
  void setMediaAttribute(MediaAttributeType attribute, bool value) {
    switch (attribute) {
      case MediaAttributeType.controls:
        rxMediaControls.value = value;
      case MediaAttributeType.autoplay:
        rxMediaAutoPlay.value = value;
      case MediaAttributeType.loop:
        rxMediaLoop.value = value;
      case MediaAttributeType.muted:
        rxMediaMuted.value = value;
    }
    editor?.setAttribute(currentNode!.webNode, attribute.name, '$value');
  }

  /// 비디오 요소를 삽입합니다
  void insertVideo(String src) => editor?.insertVideo(src);

  /// 오디오 요소를 삽입합니다
  void insertAudio(String src) => editor?.insertAudio(src);

  /// 미디어 속성들을 로드합니다
  void loadMediaAttributes() {
    rxMediaControls.value = getAttribute('controls').toBool();
    rxMediaAutoPlay.value = getAttribute('autoplay').toBool();
    rxMediaLoop.value = getAttribute('loop').toBool();
    rxMediaMuted.value = getAttribute('muted').toBool();
  }

  String getAttribute(String attributeName) {
    return currentNode?.attributes[attributeName] ?? '';
  }

  void changeImageSource(String src) =>
      editor?.changeImageSource(src); // 이미지 바꾸기
  void applyNaturalImageSize() =>
      editor?.applyNaturalImageSize(); //선택된 이미지 엘리먼트에 적용

  // _______ image design panel ___________
  void setImageStyle(int index) => editor?.applyImageClass(index);

  void setCaptionPosition(String position) {
    rxCaptionPosition.value = position;
    editor?.setCaptionPosition(position);
  }

  bool insertCaption(String caption) {
    rxShowCaption.value = true;
    return editor?.insertCaption(caption) ?? false;
  }

  bool removeCaption() {
    rxShowCaption.value = false;
    return editor?.removeCaption() ?? false;
  }
}
