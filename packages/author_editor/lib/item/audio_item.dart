import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../dialog/editor_multi_upload_dialog.dart';

class AudioItem extends StatelessWidget with EditorEventbus {
  final textEditingController = TextEditingController();

  AudioItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // VulcanXDropdown<String>(
            //   height: 40.0,
            //   value: '오디오 파일 선택',
            //   stringItems: const ['오디오 파일 선택'],
            //   onChanged: (String? newValue) {},
            //   hintText: '오디오 파일 선택',
            // ),
            // const SizedBox(height: 8),
            VulcanXTextField(
              controller: textEditingController,
              focusNode: controller.focusUploadAudioNode,
              //readOnly: true,
              suffixIcon: const Icon(Icons.more_horiz),
              onTap: () async => await _pickerFiles(context),
            ),
            const SizedBox(height: 8),
            Obx(() => ListView.builder(
                itemCount: controller.resourceState.rxAudioResources.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final resource =
                      controller.resourceState.rxAudioResources[index];
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
                              controller.insertAudio('./$id-$fileName'),
                          child: Text('add_audio'.tr)),
                    ],
                  );
                })),
            // VulcanXElevatedButton(
            //     onPressed: () => controller.insertAudio('./outro.mp3'),
            //     //오디오 추가
            //     child: Text('add_audio'.tr)),
            // const SizedBox(height: 16),
          ],
        ));
  }

  Future<void> _pickerFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      // mp3, wav, aac, ogg, wma 등 원하는 오디오 확장자만 허용
      allowedExtensions: ['mp3', 'wav', 'aac', 'ogg', 'wma'],
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
