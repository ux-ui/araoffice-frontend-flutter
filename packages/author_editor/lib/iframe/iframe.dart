import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';
import 'dart:ui_web';

import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;

@JS('window.onCallback')
external set onCallback(JSFunction callback);

/// iframe 요소 생성 및 관리를 위한 유틸리티 클래스
class IFrameUtils {
  static const Uuid _uuid = Uuid();

  /// UUID v4 생성
  static String generateUuid() {
    return _uuid.v4();
  }

  /// 안전한 iframe src 설정
  static void setSafeSrc(web.HTMLIFrameElement iframe, String url) {
    iframe.src = url;
  }

  /// iframe 속성 설정
  static void setIFrameAttributes(
    web.HTMLIFrameElement iframe, {
    String? sandbox,
    String? loading,
    String? importance,
    String? referrerPolicy,
    bool allowFullscreen = false,
  }) {
    if (sandbox != null) {
      iframe.setAttribute('sandbox', sandbox);
    }
    if (loading != null) {
      iframe.setAttribute('loading', loading);
    }
    if (importance != null) {
      iframe.setAttribute('importance', importance);
    }
    if (referrerPolicy != null) {
      iframe.setAttribute('referrerpolicy', referrerPolicy);
    }
    if (allowFullscreen) {
      iframe.setAttribute('allowfullscreen', '');
    }
  }

  /// 스크롤바 스타일 적용
  static void applyScrollbarStyles() {
    const String scrollbarStyle = '''
      ::-webkit-scrollbar {
        width: 8px;
        height: 8px;
      }
      ::-webkit-scrollbar-thumb {
        background: rgba(0, 0, 0, 0.3);
        border-radius: 4px;
      }
      ::-webkit-scrollbar-thumb:hover {
        background: rgba(0, 0, 0, 0.5);
      }
      ::-webkit-scrollbar-track {
        background: transparent;
      }
    ''';

    final existingStyle =
        web.document.querySelector('style[data-iframe-scrollbar]');
    if (existingStyle == null) {
      final styleElement =
          web.document.createElement('style') as web.HTMLStyleElement
            ..innerText = scrollbarStyle
            ..setAttribute('data-iframe-scrollbar', '');
      web.document.head?.appendChild(styleElement);
    }
  }
}

/// iframe 관련 이벤트 콜백 정의
typedef IFrameLoadCallback = void Function(JSObject contentWindow);
typedef IFrameErrorCallback = void Function(String error);
typedef IFrameMessageCallback = void Function(Map<String, dynamic> data);

/// 고급 기능을 제공하는 IFrame Widget
class IFrameWidget extends StatefulWidget {
  /// iframe이 로드할 URL
  final String url;

  /// iframe의 너비 (기본값: 무한대)
  final double width;

  /// iframe의 높이 (기본값: 500)
  final double height;

  /// 로딩 완료 시 호출되는 콜백
  final IFrameLoadCallback? onLoad;

  /// 오류 발생 시 호출되는 콜백
  final IFrameErrorCallback? onError;

  /// 메시지 수신 시 호출되는 콜백
  final IFrameMessageCallback? onMessage;

  /// 로딩 인디케이터 표시 여부
  final bool showLoadingIndicator;

  /// 오류 메시지 표시 여부
  final bool showErrorMessage;

  /// iframe 테두리 설정
  final BoxDecoration? decoration;

  /// iframe 샌드박스 속성
  final String sandbox;

  /// 전체화면 허용 여부
  final bool allowFullscreen;

  /// iframe 로딩 방식 (lazy, eager)
  final String loading;

  /// 리퍼러 정책
  final String referrerPolicy;

  /// 콜백 함수
  final Function(Map<String, dynamic>)? onCallback;

  const IFrameWidget({
    super.key,
    required this.url,
    this.width = double.infinity,
    this.height = 500,
    this.onLoad,
    this.onError,
    this.onMessage,
    this.showLoadingIndicator = true,
    this.showErrorMessage = true,
    this.decoration,
    this.sandbox =
        'allow-same-origin allow-scripts allow-forms allow-popups allow-modals',
    this.allowFullscreen = false,
    this.loading = 'lazy',
    this.referrerPolicy = 'no-referrer',
    this.onCallback,
  });

  @override
  State<IFrameWidget> createState() => _IFrameWidgetState();
}

