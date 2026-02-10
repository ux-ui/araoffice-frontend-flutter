import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// 네이버 웍스 로그인을 위한 스택 구조 Dialog
/// - 뒤: 투명한 iframe (실제 인증 진행)
/// - 앞: 로딩 인디케이터 (사용자에게 보여짐)
class NaverWorksStackedLoginDialog extends StatefulWidget {
  final String loginUrl;
  final String callbackUrlPattern;
  final Function(bool success, Map<String, dynamic>? data) onAuthComplete;

  const NaverWorksStackedLoginDialog({
    Key? key,
    required this.loginUrl,
    required this.callbackUrlPattern,
    required this.onAuthComplete,
  }) : super(key: key);

  @override
  State<NaverWorksStackedLoginDialog> createState() =>
      _NaverWorksStackedLoginDialogState();
}

class _NaverWorksStackedLoginDialogState
    extends State<NaverWorksStackedLoginDialog> {
  final String _iframeId =
      'naver-works-login-iframe-${DateTime.now().millisecondsSinceEpoch}';
  StreamSubscription? _messageSubscription;
  Timer? _urlCheckTimer;
  String _statusMessage = '네이버 웍스 인증 중...';
  bool _showDetail = false;

  @override
  void initState() {
    super.initState();
    _setupIframe();
    _setupMessageListener();
    _startStatusUpdate();
  }

  void _setupIframe() {
    // iframe 엘리먼트 생성 (화면에 보이지 않음)
    final iframe = html.IFrameElement()
      ..src = widget.loginUrl
      ..style.border = 'none'
      ..style.width = '1px'
      ..style.height = '1px'
      ..style.position = 'absolute'
      ..style.left = '-9999px'
      ..style.top = '-9999px';

    // iframe을 Flutter에 등록
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) => iframe,
    );

    // iframe을 DOM에 추가 (보이지 않는 위치)
    html.document.body?.append(iframe);
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
        } else if (data['type'] == 'naverWorksAuthProgress') {
          // 인증 진행 상태 업데이트
          setState(() {
            _statusMessage = data['message'] ?? '인증 진행 중...';
          });
        }
      }
    });
  }

  void _startStatusUpdate() {
    // 상태 메시지를 주기적으로 업데이트하여 진행 중임을 표시
    int count = 0;
    _urlCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        count++;
        setState(() {
          switch (count % 4) {
            case 0:
              _statusMessage = '네이버 웍스 인증 중';
              break;
            case 1:
              _statusMessage = '네이버 웍스 인증 중.';
              break;
            case 2:
              _statusMessage = '네이버 웍스 인증 중..';
              break;
            case 3:
              _statusMessage = '네이버 웍스 인증 중...';
              break;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _urlCheckTimer?.cancel();

    // iframe 제거
    try {
      final iframes = html.document.getElementsByTagName('iframe');
      for (var i = 0; i < iframes.length; i++) {
        final iframe = iframes[i] as html.IFrameElement;
        if (iframe.src == widget.loginUrl) {
          iframe.remove();
          break;
        }
      }
    } catch (e) {
      debugPrint('iframe 제거 중 에러: $e');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 로고
            Image.asset(
              'packages/common_assets/assets/image/naver_works_logo.png',
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.work, size: 80, color: Colors.blue);
              },
            ),
            const SizedBox(height: 24),

            // 타이틀
            const Text(
              '네이버 웍스 로그인',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 상태 메시지
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 로딩 인디케이터
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '네이버 웍스 인증 창이 열렸습니다.\n잠시만 기다려주세요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 상세 정보 토글
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showDetail = !_showDetail;
                });
              },
              icon: Icon(
                _showDetail ? Icons.expand_less : Icons.expand_more,
                size: 20,
              ),
              label: Text(
                _showDetail ? '숨기기' : '상세 정보',
                style: const TextStyle(fontSize: 12),
              ),
            ),

            // 상세 정보 (토글)
            if (_showDetail) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('인증 URL', widget.loginUrl),
                    const Divider(height: 16),
                    _buildInfoRow('상태', '인증 진행 중'),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 취소 버튼
            TextButton(
              onPressed: () {
                widget.onAuthComplete(false, {'cancelled': true});
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('취소'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
