import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math';
import 'dart:ui_web';

import 'package:author_editor/editor_event_manager.dart';
import 'package:author_editor/engine/editor_html_node.dart';
import 'package:author_editor/engine/editor_html_node_rect.dart';
import 'package:common_assets/common_assets.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

import '../dialog/editor_context_menu.dart';
import 'extension_js_type/js_editor_types.dart';
import 'extension_js_type/js_widget_info.dart';

export 'extension_js_type/js_editor_types.dart' show Editor;
export 'extension_js_type/js_paragraph_style.dart' show JSParagraphStyle;
export 'extension_js_type/js_text_style.dart' show JSTextStyle;

@JS('EditorLibrary')
external JSObject get editorLibrary;

@JS('EditorLibrary.default')
external JSFunction get editorConstructor;

class EditorIntegration extends StatefulWidget {
  final String baseUrl;
  final String langUrl;
  final String fontUrl;
  final Function(Editor editor)? onLoad;
  final Function(Editor editor)? onPageLoad;
  final Function(EditorHtmlNode node)? onSingleSelected;
  final Function(EditorHtmlNode node, String html, String capturePage)?
      onCaretSelected;
  // final Function(EditorHtmlNode node)? onCaretSelected;
  final Function(List<EditorHtmlNode> nodes)? onMultiSelected;
  final Function(EditorHtmlNode table, List<EditorHtmlNode> nodes)?
      onCellSelected;
  final Function(String html, String capturePage)? onNoneSelected;
  final Function(List<EditorHtmlNodeRect> nodeRect)? onNodeRectChanged;
  final Function(EditorHtmlNode node, String name, String value)?
      onStyleChanged;
  final Function(EditorHtmlNode node, String name, String value)?
      onAttributeChanged;
  final Function(EditorHtmlNode node)? onNodeInserted;
  final Function(EditorHtmlNode node)? onNodeRemoved;
  final Function(bool canUndo, bool canRedo)? onUndoStackChanged;
  final Function(double editorX, double editorY, double windowX, double windowY,
      bool isInEditor)? onPointerMove;
  final Function(
          EditorHtmlNode node, String id, Map<String, dynamic> properties)?
      onWidgetSelectionChanged;
  final Function()? onFrameClick;
  final Function(EditorHtmlNode node)? onDocumentChanged;

  const EditorIntegration({
    super.key,
    required this.baseUrl,
    required this.langUrl,
    required this.fontUrl,
    this.onLoad,
    this.onPageLoad,
    this.onSingleSelected,
    this.onNoneSelected,
    this.onCaretSelected,
    this.onCellSelected,
    this.onMultiSelected,
    this.onNodeRectChanged,
    this.onStyleChanged,
    this.onAttributeChanged,
    this.onNodeInserted,
    this.onNodeRemoved,
    this.onUndoStackChanged,
    this.onPointerMove,
    this.onWidgetSelectionChanged,
    this.onFrameClick,
    this.onDocumentChanged,
  });

  @override
  State<EditorIntegration> createState() => _EditorIntegrationState();
}

