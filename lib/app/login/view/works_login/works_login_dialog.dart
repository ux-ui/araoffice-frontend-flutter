import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class NaverWorksIframeDialog extends StatefulWidget {
  final String loginUrl;
  final String callbackUrlPattern;
  final Function(bool success, Map<String, dynamic>? data) onAuthComplete;

  const NaverWorksIframeDialog({
    Key? key,
    required this.loginUrl,
    required this.callbackUrlPattern,
    required this.onAuthComplete,
  }) : super(key: key);

  @override
  State<NaverWorksIframeDialog> createState() => _NaverWorksIframeDialogState();
}

class _NaverWorksIframeDialogState extends State<NaverWorksIframeDialog> {
  final String _iframeId =
      'naver-works-login-iframe-${DateTime.now().millisecondsSinceEpoch}';
  StreamSubscription? _messageSubscription;
  Timer? _urlCheckTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupIframe();
    _setupMessageListener();
    _startUrlMonitoring();
  }

  void _setupIframe() {
    // iframe 엘리먼트 생성
    final iframe = html.IFrameElement()
      ..src = widget.loginUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    // iframe을 Flutter에 등록
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) => iframe,
    );
  }

  void _setupMessageListener() {
    // postMessage 리스너 설정
    _messageSubscription = html.window.onMessage.listen((event) {
      final data = event.data;
      debugPrint('####@@@ iframe에서 받은 메시지: $data');

      if (data is Map) {
        if (data['type'] == 'naverWorksAuthComplete') {
          final success = data['success'] == true;
          widget.onAuthComplete(success, data as Map<String, dynamic>?);
        }
      }
    });
  }

  void _startUrlMonitoring() {
    // iframe의 URL을 주기적으로 확인 (same-origin인 경우에만 가능)
    _urlCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      try {
        final iframe =
            html.document.getElementById(_iframeId) as html.IFrameElement?;
        if (iframe != null && iframe.contentWindow != null) {
          // Same-origin 정책으로 인해 contentWindow.location에 접근이 제한될 수 있음
          // 이 경우 백엔드에서 postMessage를 사용해야 함

          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        // Same-origin 정책 위반 시 에러 발생 (정상)
        debugPrint('URL 모니터링 에러 (정상): $e');
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _urlCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'packages/common_assets/assets/image/naver_works_logo.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '네이버 웍스 로그인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      widget.onAuthComplete(false, {'cancelled': true});
                      Navigator.of(context).pop();
                    },
                    tooltip: '닫기',
                  ),
                ],
              ),
            ),

            // 로딩 인디케이터
            if (_isLoading) const LinearProgressIndicator(),

            // iframe
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: HtmlElementView(
                  viewType: _iframeId,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
