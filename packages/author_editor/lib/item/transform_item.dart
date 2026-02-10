import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../dialog/editor_multi_upload_dialog.dart';

class TransformItem extends StatelessWidget with EditorEventbus {
  final textEditingController = TextEditingController();
  TransformItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            VulcanXElevatedButton(
                onPressed: () => controller.transposeTable(),
                // 테이블 행과 열 바꾸기
                child: Text('transpose_table'.tr)),
            const SizedBox(height: 8),
            VulcanXElevatedButton(
                onPressed: () => controller.tableToTextbox(),
                // 테이블을 텍스트박스로 변환
                child: Text('table_to_textbox'.tr)),
            const SizedBox(height: 8),
          ],
        ));
  }

  Future<void> _pickerFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      String fileNames = result.files.map((file) => file.name).join(', ');
      textEditingController.text = fileNames;

      if (!context.mounted) return;
      final uploadSuccess = await EditorMultiUploadDialog.show(
        context,
        files: result.files,
        onUpload: (file) async {
          await controller.fileUpload(file);
        },
      );

      if (uploadSuccess != true) {
        textEditingController.text = '';
      }
    }
  }
}
