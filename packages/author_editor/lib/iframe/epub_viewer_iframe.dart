import 'dart:async';
import 'dart:collection';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:author_editor/iframe/iframe.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';

import 'iframe_mixin.dart';

@JS()
extension type WindowCallBack(JSObject _) implements JSObject {
  external void loadFromUrl(String baseUrl, String? projectId, String fileUrl);
  external void loadFromMemory(String baseUrl, String? projectId,
      JSUint8Array jsUint8Array, String fileName);
  external void openViewer(String baseUrl, String? projectId);
}

class EpubViewerIframe extends StatefulWidget with IframeMixin {
  const EpubViewerIframe({
    super.key,
    required this.baseUrl,
    required this.url,
    this.projectId,
    this.fileUrl,
    this.fileBytes,
    this.fileName,
    this.width = 500,
    this.height = 500,
    this.onClose,
    this.onConvert,
  });

  final String baseUrl;
  final String? projectId;
  final String url;
  final String? fileUrl;
  final Uint8List? fileBytes;
  final String? fileName;
  final double width;
  final double height;
  final VoidCallback? onClose;
  final OnConvertCallback? onConvert;

  @override
  State<EpubViewerIframe> createState() => _EpubViewerIframeState();
}

class _EpubViewerIframeState extends State<EpubViewerIframe> {
  late WindowCallBack? jsWindowCallBack;

  // 콜백 데이터를 저장할 큐
  final Queue<Map<String, dynamic>> _callbackQueue =
      Queue<Map<String, dynamic>>();

  // 1초마다 큐 처리를 위한 타이머
  Timer? _processTimer;

  @override
  void initState() {
    super.initState();
    // 1초마다 큐에서 데이터를 처리하는 타이머 시작
    _processTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _processQueue();
    });
  }

  @override
  void dispose() {
    _processTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        IFrameWidget(
            url: widget.url,
            width: widget.width,
            height: widget.height,
            onLoad: (contentWindow) {
              jsWindowCallBack = contentWindow as WindowCallBack;

              debugPrint('EpubViewerIframe');
              debugPrint('  - fileUrl: ${widget.fileUrl}');
              debugPrint('  - fileBytes: ${widget.fileBytes?.length ?? 0}');
              debugPrint('  - fileName: ${widget.fileName}');

              if (widget.fileUrl != null && widget.fileUrl!.isNotEmpty) {
                jsWindowCallBack?.loadFromUrl(
                  widget.baseUrl,
                  widget.projectId,
                  widget.fileUrl ?? '',
                );
              } else if (widget.fileBytes != null &&
                  (widget.fileName != null && widget.fileName!.isNotEmpty)) {
                JSUint8Array jsUint8Array = widget.fileBytes!.toJS;
                jsWindowCallBack?.loadFromMemory(
                  widget.baseUrl,
                  widget.projectId,
                  jsUint8Array,
                  widget.fileName!,
                );
              } else {
                jsWindowCallBack?.openViewer(
                  widget.baseUrl,
                  widget.projectId,
                );
              }
            },
            onCallback: (data) {
              // 콜백 데이터를 큐에 추가
              _callbackQueue.add(data);
            }),
      ],
    );
  }

  /// 큐에서 콜백 데이터를 처리하는 함수
  void _processQueue() {
    if (_callbackQueue.isEmpty) return;

    // 큐에서 데이터를 하나씩 꺼내서 처리
    final data = _callbackQueue.removeFirst();
    _handleCallback(data);
  }

  /// iframe에서 전달받은 콜백 데이터를 처리하는 함수
  void _handleCallback(Map<String, dynamic> data) {
    try {
      logger.d(
          '[EpubViewerIframe][파싱된 콜백 데이터] event:"${data['event']}", result:${data['result']}, file:"${data['file']}", page:${data['page']}, total:${data['total']}, type:${data['type']}');

      // onClose 이벤트 처리
      if (data['event'] == 'onClose') {
        widget.onClose?.call();
      }
      // onExport 이벤트 처리
      else if (data['event'] == 'onExport') {
        /**
         * [result]: 1: 종료, 2: 페이지 내보내기 중, -3: 미지원
         * [type]: 1: xhtml,
         */
        if (data['result'] == 3) {
          // 리소스 업로드 시작: 로딩 스피너 표시를 위해 즉시 전달
          final int total = data['total'] ?? 0;
          widget.onConvert?.call(3, '', 0, total, '');
        } else if (data['result'] == 2) {
          final int page = data['page'] ?? 0;
          final int total = data['total'] ?? 0;
          // final int type = data['type'] ?? 0;
          final String text = widget.safeStringConvert(data['text']) ?? '';
          final String fileName = '${widget.safeStringConvert(data['file'])}';
          widget.onConvert?.call(2, fileName, page, total, text);
        } else if (data['result'] == 1) {
          widget.onConvert?.call(1, '', 0, 0, '');
        } else if (data['result'] == -3) {
          widget.onConvert?.call(-3, '', 0, 0, '');
        }
      }
    } catch (e) {
      logger.e('콜백 데이터 처리 중 오류 발생', e);
    }
  }
}
