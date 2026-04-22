// lib/mixins/media_control_mixin.dart
import 'dart:typed_data';

import 'package:app_ui/widgets/vulcanx/vulcan_x_close_dialog_widget.dart';
import 'package:author_editor/iframe/epub_viewer_iframe.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

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
  final convertedPages = <int>[];

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
          baseUrl: AutoConfig.instance.domainType.originWithPath,
          projectId: controller.documentState.rxProjectId.value,
          url: controller.documentState.rxEpubViewerURL.value,
          fileBytes: fileBytes,
          fileName: fileName,
          width: controller.documentState.rxDocumentSizeWidth.value.toDouble() +
              450,
          height: contentHeight - 60,
          onConvert: (result, chapterFileName, page, total, content) async {
            logger.d(
                '[EpubViewerIframe][onConvert] result: $result, chapterFileName: $chapterFileName, page: $page, total: $total');

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
                  context, '${'document_conversion_error'.tr} ($result)');
              return;
            } else if (result == 3) {
              // 리소스 업로드 시작: 즉시 로딩 스피너 표시
              if (total > 1) {
                EasyLoading.showProgress(
                  0,
                  status: '${'document_converting'.tr} 0/$total',
                );
              } else {
                EasyLoading.show(status: 'document_converting'.tr);
              }
              return;
            }

            convertedPages.add(page);
            if (total > 1) {
              EasyLoading.showProgress(
                convertedPages.length / total,
                status:
                    '${'document_converting'.tr} ${convertedPages.length}/$total',
              );
            } else {
              EasyLoading.show(status: 'document_converting'.tr);
            }

            controller.rxConvertEpubViewer.value = result;
            // once(rxConvertEpubViewer, (int value) {
            //   if (value != 2) {
            //     _epubViewerDialog?.close();
            //     _epubViewerDialog = null;
            //   }
            // });

            // 원본 EPUB 파일명을 제목으로 사용, URL 로딩 등 파일명이 없는 경우 chapter 파일명으로 fallback
            final titleFileName = fileName ?? chapterFileName;
            final isSuccess =
                _convertEpubViewer(result, titleFileName, page, total, content);
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
    convertedPages.clear();
    await _epubViewerDialog?.show(context);
    _epubViewerDialog = null;
    rxConvertEpubViewer.value = 1;
    convertedPages.clear();
  }

  bool _convertEpubViewer(
    int result,
    String fileName,
    int page,
    int total,
    String content,
  ) {
    debugPrint('[Epub][$page]: ${content.length} bytes');
    final xhtmlContent = convertEpubContent(content);
    final controller = Get.find<VulcanEditorController>();
    // 새 페이지 생성을 위한 triggerCreatePageWidthContent 호출
    return controller.triggerCreatePageWidthContent(
      result,
      fileName,
      page,
      total,
      xhtmlContent,
    );
  }

  static String convertEpubContent(String content) {
    final buffer = StringBuffer();

    // DOCTYPE이 없으면 선행 삽입
    if (!content.trimLeft().startsWith('<!DOCTYPE')) {
      buffer.writeln('<!DOCTYPE html>');
    }

    // 에디터 렌더링에 필요한 CSS/JS 리소스 경로를 루트로 평탄화
    // 임의 하위 경로 지원 (예: ./styles/ve.css, ./css/custom.css, any/path/file.js → ./file)
    buffer.write(
      content
          .replaceAllMapped(
            RegExp(r'href="(?:\./)?(?:[^"]*/)([^"/ ]+\.css(?:\?[^"]*)?)"'),
            (m) => 'href="./${m.group(1)}"',
          )
          .replaceAllMapped(
            RegExp(r'src="(?:\./)?(?:[^"]*/)([^"/ ]+\.js(?:\?[^"]*)?)"'),
            (m) => 'src="./${m.group(1)}"',
          ),
    );

    // 에디터 엔진이 페이지 크기를 올바르게 인식하도록 보장
    // 에디터 엔진은 body style의 width/height를 읽으므로, 이 값이 반드시 존재해야 함
    var result = buffer.toString();
    result = _ensurePageDimensions(result);

    // <li> 내 인라인 콘텐츠를 <p>로 감싸서 에디터 정규화 오류 방지
    result = _normalizeListItems(result);

    // XHTML 호환성 보정 (void element self-closing, HTML 엔티티 변환 등)
    return _sanitizeForXhtml(result);
  }

  /// content에서 페이지 크기를 추출하고, body style과 viewport meta에 반영.
  ///
  /// 에디터 JS 엔진은 `window.editingBody.style.width/height`로 페이지 크기를 결정한다.
  /// viewport meta만으로는 반영되지 않으므로, body inline style에 width/height를 보장해야 한다.
  /// 크기 결정 우선순위: viewport meta > body style > 기본값 794x1123 (A4, 96 DPI).
  static String _ensurePageDimensions(String content) {
    String width = '794';
    String height = '1123';

    // 1. viewport meta에서 크기 추출 시도
    final viewportMatch = RegExp(
      r'<meta[^>]+name\s*=\s*"viewport"[^>]+content\s*=\s*"([^"]*)"',
      caseSensitive: false,
    ).firstMatch(content);
    if (viewportMatch != null) {
      final vc = viewportMatch.group(1)!;
      final vw = RegExp(r'width\s*=\s*(\d+)').firstMatch(vc);
      final vh = RegExp(r'height\s*=\s*(\d+)').firstMatch(vc);
      if (vw != null && vh != null) {
        width = vw.group(1)!;
        height = vh.group(1)!;
      }
    } else {
      // 2. body style에서 크기 추출 시도
      final bodyStyleMatch =
          RegExp(r'<body[^>]*style\s*=\s*"([^"]*)"', caseSensitive: false)
              .firstMatch(content);
      if (bodyStyleMatch != null) {
        final style = bodyStyleMatch.group(1)!;
        final bw = RegExp(r'width\s*:\s*(\d+)\s*px').firstMatch(style);
        final bh = RegExp(r'height\s*:\s*(\d+)\s*px').firstMatch(style);
        if (bw != null && bh != null) {
          width = bw.group(1)!;
          height = bh.group(1)!;
        }
      }
    }

    var result = content;

    // viewport meta 삽입 (없는 경우)
    if (viewportMatch == null) {
      final headMatch =
          RegExp(r'<head[^>]*>', caseSensitive: false).firstMatch(result);
      if (headMatch != null) {
        final viewportMeta =
            '<meta name="viewport" content="width=$width, height=$height" />';
        result =
            '${result.substring(0, headMatch.end)}\n$viewportMeta${result.substring(headMatch.end)}';
      }
    }

    // body style에 width/height 보장 (에디터 엔진이 실제로 읽는 값)
    result = _ensureBodyStyleDimensions(result, width, height);

    return result;
  }

  /// body 태그의 inline style에 width/height가 없으면 추가.
  static String _ensureBodyStyleDimensions(
      String content, String width, String height) {
    final bodyMatch =
        RegExp(r'<body([^>]*)>', caseSensitive: false).firstMatch(content);
    if (bodyMatch == null) return content;

    final attrs = bodyMatch.group(1)!;
    final styleMatch = RegExp(r'style\s*=\s*"([^"]*)"', caseSensitive: false)
        .firstMatch(attrs);

    if (styleMatch != null) {
      final style = styleMatch.group(1)!;
      final hasWidth = RegExp(r'width\s*:').hasMatch(style);
      final hasHeight = RegExp(r'height\s*:').hasMatch(style);
      if (hasWidth && hasHeight) return content;

      // 누락된 속성만 추가
      var newStyle = style;
      if (!hasWidth) newStyle = 'width:${width}px; $newStyle';
      if (!hasHeight) newStyle = 'height:${height}px; $newStyle';

      return content.replaceFirst(
        bodyMatch.group(0)!,
        '<body${attrs.replaceFirst(styleMatch.group(0)!, 'style="$newStyle"')}>',
      );
    } else {
      // style 속성 자체가 없는 경우 추가
      return content.replaceFirst(
        bodyMatch.group(0)!,
        '<body$attrs style="width:${width}px; height:${height}px;">',
      );
    }
  }

  /// <li>에 block-level 자식이 없으면 인라인 콘텐츠를 <p>로 감싸기.
  ///
  /// 에디터의 fr() 함수는 <li> 내부 인라인 콘텐츠를 <p>로 정규화하는데,
  /// DOM depth-first 순회 함수 he()가 인라인 래퍼(<span> 등) 내부의
  /// 자식 노드를 insertBefore 참조로 반환하여 NotFoundError가 발생한다.
  /// (참조 노드가 <li>의 직접 자식이 아닌 손자 노드이기 때문)
  ///
  /// import 시점에 <p>로 미리 감싸면, fr()가 block 조상을 발견하여
  /// 정규화 루프에 진입하지 않으므로 오류를 방지할 수 있다.
  static String _normalizeListItems(String content) {
    return content.replaceAllMapped(
      RegExp(
        r'(<li\b[^>]*>)'                    // 그룹1: <li> 여는 태그
        r'((?:(?!</?li\b|</?[uo]l\b).)*?)'  // 그룹2: 내용 (중첩 리스트 요소 제외)
        r'(</li>)',                          // 그룹3: </li> 닫는 태그
        dotAll: true,
      ),
      (m) {
        final inner = m.group(2)!;
        // 내용이 비어있으면 스킵
        if (inner.trim().isEmpty) return m.group(0)!;
        // 이미 block-level 자식이 있으면 스킵
        if (RegExp(r'<(?:p|div|h[1-6]|blockquote|pre|section|table)\b',
                caseSensitive: false)
            .hasMatch(inner)) {
          return m.group(0)!;
        }
        return '${m.group(1)}<p>$inner</p>${m.group(3)}';
      },
    );
  }

  // XHTML 호환성 보정: void element self-closing, HTML 엔티티, colgroup 복원
  static String _sanitizeForXhtml(String content) {
    const voidElements = [
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
      'wbr',
    ];
    var result = content;
    for (final tag in voidElements) {
      // <tag ...> 형태 중 self-closing(/>)이 아닌 것을 <tag ... /> 로 변환
      final pattern = RegExp(
        '<($tag)(?=[\\s/>])([^>]*?)(?<!/)>',
        caseSensitive: false,
      );
      result = result.replaceAllMapped(pattern, (match) {
        return '<${match.group(1)}${match.group(2)} />';
      });
    }
    // DOM 파서가 colgroup/col 부모-자식 관계를 분리한 경우 복원
    result = result.replaceAllMapped(
      RegExp(r'<colgroup><\/colgroup>(\s*(?:<col\b[^>]*\/?>)+)',
          caseSensitive: false),
      (match) => '<colgroup>${match.group(1)}</colgroup>',
    );
    result = result.replaceAllMapped(
      RegExp(r'<colgroup\s*\/>(\s*(?:<col\b[^>]*\/?>)+)(\s*<\/colgroup>)?',
          caseSensitive: false),
      (match) => '<colgroup>${match.group(1)}</colgroup>',
    );
    // XML에서 허용되지 않는 HTML 엔티티를 숫자 참조로 변환
    result = _convertHtmlEntitiesToNumeric(result);
    return result;
  }

  // XML은 &lt; &gt; &amp; &quot; &apos; 만 허용하므로 나머지는 숫자 참조로 변환
  static String _convertHtmlEntitiesToNumeric(String content) {
    const htmlEntityMap = {
      '&nbsp;': '&#x00A0;',
      '&iexcl;': '&#x00A1;',
      '&cent;': '&#x00A2;',
      '&pound;': '&#x00A3;',
      '&curren;': '&#x00A4;',
      '&yen;': '&#x00A5;',
      '&brvbar;': '&#x00A6;',
      '&sect;': '&#x00A7;',
      '&uml;': '&#x00A8;',
      '&copy;': '&#x00A9;',
      '&ordf;': '&#x00AA;',
      '&laquo;': '&#x00AB;',
      '&not;': '&#x00AC;',
      '&shy;': '&#x00AD;',
      '&reg;': '&#x00AE;',
      '&macr;': '&#x00AF;',
      '&deg;': '&#x00B0;',
      '&plusmn;': '&#x00B1;',
      '&sup2;': '&#x00B2;',
      '&sup3;': '&#x00B3;',
      '&acute;': '&#x00B4;',
      '&micro;': '&#x00B5;',
      '&para;': '&#x00B6;',
      '&middot;': '&#x00B7;',
      '&cedil;': '&#x00B8;',
      '&sup1;': '&#x00B9;',
      '&ordm;': '&#x00BA;',
      '&raquo;': '&#x00BB;',
      '&frac14;': '&#x00BC;',
      '&frac12;': '&#x00BD;',
      '&frac34;': '&#x00BE;',
      '&iquest;': '&#x00BF;',
      '&times;': '&#x00D7;',
      '&divide;': '&#x00F7;',
      '&ndash;': '&#x2013;',
      '&mdash;': '&#x2014;',
      '&lsquo;': '&#x2018;',
      '&rsquo;': '&#x2019;',
      '&sbquo;': '&#x201A;',
      '&ldquo;': '&#x201C;',
      '&rdquo;': '&#x201D;',
      '&bdquo;': '&#x201E;',
      '&dagger;': '&#x2020;',
      '&Dagger;': '&#x2021;',
      '&bull;': '&#x2022;',
      '&hellip;': '&#x2026;',
      '&permil;': '&#x2030;',
      '&prime;': '&#x2032;',
      '&Prime;': '&#x2033;',
      '&lsaquo;': '&#x2039;',
      '&rsaquo;': '&#x203A;',
      '&oline;': '&#x203E;',
      '&euro;': '&#x20AC;',
      '&trade;': '&#x2122;',
      '&larr;': '&#x2190;',
      '&uarr;': '&#x2191;',
      '&rarr;': '&#x2192;',
      '&darr;': '&#x2193;',
      '&harr;': '&#x2194;',
      '&ensp;': '&#x2002;',
      '&emsp;': '&#x2003;',
      '&thinsp;': '&#x2009;',
    };
    var result = content;
    htmlEntityMap.forEach((entity, numeric) {
      result = result.replaceAll(entity, numeric);
    });
    return result;
  }
}
