import 'dart:async';

import 'package:get/get.dart';

import 'editor_event_manager.dart';

/// 이벤트 발생 시 타이머를 관리하고 3초 후 EasyLoading.info를 표시하는 매니저
class EditorEventTimerManager extends GetxController {
  static EditorEventTimerManager get instance =>
      Get.find<EditorEventTimerManager>();

  Timer? _timer;
  final Set<EditorEventType> _registeredEvents = {};
  bool _isDisposed = false;
  StreamSubscription<EditorEvent>? _eventSubscription;
  String? _infoMessage;
  void Function(EditorEvent)? _onEvent;
  EditorEvent? _lastEvent;
  bool _isCallbackExecuting = false; // onEvent 콜백 실행 중인지 확인하는 플래그
  DateTime? _lastCallbackTime; // 마지막 콜백 실행 시간
  static const Duration _callbackCooldown =
      Duration(milliseconds: 500); // 콜백 후 쿨다운 시간
  void Function()? _startTimerCallback; // startTimer에서 전달받은 콜백

  /// 등록된 이벤트 목록
  Set<EditorEventType> get registeredEvents => _registeredEvents;

  /// 타이머가 현재 실행 중인지 여부를 반환
  bool get isTimerRunning => _timer != null;

  /// 이벤트 타입들을 등록하고 모니터링 시작
  /// [infoMessage]는 타이머 종료 시 표시할 메시지 (기본값: '작업이 완료되었습니다.')
  /// [onEvent]는 타이머 완료(3초 후) 시 호출될 콜백 함수
  void registerEvents(
    Set<EditorEventType> eventTypes, {
    String? infoMessage,
    void Function(EditorEvent)? onEvent,
  }) {
    if (_isDisposed) return;

    _registeredEvents.clear();
    _registeredEvents.addAll(eventTypes);
    _infoMessage = infoMessage ?? '작업이 완료되었습니다.';
    _onEvent = onEvent;
    _eventSubscription?.cancel();

    if (Get.isRegistered<EditorEventManager>()) {
      final eventManager = EditorEventManager.instance;
      _eventSubscription = eventManager.eventStream.listen(_handleEvent);
    }
  }

  /// 기본 이벤트들을 모두 등록
  /// [infoMessage]는 타이머 종료 시 표시할 메시지 (기본값: '작업이 완료되었습니다.')
  /// [onEvent]는 타이머 완료(3초 후) 시 호출될 콜백 함수
  void registerDefaultEvents(
      {String? infoMessage, void Function(EditorEvent)? onEvent}) {
    registerEvents(
      {
        EditorEventType.createPage,
        EditorEventType.deletePage,
        EditorEventType.uploadFile,
        EditorEventType.updatePageContent,
        EditorEventType.copyPage,
        EditorEventType.movePage,
        EditorEventType.renamePage,
        EditorEventType.placementProperty,
        EditorEventType.tempSave,
        EditorEventType.addWidget,
        EditorEventType.clipArt,
        EditorEventType.exportEpub,
        EditorEventType.shortUrl,
        EditorEventType.exportPdf,
        EditorEventType.activePage,
        EditorEventType.editPermission,
        EditorEventType.setStartPage,
        EditorEventType.tempSaveCheck,
        EditorEventType.createPageWithContent,
        EditorEventType.updateProjectAuth,
        EditorEventType.addUser,
        EditorEventType.deleteUser,
        EditorEventType.getUserList,
        EditorEventType.updateToc,
        EditorEventType.onLoad,
        EditorEventType.onUnload,
        EditorEventType.onPageLoad,
        EditorEventType.onRangeSelected,
        EditorEventType.onSingleSelected,
        EditorEventType.onCaretSelected,
        EditorEventType.onMultiSelected,
        EditorEventType.onCellSelected,
        EditorEventType.onInsertElement,
        EditorEventType.onNoneSelected,
        EditorEventType.onNodeRectChanged,
        EditorEventType.onStyleChanged,
        EditorEventType.onAttributeChanged,
        EditorEventType.onNodeInserted,
        EditorEventType.onNodeRemoved,
        EditorEventType.onUndoStackChanged,
        EditorEventType.onPointerMove,
        EditorEventType.onWidgetSelectionChanged,
      },
      infoMessage: infoMessage,
      onEvent: onEvent,
    );
  }