class _IFrameWidgetState extends State<IFrameWidget> {
  late final String viewType;
  bool _isLoading = true;
  String? _errorMessage;
  web.HTMLIFrameElement? _iframe;
  StreamSubscription<web.Event>? _loadSubscription;
  StreamSubscription<web.Event>? _errorSubscription;
  StreamSubscription<web.MessageEvent>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    viewType = 'iframe-widget-${IFrameUtils.generateUuid()}';
    _initializeIFrame();
    _setupMessageListener();
    IFrameUtils.applyScrollbarStyles();
  }

  void _initializeIFrame() {
    try {
      _createIFrameElement();
      _registerPlatformView();
    } catch (e) {
      _handleError('Error initializing iframe: $e');
    }
  }

  void _createIFrameElement() {
    // iframe 컨테이너 생성
    final container = web.document.createElement('div') as web.HTMLDivElement
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'relative'
      ..style.overflow = 'hidden';

    // iframe 요소 생성
    _iframe = web.document.createElement('iframe') as web.HTMLIFrameElement
      ..id = viewType
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.display = 'block';

    // iframe 속성 설정
    IFrameUtils.setIFrameAttributes(
      _iframe!,
      sandbox: widget.sandbox,
      loading: widget.loading,
      importance: 'high',
      referrerPolicy: widget.referrerPolicy,
      allowFullscreen: widget.allowFullscreen,
    );

    // URL 설정
    IFrameUtils.setSafeSrc(_iframe!, widget.url);

    // 이벤트 리스너 설정
    _setupIFrameEventListeners();

    // 컨테이너에 iframe 추가
    container.appendChild(_iframe!);

    setupGlobalCallbacks();

    // Platform View Factory에 등록할 요소 저장
    _containerElement = container;
  }

  web.HTMLDivElement? _containerElement;

  void _registerPlatformView() {
    if (_containerElement != null) {
      platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) => _containerElement!,
      );
    }
  }

  void _setupIFrameEventListeners() {
    if (_iframe == null) return;

    // 로드 완료 이벤트
    _loadSubscription = _iframe!.onLoad.listen((_) {
      if (mounted) {
        setState(() => _isLoading = false);
        final contentWindow = _iframe!.contentWindow! as JSObject;

        // iframe 로드 후 콜백 함수 재등록
        setupGlobalCallbacks();

        widget.onLoad?.call(contentWindow);
      }
    });

    // 오류 이벤트
    _errorSubscription = _iframe!.onError.listen((_) {
      _handleError('Failed to load iframe content');
    });
  }

  void _setupMessageListener() {
    // postMessage 이벤트 리스너
    _messageSubscription =
        web.window.onMessage.listen((web.MessageEvent event) {
      if (!mounted || widget.onMessage == null) return;

      try {
        final data = event.data;
        if (data is JSObject) {
          final map = data.dartify() as Map<dynamic, dynamic>;
          final convertedMap =
              map.map((key, value) => MapEntry(key.toString(), value));
          widget.onMessage!(convertedMap);
        }
      } catch (e) {
        logger.e('Error processing message', e);
      }
    });
  }

  void _handleError(String error) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      widget.onError?.call(error);
    }
  }

  /// iframe에서 dart로 통신할 전역 함수 등록
  void setupGlobalCallbacks() {
    try {
      // 전역 함수들을 window에 등록
      final callbackFunction = ((JSAny? data) {
        logger.d('전역 onCallback 호출됨');

        if (data != null) {
          try {
            // JavaScript에서 JSON 문자열로 직렬화된 데이터를 받음
            final dartData = data.dartify();

            if (dartData is String) {
              logger.d(
                  'dartData: ${dartData.substring(0, min(dartData.length, 100))}"...');
              // JSON 문자열을 Map으로 파싱
              final eventData = jsonDecode(dartData) as Map<String, dynamic>;
              logger.d(
                  '파싱된 데이터: ${eventData.toString().substring(0, min(eventData.toString().length, 100))}"...');
              widget.onCallback?.call(eventData);
            } else {
              logger.d('예상하지 못한 데이터 타입: ${dartData.runtimeType}');
            }
          } catch (e) {
            logger.e('데이터 처리 중 오류 발생', e);
          }
        } else {
          logger.d('데이터 없이 콜백 호출됨');
        }
      }).toJS;

      onCallback = callbackFunction;
    } catch (e) {
      logger.e('Error setting up global callbacks', e);
    }
  }

  /// Export 이벤트 처리
  // void _handleExportEvent(Map<String, dynamic> eventData) {
  //   final result = eventData['result'];
  //   final page = eventData['page'];
  //   final type = eventData['type'];
  //   final text = eventData['text'];

  //   logger.d('Export 이벤트 처리:');
  //   logger.d('- Result: $result');
  //   logger.d('- Page: $page');
  //   logger.d('- Type: $type');
  //   logger.d('- Text length: ${text?.toString().length ?? 0}');

  //   // 여기에 Export 이벤트에 대한 실제 처리 로직을 구현하세요
  //   // 예: 상태 업데이트, 다른 위젯에 알림, 데이터 저장 등

  //   // 예시: 위젯의 onMessage 콜백 호출
  //   if (widget.onMessage != null) {
  //     final messageData = {
  //       'type': 'export',
  //       'result': result,
  //       'page': page,
  //       'exportType': type,
  //       'content': text,
  //     };
  //     widget.onMessage!(messageData);
  //   }
  // }

  /// iframe 컨텐츠 윈도우에 메시지 전송
  void postMessage(Map<String, dynamic> message, {String? targetOrigin}) {
    // if (_iframe?.contentWindow != null) {
    //   try {
    //     final jsMessage = message.jsify() as JSObject;
    //     final origin = targetOrigin ?? '*';
    //     _iframe!.contentWindow!.postMessage(jsMessage, origin);
    //   } catch (e) {
    //     logger.e('Error posting message', e);
    //   }
    // }
  }

  /// iframe 뒤로 가기
  void goBack() {
    if (_iframe?.contentWindow != null) {
      try {
        _iframe!.contentWindow!.history.back();
      } catch (e) {
        logger.e('Error navigating back', e);
      }
    }
  }

  /// iframe 앞으로 가기
  void goForward() {
    if (_iframe?.contentWindow != null) {
      try {
        _iframe!.contentWindow!.history.forward();
      } catch (e) {
        logger.e('Error navigating forward', e);
      }
    }
  }

  /// iframe 새로고침
  void reload() {
    if (_iframe != null) {
      try {
        IFrameUtils.setSafeSrc(_iframe!, widget.url);
        setState(() => _isLoading = true);
      } catch (e) {
        logger.e('Error reloading iframe', e);
      }
    }
  }

  /// iframe URL 변경
  void navigate(String url) {
    if (_iframe != null) {
      try {
        IFrameUtils.setSafeSrc(_iframe!, url);
        setState(() => _isLoading = true);
      } catch (e) {
        logger.e('Error navigating to URL', e);
      }
    }
  }

  @override
  void dispose() {
    // 이벤트 리스너 정리
    _loadSubscription?.cancel();
    _errorSubscription?.cancel();
    _messageSubscription?.cancel();

    // iframe 정리
    if (_iframe != null) {
      try {
        _iframe!.src = 'about:blank';
        _iframe!.remove();
        _iframe = null;
      } catch (e) {
        logger.e('Error disposing iframe', e);
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width == double.infinity ? null : widget.width,
      height: widget.height,
      decoration: widget.decoration,
      child: Stack(
        children: [
          // iframe 컨텐츠
          HtmlElementView(viewType: viewType),

          // 로딩 인디케이터
          if (_isLoading && widget.showLoadingIndicator)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // 오류 메시지
          if (_errorMessage != null && widget.showErrorMessage)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// iframe과 상호작용하기 위한 컨트롤러
class IFrameController {
  _IFrameWidgetState? _state;

  void _attach(_IFrameWidgetState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  /// iframe에 메시지 전송
  void postMessage(Map<String, dynamic> message, {String? targetOrigin}) {
    _state?.postMessage(message, targetOrigin: targetOrigin);
  }

  /// iframe 뒤로 가기
  void goBack() {
    _state?.goBack();
  }

  /// iframe 앞으로 가기
  void goForward() {
    _state?.goForward();
  }

  /// iframe 새로고침
  void reload() {
    _state?.reload();
  }

  /// iframe URL 변경
  void navigate(String url) {
    _state?.navigate(url);
  }
}

/// 컨트롤러를 사용하는 IFrame Widget
class ControlledIFrameWidget extends StatefulWidget {
  /// iframe이 로드할 URL
  final String url;

  /// iframe의 너비
  final double width;

  /// iframe의 높이
  final double height;

  /// iframe 컨트롤러
  final IFrameController? controller;

  /// 로딩 완료 시 호출되는 콜백
  final IFrameLoadCallback? onLoad;

  /// 오류 발생 시 호출되는 콜백
  final IFrameErrorCallback? onError;

  /// 메시지 수신 시 호출되는 콜백
  final IFrameMessageCallback? onMessage;

  /// 로딩 인디케이터 표시 여부
  final bool showLoadingIndicator;

  /// 오류 메시지 표시 여부
  final bool showErrorMessage;

  /// iframe 테두리 설정
  final BoxDecoration? decoration;

  /// iframe 샌드박스 속성
  final String sandbox;

  /// 전체화면 허용 여부
  final bool allowFullscreen;

  const ControlledIFrameWidget({
    super.key,
    required this.url,
    this.width = double.infinity,
    this.height = 500,
    this.controller,
    this.onLoad,
    this.onError,
    this.onMessage,
    this.showLoadingIndicator = true,
    this.showErrorMessage = true,
    this.decoration,
    this.sandbox =
        'allow-same-origin allow-scripts allow-forms allow-popups allow-modals',
    this.allowFullscreen = false,
  });

  @override
  State<ControlledIFrameWidget> createState() => _ControlledIFrameWidgetState();
}

class _ControlledIFrameWidgetState extends State<ControlledIFrameWidget> {
  late final _IFrameWidgetState _iframeState;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(_iframeState);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IFrameWidget(
      url: widget.url,
      width: widget.width,
      height: widget.height,
      onLoad: widget.onLoad,
      onError: widget.onError,
      onMessage: widget.onMessage,
      showLoadingIndicator: widget.showLoadingIndicator,
      showErrorMessage: widget.showErrorMessage,
      decoration: widget.decoration,
      sandbox: widget.sandbox,
      allowFullscreen: widget.allowFullscreen,
    );
  }
}
