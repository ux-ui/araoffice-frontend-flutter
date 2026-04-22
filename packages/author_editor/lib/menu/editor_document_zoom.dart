import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class EditorDocumentZoom extends StatefulWidget {
  const EditorDocumentZoom({super.key});

  @override
  State<EditorDocumentZoom> createState() => _EditorDocumentZoomState();
}

class _EditorDocumentZoomState extends State<EditorDocumentZoom>
    with EditorEventbus {
  static const double _minZoom = 0.25;
  static const double _maxZoom = 5.0;
  static const List<int> _presets = [50, 70, 90, 100, 125, 150, 200];

  // 뷰포트 내부 여백 (눈금자 + 패딩)
  static const double _viewportPaddingH = 100.0;
  static const double _viewportPaddingV = 40.0;

  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _popupController = PopupMenuBarController();
  bool _isEditing = false;
  Worker? _initialFitWorker;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    // 뷰포트 크기가 확보되면 최초 1회 '쪽 맞춤' 적용
    _initialFitWorker = ever(controller.rxViewportWidth, (width) {
      if (width > 0 && controller.rxViewportHeight.value > 0) {
        _applyFitToPage();
        _initialFitWorker?.dispose();
        _initialFitWorker = null;
      }
    });
  }

  @override
  void dispose() {
    _initialFitWorker?.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      setState(() => _isEditing = false);
    }
  }

  void _enterEditMode() {
    final currentPercent = (controller.rxZoomValue.value * 100).round();
    _textController.text = '$currentPercent';
    _textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _textController.text.length,
    );
    setState(() => _isEditing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onTextSubmitted(String text) {
    final parsed = int.tryParse(text);
    if (parsed != null) {
      final clamped = parsed.clamp(25, 500);
      controller.scale(clamped / 100.0);
    }
    setState(() => _isEditing = false);
  }

  void _applyFitToPage() {
    final vw = controller.rxViewportWidth.value - _viewportPaddingH;
    final vh = controller.rxViewportHeight.value - _viewportPaddingV;
    final dw = controller.documentState.rxDocumentSizeWidth.value.toDouble();
    final dh = controller.documentState.rxDocumentSizeHeight.value.toDouble();
    if (dw <= 0 || dh <= 0 || vw <= 0 || vh <= 0) return;
    final factor = math.min(vw / dw, vh / dh).clamp(_minZoom, _maxZoom);
    controller.scale(factor);
  }

  void _applyFitToWidth() {
    final vw = controller.rxViewportWidth.value - _viewportPaddingH;
    final dw = controller.documentState.rxDocumentSizeWidth.value.toDouble();
    if (dw <= 0 || vw <= 0) return;
    final factor = (vw / dw).clamp(_minZoom, _maxZoom);
    controller.scale(factor);
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'fit_page':
        _applyFitToPage();
        break;
      case 'fit_width':
        _applyFitToWidth();
        break;
      default:
        final percent = int.tryParse(value);
        if (percent != null) {
          controller.scale(percent / 100.0);
        }
    }
    _popupController.close();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Tooltip(
      message: 'zoom'.tr,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 배율 텍스트 표시 / 입력 영역
            SizedBox(
              width: 64,
              child: _isEditing ? _buildTextField(themeData) : _buildDisplay(),
            ),
            // 드롭다운 화살표
            PopupMenuBar(
              controller: _popupController,
              alignmentGeometry: Alignment.bottomCenter,
              content: _buildDropdownContent(themeData),
              onMenuStateChanged: (showMenu) async {
                // 드롭다운 열릴 때 편집 모드 해제
                if (showMenu && _isEditing) {
                  setState(() => _isEditing = false);
                }
                return true;
              },
              child: Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: themeData.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return GestureDetector(
      onTap: _enterEditMode,
      child: Center(
        child: Obx(
          () => Text(
            '${(controller.rxZoomValue.value * 100).round()}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeData themeData) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          setState(() => _isEditing = false);
        }
      },
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        style: themeData.textTheme.bodySmall,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4),
          isDense: true,
        ),
        onSubmitted: _onTextSubmitted,
      ),
    );
  }

  Widget _buildDropdownContent(ThemeData themeData) {
    return VulcanXRoundedContainer(
      width: 64,
      isBoxShadow: true,
      child: PointerInterceptor(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDropdownItem('fit_to_page'.tr, 'fit_page', themeData),
            _buildDropdownItem('fit_to_width'.tr, 'fit_width', themeData),
            const Divider(height: 1),
            ..._presets.map(
              (v) => _buildDropdownItem(
                'percent'.trArgs(['$v']),
                '$v',
                themeData,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem(String label, String value, ThemeData themeData) {
    return _HoverableMenuItem(
      label: label,
      style: themeData.textTheme.bodyMedium,
      onTap: () => _onMenuItemSelected(value),
    );
  }
}

/// 마우스오버 강조 효과가 있는 드롭다운 메뉴 아이템
class _HoverableMenuItem extends StatefulWidget {
  final String label;
  final TextStyle? style;
  final VoidCallback onTap;

  const _HoverableMenuItem({
    required this.label,
    this.style,
    required this.onTap,
  });

  @override
  State<_HoverableMenuItem> createState() => _HoverableMenuItemState();
}

class _HoverableMenuItemState extends State<_HoverableMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: _isHovered
              ? Theme.of(context).colorScheme.primary.withAlpha(30)
              : null,
          child: Text(widget.label, style: widget.style),
        ),
      ),
    );
  }
}