  /// 특정 이벤트 타입 추가
  void addEvent(EditorEventType eventType) {
    if (_isDisposed) return;
    _registeredEvents.add(eventType);
  }

  /// 특정 이벤트 타입 제거
  void removeEvent(EditorEventType eventType) {
    if (_isDisposed) return;
    _registeredEvents.remove(eventType);
  }

  /// 이벤트 처리
  void _handleEvent(EditorEvent event) {
    if (_isDisposed) return;

    if (_isCallbackExecuting) {
      return;
    }

    if (_lastCallbackTime != null) {
      final timeSinceCallback = DateTime.now().difference(_lastCallbackTime!);
      if (timeSinceCallback < _callbackCooldown) {
        return;
      }
    }

    if (!_registeredEvents.contains(event.type)) {
      return;
    }

    if (event.type == EditorEventType.dispose) {
      _cancelTimer();
      _lastEvent = null;
      _isCallbackExecuting = false;
      _lastCallbackTime = null;
      return;
    }

    _lastEvent = event;
    _resetTimer();
  }

  /// 타이머 리셋 (3초 후 EasyLoading.info 표시 및 onEvent 콜백 호출)
  /// 기존 타이머를 취소하고 새로운 타이머를 시작합니다.
  void _resetTimer() {
    _cancelTimer();
    _startNewTimer(isFromStartTimer: false);
  }

  /// 타이머 취소
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void startTimer({EditorEvent? event, void Function()? onComplete}) {
    if (_isDisposed) return;

    _cancelTimer();
    _startTimerCallback = onComplete;

    if (event != null) {
      _lastEvent = event;
    } else if (_lastEvent == null) {
      if (onComplete != null) {
        final eventType = _registeredEvents.isNotEmpty
            ? _registeredEvents.first
            : EditorEventType.onNodeRectChanged;
        _lastEvent = EditorEvent(
          type: eventType,
          data: null,
        );
      } else if (_registeredEvents.isNotEmpty) {
        _lastEvent = EditorEvent(
          type: _registeredEvents.first,
          data: null,
        );
      } else {
        _startTimerCallback = null;
        return;
      }
    }

    _startNewTimer(isFromStartTimer: true);
  }

  /// 새로운 타이머 시작 (3초 후 onEvent 콜백 호출 및 타이머 종료)
  /// [isFromStartTimer]는 startTimer에서 호출된 경우 true
  void _startNewTimer({bool isFromStartTimer = false}) {
    if (_lastEvent == null) {
      return;
    }

    final eventToProcess = _lastEvent;
    final callbackToExecute = isFromStartTimer ? _startTimerCallback : null;

    _timer = Timer(const Duration(seconds: 3), () {
      _lastEvent = null;
      _timer = null;

      if (isFromStartTimer) {
        _startTimerCallback = null;
      }

      if (!_isDisposed && eventToProcess != null) {
        _isCallbackExecuting = true;

        try {
          // EasyLoading.showInfo(_infoMessage ?? '작업이 완료되었습니다.');
          _onEvent?.call(eventToProcess);
          callbackToExecute?.call();
        } finally {
          _isCallbackExecuting = false;
          _lastCallbackTime = DateTime.now();
        }
      }
    });
  }

  /// 수동으로 타이머 취소
  void cancelTimer() {
    _cancelTimer();
  }

  /// 메시지 변경
  void setInfoMessage(String message) {
    if (_isDisposed) return;
    _infoMessage = message;
  }

  @override
  void onClose() {
    _dispose();
    super.onClose();
  }

  /// 내부 dispose 처리
  void _dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _cancelTimer();
    _eventSubscription?.cancel();
    _registeredEvents.clear();
    _lastEvent = null;
    _isCallbackExecuting = false;
    _lastCallbackTime = null;
    _startTimerCallback = null;
  }
}
