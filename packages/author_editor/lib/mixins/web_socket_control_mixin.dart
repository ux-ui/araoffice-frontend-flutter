import 'dart:async';
import 'dart:convert';

import 'package:api/api.dart';
import 'package:app_ui/widgets/vulcanx/external/tree_list_widget.dart';
import 'package:author_editor/data/user_info.dart';
import 'package:author_editor/enum/project_auth_type.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../engine/engines.dart';
import '../states/document_state.dart';
import '../web_socket/web_socket_connect.dart';

/// WebSocket 관련 기능을 관리하는 Mixin
mixin WebSocketControlMixin on GetxController {
  Editor? get editor;
  DocumentState get documentState;
  String get baseUrl;

  // 스트림 구독 관리
  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _userListInfoSubscription;
  StreamSubscription? _refreshResponseSubscription;
  StreamSubscription? _treeListSubscription;
  StreamSubscription? _editorSubscription;
  StreamSubscription? _mouseDataSubscription;
  StreamSubscription? _pauseStateSubscription;

  // 에디터 상태 관리
  bool _isEditorReady = false;
  bool get isEditorReady => _isEditorReady && editor != null;
  bool _isSocketConnectedByEvent = false;
  bool get isSocketConnectedByEvent => _isSocketConnectedByEvent;
  final rxSocketConnectedByEvent = false.obs;
  Timer? _editorOperationTimer;
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;
  bool _isInitializing = false; // 초기화 중 플래그
  DateTime? _lastConnectionCheck; // 마지막 연결 체크 시간
  static const Duration _connectionCheckCooldown =
      Duration(seconds: 5); // 연결 체크 쿨다운

  // 서비스 인스턴스
  final apiService = Get.find<ProjectApiService>();
  final loginService = Get.find<LoginApiClient>();
  final wsManager = WebSocketConnect();

  // 문서 및 사용자 식별자
  final anonymousUserId = 'anonymous_${const Uuid().v4().substring(0, 8)}';
  final documentUserId = ''.obs;

  // 화면 상태 관리
  final rxScrollPositionX = 0.0.obs;
  final rxScrollPositionY = 0.0.obs;
  final rxZoomValue = 1.0.obs;
  final refreshPageSignal = false.obs;

  // 커서 및 사용자 상호작용 관리
  final cursorAction = 'none'.obs;
  final cursors = <String, Map<String, dynamic>>{}.obs;
  // final connectedUserList = <String>{}.obs;
  final connectedUserList = <UserListInfo>{}.obs;
  final cursorTrails = <String, RxList<Offset>>{}.obs;
  final newCursorPoints = <String, RxList<Offset>>{}.obs;

  // 편집 권한 및 상태 관리
  final isEditingPermission = false.obs; // 실제 편집 권한
  final isEditingStatus = true.obs; // 편집 가능 상태
  final rxEditingUserId = ''.obs; // 편집중인 유저 id
  final rxEditingDisplayName = ''.obs; // 편집중인 유저 이름
  final rxIsRequestPermission = true.obs; // 권한 요청 가능 여부
  final rxIsEditorStatus = false.obs; // 에디터 상태

  // 목차 업데이트 중 일시정지 상태 관리
  final rxIsPause = false.obs;

  /// 편집 권한 해제 시 호출되는 콜백 (서브클래스에서 오버라이드)
  void onEditorPermissionLost() {
    // 기본 구현은 빈 메서드 - VulcanEditorController에서 오버라이드
  }

   /// 에디터 초기화 상태 설정
  void setEditorReady(bool ready) {
    _isEditorReady = ready;
    debugPrint('#### Editor ready state changed to: $_isEditorReady');
  }

  /// 에디터 내부 DOM 준비 이전 enable 호출로 인한 JS 오류를 방지한다.
  void setEditorEnabledSafely(
    bool enabled, {
    String reason = 'unknown',
    int retry = 0,
  }) {
    if (_isDisposed) return;

    final targetEditor = editor;
    if (targetEditor == null) {
      debugPrint('#### setEditorEnabledSafely skipped(editor=null): $reason');
      return;
    }

    if (!isEditorReady) {
      if (retry < 6) {
        Future.delayed(const Duration(milliseconds: 120), () {
          setEditorEnabledSafely(enabled, reason: reason, retry: retry + 1);
        });
      } else {
        debugPrint('#### setEditorEnabledSafely timeout(not ready): $reason');
      }
      return;
    }

    try {
      // getDocumentState() 접근이 가능해야 내부 DOM이 준비된 상태로 본다.
      targetEditor.getDocumentState();
      targetEditor.enable(enabled);
    } catch (e) {
      if (retry < 6) {
        Future.delayed(const Duration(milliseconds: 120), () {
          setEditorEnabledSafely(enabled, reason: reason, retry: retry + 1);
        });
      } else {
        debugPrint('#### setEditorEnabledSafely failed: $reason, error=$e');
      }
    }
  }

  Future<void> initializeWebSocket({
    required bool isPermission,
  }) async {
    try {
      // 이미 초기화 중이면 중복 초기화 방지
      if (_isInitializing) {
        debugPrint('#### WebSocket 초기화가 이미 진행 중이어서 중복 초기화 방지');
        return;
      }

      // disposed 상태 리셋
      _isDisposed = false;

      // ready 상태는 실제 페이지 onPageLoad 완료 시점에만 true로 전환한다.

      final url = baseUrl
          .replaceAll(RegExp(r'/$'), '')
          .replaceAll('https://', 'wss://')
          .replaceAll('http://', 'ws://')
          .replaceAll('/api/v1', '/ws/v1');

      // 이미 웹소켓이 연결되어 있으면 리턴
      if (wsManager.stompClient?.connected ?? false) {
        debugPrint('#### WebSocket 이미 연결되어 있음');
        // 연결되어 있지만 구독이 없으면 구독만 설정
        _setupSubscriptionsIfNeeded(isPermission);
        return;
      }

      // 초기화 중 플래그 설정
      _isInitializing = true;

      // 재초기화 시 기존 로컬 스트림 리스너를 항상 정리해 중복 리슨을 방지한다.
      _cancelSubscriptions();

      // 익명 사용자일 경우 anonymousUserId를 displayName으로 사용 (예: anonymous_52f95a66)
      final isAnonymous = documentState.rxUserId.value.isEmpty;
      final effectiveUserId =
          isAnonymous ? anonymousUserId : documentState.rxUserId.value;
      final effectiveDisplayName = isAnonymous
          ? anonymousUserId // 익명 사용자는 anonymousUserId를 displayName으로 사용
          : (documentState.rxDisplayName.value.isEmpty
              ? documentState.rxUserId.value
              : documentState.rxDisplayName.value);

      wsManager.initialize(
        url: url,
        displayName: effectiveDisplayName,
        userId: effectiveUserId,
        // userId: documentState.rxUserId.value.isEmpty
        //     ? anonymousUserId
        //     : documentState.rxUserId.value,
        projectId: documentState.rxProjectId.value,
        pageId: documentState.rxPageCurrent.value?.idref ?? '',
        pageIdUrl: documentState.rxPageCurrent.value?.id ?? '',
        isPermission: isPermission,
      );

      // 모든 스트림 리스너 설정
      // _messageSubscription = wsManager.messageStream.listen(_handleNewMessage);
      _connectionStateSubscription =
          wsManager.connectionState.listen((isConnected) {
        _handleConnectionState(isConnected);
        if (isConnected && isPermission) {
          // 연결이 성공하면 에디터 스트림 구독 (중복 구독 방지)
          if (_editorSubscription == null) {
            _editorSubscription =
                wsManager.editorStream.listen(_handleEditorUpdate);
            debugPrint('#### 에디터 스트림 구독 완료');
          } else {
            debugPrint(
                '#### 에디터 스트림 구독 이미 존재: ${_editorSubscription.toString()}');
            debugPrint('#### 에디터 스트림 구독이 이미 존재하여 중복 구독 방지');
          }
        }
      });
      // _userListSubscription =
      //     wsManager.userListStream.listen(_handleUserListUpdate);
      _userListInfoSubscription =
          wsManager.userListInfoStream.listen(_handleUserListUpdate);
      // _refreshSubscription = wsManager.refreshStream.listen(_handleRefresh);
      _refreshResponseSubscription =
          wsManager.refreshResponseStream.listen(_handleRefreshResponse);
      _treeListSubscription =
          wsManager.treeListStream.listen(_handleTreeListUpdate);

      _mouseDataSubscription =
          wsManager.mouseDataStream.listen(_handleMouseDataUpdate);
      _pauseStateSubscription =
          wsManager.pauseStateStream.listen(_handlePauseStateUpdate);
      wsManager.connect();
      documentUserId.value = documentState.rxUserId.value;

      // 초기화 완료 후 플래그 리셋 (약간의 지연 후)
      await Future.delayed(const Duration(milliseconds: 500), () {
        _isInitializing = false;
      });

      debugPrint('#### WebSocket 초기화 완료: isPermission=$isPermission');
    } catch (e) {
      _isInitializing = false; // 오류 발생 시 플래그 리셋
      debugPrint('#### WebSocket 초기화 오류: $e');
    }
  }

  /// 필요한 구독이 없으면 설정하는 헬퍼 메서드
  void _setupSubscriptionsIfNeeded(bool isPermission) {
    try {
      // 기본 구독들이 없으면 설정
      if (_userListInfoSubscription == null) {
        _userListInfoSubscription =
            wsManager.userListInfoStream.listen(_handleUserListUpdate);
      }
      if (_refreshResponseSubscription == null) {
        _refreshResponseSubscription =
            wsManager.refreshResponseStream.listen(_handleRefreshResponse);
      }
      if (_treeListSubscription == null) {
        _treeListSubscription =
            wsManager.treeListStream.listen(_handleTreeListUpdate);
      }
      if (_mouseDataSubscription == null) {
        _mouseDataSubscription =
            wsManager.mouseDataStream.listen(_handleMouseDataUpdate);
      }
      if (_pauseStateSubscription == null) {
        _pauseStateSubscription =
            wsManager.pauseStateStream.listen(_handlePauseStateUpdate);
      }
      if (_connectionStateSubscription == null) {
        _connectionStateSubscription =
            wsManager.connectionState.listen(_handleConnectionState);
      }

      // 에디터 권한 구독은 isPermission에 따라 설정
      if (isPermission && _editorSubscription == null) {
        _editorSubscription =
            wsManager.editorStream.listen(_handleEditorUpdate);
      }
    } catch (e) {
      debugPrint('#### 구독 설정 중 오류: $e');
    }
  }

  Future<void> checkIsEditingCurrentPage() async {
    //documentState.rxPageCurrent.value?.idref ?? '' 현재 페이지id
    try {
      debugPrint('#### checkIsEditingCurrentPage');
      final project =
          await apiService.fetchProject(documentState.rxProjectId.value);
      if (_isDisposed) return;
      if (project == null || project.statusCode == 403) return;

      // 현재 페이지 id와 동일한 페이지의 정보만 얻고 싶어 idref 사용
      final pageId = documentState.rxPageCurrent.value?.idref ?? '';
      if (pageId.isEmpty) return;
      final page =
          project.project?.pages?.firstWhere((page) => page.idref == pageId);
      if (page?.editorUser?.displayName?.isNotEmpty ?? false) {
        isEditingStatus.value = true;
        isEditingPermission.value = true;
        rxIsRequestPermission.value = true;
        rxEditingUserId.value = page?.editorUser?.userId ?? '';
        rxEditingDisplayName.value = page?.editorUser?.displayName ?? '';
        rxIsEditorStatus.value = true;
      }
      // final treeListModel = TreeListModel.listFromJson(pages);
      // documentUserId.value = project.project?.displayName ?? '';
      // documentState.rxPages.value = treeListModel;
    } catch (e, stackTrace) {
      debugPrint('트리 리스트 변환 중 오류 발생: $e');
      debugPrint('스택 트레이스: $stackTrace');
    }
  }

  /// 현재 프로젝트 공유 권한 상태에 따라 소켓 연결/구독을 정리하거나 보장합니다.
  /// - publicLink/userLink: 연결 보장. 이미 연결되어 있으면 재연결 없이 필요한 구독만 조정
  /// - onlyMe(비공개): 연결 해제 및 구독 해제
  Future<void> ensureSocketForPermission({
    required bool isPermission,
    ProjectAuthType? overrideShareType,
  }) async {
    final share =
        overrideShareType ?? documentState.rxProjectSharePermission.value;
    final isShared = share == ProjectAuthType.publicLink ||
        share == ProjectAuthType.userLink;

    if (!isShared) {
      // 비공개: 연결 해제 (이미 해제면 무시)
      if (isSocketConnectedByEvent) {
        disposeWebSocket();
      }
      return;
    }

    // 초기화 중이면 재연결 시도 방지
    if (_isInitializing) {
      debugPrint('#### WebSocket 초기화 중이어서 ensureSocketForPermission 건너뜀');
      return;
    }

    // 연결 체크 쿨다운: 너무 자주 체크하지 않도록 방지
    final now = DateTime.now();
    if (_lastConnectionCheck != null &&
        now.difference(_lastConnectionCheck!) < _connectionCheckCooldown) {
      debugPrint('#### 연결 체크 쿨다운 중이어서 ensureSocketForPermission 건너뜀');
      return;
    }
    _lastConnectionCheck = now;

    // 공유 상태: 연결 보장
    // stompClient가 존재하고 연결되어 있는지 더 정확하게 체크
    final isConnected = wsManager.stompClient != null &&
        (wsManager.stompClient?.connected ?? false);

    if (!isConnected) {
      // 연결되어 있지 않을 때만 초기화
      debugPrint('#### WebSocket 연결되지 않음, 초기화 시작');
      await initializeWebSocket(isPermission: isPermission);
      return; // 초기화 과정에서 connect 및 기본 구독 설정
    }

    // 이미 연결되어 있으면 필요한 구독만 정리/추가
    // 에디터 권한 구독은 isPermission에 따라 on/off
    if (isPermission) {
      if (_editorSubscription == null) {
        subscribeEditor();
      }
    } else {
      if (_editorSubscription != null) {
        disposeEditorSubscription();
      }
    }
  }

  /// 에디터 업데이트 처리
  void _handleEditorUpdate(EditorResponse data) {
    try {
      // 프로젝트 공유 권한을 받은 유저들 중 편집 권한을 서로 가져올 수 있음
      if (data.id == null) {
        debugPrint('######_handleEditorUpdate: message is null');
        return;
      }
      debugPrint('######에디터 편집 유저 정보: data: ${data.toJson()}');

      // final data = EditorDataResponse.fromJson(message);
      final userId = data.id ?? '';
      final displayName = data.displayName ?? '';

      if (userId == "null" || userId.isEmpty) {
        // null - 편집자 없음
        isEditingStatus.value = true; // 편집 가능 상태를 나타내기 위함
        isEditingPermission.value = true;
        rxIsRequestPermission.value = true;
        rxEditingUserId.value = userId;
        rxEditingDisplayName.value = displayName;
        rxIsEditorStatus.value = true;
        debugPrint('######_handleEditorUpdate: userId is null');
        setEditorEnabledSafely(
          true,
          reason: '_handleEditorUpdate:no-owner',
        );
      } else if (userId == documentState.rxUserId.value) {
        debugPrint('######_handleEditorUpdate: userId is self $userId');
        // 자신 - 편집 가능
        isEditingStatus.value = false;
        isEditingPermission.value = true;
        rxEditingUserId.value = userId;
        rxIsRequestPermission.value = false; // 이미 점유 상태
        rxIsEditorStatus.value = true;
        rxEditingDisplayName.value = displayName;
        setEditorEnabledSafely(
          true,
          reason: '_handleEditorUpdate:self',
        );
      } else {
        debugPrint('######_handleEditorUpdate: userId is other');
        // 다른 사용자 - 편집 불가
        isEditingStatus.value = false;
        isEditingPermission.value = false;
        rxEditingUserId.value = userId;
        rxIsRequestPermission.value = false;
        rxIsEditorStatus.value = false;
        rxEditingDisplayName.value = displayName;
        setEditorEnabledSafely(false, reason: '_handleEditorUpdate:other');
        onEditorPermissionLost();
      }
    } catch (e) {
      debugPrint('######_handleEditorUpdate 오류: $e');
    }
  }

  void _handleMouseDataUpdate(MouseDataResponse data) {
    try {
      if (data.userId == null) {
        return;
      }

      if (data.cursorPosition == null || data.cursorPosition!.isEmpty) {
        // 커서 위치가 없는 경우는 정상적인 케이스일 수 있음
        return;
      }

      final coordinates = data.cursorPosition!.split('/');
      if (coordinates.length != 2) {
        // logger.e('잘못된 커서 위치 형식: $cursorPosition');
        return;
      }

      final x = double.tryParse(coordinates[0]);
      final y = double.tryParse(coordinates[1]);
      if (x == null || y == null) {
        debugPrint('좌표 파싱 실패: x=$x, y=$y');
        return;
      }

      final userScroll = editor?.scrollPosition();
      if (userScroll == null) {
        debugPrint('스크롤 위치를 가져올 수 없음');
        return;
      }

      rxScrollPositionX.value = userScroll.x;
      rxScrollPositionY.value = userScroll.y;

      final scale = rxZoomValue.value;
      final correctedX = x - (rxScrollPositionX.value / scale);
      final correctedY = y - (rxScrollPositionY.value / scale);

      try {
        // _updateCursorWithCorrection(data.userId!, correctedX, correctedY, scale,
        //     data.cursorAction ?? 'none', data.isMouseDown ?? 'false');
        _updateCursorWithCorrection(
            data.userId!,
            data.displayName!,
            correctedX,
            correctedY,
            scale,
            data.cursorAction ?? 'none',
            data.isMouseDown ?? 'false');
      } catch (e) {
        debugPrint('커서 업데이트 중 오류 발생: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('웹소켓 메시지 처리 중 오류 발생: $e');
      debugPrint('스택 트레이스: $stackTrace');
    }
  }

   /// 커서 위치 보정 및 업데이트
  void _updateCursorWithCorrection(
      String userId,
      String displayName,
      double correctedX,
      double correctedY,
      double scale,
      String cursorAction,
      String isMouseDown) {
    try {
      final data = {
        'displayName': displayName,
        'x': correctedX,
        'y': correctedY,
        'cursorAction': cursorAction,
        'isMouseDown': isMouseDown,
      };
      updateUserCursorPosition(userId, data);
    } catch (e) {
      debugPrint('커서 위치 업데이트 중 오류 발생: $e');
    }
  }

   /// 안전한 에디터 작업 수행
  Future<void> safeEditorOperation(Future<void> Function() operation) async {
    if (!isEditorReady) {
      debugPrint('#### Editor is not ready, skipping operation');
      return;
    }

    try {
      await operation();
    } catch (e, stackTrace) {
      debugPrint('#### Editor operation failed: $e');
      debugPrint('#### Stack trace: $stackTrace');
      // 에러 발생 시 에디터 상태 리셋
      setEditorReady(false);
    }
  }

  /// 타이머를 사용한 안전한 지연 작업
  void scheduleSafeOperation(Future<void> Function() operation) {
    _editorOperationTimer?.cancel();
    _editorOperationTimer = Timer(const Duration(seconds: 1), () {
      operation();
    });
  }

  void _handleRefreshResponse(RefreshResponse data) {
    debugPrint('#### _handleRefreshResponse data: ${data.toJson()}');
    try {
      final userId = data.userId;
      final pageUrl = data.pageId;

      if (userId == null || pageUrl == null) {
        debugPrint('#### Invalid refresh message: userId or pageUrl is null');
        return;
      }

      if (userId != documentState.rxUserId.value) {
        debugPrint(
            '#### _handleRefresh userId: $userId projectOwner: ${documentState.rxProjectOwner.value}');

        scheduleSafeOperation(() async {
          if (editor != null) {
            try {
              editor!.unload();
              debugPrint('#### Editor unloaded successfully');
            } catch (e) {
              debugPrint('#### Unload failed, proceeding with load: $e');
            }

            try {
              editor!.load(pageUrl);
              debugPrint('#### Editor loaded successfully');
            } catch (e) {
              debugPrint('#### Load failed: $e');
            }
          } else {
            debugPrint('#### Editor is null during refresh');
          }
        });
      }

      refreshPageSignal.value = true;
    } catch (e, stackTrace) {
      debugPrint('#### Error in _handleRefresh: $e');
      debugPrint('#### Stack trace: $stackTrace');
    }
  }

  void _handlePauseStateUpdate(bool isPause) {
    if (isPause) {
      EasyLoading.showInfo('목차 업데이트 중이므로 작업이 일시정지되었습니다.');
      setEditorEnabledSafely(false, reason: '_handlePauseStateUpdate:pause');
      rxIsPause.value = true;
    } else {
      EasyLoading.showInfo('목차 업데이트 완료되었습니다.');
      setEditorEnabledSafely(true, reason: '_handlePauseStateUpdate:resume');
      rxIsPause.value = false;
    }
    debugPrint('#### _handlePauseStateUpdate: $isPause');
  }

  /// 트리 리스트 업데이트 처리
  void _handleTreeListUpdate(TreeListResponse data) {
    if (_isDisposed) return;
    debugPrint('#### _handleTreeListUpdate data: ${data.toJson()}');
    final projectId = data.data;
    final userId = data.userId;

    Future.delayed(const Duration(seconds: 1), () async {
      if (_isDisposed) return;
      if (projectId == null || projectId.isEmpty) return;
      if (documentState.rxProjectId.value != projectId) return;

      try {
        final result = await compareUserId(userId ?? '');
        if (!result) {
          final project = await apiService.fetchProject('$projectId');
          if (_isDisposed) return;
          if (project == null || project.statusCode == 403) return;

          final pages = project.project?.toPageJson();
          if (pages == null) return;

          final treeListModel = TreeListModel.listFromJson(pages);
          documentUserId.value = project.project?.displayName ?? '';
          documentState.rxPages.value = treeListModel;
        }
      } catch (e, stackTrace) {
        debugPrint('트리 리스트 변환 중 오류 발생: $e');
        debugPrint('스택 트레이스: $stackTrace');
      }
    });
  }

  Future<bool> compareUserId(String userId) async {
    final result = await loginService.userInfo();
    debugPrint(
        '#### compareUserId result: ${result?.userId} projectOwner: ${documentState.rxProjectOwner.value}');
    // return result?.userId == documentState.rxProjectOwner.value ? true : false;
    return result?.userId == userId ? true : false;
  }

  Future<void> reConnectTreeList() async {
    final project =
        await apiService.fetchProject(documentState.rxProjectId.value);
    if (project == null || project.statusCode == 403) return;

    final pages = project.project?.toPageJson();
    if (pages == null) return;

    final treeListModel = TreeListModel.listFromJson(pages);
    documentUserId.value = project.project?.displayName ?? '';
    documentState.rxPages.value = treeListModel;
  }

  void _handleConnectionState(bool isConnected) {
    try {
      _isSocketConnectedByEvent = isConnected;
      rxSocketConnectedByEvent.value = isConnected;
      debugPrint('연결 상태: ${isConnected ? "연결됨" : "연결 해제됨"}');

      if (isConnected) {
        // 연결 성공 시 초기화 플래그 리셋
        _isInitializing = false;
        // 여기서 페이지 편집중인 유저가 있는지 먼저 확인 후 있다면 셋팅 후 동작
        // checkIsEditingCurrentPage();
        reConnectTreeList();
      } else {
        // 연결이 끊어졌을 때 에디터 상태 초기화
        setEditorReady(false);
        _editorOperationTimer?.cancel();

        // if (!wsManager.isIntentionalDisconnect && !_isInitializing) {
        //   // 의도적인 연결 해제가 아니고 초기화 중이 아닐 때만 재연결 시도
        //   Future.delayed(const Duration(seconds: 3), () {
        //     // 재연결 시도 전에 다시 한 번 체크
        //     if (!wsManager.isConnected && !_isInitializing) {
        //       debugPrint('#### WebSocket 재연결 시도');
        //       wsManager.connect();
        //     } else {
        //       debugPrint('#### WebSocket이 이미 연결되었거나 초기화 중이어서 재연결 건너뜀');
        //     }
        //   });
        // }
      }
    } catch (e, stackTrace) {
      debugPrint('#### Error in _handleConnectionState: $e');
      debugPrint('#### Stack trace: $stackTrace');
    }
  }

  void _handleUserListUpdate(dynamic users) {
    connectedUserList.clear();
    connectedUserList.addAll(users);

    // 연결이 끊긴 사용자의 커서 제거
    cursors.keys
        .where((userId) =>
            !connectedUserList.any((userInfo) => userInfo.userId == userId))
        .toList()
        .forEach(removeCursor);
    debugPrint('#### _handleTestUserListUpdate data: ${jsonEncode(users)}');
  }

  void updateCursorPosition(
      {required double x,
      required double y,
      required double scrollX,
      required double scrollY}) {
    // disposed 상태이면 커서 업데이트 건너뛰기
    if (_isDisposed) {
      return;
    }

    if (documentState.hasSharedPermission) {
      // 익명 사용자일 경우 anonymousUserId를 displayName으로 사용
      final isAnonymous = documentState.rxUserId.value.isEmpty;
      final effectiveDisplayName = isAnonymous
          ? anonymousUserId
          : (documentState.rxDisplayName.value.isEmpty
              ? documentState.rxUserId.value
              : documentState.rxDisplayName.value);

      wsManager.sendCursorPosition(
          documentState.rxProjectId.value,
          effectiveDisplayName,
          documentState.rxPageCurrent.value?.idref ?? 'cover.xhtml',
          x,
          y,
          documentState.rxDocumentSizeWidth.value.toDouble(),
          documentState.rxDocumentSizeHeight.value.toDouble(),
          cursorAction.value,
          _safeGetWhiteBoardMouseDown());
    }
  }

  /// 화이트보드 마우스 다운 상태를 안전하게 확인하는 헬퍼 함수
  String _safeGetWhiteBoardMouseDown() {
    try {
      if (editor == null) return 'false';
      return editor?.whiteBoardIsMouseDown() == true ? 'true' : 'false';
    } catch (e) {
      // JavaScript에서 null 참조 오류 발생 시 기본값 반환
      debugPrint('_safeGetWhiteBoardMouseDown error: $e');
      return 'false';
    }
  }

  void updateUserCursorPosition(String userId, Map<String, dynamic> data) {
    try {
      final displayName = data['displayName'] as String? ?? '';
      final x = data['x'] as double? ?? 0.0;
      final y = data['y'] as double? ?? 0.0;
      final cursorAction = data['cursorAction'] as String? ?? 'none';
      final isMouseDown = data['isMouseDown'] as String? ?? 'false';

      // cursors[userId] = {'x': x, 'y': y};
      // userId를 키로 사용하고, displayName은 값에 포함
      cursors[userId] = {'x': x, 'y': y, 'displayName': displayName};

      switch (cursorAction) {
        case 'none':
          // updateTrailPosition(userId: userId, x: x, y: y);
          updateTrailPosition(
              userId: userId, displayName: displayName, x: x, y: y);
          break;
        case 'drawing':
          if (isMouseDown == 'true' && editor != null) {
            editor?.publicDrawPoint(x.toInt(), y.toInt());
          } else {
            editor?.endDrawing();
          }
          break;
        case 'erase':
          if (isMouseDown == 'true' && editor != null) {
            editor?.publicErasePoint(x.toInt(), y.toInt());
          } else {
            editor?.endDrawing();
          }
          break;
        case 'clear':
          editor?.clearDrawing();
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('커서 위치 업데이트 중 오류 발생: $e');
      debugPrint('스택 트레이스: $stackTrace');
    }
  }

  /// 페이지 변경 시 웹소켓 연결 재설정
  void onChangedPage(String pageId, {required bool isPermission}) {
    try {
      // 기존 구독 해제
      disposeMouseDataSubscription();
      disposeRefreshSubscription();
      disposeEditorSubscription();

      if (!wsManager.isConnected) {
        debugPrint('#### WebSocket 미연결 상태 - 페이지 변경 구독은 연결 후 재설정');
        initializeWebSocket(isPermission: isPermission);
        return;
      }

      // 새로운 구독 설정
      subscribeCursor();
      subscribeRefresh();
      if (isPermission) {
        subscribeEditor();
      }

      // 이전 커서 제거
      final userId = documentState.rxUserId.value.isEmpty
          ? anonymousUserId
          : documentState.rxUserId.value;
      removeCursor(userId);
    } catch (e) {
      debugPrint('페이지 변경 중 오류 발생: $e');
    }
  }

  void removeCursor(String userId) {
    cursors.remove(userId);
  }

  /// 모든 구독을 취소
  void _cancelSubscriptions() {
    try {
      _connectionStateSubscription?.cancel();
      _userListInfoSubscription?.cancel();
      _refreshResponseSubscription?.cancel();
      _treeListSubscription?.cancel();
      _editorSubscription?.cancel();
      _mouseDataSubscription?.cancel();
      _pauseStateSubscription?.cancel();
      // 구독 변수들을 null로 설정
      _connectionStateSubscription = null;
      _userListInfoSubscription = null;
      _refreshResponseSubscription = null;
      _treeListSubscription = null;
      _editorSubscription = null;
      _mouseDataSubscription = null;
    } catch (e) {
      debugPrint('구독 취소 중 오류 발생: $e');
    }
  }

  /// 마우스 데이터 구독 해제
  void disposeMouseDataSubscription() {
    _mouseDataSubscription?.cancel();
    _mouseDataSubscription = null;
    wsManager.unsubscribeFromCursor();
    debugPrint('마우스 데이터 구독 해제 완료');
  }

  /// 사용자 목록 구독 해제
  void disposeUserListInfoSubscription() {
    _userListInfoSubscription?.cancel();
    _userListInfoSubscription = null;
    wsManager.unsubscribeFromUserList();
    debugPrint('사용자 목록 구독 해제 완료');
  }

  /// 새로고침 구독 해제
  void disposeRefreshSubscription() {
    _refreshResponseSubscription?.cancel();
    _refreshResponseSubscription = null;
    wsManager.unsubscribeFromRefresh();
    debugPrint('새로고침 구독 해제 완료');
  }

  /// 트리 리스트 구독 해제
  void disposeTreeListSubscription() {
    _treeListSubscription?.cancel();
    _treeListSubscription = null;
    wsManager.unsubscribeFromTreeList();
    debugPrint('트리 리스트 구독 해제 완료');
  }

  /// 에디터 구독 해제
  void disposeEditorSubscription() {
    _editorSubscription?.cancel();
    _editorSubscription = null;
    wsManager.unsubscribeFromEditor();
    debugPrint('에디터 구독 해제 완료');
  }

  /// 커서 구독 설정
  void subscribeCursor() {
    try {
      if (!isSocketConnectedByEvent) {
        debugPrint('커서 구독 설정 생략: WebSocket 미연결');
        return;
      }
      wsManager.connectCursor(
        documentState.rxProjectId.value,
        documentState.rxPageCurrent.value?.idref ?? '',
      );
      _mouseDataSubscription =
          wsManager.mouseDataStream.listen(_handleMouseDataUpdate);
      debugPrint('커서 구독 설정 완료');
    } catch (e) {
      debugPrint('커서 구독 설정 중 오류 발생: $e');
    }
  }

  /// 사용자 목록 구독 설정
  void subscribeUserListInfo() {
    try {
      if (!isSocketConnectedByEvent) {
        debugPrint('사용자 목록 구독 설정 생략: WebSocket 미연결');
        return;
      }
      wsManager.connectUserListInfo(documentState.rxProjectId.value);
      _userListInfoSubscription =
          wsManager.userListInfoStream.listen(_handleUserListUpdate);
      debugPrint('사용자 목록 구독 설정 완료');
    } catch (e) {
      debugPrint('사용자 목록 구독 설정 중 오류 발생: $e');
    }
  }

  /// 새로고침 구독 설정
  void subscribeRefresh() {
    try {
      if (!isSocketConnectedByEvent) {
        debugPrint('새로고침 구독 설정 생략: WebSocket 미연결');
        return;
      }
      wsManager.connectRefresh(
        documentState.rxProjectId.value,
        documentState.rxPageCurrent.value?.idref ?? '',
      );
      _refreshResponseSubscription =
          wsManager.refreshResponseStream.listen(_handleRefreshResponse);
      debugPrint('새로고침 구독 설정 완료');
    } catch (e) {
      debugPrint('새로고침 구독 설정 중 오류 발생: $e');
    }
  }

  /// 트리 리스트 구독 설정
  void subscribeTreeList() {
    try {
      if (!isSocketConnectedByEvent) {
        debugPrint('트리 리스트 구독 설정 생략: WebSocket 미연결');
        return;
      }
      wsManager.connectTreeList(documentState.rxProjectId.value);
      _treeListSubscription =
          wsManager.treeListStream.listen(_handleTreeListUpdate);
      debugPrint('트리 리스트 구독 설정 완료');
    } catch (e) {
      debugPrint('트리 리스트 구독 설정 중 오류 발생: $e');
    }
  }

  /// 에디터 구독 설정
  void subscribeEditor() {
    try {
      if (!isSocketConnectedByEvent) {
        debugPrint('에디터 구독 설정 생략: WebSocket 미연결');
        return;
      }
      wsManager.connectEditor(
        documentState.rxProjectId.value,
        documentState.rxPageCurrent.value?.id ?? '',
      );
      _editorSubscription = wsManager.editorStream.listen(_handleEditorUpdate);

      debugPrint('에디터 구독 설정 완료');
    } catch (e) {
      debugPrint('에디터 구독 설정 중 오류 발생: $e');
    }
  }

  /// 연결 상태 구독 설정
  void subscribeConnectionState() {
    try {
      _connectionStateSubscription =
          wsManager.connectionState.listen(_handleConnectionState);
      debugPrint('연결 상태 구독 설정 완료');
    } catch (e) {
      debugPrint('연결 상태 구독 설정 중 오류 발생: $e');
    }
  }

  void disposeWebSocket() {
    try {
      debugPrint('#### Disposing WebSocket connections and resources');
      _isSocketConnectedByEvent = false;
      rxSocketConnectedByEvent.value = false;

      // disposed 상태로 설정
      _isDisposed = true;
      _isInitializing = false; // 초기화 플래그도 리셋
      _lastConnectionCheck = null; // 연결 체크 시간도 리셋

      // 진행 중인 타이머 취소
      _editorOperationTimer?.cancel();
      _editorOperationTimer = null;

      // 스트림 구독 해제
      _cancelSubscriptions();

      // 웹소켓 연결 해제
      try {
        wsManager.dispose();
      } catch (e) {
        debugPrint('웹소켓 연결 해제 중 오류 (무시됨): $e');
      }

      // 상태 초기화
      cursors.clear();
      connectedUserList.clear();
      cursorTrails.clear();
      newCursorPoints.clear();

      debugPrint('#### WebSocket resources disposed successfully');
    } catch (e, stackTrace) {
      debugPrint('#### Error disposing WebSocket resources: $e');
      debugPrint('#### Stack trace: $stackTrace');
    }
  }

  void updateTrailPosition({
    required String displayName,
    required double x,
    required double y,
    required String userId,
  }) {
    if (displayName.isEmpty) return;
    if (x == 0 && y == 0) return;

    if (!cursorTrails.containsKey(displayName)) {
      cursorTrails[displayName] = <Offset>[].obs;
    }
    if (!newCursorPoints.containsKey(displayName)) {
      newCursorPoints[displayName] = <Offset>[].obs;
    }

    final point = Offset(x, y);
    cursorTrails[displayName]!.add(point);
    newCursorPoints[displayName]!.add(point);
    update();
  }

  void eraseTrail(String displayName) {
    cursorTrails[displayName]?.clear();
    newCursorPoints[displayName]?.clear();
    update();
  }

  void clearNewPoints(String displayName) {
    newCursorPoints.clear();
    update();
  }
}

class EditorDataResponse {
  final String? userId;
  final String? displayName;

  EditorDataResponse({
    this.userId,
    this.displayName,
  });

  factory EditorDataResponse.fromJson(Map<String, dynamic> json) {
    return EditorDataResponse(
        userId: json['id'] as String?,
        displayName: json['displayName'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'displayName': displayName,
    };
  }
}

class MouseDataResponse {
  final String? userId;
  final String? displayName;
  final String? pageId;
  final String? cursorPosition;
  final String? cursorAction;
  final String? isMouseDown;

  MouseDataResponse({
    this.userId,
    this.displayName,
    this.pageId,
    this.cursorPosition,
    this.cursorAction,
    this.isMouseDown,
  });

  factory MouseDataResponse.fromJson(Map<String, dynamic> json) {
    return MouseDataResponse(
      userId: json['userId'] as String?,
      pageId: json['pageId'] as String?,
      displayName: json['displayName'] as String?,
      cursorPosition: json['cursorPosition'] as String?,
      cursorAction: json['cursorAction'] as String?,
      isMouseDown: json['isMouseDown'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pageId': pageId,
      'displayName': displayName,
      'cursorPosition': cursorPosition,
      'cursorAction': cursorAction,
      'isMouseDown': isMouseDown,
    };
  }
}

class UserListResponse {
  final String? userId;
  final String? displayName;

  UserListResponse({
    this.userId,
    this.displayName,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      userId: json['userId'] as String?,
      displayName: json['displayName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
    };
  }
}

class RefreshResponse {
  final String? userId;
  final String? pageId;

  RefreshResponse({
    this.userId,
    this.pageId,
  });

  factory RefreshResponse.fromJson(Map<String, dynamic> json) {
    return RefreshResponse(
      userId: json['userId'] as String?,
      pageId: json['data'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pageId': pageId,
    };
  }
}

class TreeListResponse {
  final String? userId;
  final String? data;

  TreeListResponse({
    this.userId,
    this.data,
  });

  factory TreeListResponse.fromJson(Map<String, dynamic> json) {
    return TreeListResponse(
      userId: json['userId'] as String?,
      data: json['data'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'data': data,
    };
  }
}

class PauseStateResponse {
  final String? projectId;
  final bool? isPause;

  PauseStateResponse({
    this.projectId,
    this.isPause,
  });

  factory PauseStateResponse.fromJson(Map<String, dynamic> json) {
    return PauseStateResponse(
      projectId: json['projectId'] as String?,
      isPause: json['isPause'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'isPause': isPause,
    };
  }
}

class EditorResponse {
  final String? id;
  final String? displayName;

  EditorResponse({
    this.id,
    this.displayName,
  });

  factory EditorResponse.fromJson(Map<String, dynamic> json) {
    return EditorResponse(
      id: json['id'] as String?,
      displayName: json['displayName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
    };
  }
}
