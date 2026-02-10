// lib/mixins/animation_control_mixin.dart
import 'package:get/get.dart';

import '../engine/engines.dart';
import '../engine/extension_js_type/js_animation_property.dart';
import '../enum/enums.dart';

/// 애니메이션 관련 기능을 관리하는 Mixin
mixin AnimationControlMixin on GetxController {
  Editor? get editor;
  EditorHtmlNode? get currentNode;

  // Animation properties
  final rxAnimationDelay = 1.0.obs;
  final rxAnimationDuration = 1.0.obs;
  final rxAnimationRepeat = 1.obs;
  final rxAnimationNames = AnimationType.no.obs;
  final rxAnimationTrigger = AnimationTriggerType.click.obs;

  /// 애니메이션을 설정합니다
  void setAnimation() {
    final property = JSAnimationProperty.create(
        name: rxAnimationNames.value.cssName,
        trigger: rxAnimationTrigger.value.name,
        delay: rxAnimationDelay.value,
        duration: rxAnimationDuration.value,
        repeat: rxAnimationRepeat.value);
    editor?.setAnimation(currentNode!.webNode, property);
  }

  /// 애니메이션을 제거합니다
  void removeAnimation() => editor?.removeAnimation(currentNode!.webNode);

  /// 애니메이션을 실행합니다
  void runAnimation() => editor?.runAnimation(currentNode!.webNode);

  /// 애니메이션을 중지합니다
  void stopAnimation() => editor?.stopAnimation(currentNode!.webNode);
}
