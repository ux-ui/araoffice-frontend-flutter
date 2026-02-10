import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../app_ui.dart';

// 컨트롤러 클래스 추가
class PopupMenuBarController {
  VoidCallback? _closeCallback;

  void close() {
    _closeCallback?.call();
  }

  void _attach(VoidCallback closeCallback) {
    _closeCallback = closeCallback;
  }

  void _detach() {
    _closeCallback = null;
  }
}

class PopupMenuBar extends StatefulWidget {
  final Widget child;
  final Widget content;
  final AlignmentGeometry? alignmentGeometry;
  final Future<bool?> Function(bool)? onMenuStateChanged;
  final PopupMenuBarController? controller; // 컨트롤러 추가

  const PopupMenuBar({
    super.key,
    required this.child,
    required this.content,
    this.alignmentGeometry,
    this.onMenuStateChanged,
    this.controller,
  });

  @override
  State<PopupMenuBar> createState() => PopupMenuBarState();
}

class PopupMenuBarState extends State<PopupMenuBar> {
  bool _showMenu = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(removeOverlay);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    removeOverlay();
    super.dispose();
  }

  Future<void> _toggleOverlay() async {
    final showMenuFuture = !_showMenu;
    if (showMenuFuture) {
      final canShow = await widget.onMenuStateChanged?.call(true);
      if (canShow == false) {
        _showMenu = false;
        removeOverlay();
        return;
      }
    } else {
      widget.onMenuStateChanged?.call(false);
    }

    setState(() {
      _showMenu = !_showMenu;
      if (_showMenu) {
        _showOverlay();
      } else {
        removeOverlay();
      }
    });
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_showMenu) {
      setState(() {
        _showMenu = false;
        widget.onMenuStateChanged?.call(false);
      });
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // alignmentGeometry를 기반으로 offset 계산
    final alignment = widget.alignmentGeometry ?? Alignment.bottomRight;
    const popupWidth = 250.0;

    Offset offset;
    if (alignment == Alignment.bottomLeft) {
      offset = Offset(-popupWidth, size.height);
    } else if (alignment == Alignment.bottomRight) {
      offset = Offset(size.width, size.height);
    } else if (alignment == Alignment.topLeft) {
      offset = const Offset(-popupWidth, 0);
    } else if (alignment == Alignment.topRight) {
      offset = Offset(size.width, 0);
    } else if (alignment == Alignment.centerLeft) {
      offset = Offset(-popupWidth, size.height / 2);
    } else if (alignment == Alignment.centerRight) {
      offset = Offset(size.width, size.height / 2);
    } else if (alignment == Alignment.bottomCenter) {
      offset = Offset((size.width - popupWidth) / 2, size.height);
    } else if (alignment == Alignment.topCenter) {
      offset = Offset((size.width - popupWidth) / 2, 0);
    } else {
      // 기본값: bottomRight
      offset = Offset(size.width, size.height);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => PointerInterceptor(
        child: GestureDetector(
          onTap: removeOverlay,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned(
                width: popupWidth,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: offset,
                  child: widget.content,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: VulcanXInkWell(
        onTap: _toggleOverlay,
        child: widget.child,
      ),
    );
  }
}
