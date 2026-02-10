import 'dart:async';
import 'dart:convert';

import 'package:author_editor/data/user_info.dart';
import 'package:author_editor/mixins/web_socket_control_mixin.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketConnect {
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const int _maxReconnectAttempts = 3;
  int _reconnectAttemptCount = 0;

  void resetReconnectAttemptCount() {
    _reconnectAttemptCount = 0;
  }

  bool get canAttemptReconnect =>
      _reconnectAttemptCount < _maxReconnectAttempts;

  int get reconnectAttemptCount => _reconnectAttemptCount;

  void incrementReconnectAttempt() {
    _reconnectAttemptCount++;
  }

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

  /// DFERI 도메인용 Author WebSocket 클라이언트 (wss://www.edunavi.kr/booknavi/author/ws/v1)
  StompClient? stompClientAuthor;
  final Map<String, StompUnsubscribe> authorSubscriptions = {};
  String? _wsAuthorBaseUrl;
  bool get isAuthorConnected => stompClientAuthor?.connected == true;

  static const int _maxAuthorReconnectAttempts = 3;
  int _authorReconnectAttemptCount = 0;

  void resetAuthorReconnectAttemptCount() {
    _authorReconnectAttemptCount = 0;
  }

  bool get canAttemptAuthorReconnect =>
      _authorReconnectAttemptCount < _maxAuthorReconnectAttempts;

  void _scheduleAuthorReconnect() {
    _authorReconnectAttemptCount++;
    if (!canAttemptAuthorReconnect) {
      debugPrint(
          '[WS-Author] 재연결 최대 횟수($_maxAuthorReconnectAttempts) 초과, 연결 해제 후 재시도 중단');
      _disconnectAuthorClientSilent();
      return;
    }
    debugPrint(
        '[WS-Author] 재연결 시도 ($_authorReconnectAttemptCount/$_maxAuthorReconnectAttempts)');
    Future.delayed(const Duration(seconds: 3), () {
      if (_authorReconnectAttemptCount >= _maxAuthorReconnectAttempts) {
        debugPrint('[WS-Author] 재연결 콜백 스킵 (최대 횟수 초과)');
        return;
      }
      if (stompClientAuthor != null && !stompClientAuthor!.connected) {
        connectAuthorClient();
      }
    });
  }

  /// 재연결 포기 시 Author 클라이언트만 해제 (추가 연결 시도/에러 콜백 방지)
  void _disconnectAuthorClientSilent() {
    try {
      for (final sub in authorSubscriptions.values) {
        try {
          sub();
        } catch (_) {}
      }
      authorSubscriptions.clear();
      stompClientAuthor?.deactivate();
      stompClientAuthor = null;
      _wsAuthorBaseUrl = null;
    } catch (_) {}
  }

  /// WebSocket 연결 base URL (예: ws://localhost:8082/ws/v1)
  String? _wsBaseUrl;
  String? get wsBaseUrl => _wsBaseUrl;

  /// 구독 destination에 대한 풀 주소 (연결 URL + destination)
  /// 예: ws://localhost:8082/ws/v1 -> /sub/users/p123
  String getSubscriptionFullUrl(String destination) {
    if (_wsBaseUrl == null) return destination;
    return '$_wsBaseUrl -> $destination';
  }

  void initialize({
    required String url,
    required String userId,
    required String projectId,
    required String pageId,
    required bool isPermission,
    required String pageIdUrl,
  }) {
    // 이미 같은 파라미터로 초기화되어 있고 연결되어 있으면 중복 초기화 방지
    if (stompClient != null && stompClient!.connected == true) {
      debugPrint('#### WebSocket이 이미 연결되어 있어 초기화 생략');
      return;
    }

    // 기존 연결이 있다면 먼저 정리
    if (stompClient != null) {
      try {
        stompClient!.deactivate();
      } catch (e) {
        logger.d('기존 연결 해제 중 오류 (무시됨): $e');
      }
      stompClient = null;
    }

    resetReconnectAttemptCount();

    // 구독 정보 초기화
    subscriptions.clear();
    _isSettingUpSubscriptions = false;

    // 스트림 컨트롤러들이 닫혀있다면 새로 생성
    _recreateStreamControllersIfNeeded();

    currentUserId = userId;
    _wsBaseUrl = url;

    debugPrint('#### WebSocket 연결 URL: $url');
    debugPrint(
        '#### WebSocket 구독 URL: ${getSubscriptionFullUrl('/sub/users/$projectId')}');
    stompClient = StompClient(
      config: StompConfig(
        // url: 'ws://localhost:8080/ws/v',
        url: url,
        onConnect: (StompFrame frame) =>
            _onConnect(frame, projectId, pageId, isPermission, pageIdUrl),
        onDisconnect: _onDisconnect,
        onWebSocketError: (dynamic error) => debugPrint('웹소켓 에러: $error'),
        stompConnectHeaders: {'userId': userId},
        webSocketConnectHeaders: {'userId': userId},
        beforeConnect: () async {
          logger.i('###웹소켓 연결 시도');
        },
        onStompError: (error) {
          debugPrint('###STOMP 에러: $error');
        },
      ),
    );
  }

  /// DFERI 도메인일 때 Author 베이스(wss://www.edunavi.kr/booknavi/author/ws/v1) 소켓 클라이언트 초기화 및 구독(로그용)
  void initializeAuthorClient({
    required String url,
    required String userId,
    required String projectId,
    required String pageId,
    required bool isPermission,
  }) {
    if (stompClientAuthor != null) {
      debugPrint('[WS-Author] 이미 초기화되어 있음, 재연결 시 초기화 생략');
      return;
    }
    resetAuthorReconnectAttemptCount();
    _wsAuthorBaseUrl = url;
    logger.i('[WS-Author] 초기화 URL: $url');
    stompClientAuthor = StompClient(
      config: StompConfig(
        url: url,
        onConnect: (StompFrame frame) {
          resetAuthorReconnectAttemptCount();
          logger.i('[WS-Author] 연결 성공');
          _onAuthorConnect(frame, projectId, pageId, isPermission);
        },
        onDisconnect: (StompFrame frame) {
          logger.i('[WS-Author] 연결 해제');
        },
        onWebSocketError: (dynamic error) {
          // handshake 실패 시 예: Unexpected response code: 400 (서버 경로/프록시/헤더 설정 확인 필요)
          debugPrint('[WS-Author] 웹소켓 에러: $error');
          _scheduleAuthorReconnect();
        },
        stompConnectHeaders: {'userId': userId},
        webSocketConnectHeaders: {'userId': userId},
        beforeConnect: () async {
          logger.i('[WS-Author] 연결 시도 중...');
        },
        onStompError: (error) {
          debugPrint('[WS-Author] STOMP 에러: $error');
          // 재연결은 onWebSocketError에서만 스케줄 (한 번 실패에 한 번만 재시도)
        },
      ),
    );
  }

  void _onAuthorConnect(
      StompFrame frame, String projectId, String pageId, bool isPermission) {
    logger.i('[WS-Author] onConnect 완료, 구독 설정 시작');
    _setupAuthorSubscriptions(projectId, pageId, isPermission);
    logger.i('[WS-Author] 구독 설정 완료');
  }

  void _setupAuthorSubscriptions(
      String projectId, String pageId, bool isPermission) {
    final client = stompClientAuthor;
    if (client == null || !client.connected) {
      debugPrint('[WS-Author] 클라이언트 없음 또는 미연결, 구독 생략');
      return;
    }
    final prefix = '$_wsAuthorBaseUrl -> ';
    void logSub(String dest) => logger.i('[WS-Author] 구독: $prefix$dest');

    try {
      final subUsers = client.subscribe(
        destination: '/sub/users/$projectId',
        callback: (StompFrame frame) {
          logger.d(
              '[WS-Author] 수신 /sub/users/$projectId: bodyLength=${frame.body?.length ?? 0}');
        },
      );
      authorSubscriptions['/sub/users'] = subUsers;
      logSub('/sub/users/$projectId');

      final subCursor = client.subscribe(
        destination: '/sub/cursor/$projectId/$pageId',
        callback: (StompFrame frame) {
          logger.d(
              '[WS-Author] 수신 /sub/cursor/$projectId/$pageId: bodyLength=${frame.body?.length ?? 0}');
        },
      );
      authorSubscriptions['/sub/cursor'] = subCursor;
      logSub('/sub/cursor/$projectId/$pageId');

      final subRefresh = client.subscribe(
        destination: '/sub/refresh/$projectId/$pageId',
        callback: (StompFrame frame) {
          logger.d(
              '[WS-Author] 수신 /sub/refresh/$projectId/$pageId: bodyLength=${frame.body?.length ?? 0}');
        },
      );
      authorSubscriptions['/sub/refresh'] = subRefresh;
      logSub('/sub/refresh/$projectId/$pageId');

      final subTree = client.subscribe(
        destination: '/sub/refresh/$projectId',
        callback: (StompFrame frame) {
          logger.d(
              '[WS-Author] 수신 /sub/refresh/$projectId: bodyLength=${frame.body?.length ?? 0}');
        },
      );
      authorSubscriptions['/sub/refresh/treeList'] = subTree;
      logSub('/sub/refresh/$projectId');

      final subPause = client.subscribe(
        destination: '/sub/pause/$projectId',
        callback: (StompFrame frame) {
          logger.d(
              '[WS-Author] 수신 /sub/pause/$projectId: bodyLength=${frame.body?.length ?? 0}');
        },
      );
      authorSubscriptions['/sub/pause'] = subPause;
      logSub('/sub/pause/$projectId');

      if (isPermission) {
        final subEditor = client.subscribe(
          destination: '/sub/editor/$projectId/$pageId',
          callback: (StompFrame frame) {
            logger.d(
                '[WS-Author] 수신 /sub/editor/$projectId/$pageId: bodyLength=${frame.body?.length ?? 0}');
          },
        );
        authorSubscriptions['/sub/editor'] = subEditor;
        logSub('/sub/editor/$projectId/$pageId');
      }
    } catch (e, st) {
      debugPrint('[WS-Author] 구독 설정 오류: $e');
      debugPrint('[WS-Author] 스택: $st');
    }
  }

  void connectAuthorClient() {
    if (stompClientAuthor == null) return;
    if (_authorReconnectAttemptCount >= _maxAuthorReconnectAttempts) {
      debugPrint('[WS-Author] 재연결 횟수 초과로 connect 생략');
      return;
    }
    if (stompClientAuthor!.connected) {
      debugPrint('[WS-Author] 이미 연결됨');
      return;
    }
    logger.i('[WS-Author] connect() 호출');
    stompClientAuthor!.activate();
  }

  void unsubscribeAuthorAll() {
    try {
      for (final sub in authorSubscriptions.values) {
        try {
          sub();
        } catch (e) {
          debugPrint('[WS-Author] 구독 해제 오류: $e');
        }
      }
      authorSubscriptions.clear();
      logger.i('[WS-Author] 모든 구독 해제 완료');
    } catch (e) {
      debugPrint('[WS-Author] unsubscribeAuthorAll 오류: $e');
    }
  }

  void disconnectAuthorClient() {
    try {
      _intentionalDisconnect = true;
      resetAuthorReconnectAttemptCount();
      unsubscribeAuthorAll();
      stompClientAuthor?.deactivate();
      stompClientAuthor = null;
      _wsAuthorBaseUrl = null;
      logger.i('[WS-Author] 연결 해제 완료');
    } catch (e) {
      debugPrint('[WS-Author] disconnect 오류: $e');
    }
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
      debugPrint('스트림 컨트롤러 재생성 중 오류: $e');
    }
  }

  void connect() {
    try {
      debugPrint('#### WebSocket 연결 시도 base url: $_wsBaseUrl');
      debugPrint('#### WebSocket 연결 시도 url: ${stompClient?.config.url}');
      _intentionalDisconnect = false; // 연결 시도시 플래그 초기화
      // 이미 연결되어 있으면 중복 연결 방지
      if (stompClient?.connected == true) {
        debugPrint('#### WebSocket 이미 연결되어 있어 연결 시도 생략');
        return;
      }
      stompClient?.activate();
      // 실제 연결 성공은 _onConnect에서 처리하므로 여기서는 상태를 변경하지 않음
    } catch (e) {
      debugPrint('###연결 에러: $e');
      _connectionStateController?.add(false);
    }
  }

  void disconnect() {
    try {
      _intentionalDisconnect = true; // 의도적인 연결 해제를 표시
      resetReconnectAttemptCount();

      // 연결 상태를 먼저 업데이트
      _connectionStateController?.add(false);
      connectedUsers.clear();
      _userListInfoController?.add(connectedUserList);

      // STOMP 클라이언트 비활성화
      stompClient?.deactivate();
      // DFERI용 Author 소켓도 함께 해제
      disconnectAuthorClient();
    } catch (e) {
      debugPrint('###연결 해제 에러: $e');
    }
  }

  void _onConnect(StompFrame frame, String projectId, String pageId,
      bool isPermission, String pageIdUrl) {
    debugPrint('#### WebSocket 연결 성공: ${frame.headers}');
    resetReconnectAttemptCount();

    // 중복 연결 방지: 이미 구독이 설정되어 있고 설정 중이 아니면 생략
    if (subscriptions.isNotEmpty && !_isSettingUpSubscriptions) {
      debugPrint('#### 구독이 이미 설정되어 있어 중복 구독 설정 생략');
      _connectionStateController?.add(true);
      return;
    }

    try {
      // 연결 상태를 실제 연결 성공 시에만 true로 설정
      _connectionStateController?.add(true);
      _setupSubscriptions(projectId, pageId, isPermission, pageIdUrl);
    } catch (e, stackTrace) {
      debugPrint('###WebSocket 초기화 중 오류: $e');
      debugPrint('###스택 트레이스: $stackTrace');
      _connectionStateController?.add(false);
      _isSettingUpSubscriptions = false;
      // 재연결 시도 (최대 3회)
      Future.delayed(const Duration(seconds: 3), () {
        if (stompClient?.connected != true) {
          incrementReconnectAttempt();
          if (!canAttemptReconnect) {
            debugPrint(
                '#### WebSocket 재연결 최대 횟수($_maxReconnectAttempts) 초과, 재시도 중단');
            return;
          }
          debugPrint(
              '#### WebSocket 재연결 시도 ($_reconnectAttemptCount/$_maxReconnectAttempts)');
          connect();
        }
      });
    }
  }

  void _setupSubscriptions(
      String projectId, String pageId, bool isPermission, String pageIdUrl) {
    // 중복 구독 방지
    if (_isSettingUpSubscriptions) {
      debugPrint('#### 구독 설정이 이미 진행 중이어서 중복 실행 방지');
      return;
    }
    _isSettingUpSubscriptions = true;

    try {
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
      _isSettingUpSubscriptions = false;
    });

    try {
      // 초기 유저 등록
      final fullDestination = '/pub/users/$projectId';
      debugPrint('#### 유저 등록 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
      stompClient?.send(
        destination: fullDestination,
        body: jsonEncode({
          'userId': currentUserId ?? 'anonymous',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      // 초기 커서 위치 전송
      _sendCursorPosition(projectId, pageId, '0.0', 'none', 'false');
    } catch (e) {
      debugPrint('###초기화 메시지 전송 오류: $e');
    }
  }

  void connectUserListInfo(String projectId) {
    try {
      // 이미 사용자 목록 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/users')) {
        debugPrint('#### 사용자 목록 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      final fullDestination = '/sub/users/$projectId';
      debugPrint(
          '#### 사용자 목록 구독 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
      final subscription = stompClient?.subscribe(
        destination: fullDestination,
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
              debugPrint('###사용자 목록 메시지 처리 오류: $e');
            }
          }
        },
      );
      if (subscription != null) {
        // subscriptions['/sub/users/$projectId'] = subscription;
        subscriptions['/sub/users'] = subscription;
      }
    } catch (e) {
      debugPrint('###사용자 목록 구독 오류: $e');
    }
  }

  void connectCursor(String projectId, String pageId) {
    try {
      // 이미 커서 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/cursor')) {
        debugPrint('#### 커서 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      final fullDestination = '/sub/cursor/$projectId/$pageId';
      debugPrint('#### 커서 구독 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
      final subscription = stompClient?.subscribe(
        destination: fullDestination,
        callback: (StompFrame frame) {
          if (frame.body != null) {
            final data = _parseEditorMessage(frame.body!);
            _mouseDataController?.add(data);
            // try {
            //   final message = _parseMessage(frame.body!);
            //   if (message.isNotEmpty) {
            //     _messageController.add(message);
            //   }
            // } catch (e) {
            //   debugPrint('커서 메시지 처리 오류: $e');
            // }
          }
        },
      );
      if (subscription != null) {
        // subscriptions['/sub/cursor/$projectId/$pageId'] = subscription;
        subscriptions['/sub/cursor'] = subscription;
      }
    } catch (e) {
      debugPrint('###커서 구독 오류: $e');
    }
  }

  void connectRefresh(String projectId, String pageId) {
    try {
      // 이미 새로고침 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/refresh')) {
        debugPrint('#### 새로고침 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      final fullDestination = '/sub/refresh/$projectId/$pageId';
      debugPrint(
          '#### 새로고침 구독 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
      final subscription = stompClient?.subscribe(
        destination: fullDestination,
        callback: (StompFrame frame) {
          if (frame.body != null) {
            try {
              final message = _parseMessage(frame.body!);
              if (message.isNotEmpty) {
                // _refreshController.add(message);
                final refreshResponse = RefreshResponse.fromJson(message);
                _refreshResponseController?.add(refreshResponse);
              }
            } catch (e) {
              debugPrint('###새로고침 메시지 처리 오류: $e');
            }
          }
        },
      );
      if (subscription != null) {
        // subscriptions['/sub/refresh/$projectId/$pageId'] = subscription;
        subscriptions['/sub/refresh'] = subscription;
      }
    } catch (e) {
      debugPrint('###새로고침 구독 오류: $e');
    }
  }

  void connectTreeList(String projectId) {
    try {
      // 이미 트리 리스트 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/refresh/treeList')) {
        debugPrint('#### 트리 리스트 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      final fullDestination = '/sub/refresh/$projectId';
      debugPrint(
          '#### 트리 리스트 구독 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
      final subscription = stompClient?.subscribe(
        destination: fullDestination,
        callback: (StompFrame frame) {
          if (frame.body != null) {
            try {
              final message = _parseMessage(frame.body!);
              if (message.isNotEmpty) {
                // _treeListController.add(message);
                final treeListResponse = TreeListResponse.fromJson(message);
                _treeListController?.add(treeListResponse);
              }
            } catch (e) {
              debugPrint('###트리 리스트 메시지 처리 오류: $e');
            }
          }
        },
      );
      if (subscription != null) {
        // subscriptions['/sub/refresh/$projectId'] = subscription;
        subscriptions['/sub/refresh/treeList'] = subscription;
      }
    } catch (e) {
      debugPrint('###트리 리스트 구독 오류: $e');
    }
  }

  void connectPauseState(String projectId) {
    try {
      // 이미 일시정지 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/pause')) {
        debugPrint('#### 일시정지 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      final fullDestination = '/sub/pause/$projectId';
      debugPrint(
          '#### 일시정지 구독 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
      final subscription = stompClient?.subscribe(
        destination: fullDestination,
        callback: (StompFrame frame) {
          if (frame.body != null) {
            try {
              final message = _parseMessage(frame.body!);
              final pauseStateResponse = PauseStateResponse.fromJson(message);
              _pauseStateController?.add(pauseStateResponse.isPause ?? false);
            } catch (e) {
              debugPrint('###일시정지 메시지 처리 오류: $e');
            }
          }
        },
      );
      if (subscription != null) {
        subscriptions['/sub/pause'] = subscription;
      }
    } catch (e) {
      debugPrint('###일시정지 구독 오류: $e');
    }
  }

  void connectEditor(String projectId, String pageId) {
    try {
      if (stompClient == null) {
        debugPrint('#### WebSocket이 연결되어 있지 않습니다.');
        return;
      }
      // 이미 에디터 구독이 있으면 중복 구독 방지
      if (subscriptions.containsKey('/sub/editor')) {
        debugPrint('#### 에디터 구독이 이미 존재하여 중복 구독 방지');
        return;
      }
      final fullDestination = '/sub/editor/$projectId/$pageId';
      debugPrint(
          '#### 에디터 구독 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
      // 에디터 구독
      final subscription = stompClient!.subscribe(
        destination: fullDestination,
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

      // debugPrint('#### 에디터 메시지 전송: /pub/editor/$projectId/$pageId');

      // 초기 메시지 전송 - 테스트용
      // stompClient.send(
      //   destination: '/pub/editor/$projectId/$pageId',
      //   body: jsonEncode({
      //     'userId': currentUserId,
      //     'pageId': pageId,
      //     'timestamp': DateTime.now().millisecondsSinceEpoch,
      //   }),
      // );
    } catch (e) {
      debugPrint('### 에디터 연결 오류: $e');
    }
  }

  void _onDisconnect(StompFrame frame) {
    logger.i('연결이 해제되었습니다.');

    // 의도적인 연결 해제가 아닐 때만 스트림에 이벤트 추가
    if (!_intentionalDisconnect) {
      try {
        connectedUsers.clear();
        _userListInfoController?.add(connectedUserList);
        _connectionStateController?.add(false);
      } catch (e) {
        debugPrint('연결 해제 콜백에서 스트림 업데이트 오류: $e');
      }
    }
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

      // 2. JSON 디코딩 재시도
      try {
        final decoded = jsonDecode(message);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        // JSON 디코딩 실패 시 무시
      }

      // 3. 마지막으로 기본 디코딩 시도
      try {
        final decodedString = String.fromCharCodes(message.runes);
        final decoded = jsonDecode(decodedString);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (e) {
        debugPrint('최종 디코딩 실패: $e');
      }

      debugPrint('메시지가 올바른 JSON 형식이 아닙니다: $message');
      return {};
    } catch (e, stackTrace) {
      debugPrint('메시지 파싱 에러: $e');
      debugPrint('스택 트레이스: $stackTrace');
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
        debugPrint('스트림 컨트롤러 닫기 중 오류: $e');
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
      debugPrint('구독 해제 중 오류 발생: $e');
    }
  }

  void sendPauseState(String projectId, bool isPause) {
    final fullDestination = '/pub/pause/$projectId';
    debugPrint(
        '#### 일시정지 메시지 전송 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
    stompClient?.send(
      destination: fullDestination,
      body: jsonEncode({'userId': currentUserId, 'isPause': isPause}),
    );
    _pauseStateController?.add(isPause);
  }

  void sendCursorPosition(
      String projectId,
      String pageId,
      double line,
      double column,
      double editorWidth,
      double editorHeight,
      String cursorAction,
      String isMouseDown) {
    if (stompClient == null ||
        !stompClient!.connected ||
        currentUserId == null) {
      logger.d('커서 위치 전송 실패: WebSocket이 초기화되지 않았거나 연결되지 않았습니다.');
      return;
    }

    // final cursorPosition = '${line.toInt()}.${column.toInt()}';
    if (subscriptions.containsKey('/sub/cursor')) {
      final cursorPosition =
          '${line.toStringAsFixed(7)}/${column.toStringAsFixed(7)}';
      _sendCursorPosition(
          projectId, pageId, cursorPosition, cursorAction, isMouseDown);
    } else {
      return;
    }
  }

  void _sendCursorPosition(
    String projectId,
    String pageId,
    String cursorPosition,
    String cursorAction,
    String isMouseDown,
  ) {
    // stompClient가 null이거나 연결되지 않은 경우 메서드 종료
    if (stompClient == null || !stompClient!.connected) {
      logger.d('커서 위치 전송 실패: WebSocket이 초기화되지 않았거나 연결되지 않았습니다.');
      return;
    }
    final fullDestination = '/pub/cursor/$projectId/$pageId';
    debugPrint(
        '#### 커서 위치 전송 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
    stompClient?.send(
      destination: fullDestination,
      body: jsonEncode({
        'userId': currentUserId,
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
    final fullDestination = '/pub/refresh/$projectId/$pageId';
    debugPrint(
        '#### 새로고침 메시지 전송 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
    stompClient?.send(
      destination: fullDestination,
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

    final fullDestination = '/pub/refresh/$projectId';
    debugPrint(
        '#### 트리 리스트 메시지 전송 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
    stompClient!.send(
      destination: fullDestination,
      body: jsonEncode({
        'userId': currentUserId,
        // 'data': treeListModel,
        // 'data': treeListJson.toString(),
        'data': projectId
      }),
    );
  }

  void sendPageEditorResponse(String projectId, String pageId) {
    final fullDestination = '/pub/editor/$projectId/$pageId';
    debugPrint(
        '#### 에디터 메시지 전송 풀 주소: ${getSubscriptionFullUrl(fullDestination)}');
    stompClient?.send(
      destination: fullDestination,
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
      disconnectAuthorClient();
    } catch (e) {
      debugPrint('dispose 중 오류 발생: $e');
    }
  }
}
