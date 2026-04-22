import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
class IFrameEditorWidget extends StatefulWidget {
  final String url;
  final String? fontUrl;
  final double width;
  final double height;
  final Set<String> validInternalHrefs;
  final String invalidInternalLinkMessage;
  final void Function(String)? onLoad;
  final void Function(String)? onError;
  final void Function(String)? onPageUrlChanged;
  final double? documentWidth;
  final double? documentHeight;

  const IFrameEditorWidget({
    super.key,
    required this.url,
    this.fontUrl,
    this.width = double.infinity,
    this.height = 500,
    this.validInternalHrefs = const <String>{},
    this.invalidInternalLinkMessage = '삭제되었거나 존재하지 않는 페이지 링크입니다.',
    this.onLoad,
    this.onError,
    this.onPageUrlChanged,
    this.documentWidth,
    this.documentHeight,
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
            _injectFontStyle(iframeDocument);
            _injectPreviewLinkInterceptor(iframeDocument);
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
             // ..width = '100%'
              // ..height = '100%';
              ..width = widget.documentWidth != null
                  ? '${widget.documentWidth.toString()}px'
                  : '100%'
              ..height = widget.documentHeight != null
                  ? '${widget.documentHeight.toString()}px'
                  : '100%';
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

  Future<void> _injectFontStyle(web.Document iframeDocument) async {
    if (widget.fontUrl == null) return;
    try {
      final response = await web.window.fetch(widget.fontUrl!.toJS).toDart;
      if (!response.ok) return;
      final text = (await response.text().toDart).toDart;
      final data = jsonDecode(text);
      if (data == null || data['fonts'] == null) return;
      final buffer = StringBuffer();
      for (final font in data['fonts']) {
        buffer.write("@font-face { font-family: '${font['family']}'; "
            "src: url('${font['url']}'); "
            "font-weight: ${font['weight']}; "
            "font-display: swap; }");
      }
      final style =
          iframeDocument.createElement('style') as web.HTMLStyleElement
            ..id = 've-styleforfont'
            ..textContent = buffer.toString();
      iframeDocument.head?.appendChild(style);
    } catch (e) {
      debugPrint('Error injecting font style: $e');
    }
  }

  void _injectPreviewLinkInterceptor(web.Document iframeDocument) {
    final interceptorId = 'vulcan-preview-link-interceptor';
    if (iframeDocument.getElementById(interceptorId) != null) {
      return;
    }

    final validInternalHrefJson = jsonEncode(
      widget.validInternalHrefs.map((e) => e.toLowerCase()).toList(),
    );
    final invalidInternalLinkMessageJson =
        jsonEncode(widget.invalidInternalLinkMessage);

    final script =
        iframeDocument.createElement('script') as web.HTMLScriptElement
          ..id = interceptorId
          ..text = '''
(function () {
  if (window.__vulcanPreviewLinkInterceptorInstalled) {
    return;
  }
  window.__vulcanPreviewLinkInterceptorInstalled = true;
  var validInternalHrefs = new Set($validInternalHrefJson);
  var invalidInternalLinkMessage = $invalidInternalLinkMessageJson;

  function normalizeInternalHref(rawHref) {
    if (!rawHref) {
      return null;
    }
    var value = (rawHref || '').trim();
    if (!value || value.charAt(0) === '#') {
      return null;
    }

    var lower = value.toLowerCase();
    if (lower.startsWith('mailto:') ||
        lower.startsWith('tel:') ||
        lower.startsWith('javascript:') ||
        lower.startsWith('data:')) {
      return null;
    }

    var hasScheme = /^[a-z][a-z0-9+.-]*:/i.test(value);
    if (hasScheme) {
      return null;
    }

    try {
      var parsed = new URL(value, window.location.href);
      var path = parsed.pathname || '';
      var segments = path.split('/').filter(function (seg) { return !!seg; });
      if (segments.length === 0) {
        return null;
      }
      var fileName = decodeURIComponent(segments[segments.length - 1]).toLowerCase();
      if (!/^[^/]+\\.(xhtml|html?)\$/i.test(fileName)) {
        return null;
      }
      return fileName;
    } catch (_) {
      var noHash = value.split('#')[0];
      var noQuery = noHash.split('?')[0];
      var parts = noQuery.split('/').filter(function (seg) { return !!seg; });
      if (parts.length === 0) {
        return null;
      }
      var fallback = decodeURIComponent(parts[parts.length - 1]).toLowerCase();
      if (!/^[^/]+\\.(xhtml|html?)\$/i.test(fallback)) {
        return null;
      }
      return fallback;
    }
  }

  document.addEventListener('click', function (event) {
    var target = event.target;
    if (!(target instanceof Element)) {
      return;
    }

    var anchor = target.closest('a[href]');
    if (!anchor) {
      return;
    }

    var rawHref = (anchor.getAttribute('href') || '').trim();
    if (!rawHref) {
      return;
    }

    var internalHref = normalizeInternalHref(rawHref);
    if (internalHref) {
      if (!validInternalHrefs.has(internalHref)) {
        event.preventDefault();
        event.stopPropagation();
        if (window.alert) {
          window.alert(invalidInternalLinkMessage);
        }
      }
      return;
    }

    var lowerHref = rawHref.toLowerCase();
    if (lowerHref.startsWith('mailto:') ||
        lowerHref.startsWith('tel:') ||
        lowerHref.startsWith('javascript:')) {
      return;
    }

    var hasScheme = /^[a-z][a-z0-9+.-]*:/i.test(rawHref);
    var looksLikeDomainWithoutScheme = /^(?:www\.)?(?:[a-z0-9-]+\.)+[a-z]{2,}(?:[/:?#].*)?\$/i.test(rawHref);

    if (!hasScheme && !looksLikeDomainWithoutScheme) {
      return;
    }

    var openUrl = rawHref;
    if (!hasScheme && looksLikeDomainWithoutScheme) {
      openUrl = 'https://' + rawHref;
    }

    event.preventDefault();
    event.stopPropagation();
    window.open(openUrl, '_blank', 'noopener,noreferrer');
  }, true);
})();
''';

    iframeDocument.head?.appendChild(script);
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
