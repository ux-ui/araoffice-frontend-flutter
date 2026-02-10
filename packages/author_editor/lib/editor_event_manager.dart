import 'dart:async';

import 'package:get/get.dart';

class EditorEventManager extends GetxController {
  static EditorEventManager get instance => Get.find<EditorEventManager>();

  final _eventController = StreamController<EditorEvent>.broadcast();
  Stream<EditorEvent> get eventStream => _eventController.stream;

  final _listeners = <Function(EditorEvent)>[];
  bool _isDisposed = false;

  // 이벤트 발생 시키기
  void emit(EditorEventType type, dynamic data) {
    if (_isDisposed) return; // 이미 dispose된 경우 이벤트 발생 방지
    if (type == EditorEventType.dispose) {
      _dispose();
      return;
    }

    final event = EditorEvent(type: type, data: data);
    _eventController.add(event);

    for (var listener in _listeners) {
      listener(event);
    }

    // dispose 이벤트인 경우 자동으로 정리 작업 수행
    // if (type == EditorEventType.dispose) {
    //   _dispose();
    // }
  }

  // 내부 dispose 처리
  void _dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _eventController.close();
    _listeners.clear();
    Get.delete<EditorEventManager>(); // GetX 인스턴스 제거
  }

  @override
  void onClose() {
    _dispose();
    super.onClose();
  }

  // 이벤트 리스너 등록
  void onEvent(void Function(EditorEvent) listener) {
    if (_isDisposed) return;
    _listeners.add(listener);
  }

  // 이벤트 리스너 제거
  void offEvent(void Function(EditorEvent) listener) {
    _listeners.remove(listener);
  }

  @override
  void Function() addListener(void Function() listener) {
    return super.addListener(listener);
  }

  @override
  void removeListener(void Function() listener) {
    super.removeListener(listener);
  }

  // 특정 이벤트 타입만 필터링해서 듣기
  Stream<EditorEvent> filterByType(EditorEventType type) {
    return eventStream.where((event) => event.type == type);
  }
}

class EditorEvent {
  final EditorEventType type;
  final dynamic data;
  final DateTime timestamp;

  EditorEvent({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum EditorEventType {
  createPage,
  deletePage,
  uploadFile,
  updatePageContent,
  copyPage,
  movePage,
  renamePage,
  placementProperty,
  tempSave,
  addWidget,
  clipArt,
  exportEpub,
  shortUrl,
  exportPdf,
  activePage,
  editPermission,
  setStartPage,
  tempSaveCheck,
  createPageWithContent,
  updateProjectAuth,
  addUser,
  deleteUser,
  getUserList,
  updateToc,
  onLoad,
  onUnload,
  onPageLoad,
  onRangeSelected,
  onSingleSelected,
  onCaretSelected,
  onMultiSelected,
  onCellSelected,
  onInsertElement,
  onNoneSelected,
  onNodeRectChanged,
  onStyleChanged,
  onAttributeChanged,
  onNodeInserted,
  onNodeRemoved,
  onUndoStackChanged,
  onPointerMove,
  onWidgetSelectionChanged,
  dispose, // 에디터 종료 이벤트 추가
}
