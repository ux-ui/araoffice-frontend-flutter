import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../dialog/editor_multi_upload_dialog.dart';

class VideoItem extends StatelessWidget with EditorEventbus {
  final textEditingController = TextEditingController();
  VideoItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // VulcanXDropdown<String>(
            //   value: '동영상 파일 선택',
            //   stringItems: const ['동영상 파일 선택'],
            //   onChanged: (String? newValue) {},
            //   hintText: '동영상 파일 선택',
            // ),
            // const SizedBox(height: 8),
            VulcanXTextField(
              controller: textEditingController,
              focusNode: controller.focusUploadVideoNode,
              //readOnly: true,
              suffixIcon: const Icon(Icons.more_horiz),
              onTap: () async => await _pickerFiles(context),
            ),
            const SizedBox(height: 8),
            Obx(() => ListView.builder(
                itemCount: controller.resourceState.rxVideoResources.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final resource =
                      controller.resourceState.rxVideoResources[index];
                  final fileName = resource?.fileName ?? '';
                  final id = resource?.id ?? '';

                  return Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                          onPressed: () =>
                              controller.insertVideo('./$id-$fileName'),
                          child: Text('add_video'.tr)),
                    ],
                  );
                })),
            // VulcanXElevatedButton(
            //     onPressed: () => controller.insertVideo('./fall.mp4'),
            //     //동영상 추가
            //     child: Text('add_video'.tr)),
            // const SizedBox(height: 16),
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
