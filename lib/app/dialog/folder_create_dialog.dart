import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FolderCreateDialog extends StatefulWidget {
  final ValueChanged<String> onTap;
  FolderCreateDialog({super.key, required this.onTap});

  @override
  State<FolderCreateDialog> createState() => _FolderCreateDialogState();
}

class _FolderCreateDialogState extends State<FolderCreateDialog> {
  final textEditingController = TextEditingController();

  bool _isValidLength(String text) {
    return text.length >= 2 && text.length <= 20;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 폴더명을 입력해주세요.
        VulcanXTextField(
          controller: textEditingController,
          onChanged: (text) {
            setState(() {}); // 버튼 활성화 상태 업데이트
          },
          onSubmitted: (text) {
            // 최소 2글자, 최대 20글자 검증
            if (_isValidLength(text)) {
              widget.onTap.call(text);
            }
          },
          height: 60,
          maxLength: 20,
          hintText: 'created_folder_input_name_hint'.tr,
          autofocus: true,
        ),
        // *폴더명은 2~20자까지 가능합니다.
        Text('created_folder_input_message'.tr,
            style: context.bodySmall?.copyWith(color: context.outlineVariant)),
        const SizedBox(height: 14),
        VulcanXElevatedButton.primary(
            width: double.infinity,
            onPressed: _isValidLength(textEditingController.text)
                ? () {
                    final text = textEditingController.text;
                    // 최소 2글자, 최대 20글자 검증
                    if (_isValidLength(text)) {
                      widget.onTap.call(text);
                    }
                  }
                : null,
            //적용하기
            child: Text('apply'.tr)),
      ],
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
