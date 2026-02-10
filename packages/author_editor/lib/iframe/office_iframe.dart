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
  external void loadFromUrl(bool readOnly, String fileUrl);
  external void loadFromMemory(
      bool readOnly, JSArrayBuffer arrayBuffer, String fileName);
  external void openViewer(bool readOnly);
  external int getCurrentPage();
  external int getTotalPages();
}

class OfficeIframe extends StatefulWidget with IframeMixin {
  const OfficeIframe({
    super.key,
    required this.url,
    this.fileUrl,
    this.fileBytes,
    this.fileName,
    this.width = 500,
    this.height = 500,
    this.projectId,
    this.baseUrl,
    this.readOnly = false,
    this.onConvert,
  });

  final String url;
  final String? fileUrl;
  final Uint8List? fileBytes;
  final String? fileName;
  final double width;
  final double height;
  final String? projectId;
  final String? baseUrl;
  final bool readOnly;
  final OnConvertCallback? onConvert;

  @override
  State<OfficeIframe> createState() => _OfficeIframeState();
}

class _OfficeIframeState extends State<OfficeIframe> {
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

              debugPrint('OfficeIframe');
              debugPrint('  - fileUrl: ${widget.fileUrl}');
              debugPrint('  - fileBytes: ${widget.fileBytes?.length ?? 0}');
              debugPrint('  - fileName: ${widget.fileName}');

              if (widget.fileUrl != null) {
                jsWindowCallBack?.loadFromUrl(
                  widget.readOnly,
                  widget.fileUrl ?? '',
                );
              } else if (widget.fileBytes != null && widget.fileName != null) {
                JSArrayBuffer jsArrayBuffer = widget.fileBytes!.buffer.toJS;
                jsWindowCallBack?.loadFromMemory(
                  widget.readOnly,
                  jsArrayBuffer,
                  widget.fileName ?? '',
                );
              } else {
                jsWindowCallBack?.openViewer(widget.readOnly);
              }
            },
            onCallback: (data) {
              // 콜백 데이터를 큐에 추가
              _callbackQueue.add(data);
            }),
      ],
    );
  }

  int getCurrentPage() {
    return jsWindowCallBack?.getCurrentPage() ?? 0;
  }

  int getTotalPages() {
    return jsWindowCallBack?.getTotalPages() ?? 0;
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
          '[OfficeIframe][파싱된 콜백 데이터] event:"${data['event']}", result:${data['result']}, file:"${data['file']}", page:${data['page']}, type:${data['type']}');

      // onExport 이벤트 처리
      if (data['event'] == 'onExport') {
        /**
         * [result]: 1: 종료, 2: 페이지 내보내기 중, -3: 미지원
         * [type]: 1: xhtml,
         */
        if (data['result'] == 2) {
          final int page = data['page'] ?? 0;
          // final int type = data['type'] ?? 0;
          final String text = widget.safeStringConvert(data['text']) ?? '';
          final String fileName = '${widget.safeStringConvert(data['file'])}';
          widget.onConvert?.call(2, fileName, page, text);
        } else if (data['result'] == 1) {
          widget.onConvert?.call(1, '', 0, '');
        } else if (data['result'] == -3) {
          widget.onConvert?.call(-3, '', 0, '');
        }
      }
    } catch (e) {
      logger.e('콜백 데이터 처리 중 오류 발생', e);
    }
  }
}
