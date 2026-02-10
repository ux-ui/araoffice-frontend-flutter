// lib/mixins/media_control_mixin.dart
import 'dart:typed_data';

import 'package:app_ui/widgets/vulcanx/vulcan_x_close_dialog_widget.dart';
import 'package:author_editor/iframe/epub_viewer_iframe.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html_parser;

import '../engine/engines.dart';
import '../states/document_state.dart';
import '../vulcan_editor_controller.dart';
import 'page_control_mixin.dart';

/// 이펍 뷰어 기능을 관리하는 Mixin
mixin EpubViewerMixin on GetxController {
  Editor? get editor;
  PageControlMixin get pageController;
  // 문서 크기를 가져오는 프로퍼티 추가
  DocumentState get documentState;
  VulcanCloseDialogWidget? _epubViewerDialog;
  final rxConvertEpubViewer = Rx<int>(1);

  Future<void> showEpubViewerAlertDialog(
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

  Future<void> showEpubViewerWebViewDialog(
    BuildContext context, {
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final controller = Get.find<VulcanEditorController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.9;
    final contentHeight = dialogHeight;

    _epubViewerDialog = VulcanCloseDialogWidget(
      isShowConfirm: false,
      isShowCancel: false,
      width:
          (controller.documentState.rxDocumentSizeWidth.value + 450).toDouble(),
      height: dialogHeight + 50,
      title: 'epub_viewer'.tr,
      content: Center(
        child: EpubViewerIframe(
          url: controller.documentState.rxEpubViewerURL.value,
          fileBytes: fileBytes,
          fileName: fileName,
          width: controller.documentState.rxDocumentSizeWidth.value.toDouble() +
              450,
          height: contentHeight - 60,
          onConvert: (result, fileName, page, content) async {
            logger.d(
                '[OfficeIframe][onConvert] result: $result, fileName: $fileName, page: $page');

            if (result == -3) {
              // 미지원
              EasyLoading.dismiss();
              await showEpubViewerAlertDialog(
                  context, 'document_unsupported'.tr);
              return;
            } else if (result == 1) {
              EasyLoading.dismiss();
              if (rxConvertEpubViewer.value != 2) {
                // 페이지 내보내기 없이 완료 응답(result == 1)이 온 경우
                await showEpubViewerAlertDialog(
                    context, 'document_invalid_page'.tr);
              } else {
                EasyLoading.dismiss();
                EasyLoading.showSuccess('document_conversion_completed'.tr);
                _epubViewerDialog?.close();
                _epubViewerDialog = null;
              }
              return;
            } else if (result <= 0) {
              // 엔진 에러
              EasyLoading.dismiss();
              await showEpubViewerAlertDialog(
                  context, '${'document_error'.tr} ($result)');
              return;
            }

            if (!EasyLoading.isShow) {
              EasyLoading.show();
            }
            controller.rxConvertEpubViewer.value = result;
            // once(rxConvertEpubViewer, (int value) {
            //   if (value != 2) {
            //     _epubViewerDialog?.close();
            //     _epubViewerDialog = null;
            //   }
            // });

            final isSuccess =
                _convertEpubViewer(result, fileName, page, content);
            if (isSuccess != true) {
              EasyLoading.dismiss();
              await showEpubViewerAlertDialog(
                  context, 'document_invalid_data'.tr);
              return;
            }
          },
        ),
      ),
    );

    rxConvertEpubViewer.value = 1;
    await _epubViewerDialog?.show(context);
    _epubViewerDialog = null;
    rxConvertEpubViewer.value = 1;
  }

  bool _convertEpubViewer(
    int result,
    String fileName,
    int page,
    String content,
  ) {
    debugPrint('[Epub][$page]: $content');
    final xhtmlContent = convertEpubContent(content);
    final controller = Get.find<VulcanEditorController>();
    // 새 페이지 생성을 위한 triggerCreatePageWidthContent 호출
    return controller.triggerCreatePageWidthContent(
      result,
      fileName,
      page,
      xhtmlContent,
    );
  }

  static String convertEpubContent(String content) {
    final buffer = StringBuffer();
    final htmlDocument = html_parser.parse(content);
    // DOCTYPE 추가
    _addDocType(buffer, htmlDocument);
    // head에 meta, link, script추가
    _addHeadElements(htmlDocument);
    // XHTML 형식으로 변환 (void elements 태그 목록)
    final xhtmlContent = _ensureXhtml(htmlDocument);
    buffer.write(xhtmlContent);
    return buffer.toString();
  }

  static void _addDocType(StringBuffer buffer, html_dom.Document htmlDocument) {
    final hasDocType =
        htmlDocument.firstChild?.nodeType == html_dom.Node.DOCUMENT_TYPE_NODE;
    if (!hasDocType) {
      buffer.writeln('<!DOCTYPE html>');
    }
  }

  static void _addHeadElements(html_dom.Document htmlDocument) {
    // <meta http-equiv="default-style" content="application/xhtml+xml; charset=utf-8" />
    // final meta = html_dom.Element.tag('meta');
    // meta.attributes['http-equiv'] = 'default-style';
    // meta.attributes['content'] = 'application/xhtml+xml; charset=utf-8';
    // htmlDocument.head?.children.add(meta);

    // <link href="./ve_basic.css" rel="stylesheet" type="text/css" />
    final linkBasic = html_dom.Element.tag('link');
    linkBasic.attributes['href'] = './ve_basic.css';
    linkBasic.attributes['rel'] = 'stylesheet';
    linkBasic.attributes['type'] = 'text/css';
    htmlDocument.head?.children.add(linkBasic);

    // <link href="./ve_builtin_style.css" rel="stylesheet" type="text/css" />
    final linkBuiltinStyle = html_dom.Element.tag('link');
    linkBuiltinStyle.attributes['href'] = './ve_builtin_style.css';
    linkBuiltinStyle.attributes['rel'] = 'stylesheet';
    linkBuiltinStyle.attributes['type'] = 'text/css';
    htmlDocument.head?.children.add(linkBuiltinStyle);

    // <script src="./jquery.min.js" type="text/javascript" />
    final scriptJQuery = html_dom.Element.tag('script');
    scriptJQuery.attributes['src'] = './jquery.min.js';
    scriptJQuery.attributes['type'] = 'text/javascript';
    htmlDocument.head?.children.add(scriptJQuery);

    // <script src="./ve_basic.js" type="text/javascript" />
    final scriptBasic = html_dom.Element.tag('script');
    scriptBasic.attributes['src'] = './ve_basic.js';
    scriptBasic.attributes['type'] = 'text/javascript';
    htmlDocument.head?.children.add(scriptBasic);

    // <script src="./ve_shape.js" type="text/javascript" />
    final scriptShape = html_dom.Element.tag('script');
    scriptShape.attributes['src'] = './ve_shape.js';
    scriptShape.attributes['type'] = 'text/javascript';
    htmlDocument.head?.children.add(scriptShape);
  }

  static String _ensureXhtml(html_dom.Document htmlDocument) {
    // html - void elements 태그 목록
    final voidElements = [
      'area',
      'base',
      'br',
      'col',
      'embed',
      'hr',
      'img',
      'input',
      'keygen',
      'link',
      'meta',
      'param',
      'source',
      'track',
      'wbr'
    ];
    var result = htmlDocument.outerHtml;
    for (var tag in voidElements) {
      // <tag> 형태를 <tag></tag> 또는 <tag /> 형태로 변환
      RegExp pattern = RegExp('<($tag)([^>]*?)(?<!/)>', caseSensitive: false);
      result = result.replaceAllMapped(pattern, (match) {
        String tagName = match.group(1)!;
        String attributes = match.group(2)!;
        return '<$tagName$attributes />'; // XHTML 스타일
      });
    }
    return result;
  }
}
