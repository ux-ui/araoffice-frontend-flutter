import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../app_ui.dart';

class DocumentCopyPopumenu extends StatelessWidget {
  final Function(bool)? onMenuStateChanged; // 새로운 콜백 함수
  const DocumentCopyPopumenu({super.key, this.onMenuStateChanged});

  @override
  Widget build(BuildContext context) {
    final itemGroups = [
      [
        {'leftLabel': '복사하기', 'rightLabel': ''},
        {'leftLabel': '붙여넣기', 'rightLabel': 'Ctrl+N'},
        {'leftLabel': '덮어쓰기', 'rightLabel': 'Ctrl+S'},
      ],
      [
        {'leftLabel': '페이지 추가', 'rightLabel': ''},
        {'leftLabel': '페이지 복제', 'rightLabel': ''},
        {'leftLabel': '페이지 삭제', 'rightLabel': ''},
        {'leftLabel': '페이지 모두 선택', 'rightLabel': ''},
      ],
    ];
    return Tooltip(
      message: 'copy',
      child: PopupMenuBar(
        content: VulcanXRoundedContainer(
          child: PointerInterceptor(
            child: GroupedVerticalItems<Map<String, dynamic>>(
              itemGroups: itemGroups,
              itemBuilder: (context, itemData, isSelected, onSelected) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextTwoButton(
                    leftLabel: itemData['leftLabel'],
                    rightLabel: itemData['rightLabel'],
                  ),
                );
              },
            ),
          ),
        ),
        onMenuStateChanged: (showMenu) => onMenuStateChanged?.call(showMenu),
        child: CommonAssets.icon.contentCopy.svg(),
      ),
    );
  }
}
