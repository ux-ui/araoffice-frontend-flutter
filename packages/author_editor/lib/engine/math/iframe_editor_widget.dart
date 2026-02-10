import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class IFrameEditorWidget extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final void Function(String)? onLoad;
  final void Function(String)? onError;

  const IFrameEditorWidget({
    super.key,
    required this.url,
    this.width = double.infinity,
    this.height = 500,
    this.onLoad,
    this.onError,
  });

  @override
  State<IFrameEditorWidget> createState() => IFrameEditorWidgetState();
}

class IFrameEditorWidgetState extends State<IFrameEditorWidget> {
  late final String viewType;
  bool _isLoading = true;
  String? _errorMessage;
  web.HTMLIFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    windowVulcan(false.toJS);
    viewType = 'iframe-editor-${_generateUuid()}';
    _registerIFrameElement();
  }

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

  void goBack() {
    try {
      if (_iframe != null) {
        final contentWindow = _iframe!.contentWindow;
        if (contentWindow != null) {
          contentWindow.history.back();
        }
      }
    } catch (e) {
      debugPrint('Error navigating back: $e');
    }
  }

  void goForward() {
    try {
      if (_iframe != null) {
        final contentWindow = _iframe!.contentWindow;
        if (contentWindow != null) {
          contentWindow.history.forward();
        }
      }
    } catch (e) {
      debugPrint('Error navigating forward: $e');
    }
  }

  void _registerIFrameElement() {
    try {
      // 외부 컨테이너 추가
      final wrapperDiv = web.document.createElement('div') as web.HTMLDivElement
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'flex'
        ..style.justifyContent = 'center'
        ..style.alignItems = 'center';

      final containerDiv =
          web.document.createElement('div') as web.HTMLDivElement
            ..style.width = '${widget.width}px'
            ..style.height = '${widget.height}px'
            ..style.overflow = 'hidden'
            ..style.position = 'relative'
            ..style.border = '1px solid #e0e0e0'
            ..style.borderRadius = '4px';

      _iframe = web.document.createElement('iframe') as web.HTMLIFrameElement
        ..src = widget.url
        ..style.width = '100%'
        ..style.height = '100%';

      // containerDiv를 wrapperDiv 안에 넣기
      containerDiv.appendChild(_iframe!);
      wrapperDiv.appendChild(containerDiv);

      _iframe!.onLoad.listen((event) {
        try {
          final iframeDocument = _iframe!.contentDocument;
          if (iframeDocument != null && iframeDocument.body != null) {
            final contentWidth =
                iframeDocument.documentElement?.scrollWidth ?? 0;
            final contentHeight =
                iframeDocument.documentElement?.scrollHeight ?? 0;

            final scaleX = widget.width / contentWidth;
            final scaleY = widget.height / contentHeight;
            final scale = math.min(scaleX, scaleY);

            final scaledWidth = contentWidth * scale;
            final scaledHeight = contentHeight * scale;

            containerDiv
              ..style.width = '${scaledWidth}px'
              ..style.height = '${scaledHeight}px';

            _iframe!
              ..style.width = '100%'
              ..style.height = '100%';

            iframeDocument.body!.style
              ..transform = 'scale($scale)'
              ..transformOrigin = 'top left'
              ..width = '100%'
              ..height = '100%';
          }

          if (mounted) {
            setState(() => _isLoading = false);
            widget.onLoad?.call('IFrame loaded successfully');
          }
        } catch (e) {
          debugPrint('Error modifying iframe body style: $e');
        }
      });

      const String scrollbarStyle = '''
        ::-webkit-scrollbar {
          width: 8px;
          height: 8px;
        }
        ::-webkit-scrollbar-thumb {
          background: rgba(0, 0, 0, 0.2);
          border-radius: 4px;
        }
        ::-webkit-scrollbar-track {
          background: transparent;
        }
      ''';

      final styleElement = web.document.createElement('style')
          as web.HTMLStyleElement
        ..innerText = scrollbarStyle;

      web.document.head?.appendChild(styleElement);

      _iframe!.onLoad.listen((event) {
        if (mounted) {
          setState(() => _isLoading = false);
          widget.onLoad?.call('IFrame loaded successfully');
        }
      });

      _iframe!.onError.listen((event) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load iframe content';
          });
          widget.onError?.call('Failed to load iframe content');
        }
      });

      _iframe!
        ..setAttribute('sandbox',
            'allow-same-origin allow-scripts allow-forms allow-popups allow-modals')
        ..setAttribute('loading', 'lazy')
        ..setAttribute('importance', 'high')
        ..setAttribute('referrerpolicy', 'no-referrer');

      containerDiv.appendChild(_iframe!);

      platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) => wrapperDiv,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error creating iframe: $e';
        });
        widget.onError?.call('Error creating iframe: $e');
      }
    }
  }

  @override
  void dispose() {
    windowVulcan(true.toJS);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    return Stack(
      children: [
        HtmlElementView(viewType: viewType),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  void windowVulcan(JSBoolean value) {
    final jsWindow = globalContext.getProperty('window'.toJS) as JSObject;
    final jsParent = jsWindow.getProperty('parent'.toJS) as JSObject;
    jsParent.setProperty('vulcan'.toJS, value);
  }
}
