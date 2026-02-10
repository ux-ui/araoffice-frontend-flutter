import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditorPageRenameDialog extends StatelessWidget {
  final textEditingController = TextEditingController();

  final ValueChanged<String> onTap;
  EditorPageRenameDialog({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 변경할 페이지 이름을 입력해주세요.
        Text('page_rename_message'.tr, style: context.bodyLarge),
        const SizedBox(height: 20),
        VulcanXTextField(
            controller: textEditingController,
            hintText: 'input_page_rename_hint'.tr),
        const SizedBox(height: 14),
        VulcanXElevatedButton.primary(
            onPressed: () => onTap.call(textEditingController.text),
            child: Text('apply'.tr,
                style: context.bodyMedium?.copyWith(color: context.onPrimary)))
      ],
    );
  }
}
