import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

// 드래그 가능한 플로팅 팝업 메뉴 바 위젯
class DraggablePopupMenuBar extends StatefulWidget {
  final List<Widget> menuItems; // 메뉴에 표시될 위젯들
  final Offset initialPosition; // 초기 위치
  final RxBool? isInteracting;

  const DraggablePopupMenuBar({
    Key? key,
    required this.menuItems,
    this.initialPosition = const Offset(50, 50), // 기본 초기 위치
    this.isInteracting,
  }) : super(key: key);

  @override
  State<DraggablePopupMenuBar> createState() => _DraggablePopupMenuBarState();
}

class _DraggablePopupMenuBarState extends State<DraggablePopupMenuBar> {
  late Offset _currentPosition;
  final _localInteracting = false.obs;
  Size? _screenSize;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateScreenSize();
        _clampPosition();
      }
    });
  }

  @override
  void didUpdateWidget(DraggablePopupMenuBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPosition != widget.initialPosition) {
      _currentPosition = widget.initialPosition;
      _clampPosition();
    }
  }

  void _updateScreenSize() {
    final context = this.context;
    if (context.mounted) {
      setState(() {
        _screenSize = MediaQuery.of(context).size;
        _clampPosition();
      });
    }
  }

  void _clampPosition() {
    if (_screenSize == null) return;

    final maxWidth = _screenSize!.width - 100;
    final maxHeight = _screenSize!.height - 50;

    if (maxWidth <= 0 || maxHeight <= 0) return;

    setState(() {
      _currentPosition = Offset(
        _currentPosition.dx.clamp(0.0, maxWidth),
        _currentPosition.dy.clamp(0.0, maxHeight),
      );
    });
  }

  bool get isInteracting =>
      widget.isInteracting?.value ?? _localInteracting.value;

  void setInteracting(bool value) {
    if (widget.isInteracting != null) {
      widget.isInteracting!.value = value;
    } else {
      _localInteracting.value = value;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!mounted) return;

    setState(() {
      final newPosition = _currentPosition + details.delta;
      _currentPosition = Offset(
        newPosition.dx.clamp(0.0, (_screenSize?.width ?? 0) - 100),
        newPosition.dy.clamp(0.0, (_screenSize?.height ?? 0) - 50),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_screenSize == null) {
      _screenSize = MediaQuery.of(context).size;
    }

    return Positioned(
      left: _currentPosition.dx,
      top: _currentPosition.dy,
      child: PointerInterceptor(
        intercepting: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: GestureDetector(
            onPanUpdate: _handlePanUpdate,
            child: Material(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey[300]!, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('co_op_editing'.tr,
                        style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.menuItems,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
