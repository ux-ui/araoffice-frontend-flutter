// lib/mixins/media_control_mixin.dart
import 'dart:typed_data';

import 'package:app_ui/widgets/vulcanx/vulcan_x_close_dialog_widget.dart';
import 'package:author_editor/iframe/office_iframe.dart';
import 'package:common_util/common_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import '../engine/engines.dart';
import '../states/document_state.dart';
import '../vulcan_editor_controller.dart';
import 'page_control_mixin.dart';

/// 오피스 문서 변환 기능을 관리하는 Mixin
mixin DragDocsMixin on GetxController {
  static const allowedViewerExtensions = [
    'doc',
    'docx',
    'hwp',
    'hwpx',
    'odt',
    'ppt',
    'pptx',
    'xls',
    'xlsx',
    'pdf',
    'txt',
    'xhtml',
  ];
  static const allowedOfficeExtensions = [
    'doc',
    'docx',
    'hwp',
    'hwpx',
    'odt',
    'txt',
    'xhtml',
  ];
  static const allowedEpubExtensions = [
    'epub',
  ];
  static const allowedDocumentExtensions = [
    ...allowedOfficeExtensions,
    ...allowedEpubExtensions,
  ];

  Editor? get editor;
  PageControlMixin get pageController;
  // 문서 크기를 가져오는 프로퍼티 추가
  DocumentState get documentState;
  VulcanCloseDialogWidget? _dragDocsDialog;
  final rxConvertOfficeDoc = Rx<int>(1);

  Future<PlatformFile?> pickDocumentFile(
    BuildContext context, {
    List<String> extensions = allowedDocumentExtensions,
  }) async {
    final allowedExtensions = List<String>.from(extensions);
    allowedExtensions
        .removeWhere((item) => !allowedDocumentExtensions.contains(item));

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: allowedExtensions,
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      String fileExtension = file.extension ?? '';
      Uint8List fileBytes = file.bytes ?? Uint8List(0);

      if (allowedExtensions.contains(fileExtension) && fileBytes.isNotEmpty) {
        return file;
      }
    }

    return null;
  }

  Future<void> showDragDocsAlertDialog(
    BuildContext context,
    String message,
  ) async {
    await VulcanCloseDialogWidget(
      isShowConfirm: false,
      isShowCancel: false,
      width: 300,
      height: 150,
      // 알림
      title: 'info_title'.tr,
      content: Center(
        child: Text(message),
      ),
    ).show(context);
  }

  Future<void> showDragDocsWebViewDialog(
    BuildContext context, {
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final controller = Get.find<VulcanEditorController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.9;
    final contentHeight = dialogHeight;
    final fileExtension = p.extension(fileName ?? '');
    final url =
        fileExtension.endsWith('.txt') || fileExtension.endsWith('.xhtml')
            ? controller.documentState.rxTextViewerURL.value
            : controller.documentState.rxDragdocsURL.value;

    _dragDocsDialog = VulcanCloseDialogWidget(
      isShowConfirm: false,
      isShowCancel: false,
      width:
          (controller.documentState.rxDocumentSizeWidth.value + 450).toDouble(),
      height: dialogHeight + 50,
      title: 'drag_docs'.tr,
      content: Center(
        child: OfficeIframe(
          url: url,
          fileBytes: fileBytes,
          fileName: fileName,
          width: controller.documentState.rxDocumentSizeWidth.value.toDouble() +
              450,
          height: contentHeight - 60,
          readOnly: false,
          onConvert: (result, fileName, page, content) async {
            logger.d(
                '[OfficeIframe][onConvert] result: $result, fileName: $fileName, page: $page');

            if (result == -3) {
              // 미지원
              EasyLoading.dismiss();
              await showDragDocsAlertDialog(context, 'document_unsupported'.tr);
              return;
            } else if (result == 1) {
              EasyLoading.dismiss();
              if (rxConvertOfficeDoc.value != 2) {
                // 페이지 내보내기 없이 완료 응답(result == 1)이 온 경우
                await showDragDocsAlertDialog(
                    context, 'document_invalid_page'.tr);
              } else {
                EasyLoading.dismiss();
                EasyLoading.showSuccess('document_conversion_completed'.tr);
                _dragDocsDialog?.close();
                _dragDocsDialog = null;
              }
              return;
            } else if (result <= 0) {
              // 엔진 에러
              EasyLoading.dismiss();
              await showDragDocsAlertDialog(
                  context, '${'document_error'.tr} ($result)');
              return;
            }

            if (!EasyLoading.isShow) {
              EasyLoading.show();
            }
            controller.rxConvertOfficeDoc.value = result;
            // once(rxConvertOfficeDoc, (int value) {
            //   if (value != 2) {
            //     _dragDocsDialog?.close();
            //     _dragDocsDialog = null;
            //   }
            // });

            final isSuccess =
                _convertOfficeDoc(result, fileName, page, content);
            if (isSuccess != true) {
              EasyLoading.dismiss();
              await showDragDocsAlertDialog(
                  context, 'document_invalid_data'.tr);
              return;
            }
          },
        ),
      ),
    );

    rxConvertOfficeDoc.value = 1;
    await _dragDocsDialog?.show(context);
    _dragDocsDialog = null;
    rxConvertOfficeDoc.value = 1;
  }

  bool _convertOfficeDoc(
    int result,
    String fileName,
    int page,
    String content,
  ) {
    final controller = Get.find<VulcanEditorController>();
    // 새 페이지 생성을 위한 triggerCreatePageWidthContent 호출
    return controller.triggerCreatePageWidthContent(
      result,
      fileName,
      page,
      content,
    );
  }
}
