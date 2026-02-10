import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../dialog/editor_multi_upload_dialog.dart';
import '../enum/enums.dart';
import '../vulcan_editor_eventbus.dart';
import 'items.dart';

class ImageItem extends StatelessWidget with EditorEventbus {
  final textEditingController = TextEditingController();
  final bool visibleGovElementLogo;
  final ObjectType? type;
  final ObjectType? type2;
  final ObjectType? backgroundType;

  ImageItem(
      {super.key,
      this.type,
      this.type2,
      this.backgroundType,
      this.visibleGovElementLogo = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // 파일 업로드 영역
          VulcanXTextField(
            controller: textEditingController,
            focusNode: controller.focusUploadImageNode,
            suffixIcon: const Icon(Icons.more_horiz),
            onTap: () async => await _pickerFiles(context),
          ),

          const SizedBox(height: 8),

          // 업로드된 이미지 리소스 그리드
          Obx(() => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 84,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: controller.resourceState.rxImageResources.length,
                itemBuilder: (context, index) {
                  final resource =
                      controller.resourceState.rxImageResources[index];
                  final fileName = resource?.fileName ?? '';
                  final id = resource?.id ?? '';
                  final thumbnailFileName = resource?.thumbnailFileName ?? '';

                  final idFileName = './$id-$fileName';
                  return VulcanXInkWell(
                    onTap: () => (type == ObjectType.backgroundImage)
                        ? controller.setObjectBackImage(
                            path: idFileName, type: type2?.value)
                        : (type == ObjectType.bodyBackgroundImage)
                            ? controller.setBodyBackImageUrl(idFileName)
                            : (type2 == ObjectType.changeImage)
                                ? controller.changeImageSource(idFileName)
                                : controller.insertImage(idFileName,
                                    type?.value ?? ObjectType.image.value),
                    child: VulcanXRoundedContainer(
                      width: 84,
                      height: 84,
                      borderColor: context.outline,
                      child: Image.network(
                          '${controller.documentState.rxBaseURL}user/project/${controller.documentState.rxProjectId}/$thumbnailFileName'),
                    ),
                  );
                },
              )),
          const SizedBox(height: 16),
          // 정부로고 드롭다운 - 안전하게 래핑
          Visibility(
            visible: visibleGovElementLogo,
            child: LayoutBuilder(
              builder: (context, constraints) {
                try {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      minWidth: 0,
                    ),
                    child: CategoryDropdownItem(
                      templateType: TemplateType.glogo,
                      title: 'government_logo',
                      type: (type2 == ObjectType.changeImage)
                          ? type2?.value
                          : type?.value,
                      // backgroundType: backgroundType,
                    ),
                  );
                } catch (e) {
                  debugPrint('Error building glogo dropdown: $e');
                  return const SizedBox.shrink();
                }
              },
            ),
          ),

          const SizedBox(height: 8),

          // 클립아트 드롭다운 - 안전하게 래핑
          LayoutBuilder(
            builder: (context, constraints) {
              try {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    minWidth: 0,
                  ),
                  child: CategoryDropdownItem(
                    templateType: TemplateType.clipart,
                    title: 'clipart',
                    type: (type2 == ObjectType.changeImage)
                        ? type2?.value
                        : type?.value,
                    // backgroundType: backgroundType,
                  ),
                );
              } catch (e) {
                debugPrint('Error building clipart dropdown: $e');
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickerFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'bmp'],
      allowMultiple: true,
    );

    debugPrint('picker result 0: ${result?.files.first.name}');
    if (result != null && result.files.isNotEmpty) {
      debugPrint('picker result 1: ${result.files.first.name}');
      String fileNames = result.files.map((file) => file.name).join(', ');
      textEditingController.text = fileNames;

      if (!context.mounted) return;
      debugPrint('picker result 2: ${result.files.first.name}');
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
