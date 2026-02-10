import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../engine/math/math_editor_iframe.dart';

class MathItem extends StatelessWidget with EditorEventbus {
  MathItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            VulcanXElevatedButton(
                onPressed: () {
                  _showWebViewDialog(context);
                },
                // 수식 입력기
                child: Text('math_button'.tr)),
            const SizedBox(height: 16),
          ],
        ));
  }

  Future<void> _showWebViewDialog(BuildContext context) async {
    await VulcanCloseDialogWidget(
      isShowConfirm: false,
      isShowCancel: false,
      width: 650,
      height: 455,
      //수식
      title: 'math_title'.tr,
      content: MathEditorIFrame(
        url: controller.documentState.rxMathURL.value,
        width: 650,
        height: 337,
        onSave: (content) {
          controller.insertMath(content);
          context.pop();
        },
      ),
    ).show(context);
  }
}
