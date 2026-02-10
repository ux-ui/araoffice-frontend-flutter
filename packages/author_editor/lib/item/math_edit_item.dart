import 'dart:convert';

import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../engine/math/math_editor_iframe.dart';

class MathEditItem extends StatelessWidget with EditorEventbus {
  final String mathMarkup;
  MathEditItem({super.key, required this.mathMarkup});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            VulcanXElevatedButton(
                onPressed: () => _showWebViewDialog(context),
                // 수식 편집
                child: Text('math_edit_button'.tr)),
            const SizedBox(height: 16),
          ],
        ));
  }

  Future<void> _showWebViewDialog(BuildContext context) async {
    // math 문자열을 base64로 인코딩
    final encodedMath = base64Encode(utf8.encode(mathMarkup));
    // URL 안전하게 인코딩 (+ 문자 등이 보존됨)
    final urlSafeMath = Uri.encodeComponent(encodedMath);

    await VulcanCloseDialogWidget(
      isShowConfirm: false,
      isShowCancel: false,
      width: 650,
      height: 455,
      //수식
      title: 'math_title'.tr,
      content: MathEditorIFrame(
        url: '${controller.documentState.rxMathURL.value}?edit=$urlSafeMath',
        width: 650,
        height: 337,
        onSave: (content) {
          controller.updateMath(content);
          context.pop();
        },
      ),
    ).show(context);
  }
}