class _EditorIntegrationState extends State<EditorIntegration>
    with SingleTickerProviderStateMixin {
  String viewType = 'editor-view';
  late Editor editor;
  bool _isEditorInitialized = false;
  EventCallback? _eventCallback;
  JSFunction? _contextMenuEventListener;
  late final EditorEventManager _eventManager;

  final GlobalKey _editorKey = GlobalKey();
  double? _offset;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showAnimation = true;

  @override
  void initState() {
    super.initState();
    _registerHtmlFactory().then((_) => _loadJsLibraries());
    _eventManager = Get.find<EditorEventManager>();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.forward().then((_) {
          setState(() {
            _showAnimation = false;
          });
        });
      }
    });
  }

  double getCurrentOffset() {
    if (_editorKey.currentContext != null) {
      final RenderBox renderBox =
          _editorKey.currentContext!.findRenderObject() as RenderBox;
      final Offset position = renderBox.localToGlobal(Offset.zero);
      return position.dx;
    }
    return 0;
  }

  void _loadJsLibraries() {
    logger.i('_loadJsLibraries');
    final existingScript =
        web.document.querySelector('script[src="editor-library.min.js"]');
    if (existingScript != null) {
      logger.i('EditorLibrary already loaded');
      _initializeJavaScript();
      return;
    }

    final editorLibScript =
        web.document.createElement('script') as web.HTMLScriptElement
          ..src = 'editor-library.min.js'
          ..type = 'application/javascript';

    editorLibScript.onLoad.listen((_) {
      logger.i('EditorLibrary loaded successfully');
      _initializeJavaScript();
    });

    editorLibScript.onError.listen((event) {
      logger.e('Failed to load EditorLibrary: $event');
    });

    web.document.body!.append(editorLibScript);
  }

  Future<void> _registerHtmlFactory() {
    logger.i('_registerHtmlFactory loaded successfully');
    final container = web.document.createElement('div') as web.HTMLDivElement
      ..id = 'editor-container'
      ..style.width = '100%'
      ..style.height = '100%';

    final mainEditorContainer =
        web.document.createElement('div') as web.HTMLDivElement
          ..className = 'mainEditorContainer'
          ..id = 'editorParent';

    final opener = web.document.createElement('div') as web.HTMLDivElement
      ..id = 'opener';

    mainEditorContainer.appendChild(opener);
    container.appendChild(mainEditorContainer);
    viewType = '$viewType-${Random().nextInt(1000)}';
    logger
        .i('mainEditorContainer id---> ${mainEditorContainer.id} / $viewType');
    platformViewRegistry.registerViewFactory(
        viewType, (int viewId) => container);

    return Future.delayed(const Duration(milliseconds: 500));
  }

  void _initializeJavaScript() {
    try {
      final mainEditorContainer =
          web.document.getElementById('editorParent') as web.HTMLElement?;
      if (mainEditorContainer != null) {
        while (mainEditorContainer.children.length > 1) {
          final child = mainEditorContainer.lastElementChild;
          if (child?.id != 'opener') {
            child?.remove();
          }
        }
      }
    } catch (e) {
      logger.e('Error cleaning up mainEditorContainer: $e');
    }

    _eventCallback = EventCallback.create(
      onLoad: () {
        logger.i('Editor onLoad called');
        // _eventManager.emit(EditorEventType.onLoad, {'editor': editor});
        widget.onPageLoad?.call(editor);
      }.toJS,
      onUnload: () {
        logger.i('Editor onUnload called');
        // _eventManager.emit(EditorEventType.onUnload, {});
      }.toJS,
      onNoneSelected: () {
        logger.i('onNoneSelected');
        final html = editor.getHtmlString();
        widget.onNoneSelected?.call(html, '');
      }.toJS,
      onCaretSelected: ((JSAny node, JSAny offset) => _handleNodeSelection(
          node: node,
          callback: (value) {
            final html = editor.getHtmlString();
            widget.onCaretSelected?.call(value, html, '');
            // TODO :추후 해당 주석과 코드 제거(vulcan 엔진에서 생성되는 캡쳐 이미지의 시간차로 인해 이벤트가 늦게 전달되는 문제가 발생하여 캡쳐이미지 호출 함수 제거)
            // try {
            //   editor.capturePage().toDart.then((JSString capturePage) {
            //     _eventManager.emit(EditorEventType.onCaretSelected, {
            //       'node': value,
            //       'html': html,
            //       'capturePage': capturePage.toDart,
            //     });
            //     widget.onCaretSelected?.call(value, html, capturePage.toDart);
            //   }).catchError((error) {
            //     logger.e('Error capturing page: $error');
            //     widget.onCaretSelected?.call(value, html, '');
            //   });
            // } catch (e) {
            //   logger.e('Error: $e');
            //   widget.onCaretSelected?.call(value, html, '');
            // }
          })).toJS,
      onRangeSelected: (JSAny startNode, JSAny startOffset, JSAny focusNode,
          JSAny focusOffset) {
        logger.i('onRangeSelected');
        _eventManager.emit(EditorEventType.onRangeSelected, {
          'startNode': startNode.dartify(),
          'startOffset': startOffset.dartify(),
          'focusNode': focusNode.dartify(),
          'focusOffset': focusOffset.dartify(),
        });
      }.toJS,
      onSingleSelected: ((JSAny node) => _handleNodeSelection(
          node: node, callback: widget.onSingleSelected)).toJS,
      onMultiSelected: ((JSAny nodes) => _handleMultiSelection(
          nodes: nodes, callback: widget.onMultiSelected)).toJS,
      onCellSelected: ((JSAny node, JSAny nodes) => _handleCellSelection(
          node: node, nodes: nodes, callback: widget.onCellSelected)).toJS,
      onInsertElement: (JSAny element) {
        logger.i('Editor onInsertElement called ${element.toString()}');
        _eventManager.emit(EditorEventType.onInsertElement, {
          'element': element.dartify(),
        });
      }.toJS,
      onNodeRectChanged: ((JSArray<JSObject> nodeRects) =>
          _handleNodeRectChanged(
              nodeRects: nodeRects, callback: widget.onNodeRectChanged)).toJS,
      onNodeInserted: ((JSAny node) =>
              _handleNodeSelection(node: node, callback: widget.onNodeInserted))
          .toJS,
      onNodeRemoved: ((JSAny node) =>
              _handleNodeSelection(node: node, callback: widget.onNodeRemoved))
          .toJS,
      onUndoStackChanged: ((JSAny canUndo, JSAny canRedo) {
        widget.onUndoStackChanged?.call(
          canUndo.dartify() as bool,
          canRedo.dartify() as bool,
        );
      }).toJS,
      onPointerMove: ((JSAny editorX, JSAny editorY, JSAny windowX,
          JSAny windowY, JSAny isInEditor) {
        // debugPrint('onPointerMove');
        // debugPrint('editorX: ${editorX.dartify()}');
        // debugPrint('editorY: ${editorY.dartify()}');
        // debugPrint('windowX: ${windowX.dartify()}');
        // debugPrint('windowY: ${windowY.dartify()}');
        // debugPrint('isInEditor: ${isInEditor.dartify()}');
        widget.onPointerMove?.call(
          editorX.dartify() as double,
          editorY.dartify() as double,
          windowX.dartify() as double,
          windowY.dartify() as double,
          isInEditor.dartify() as bool,
        );
      }).toJS,
      onWidgetSelectionChanged: ((JSWidgetInfo widgetInfo) {
        logger.i('onWidgetSelectionChanged');

        if (widgetInfo.id.dartify() as String == '') {
          return;
        }

        final nodeInfo = EditorHtmlNode.fromNode(widgetInfo.widget);
        final id = widgetInfo.id.dartify() as String;
        final properties = widgetInfo.getAllProperties();

        _eventManager.emit(EditorEventType.onWidgetSelectionChanged, {
          'node': nodeInfo,
          'id': id,
          'properties': properties,
        });

        widget.onWidgetSelectionChanged?.call(
          nodeInfo,
          id,
          properties,
        );
      }).toJS,
      onFrameClick: (() {
        widget.onFrameClick?.call();
      }).toJS,
      onDocumentChanged: ((JSAny node) => _handleNodeSelection(
          node: node, callback: widget.onDocumentChanged)).toJS,
    );

    final editorParent = web.document.getElementById('editorParent');
    editor = editorConstructor.callAsConstructorVarArgs([
      editorParent,
      _eventCallback,
      true.toJS, // showRuler
      true.toJS, // showGrid
      true.toJS, // snapToGrid
      100.toJS, // gridGap
      widget.langUrl.toJS, // lang
      widget.fontUrl.toJS, // /fonts/mois/font.json
      widget.baseUrl.toJS // baseUrl
    ]) as Editor;

    _isEditorInitialized = true;
    widget.onLoad?.call(editor);

    _contextMenuEventListener = ((web.Event event) {
      event.preventDefault();
    }).toJS;

    web.document.addEventListener('contextmenu', _contextMenuEventListener!);
  }

  void _updateEditorPosition() {
    if (!_isEditorInitialized) {
      logger.i('Editor not initialized yet');
      return;
    }

    try {
      editor.updateEditorPosition();
    } catch (e) {
      logger.e('Failed to update editor position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _editorKey,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final newOffset = getCurrentOffset();
          if (_offset != newOffset && _isEditorInitialized) {
            _offset = newOffset;
            _updateEditorPosition();
          }
        });
        return GestureDetector(
            onSecondaryTapDown: (details) => _showContextMenu(context, details),
            onTapDown: (_) => _removeContextMenu(),
            child: Stack(
              children: [
                HtmlElementView(viewType: viewType),
                if (_showAnimation)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CommonAssets.image.animationBook.image(
                                width: 200, height: 200, fit: BoxFit.fill),
                            const SizedBox(height: 8),
                            const CircularProgressIndicator()
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ));
      }),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();

    if (_isEditorInitialized) {
      // context menu 이벤트 리스너 제거
      if (_contextMenuEventListener != null) {
        web.document
            .removeEventListener('contextmenu', _contextMenuEventListener!);
        _contextMenuEventListener = null;
      }

      // editor 요소들 정리
      try {
        // script 태그 제거
        final scriptElement =
            web.document.querySelector('script[src="editor-library.min.js"]');
        scriptElement?.remove();

        // editor container 정리
        final mainEditorContainer =
            web.document.getElementById('editorParent') as web.HTMLElement?;
        if (mainEditorContainer != null) {
          while (mainEditorContainer.hasChildNodes()) {
            final child = mainEditorContainer.firstChild;
            if (child != null) {
              mainEditorContainer.removeChild(child);
            }
          }
        }
      } catch (e) {
        logger.e('Error cleaning up elements: $e');
      }

      // EventCallback 정리
      _eventCallback = null;

      editor.unload();
      _isEditorInitialized = false;
    }

    super.dispose();
  }

  void _handleNodeSelection({
    required JSAny node,
    required Function(EditorHtmlNode)? callback,
  }) {
    if (callback == null || !_isEditorInitialized) return;

    try {
      final nodeElement = node.dartify() as web.Node;
      final nodeInfo = EditorHtmlNode.fromNode(nodeElement);
      _eventManager.emit(EditorEventType.onSingleSelected, {
        'node': nodeInfo,
      });
      callback(nodeInfo);
    } catch (e) {
      logger.e('Error handling node selection: $e');
    }
  }

  void _handleCellSelection({
    required JSAny node,
    required JSAny nodes,
    required Function(EditorHtmlNode, List<EditorHtmlNode>)? callback,
  }) {
    if (callback == null || !_isEditorInitialized) return;

    try {
      final nodesList = nodes.dartify() as List;
      final List<EditorHtmlNode> htmlNodes = [];

      for (var node in nodesList) {
        final nodeElement = node as web.Node;
        final nodeInfo = EditorHtmlNode.fromNode(nodeElement);
        htmlNodes.add(nodeInfo);
      }

      final nodeElement = node.dartify() as web.Node;
      final nodeItem = EditorHtmlNode.fromNode(nodeElement);
      _eventManager.emit(EditorEventType.onCellSelected, {
        'node': nodeItem,
        'nodes': htmlNodes,
      });
      callback(nodeItem, htmlNodes);
    } catch (e) {
      logger.e('Error handling multi selection: $e');
    }
  }

  void _handleNodeRectChanged({
    required JSArray<JSObject> nodeRects,
    required Function(List<EditorHtmlNodeRect>)? callback,
  }) {
    if (callback == null || !_isEditorInitialized) return;

    try {
      final List<EditorHtmlNodeRect> htmlNodeRects = [];
      final dartNodeRects = nodeRects.toDart;
      for (var i = 0; i < dartNodeRects.length; i++) {
        final jsRect = dartNodeRects[i] as NodeRect;
        htmlNodeRects.add(EditorHtmlNodeRect.fromJS(jsRect));
      }

      _eventManager.emit(EditorEventType.onNodeRectChanged, {
        'nodeRects': htmlNodeRects,
      });
      callback(htmlNodeRects);
    } catch (e) {
      logger.e('Error handling Node Rect Changed: $e');
    }
  }

  void _handleMultiSelection({
    required JSAny nodes,
    required Function(List<EditorHtmlNode>)? callback,
  }) {
    if (callback == null || !_isEditorInitialized) return;

    try {
      final nodesList = nodes.dartify() as List;
      final List<EditorHtmlNode> htmlNodes = [];

      for (var node in nodesList) {
        final nodeElement = node as web.Node;
        final nodeInfo = EditorHtmlNode.fromNode(nodeElement);
        htmlNodes.add(nodeInfo);
      }
      _eventManager.emit(EditorEventType.onMultiSelected, {
        'nodes': htmlNodes,
      });
      callback(htmlNodes);
    } catch (e) {
      logger.e('Error handling multi selection: $e');
    }
  }

  OverlayEntry? _contextMenuOverlay;
  Offset _contextMenuPosition = Offset.zero;

  void _showContextMenu(BuildContext context, TapDownDetails details) {
    _removeContextMenu();

    _contextMenuPosition = details.globalPosition;
    _contextMenuOverlay = OverlayEntry(
      builder: (context) => EditorContextMenu(
        position: _contextMenuPosition,
        onTap: (option) {
          _removeContextMenu();
          editor.setZindex(option);
        },
      ),
    );

    Overlay.of(context).insert(_contextMenuOverlay!);
  }

  void _removeContextMenu() {
    _contextMenuOverlay?.remove();
    _contextMenuOverlay = null;
  }

  // 드로잉 관련 함수
  bool isDrawingModeEnabled() {
    final result = editor.isDrawingModeEnabled();
    return result;
  }

  void toggleDrawingMode(String type) {
    editor.toggleDrawingMode(type);
  }

  void clearDrawing() {
    editor.clearDrawing();
  }
}
