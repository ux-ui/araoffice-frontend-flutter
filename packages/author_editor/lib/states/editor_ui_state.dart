import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// 에디터의 UI 관련 상태를 관리하는 클래스
/// 드로워, 패널, 속성창 등의 UI 요소의 상태를 제어합니다.
class EditorUIState {
  /// 오른쪽 드로워의 열림/닫힘 상태
  /// true: 열림, false: 닫힘
  final isRightDrawerOpen = true.obs;

  /// 왼쪽 드로워의 열림/닫힘 상태
  /// true: 열림, false: 닫힘
  final isLeftDrawerOpen = true.obs;

  /// 현재 선택된 패널 위젯
  /// null일 경우 패널이 선택되지 않은 상태
  final rxPanel = Rx<Widget?>(null);

  /// 현재 표시중인 속성 패널 위젯
  /// 선택된 요소의 속성을 편집하는 패널
  final rxAttribute = Rx<Widget?>(null);

  /// 이전에 표시했던 속성 패널 위젯
  /// 속성 패널 변경 시 비교를 위해 사용
  final rxOldAttribute = Rx<Widget?>(null);

  /// 이전에 표시했던 속성 패널 위젯
  /// 속성 패널 변경 시 비교를 위해 사용
  final previousDrawerState = false.obs;

  /// 속성 패널 관련 상태를 초기화하는 메서드
  void resetAttributes() {
    rxOldAttribute.value = null;
    rxAttribute.value = null;
  }
}
