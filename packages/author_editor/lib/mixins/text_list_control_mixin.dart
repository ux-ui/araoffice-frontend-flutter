import 'dart:math' as math;

import 'package:get/get.dart';

import '../engine/engines.dart';

mixin VirtualListControlMixin on GetxController {
  final rxVirtualListClass = false.obs;
  final rxVirtualListDepth = 0.obs;
  final rxVirtualListDepthType = 'none'.obs;
  final rxVirtualList = <int>[].obs;
  final rxVirtualListStyles = <String>[].obs;
  final rxIsVirtualList = false.obs;
  final rxHasVirtualList = false.obs;

  Editor? get editor;

  void setVirtualListDepthToggle(int value) {
    int listDepth = 0;
    if (value == 0) {
      // rxListDepth 값을 -1하고 최소 0
      listDepth = math.max(0, rxVirtualListDepth.value - 1);
    } else if (value == 1) {
      // rxListDepth 값을 +1하고 최대 5
      listDepth = math.min(5, rxVirtualListDepth.value + 1);
    }

    rxVirtualListDepth.value = listDepth;
    editor?.setVirtualListDepthWithStyle(
        listDepth, rxVirtualListDepthType.value);
  }

  void setVirtualListDepth(String value) {
    rxVirtualListDepth.value = value.isEmpty ? 0 : 1;

    rxHasVirtualList.value = (rxVirtualListDepth.value != 0);

    rxVirtualListDepthType.value = value;
    editor?.setVirtualListDepthWithStyle(
        rxVirtualListDepth.value, rxVirtualListDepthType.value);
  }
}
