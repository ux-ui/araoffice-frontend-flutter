import 'dart:async';
import 'dart:js_interop';
import 'dart:math' as math;
import 'dart:ui_web';

import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as web;

@JS()
extension type MathEditor(JSObject _) implements JSObject {
  external String getMathML();
}

@JS()
extension type WindowWithMath(JSObject _) implements JSObject {
  external MathEditor get editor;
  external String getMathContent();
}

class MathEditorIFrame extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final void Function(String)? onSave;

  const MathEditorIFrame({
    super.key,
    required this.url,
    this.width = double.infinity,
    this.height = 500,
    this.onSave,
  });

  @override
  State<MathEditorIFrame> createState() => _MathEditorIFrameState();
}

class _MathEditorIFrameState extends State<MathEditorIFrame> {
  late final String viewType;
  bool _isLoading = true;
  web.HTMLIFrameElement? _iframe;
  StreamSubscription<web.Event>? _loadSubscription;
  StreamSubscription<web.Event>? _messageSubscription;

  // UUID v4 생성 함수
  String _generateUuid() {
    const String hexChars = '0123456789abcdef';
    final math.Random random = math.Random();
    final List<String> uuid = List.filled(36, '', growable: false);

    for (int i = 0; i < 36; i++) {
      if (i == 8 || i == 13 || i == 18 || i == 23) {
        uuid[i] = '-';
      } else if (i == 14) {
        uuid[i] = '4';
      } else if (i == 19) {
        uuid[i] = hexChars[(random.nextInt(4) | 8)];
      } else {
        uuid[i] = hexChars[random.nextInt(16)];
      }
    }

    return uuid.join('');
  }

  @override
  void initState() {
    super.initState();
    viewType = 'math-editor-${_generateUuid()}';
    _registerIFrameElement();
    _setupMessageListener();
  }

  void _registerIFrameElement() {
    try {
      // 새로운 iframe 생성
      _iframe = web.document.createElement('iframe') as web.HTMLIFrameElement
        ..id = viewType // 생성된 UUID를 id로 설정
        ..src = widget.url
        ..width = widget.width.toString()
        ..height = widget.height.toString()
        ..style.border = 'none';

      _iframe!.setAttribute(
          'sandbox', 'allow-same-origin allow-scripts allow-forms');

      _loadSubscription = _iframe!.onLoad.listen((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });

      final iframeElement = _iframe;
      if (iframeElement != null) {
        platformViewRegistry.registerViewFactory(
          viewType,
          (int viewId) => iframeElement,
        );
      }
    } catch (e) {
      logger.e('Error creating iframe: $e');
    }
  }

  void _setupMessageListener() {
    _messageSubscription =
        web.window.onMessage.listen((web.MessageEvent event) {
      if (!mounted) return;

      try {
        final data = event.data;
        if (data is JSObject) {
          final map = data.dartify() as Map<dynamic, dynamic>;
          if (map['type'] == 'MATH_CONTENT' && map['content'] != null) {
            final content = map['content'].toString();
            if (content.isNotEmpty) {
              widget.onSave?.call(content);
            }
          }
        }
      } catch (e) {
        logger.e('Error processing message: $e');
      }
    });
  }

  void callSaveContent() {
    if (!mounted) return;

    try {
      if (_iframe?.contentWindow != null) {
        final contentWindow = _iframe!.contentWindow! as JSObject;
        final windowWithMath = contentWindow as WindowWithMath;

        try {
          final content = windowWithMath.getMathContent();
          if (content.isNotEmpty) {
            logger.e('Math content from getMathContent: $content');
            widget.onSave?.call(content);
            return;
          }
        } catch (e) {
          logger.e('Error calling getMathContent: $e');
        }

        try {
          final mathml = windowWithMath.editor.getMathML();
          if (mathml.isNotEmpty) {
            logger.e('Math content from editor.getMathML: $mathml');
            widget.onSave?.call(mathml);
          }
        } catch (e) {
          logger.e('Error calling editor.getMathML: $e');
        }
      }
    } catch (e) {
      logger.e('Error in callSaveContent: $e');
    }
    context.pop();
  }

  @override
  void dispose() {
    // 등록된 모든 리스너 해제
    _loadSubscription?.cancel();
    _messageSubscription?.cancel();

    // iframe 제거
    if (_iframe != null) {
      try {
        // iframe의 src를 비워서 리소스 해제
        _iframe!.src = 'about:blank';
        // DOM에서 iframe 요소 제거
        _iframe!.remove();
        _iframe = null;
      } catch (e) {
        logger.e('Error removing iframe: $e');
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height + 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: widget.width,
                height: widget.height,
                child: HtmlElementView(viewType: viewType),
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Row를 우측 정렬
            mainAxisSize: MainAxisSize.max, // Row가 전체 너비를 사용하도록 설정
            children: [
              TextButton(onPressed: callSaveContent, child: Text('apply'.tr)),
              TextButton(
                  onPressed: () => context.pop(), child: Text('cancel'.tr)),
            ],
          ),
        ],
      ),
    );
  }
}
