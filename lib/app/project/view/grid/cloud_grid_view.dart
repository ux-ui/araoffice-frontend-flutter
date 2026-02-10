import 'package:api/api.dart';
import 'package:app/app/project/controller/cloud_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CloudGridView extends StatelessWidget {
  final List<CloudFileModel> items;
  final String currentFolderId;
  final CloudController? controller;
  final Function(CloudFileModel)? onCloseDialog;

  const CloudGridView({
    super.key,
    required this.items,
    required this.currentFolderId,
    this.controller,
    this.onCloseDialog,
  });

  final containerWidth = 220.0;
  final containerHeight = 280.0;
  final iconWidth = 175.0;
  final iconHeight = 210.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 16,
            runSpacing: 16,
            children: items
                .map((item) => SizedBox(
                      width: containerWidth,
                      height: containerHeight,
                      child: _buildGridItem(context, item, false),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Obx(
            () => (controller != null &&
                    controller!.rxHasMoreData.value &&
                    controller!.rxIsLoading.isFalse)
                ? VulcanXOutlinedButton(
                    onPressed: () => controller?.loadMoreFiles(),
                    child: const Text('더 불러오기'),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    CloudFileModel item,
    bool isTargeted,
  ) {
    if (item.isFile) {
      return _buildFileItem(context, item, isTargeted);
    }

    return _buildFolderItem(context, item, isTargeted);
  }

  Widget _buildFileItem(
    BuildContext context,
    CloudFileModel item,
    bool isTargeted,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: HoverableAnimatedTap(
            onTap: () async {
              // ARA, Office file이면 다운로드 URL을 받아옴
              final cloudController = controller ?? Get.find<CloudController>();
              if (cloudController.isSupportedFile(item)) {
                await cloudController.handleFileDownload(
                  item,
                  onCloseDialog: onCloseDialog,
                );
              } else {
                // ARA, Office 파일이 아닌 경우의 기본 동작
                debugPrint('Click: ${item.fileName}');
              }
            },
            child: _buildFileIcon(item),
          ),
        ),
        Text(item.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(
          item.readableFileSize,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Text(
          _parseDateWithSeparator(item.modifiedTime.toString(), '-'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
        ),
      ],
    );
  }

  Widget _buildFolderItem(
    BuildContext context,
    CloudFileModel item,
    bool isTargeted,
  ) {
    return GestureDetector(
      onTap: () {
        // 폴더 클릭 시 해당 폴더로 이동
        debugPrint('폴더 열기: ${item.fileName}');
        controller?.navigateToFolder(item);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: VulcanXRoundedContainer.grey(
              width: iconWidth,
              height: iconHeight,
              child: Stack(
                children: [
                  Center(
                    child: item.fileTypeIconWidget(isTargeted: isTargeted),
                  ),
                  if (isTargeted)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  // 공유 상태 표시
                  if (item.shared)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Text(
            '${item.fileSize} items',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  // 날짜 파싱
  String _parseDateWithSeparator(String dateTimeString, String separator) {
    try {
      final dateTime = DateTime.parse(dateTimeString);

      final year = dateTime.year.toString().padLeft(4, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');

      return '$year$separator$month$separator$day';
    } catch (e) {
      debugPrint('날짜 파싱 오류: $e');
      return dateTimeString;
    }
  }

  Widget _buildFileIcon(CloudFileModel item) {
    return Container(
      width: iconWidth,
      height: iconHeight,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          item.fileTypeIconWidget(),
        ],
      ),
    );
  }
}

extension CloudFileModelExtension on CloudFileModel {
  // 파일 타입에 따른 아이콘 반환
  Widget fileTypeIconWidget({bool? isTargeted}) {
    if (fileType.toUpperCase() == 'FOLDER') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder,
            size: 60,
            color: isTargeted == true ? Colors.green : Colors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            fileType.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      );
    }
    switch (fileExtension.toUpperCase()) {
      case 'ARA':
        return VulcanXSvgLabelIconWidget(
          icon: CommonAssets.image.araCircleLogo,
          width: 60,
          height: 60,
          label: 'app_name'.tr,
          labelStyle: const TextStyle(fontSize: 12),
        );
      case 'DOC':
      case 'DOCX':
        return VulcanXImageLabelIconWidget(
          icon: CommonAssets.image.officeDoc,
          width: 60,
          height: 60,
          label: 'office_ms_doc'.tr,
          labelStyle: const TextStyle(fontSize: 12),
        );
      case 'PPT':
      case 'PPTX':
        return VulcanXImageLabelIconWidget(
          icon: CommonAssets.image.officePpt,
          width: 60,
          height: 60,
          label: 'office_ms_ppt'.tr,
          labelStyle: const TextStyle(fontSize: 12),
        );
      case 'XLS':
      case 'XLSX':
        return VulcanXImageLabelIconWidget(
          icon: CommonAssets.image.officeXls,
          width: 60,
          height: 60,
          label: 'office_ms_xls'.tr,
          labelStyle: const TextStyle(fontSize: 12),
        );
      case 'PDF':
        return VulcanXSvgLabelIconWidget(
          icon: CommonAssets.icon.officePdf,
          label: 'office_pdf'.tr,
          width: 60,
          height: 60,
          labelStyle: const TextStyle(fontSize: 12),
        );
      case 'HWP':
      case 'HWPX':
        return VulcanXSvgLabelIconWidget(
          icon: CommonAssets.icon.officeHwp,
          label: 'office_hwp'.tr,
          width: 60,
          height: 60,
          labelStyle: const TextStyle(fontSize: 12),
        );
      case 'TXT':
        return VulcanXSvgLabelIconWidget(
          icon: CommonAssets.icon.stickyNote2,
          label: 'office_txt'.tr,
          width: 60,
          height: 60,
          labelStyle: const TextStyle(fontSize: 12),
        );
      case 'EPUB':
        return VulcanXSvgLabelIconWidget(
          icon: CommonAssets.icon.officeEpub,
          label: 'office_epub'.tr,
          width: 60,
          height: 60,
          labelStyle: const TextStyle(fontSize: 12),
        );
      case 'JPG':
      case 'JPEG':
      case 'PNG':
      case 'GIF':
      case 'IMG':
        return const Icon(
          Icons.image,
          size: 60,
        );
      case 'MP4':
      case 'AVI':
      case 'MOV':
      case 'VIDEO':
        return const Icon(
          Icons.video_file,
          size: 60,
        );
      case 'MP3':
      case 'WAV':
      case 'AUDIO':
        return const Icon(
          Icons.audio_file,
          size: 60,
        );
      case 'ZIP':
      case 'RAR':
        return const Icon(
          Icons.archive,
          size: 60,
        );
      default:
        return const Icon(
          Icons.insert_drive_file,
          size: 60,
        );
    }
  }
}
