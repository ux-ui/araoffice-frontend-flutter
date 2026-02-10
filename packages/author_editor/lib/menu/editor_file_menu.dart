import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditorFileMenu extends StatelessWidget with EditorEventbus {
  EditorFileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final itemGroups = [
      [
        {'label': 'go_dashboard'.tr, 'shortcut': '', 'index': '0'},
        //{'label': '새 프로젝트', 'shortcut': '', 'index': '1'},
        // {'label': '저장', 'shortcut': 'Ctrl+S', 'index': '2'},
        // {'label': '다른이름으로 저장', 'shortcut': 'Ctrl+Shift+S', 'index': '3'},
      ],
      // [
      //   {'label': '가져오기', 'shortcut': '', 'index': '4'},
      //   {'label': '내보내기', 'shortcut': '', 'index': '5'},
      //   {'label': '설정', 'shortcut': '', 'index': '6'},
      // ],
      // [
      //   {'label': '도움말', 'shortcut': '', 'index': '7'},
      // ],
    ];

    return Tooltip(
        message: 'file'.tr,
        child: ShortcutMenuBar(
          itemGroups: itemGroups,
          onTap: (index) async {
            if (index == 0) {
              await controller.gotoHome(context);
            } else if (index == 1) {
              controller.updateCreateNewEditor(context);
            }
          },
          child: AutoConfig.instance.domainType.isDferiDomain
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CommonAssets.image.booknaviIcon
                      .image(width: 24.0, height: 24.0),
                )
              : CommonAssets.icon.editorLogoIcon.svg(width: 56.0, height: 32.0),
        ));
  }
}
