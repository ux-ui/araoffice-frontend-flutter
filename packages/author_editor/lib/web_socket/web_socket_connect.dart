import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:author_editor/data/user_info.dart';
import 'package:author_editor/mixins/web_socket_control_mixin.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketConnect {
  static const Duration reconnectDelay = Duration(seconds: 5);
  bool _intentionalDisconnect = false;
  bool get isIntentionalDisconnect => _intentionalDisconnect;

  StompClient? stompClient;
  bool get isConnected => stompClient?.connected == true;
  String? currentUserId;
  Set<String> connectedUsers = {};
  List<UserListInfo> connectedUserList = [];

  // 콜백 함수들을 위한 컨트롤러
  StreamController<MouseDataResponse>? _mouseDataController;
  StreamController<bool>? _connectionStateController;
  StreamController<List<UserListInfo>>? _userListInfoController;
  StreamController<RefreshResponse>? _refreshResponseController;
  StreamController<TreeListResponse>? _treeListController;
  StreamController<EditorResponse>? _editorController;
  StreamController<bool>? _pauseStateController;

  // 스트림 게터
  Stream<MouseDataResponse> get mouseDataStream =>
      _mouseDataController?.stream ?? const Stream.empty();
  Stream<bool> get connectionState =>
      _connectionStateController?.stream ?? const Stream.empty();
  Stream<List<UserListInfo>> get userListInfoStream =>
      _userListInfoController?.stream ?? const Stream.empty();
  Stream<RefreshResponse> get refreshResponseStream =>
      _refreshResponseController?.stream ?? const Stream.empty();
  Stream<TreeListResponse> get treeListStream =>
      _treeListController?.stream ?? const Stream.empty();
  Stream<EditorResponse> get editorStream =>
      _editorController?.stream ?? const Stream.empty();
  Stream<bool> get pauseStateStream =>
      _pauseStateController?.stream ?? const Stream.empty();
  // 구독 관리
  final Map<String, StompUnsubscribe> subscriptions = {};
  bool _isSettingUpSubscriptions = false; // 구독 설정 중복 방지 플래그
  bool? _lastConnectionState;
  bool _isDisconnectHandled = false;

  String _shortToken(String? value, {int max = 8}) {
    if (value == null || value.isEmpty) {
      return 'unknown';
    }
    if (value.length <= max) {
      return value;
    }
    return value.substring(0, max);
  }

  String _sessionTag([Map<String, String>? headers]) {
    final sessionId = headers?['session'] ?? headers?['user-name'];
    return _shortToken(sessionId ?? currentUserId);
  }

  void initialize({
    required String url,
    required String userId,
    required String displayName,
    required String projectId,
    required String pageId,
    required bool isPermission,
    required String pageIdUrl,
  }) {
    _isDisconnectHandled = false;

    // 이미 같은 파라미터로 초기화되어 있고 연결되어 있으면 중복 초기화 방지
    if (stompClient != null && stompClient!.connected == true) {
      debugPrint('#### WebSocket이 이미 연결되어 있어 초기화 생략');
      return;
    }

    // 기존 연결이 있다면 먼저 정리
    if (stompClient != null) {
      try {
        _intentionalDisconnect = true;
        stompClient!.deactivate();
      } catch (e) {
        logger.d('기존 연결 해제 중 오류 (무시됨): $e');
      }
      stompClient = null;
    }

    // 구독 정보 초기화
    subscriptions.clear();
    _isSettingUpSubscriptions = false;

    // 스트림 컨트롤러들이 닫혀있다면 새로 생성
    _recreateStreamControllersIfNeeded();

    currentUserId = userId;

    stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: (StompFrame frame) => _onConnect(
            frame, projectId, displayName, pageId, isPermission, pageIdUrl),
        onDisconnect: _onDisconnect,
        onWebSocketDone: _onWebSocketDone,
        reconnectDelay: _buildReconnectDelayWithJitter(),
        onWebSocketError: _onWebSocketError,
        stompConnectHeaders: {'userId': userId},
        webSocketConnectHeaders: {'userId': userId},
        beforeConnect: () async {
          debugPrint('###웹소켓 연결 시도 [ws:${_sessionTag()}]');
        },
        onStompError: (error) {
          logger.e('###STOMP 에러: $error');
        },
      ),
    );
  }

  void _recreateStreamControllersIfNeeded() {
    try {
      // 각 스트림 컨트롤러가 null이거나 닫혀있는지 확인하고 필요시 재생성
      if (_mouseDataController == null || _mouseDataController!.isClosed) {
        _mouseDataController = StreamController<MouseDataResponse>.broadcast();
      }
      if (_connectionStateController == null ||
          _connectionStateController!.isClosed) {
        _connectionStateController = StreamController<bool>.broadcast();
      }
      if (_userListInfoController == null ||
          _userListInfoController!.isClosed) {
        _userListInfoController =
            StreamController<List<UserListInfo>>.broadcast();
      }
      if (_refreshResponseController == null ||
          _refreshResponseController!.isClosed) {
        _refreshResponseController =
            StreamController<RefreshResponse>.broadcast();
      }
      if (_treeListController == null || _treeListController!.isClosed) {
        _treeListController = StreamController<TreeListResponse>.broadcast();
      }
      if (_editorController == null || _editorController!.isClosed) {
        _editorController = StreamController<EditorResponse>.broadcast();
      }
      if (_pauseStateController == null || _pauseStateController!.isClosed) {
        _pauseStateController = StreamController<bool>.broadcast();
      }
    } catch (e) {
      logger.e('스트림 컨트롤러 재생성 중 오류: $e');
    }
  }

  void _emitConnectionState(bool isConnected) {
    final controller = _connectionStateController;
    if (controller == null || controller.isClosed) return;
    if (_lastConnectionState == isConnected) return;
    _lastConnectionState = isConnected;
    controller.add(isConnected);
  }

  /// 소켓 단절 시 세션 상태를 초기화한다.
  /// STOMP 세션이 끊기면 기존 unsubscribe 핸들은 무효가 되므로
  /// 로컬 구독 캐시를 반드시 비워야 재연결 후 재구독이 정상 동작한다.
  void _resetSessionStateOnDisconnect() {
    debugPrint('#### 소켓 단절 시 세션 상태를 초기화');
    subscriptions.clear();
    _isSettingUpSubscriptions = false;
    // connectedUsers.clear();
    // connectedUserList = [];
  }

  void connect() {
    try {
      _intentionalDisconnect = false; // 연결 시도시 플래그 초기화
      if (stompClient?.isActive == true) {
        debugPrint('#### WebSocket activate 상태여서 연결 시도 생략');
        return;
      }
      // 이미 연결되어 있으면 중복 연결 방지
      if (stompClient?.connected == true) {
        debugPrint('#### WebSocket 이미 연결되어 있어 연결 시도 생략');
        return;
      }
      stompClient?.activate();
      // 실제 연결 성공은 _onConnect에서 처리하므로 여기서는 상태를 변경하지 않음
    } catch (e) {
      logger.e('###연결 에러', e);
      _emitConnectionState(false);
    }
  }

  void disconnect() {
    try {
      _intentionalDisconnect = true; // 의도적인 연결 해제를 표시
      _resetSessionStateOnDisconnect();

      // 연결 상태를 먼저 업데이트
      _emitConnectionState(false);
      _userListInfoController?.add(connectedUserList);

      // STOMP 클라이언트 비활성화
      stompClient?.deactivate();
    } catch (e) {
      logger.e('###연결 해제 에러', e);
    }
  }

  void _onConnect(StompFrame frame, String projectId, String displayName,
      String pageId, bool isPermission, String pageIdUrl) {
    debugPrint(
        '#### [ws:${_sessionTag(frame.headers)}] WebSocket 연결 성공: ${frame.headers}');

    try {
      _isDisconnectHandled = false;
      // 재연결 세션에서는 서버측 구독이 유효하지 않으므로 로컬 구독 캐시를 초기화한다.
      if (subscriptions.isNotEmpty) {
        debugPrint(
            '#### [ws:${_sessionTag(frame.headers)}] 재연결 감지: 기존 구독 캐시 초기화 후 재구독');
        debugPrint(
            '#### 삭제 전 subscriptions 목록: ${subscriptions.keys.toList()}');
        subscriptions.clear();
        // 삭제 된 후 subscriptions 목록 로그
        debugPrint(
            '#### 삭제 된 후 subscriptions 목록: ${subscriptions.keys.toList()}');
      }
      _isSettingUpSubscriptions = false;

      // 연결 상태를 실제 연결 성공 시에만 true로 설정
      _emitConnectionState(true);
      _setupSubscriptions(
          projectId, displayName, pageId, isPermission, pageIdUrl);
    } catch (e, stackTrace) {
      logger.e('###WebSocket 초기화 중 오류: $e');
      logger.e('###스택 트레이스: $stackTrace');
      _emitConnectionState(false);
      _isSettingUpSubscriptions = false;
      // 재연결 시도
      Future.delayed(const Duration(seconds: 3), () {
        if (stompClient?.connected != true) {
          connect();
        }
      });
    }
  }

  void _setupSubscriptions(String projectId, String displayName, String pageId,
      bool isPermission, String pageIdUrl) {
    // 중복 구독 방지
    if (_isSettingUpSubscriptions) {
      debugPrint('#### 구독 설정이 이미 진행 중이어서 중복 실행 방지');
      return;
    }
    _isSettingUpSubscriptions = true;

    try {
      debugPrint('#### 각 채널 구독 설정');
      connectUserListInfo(projectId);
      connectCursor(projectId, pageId);
      connectRefresh(projectId, pageId);
      connectTreeList(projectId);
    } catch (e) {
      debugPrint('###초기 구독 오류: $e');
    }
    if (isPermission) {
      try {
        debugPrint('#### 권한 있음, 에디터 연결 시도');
        connectEditor(projectId, pageIdUrl);
        connectPauseState(projectId);
      } catch (e) {
        debugPrint('###에디터 연결 오류: $e');
      }
    }

    // 구독 설정 완료 후 플래그 리셋 (약간의 지연 후)
    Future.delayed(const Duration(milliseconds: 100), () {
      // EasyLoading.showInfo('WebSocket 연결');
      _isSettingUpSubscriptions = false;
    });

    try {
      // 초기 유저 등록
      stompClient?.send(
        destination: '/pub/users/$projectId',
        body: jsonEncode({
          'userId': currentUserId ?? 'anonymous',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      // 초기 커서 위치 전송
      _sendCursorPosition(
          projectId, displayName, pageId, '0.0', 'none', 'false');
    } catch (e) {
      logger.e('###초기화 메시지 전송 오류: $e');
    }
  }

  void connectUserListInfo(String projectId) {
    try {
      // 이미 사용자 목록 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/users')) {
        debugPrint('#### 사용자 목록 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      final subscription = stompClient?.subscribe(
        destination: '/sub/users/$projectId',
        callback: (StompFrame frame) {
          debugPrint('#### 사용자 목록 메시지 수신');
          if (frame.body != null) {
            try {
              final message = _parseMessage(frame.body!);
              if (message.containsKey('users')) {
                final usersList = message['users'];
                if (usersList is List) {
                  // connectedUsers =
                  //     Set<String>.from(usersList.map((e) => e.toString()));

                  connectedUserList =
                      usersList.map((e) => UserListInfo.fromJson(e)).toList();

                  // _userListController.add(connectedUsers);
                  _userListInfoController?.add(connectedUserList);
                }
              }
            } catch (e) {
              logger.e('###사용자 목록 메시지 처리 오류: $e');
            }
          }
        },
      );
      if (subscription != null) {
        // subscriptions['/sub/users/$projectId'] = subscription;
        subscriptions['/sub/users'] = subscription;
      }
    } catch (e) {
      logger.e('###사용자 목록 구독 오류: $e');
    }
  }

  void connectCursor(String projectId, String pageId) {
    try {
      // 이미 커서 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/cursor')) {
        debugPrint('#### 커서 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      final subscription = stompClient?.subscribe(
        destination: '/sub/cursor/$projectId/$pageId',
        callback: (StompFrame frame) {
          // debugPrint('#### 커서 메시지 수신');
          if (frame.body != null) {
            final data = _parseEditorMessage(frame.body!);
            _mouseDataController?.add(data);
            // try {
            //   final message = _parseMessage(frame.body!);
            //   if (message.isNotEmpty) {
            //     _messageController.add(message);
            //   }
            // } catch (e) {
            //   logger.e('커서 메시지 처리 오류: $e');
            // }
          }
        },
      );
      if (subscription != null) {
        // subscriptions['/sub/cursor/$projectId/$pageId'] = subscription;
        subscriptions['/sub/cursor'] = subscription;
      }
    } catch (e) {
      logger.e('###커서 구독 오류: $e');
    }
  }

  void connectRefresh(String projectId, String pageId) {
    try {
      // 이미 새로고침 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/refresh')) {
        debugPrint('#### 새로고침 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      final subscription = stompClient?.subscribe(
        destination: '/sub/refresh/$projectId/$pageId',
        callback: (StompFrame frame) {
          debugPrint('#### 새로고침 메시지 수신');
          if (frame.body != null) {
            try {
              final message = _parseMessage(frame.body!);
              if (message.isNotEmpty) {
                // _refreshController.add(message);
                final refreshResponse = RefreshResponse.fromJson(message);
                _refreshResponseController?.add(refreshResponse);
              }
            } catch (e) {
              logger.e('###새로고침 메시지 처리 오류: $e');
            }
          }
        },
      );
      if (subscription != null) {
        // subscriptions['/sub/refresh/$projectId/$pageId'] = subscription;
        subscriptions['/sub/refresh'] = subscription;
      }
    } catch (e) {
      logger.e('###새로고침 구독 오류: $e');
    }
  }

  void connectTreeList(String projectId) {
    try {
      // 이미 트리 리스트 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/refresh/treeList')) {
        debugPrint('#### 트리 리스트 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      final subscription = stompClient?.subscribe(
        destination: '/sub/refresh/$projectId',
        callback: (StompFrame frame) {
          debugPrint('#### 트리 리스트 메시지 수신');
          if (frame.body != null) {
            try {
              final message = _parseMessage(frame.body!);
              if (message.isNotEmpty) {
                // _treeListController.add(message);
                final treeListResponse = TreeListResponse.fromJson(message);
                _treeListController?.add(treeListResponse);
              }
            } catch (e) {
              logger.e('###트리 리스트 메시지 처리 오류: $e');
            }
          }
        },
      );
      if (subscription != null) {
        // subscriptions['/sub/refresh/$projectId'] = subscription;
        subscriptions['/sub/refresh/treeList'] = subscription;
      }
    } catch (e) {
      logger.e('###트리 리스트 구독 오류: $e');
    }
  }

  void connectPauseState(String projectId) {
    try {
      // 이미 일시정지 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/pause')) {
        debugPrint('#### 일시정지 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      final subscription = stompClient?.subscribe(
        destination: '/sub/pause/$projectId',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            try {
              final message = _parseMessage(frame.body!);
              final pauseStateResponse = PauseStateResponse.fromJson(message);
              _pauseStateController?.add(pauseStateResponse.isPause ?? false);
            } catch (e) {
              logger.e('###일시정지 메시지 처리 오류: $e');
            }
          }
        },
      );
      if (subscription != null) {
        subscriptions['/sub/pause'] = subscription;
      }
    } catch (e) {
      logger.e('###일시정지 구독 오류: $e');
    }
  }

  void connectEditor(String projectId, String pageId) {
    try {
      if (stompClient == null || !stompClient!.connected) {
        debugPrint('#### WebSocket이 연결되어 있지 않습니다.');
        return;
      }
      // 이미 에디터 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/editor')) {
        debugPrint('#### 에디터 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      // 에디터 구독
      final subscription = stompClient!.subscribe(
        destination: '/sub/editor/$projectId/$pageId',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            try {
              final message = _parseMessage(frame.body!);
              final editorResponse = EditorResponse.fromJson(message);
              _editorController?.add(editorResponse);
              // _editorController.add(message);
            } catch (e) {
              debugPrint('### 에디터 메시지 파싱 오류: $e');
            }
          }
        },
      );

      // 구독 정보 저장
      // subscriptions['/sub/editor/$projectId/$pageId'] = subscription;
      subscriptions['/sub/editor'] = subscription;

      // 초기 진입/재연결 직후 현재 편집자 상태를 즉시 동기화한다.
      sendPageEditorResponse(projectId, pageId);
    } catch (e) {
      debugPrint('### 에디터 연결 오류: $e');
    }
  }

  void _onDisconnect(StompFrame frame) {
    _handleSocketClosed(
      showErrorToast: false,
      source: 'disconnect',
      sessionTag: _sessionTag(frame.headers),
    );
  }

  void _onWebSocketDone() {
    _handleSocketClosed(
      showErrorToast: true,
      source: 'onWebSocketDone',
      sessionTag: _sessionTag(),
    );
  }

  void _handleSocketClosed({
    required bool showErrorToast,
    required String source,
    required String sessionTag,
  }) {
    if (_isDisconnectHandled) {
      return;
    }
    _isDisconnectHandled = true;

    if (source == 'onWebSocketDone') {
      debugPrint('#### WebSocket 연결이 종료되었습니다 (onWebSocketDone)');
    } else {
      debugPrint('연결이 해제되었습니다. [ws:$sessionTag]');
    }

    _resetSessionStateOnDisconnect();
    try {
      _userListInfoController?.add(connectedUserList);
      _emitConnectionState(false);
      if (showErrorToast && !_intentionalDisconnect) {
        // EasyLoading.showError('WebSocket 연결이 종료되었습니다');
      }
    } catch (e) {
      logger.e('웹소켓 종료 콜백에서 스트림 업데이트 오류: $e');
    }
  }

  void _onWebSocketError(dynamic error) {
    debugPrint('웹소켓 에러: $error');
    _handleSocketClosed(
      showErrorToast: false,
      source: 'error',
      sessionTag: _sessionTag(),
    );
  }

  Duration _buildReconnectDelayWithJitter() {
    // 1.0s ~ 3.0s (밀리초 단위 랜덤)
    final ms = 1000 + Random().nextInt(2001);
    return Duration(milliseconds: ms);
  }

  MouseDataResponse _parseEditorMessage(String message) {
    final messageMap = jsonDecode(message);
    return MouseDataResponse.fromJson(messageMap);
  }

  Map<String, dynamic> _parseMessage(String message) {
    try {
      if (message.isEmpty) {
        return {};
      }

      // 1. 먼저 직접 JSON 디코딩 시도
      try {
        final decoded = jsonDecode(message);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        // JSON 디코딩 실패 시 무시하고 다음 단계로
      }

      // 2. 문자열이 유효한 UTF-8인지 확인
      if (utf8.encode(message) is List<int>) {
        try {
          final decoded = jsonDecode(message);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        } catch (_) {
          // JSON 디코딩 실패 시 무시
        }
      }

      // 3. 마지막으로 기본 디코딩 시도
      try {
        final decodedString = String.fromCharCodes(message.runes);
        final decoded = jsonDecode(decodedString);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (e) {
        logger.e('최종 디코딩 실패: $e');
      }

      logger.e('메시지가 올바른 JSON 형식이 아닙니다: $message');
      return {};
    } catch (e, stackTrace) {
      logger.e('메시지 파싱 에러: $e');
      logger.e('스택 트레이스: $stackTrace');
      return {};
    }
  }

  /// 특정 채널의 구독을 해제합니다.
  void _unsubscribeFromChannel(String channel) {
    final subscription = subscriptions[channel];
    if (subscription != null) {
      subscription();
      subscriptions.remove(channel);
    }
  }

  // 각 채널별 구독 해제 메서드
  void unsubscribeFromCursor() => _unsubscribeFromChannel('/sub/cursor');
  void unsubscribeFromUserList() => _unsubscribeFromChannel('/sub/users');
  void unsubscribeFromRefresh() => _unsubscribeFromChannel('/sub/refresh');
  void unsubscribeFromTreeList() =>
      _unsubscribeFromChannel('/sub/refresh/treeList');
  void unsubscribeFromEditor() => _unsubscribeFromChannel('/sub/editor');

  // 모든 구독 해제
  void unsubscribeAll() {
    try {
      // 구독 해제
      unsubscribeFromCursor();
      unsubscribeFromUserList();
      unsubscribeFromRefresh();
      unsubscribeFromTreeList();
      unsubscribeFromEditor();

      for (final subscription in subscriptions.values) {
        subscription();
      }
      subscriptions.clear();

      // 스트림 컨트롤러들을 안전하게 닫기
      try {
        _mouseDataController?.close();
        _connectionStateController?.close();
        _userListInfoController?.close();
        _refreshResponseController?.close();
        _treeListController?.close();
        _editorController?.close();
        _pauseStateController?.close();
      } catch (e) {
        logger.e('스트림 컨트롤러 닫기 중 오류: $e');
      }

      // 스트림 컨트롤러들을 null로 설정
      _mouseDataController = null;
      _connectionStateController = null;
      _userListInfoController = null;
      _refreshResponseController = null;
      _treeListController = null;
      _editorController = null;
      _pauseStateController = null;
    } catch (e) {
      logger.e('구독 해제 중 오류 발생: $e');
    }
  }

  void sendPauseState(String projectId, bool isPause) {
    stompClient?.send(
      destination: '/pub/pause/$projectId',
      body: jsonEncode({'userId': currentUserId, 'isPause': isPause}),
    );
    _pauseStateController?.add(isPause);
  }

  void sendCursorPosition(
      String projectId,
      String displayName,
      String pageId,
      double line,
      double column,
      double editorWidth,
      double editorHeight,
      String cursorAction,
      String isMouseDown) {
    if (stompClient == null ||
        // !stompClient!.connected ||
        _lastConnectionState == false ||
        currentUserId == null) {
      // logger.d('커서 위치 전송 실패: WebSocket이 초기화되지 않았거나 연결되지 않았습니다.');
      logger.d(
          '커서 위치 전송 실패: stompClient: ${stompClient!.connected}: ${stompClient?.isActive}, _lastConnectionState: $_lastConnectionState currentUserId: $currentUserId');
      return;
    }

    // final cursorPosition = '${line.toInt()}.${column.toInt()}';
    if (subscriptions.containsKey('/sub/cursor')) {
      final cursorPosition =
          '${line.toStringAsFixed(7)}/${column.toStringAsFixed(7)}';
      _sendCursorPosition(projectId, displayName, pageId, cursorPosition,
          cursorAction, isMouseDown);
    } else {
      return;
    }
  }

  void _sendCursorPosition(
    String projectId,
    String displayName,
    String pageId,
    String cursorPosition,
    String cursorAction,
    String isMouseDown,
  ) {
    // stompClient가 null이거나 연결되지 않은 경우 메서드 종료
    if (stompClient == null || !stompClient!.connected) {
      logger.d(
          '커서 위치 전송 실패 _sendCursorPosition: WebSocket이 초기화되지 않았거나 연결되지 않았습니다.');
      return;
    }

    stompClient?.send(
      destination: '/pub/cursor/$projectId/$pageId',
      body: jsonEncode({
        'userId': currentUserId,
        'displayName': displayName,
        'pageId': pageId,
        'cursorPosition': cursorPosition,
        'cursorAction': cursorAction,
        'isMouseDown': isMouseDown,
      }),
    );
  }

  void sendRefresh(String projectId, String pageId, String pageUrl) {
    // stompClient가 null이거나 연결되지 않은 경우 메서드 종료
    if (stompClient == null ||
        !stompClient!.connected ||
        currentUserId == null) {
      logger.d('새로고침 메시지 전송 실패: WebSocket이 초기화되지 않았거나 연결되지 않았습니다.');
      return;
    }

    stompClient?.send(
      destination: '/pub/refresh/$projectId/$pageId',
      body: jsonEncode({
        'userId': currentUserId,
        'data': pageUrl,
      }),
    );
  }

  void sendTreeList(String projectId) {
    // stompClient가 초기화되지 않았거나 연결되지 않은 경우 메서드 종료
    if (stompClient == null ||
        !stompClient!.connected ||
        currentUserId == null) {
      logger.d('트리 목록 전송 실패: WebSocket이 초기화되지 않았거나 연결되지 않았습니다.');
      return;
    }

    stompClient!.send(
      destination: '/pub/refresh/$projectId',
      body: jsonEncode({
        'userId': currentUserId,
        // 'data': treeListModel,
        // 'data': treeListJson.toString(),
        'data': projectId
      }),
    );
  }

  void sendPageEditorResponse(String projectId, String pageId) {
    stompClient?.send(
      destination: '/pub/editor/$projectId/$pageId',
      body: jsonEncode({
        'userId': currentUserId,
        'pageId': pageId,
      }),
    );
  }

  // void sendPauseState(String projectId, bool isPause) {
  //   stompClient?.send(
  //     destination: '/pub/pause/$projectId',
  //     body: jsonEncode({'userId': currentUserId, 'isPause': isPause}),
  //   );
  //   _pauseStateController?.add(isPause);
  // }

  // 커서 채널 구독
  // void subscribeToCursorChannel(String projectId, String pageId) {
  //   final channel = '/sub/cursor/$projectId/$pageId';
  //   subscriptions[channel] = stompClient.subscribe(
  //     destination: channel,
  //     callback: (StompFrame frame) {
  //       if (frame.body != null) {
  //         final message = _parseMessage(frame.body!);
  //       }
  //     },
  //   );
  // }

  void dispose() {
    try {
      _intentionalDisconnect = true;
      disconnect();
      unsubscribeAll();
    } catch (e) {
      logger.e('dispose 중 오류 발생: $e');
    }
  }
}
