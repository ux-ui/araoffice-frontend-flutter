import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item/items.dart';
import '../vulcan_editor_eventbus.dart';

class ElementPanel extends StatefulWidget {
  /// 요소 패널
  const ElementPanel({super.key});

  @override
  State<ElementPanel> createState() => _ElementPanelState();
}

class _ElementPanelState extends State<ElementPanel> with EditorEventbus {
  // 지연 로딩을 위한 캐싱
  Widget? _symbolWidget;
  Widget? _shapeWidget;

  late final List<WrapExpanstionPanelItem> _data = [
    WrapExpanstionPanelItem(
        //글상자
        headerValue: "text_box".tr,
        child: TextBoxItem()),
    WrapExpanstionPanelItem(
        //표
        headerValue: "table".tr,
        child: TableItem()),
    WrapExpanstionPanelItem(
        //이미지
        headerValue: "image".tr,
        child: ImageItem(
          visibleGovElementLogo: controller.govElementLogoStatus.value,
        )),
    WrapExpanstionPanelItem(
        //비디오
        headerValue: "video".tr,
        child: VideoItem()),
    WrapExpanstionPanelItem(
        //오디오
        headerValue: "audio".tr,
        child: AudioItem()),
    WrapExpanstionPanelItem(
        //기호 - 지연 로딩
        headerValue: "symbol".tr,
        child: _LazyWidget(
          builder: () {
            _symbolWidget ??= SymbolItem();
            return _symbolWidget!;
          },
          placeholder: Container(
            height: 60,
            alignment: Alignment.center,
            child:
                // 로딩 중...
                Text("loading".tr, style: const TextStyle(color: Colors.grey)),
          ),
        )),
    if (controller.mathMenuStatus.value)
      WrapExpanstionPanelItem(
          //수식
          headerValue: "math".tr,
          child: MathItem()),
    WrapExpanstionPanelItem(
        //도형 - 지연 로딩
        headerValue: "shape".tr,
        child: _LazyWidget(
          builder: () {
            _shapeWidget ??= ShapeItem();
            return _shapeWidget!;
          },
          placeholder: Container(
            height: 60,
            alignment: Alignment.center,
            child:
                Text("loading".tr, style: const TextStyle(color: Colors.grey)),
          ),
        )),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // TODO ____ 추후 적용 ___
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   color: context.surface,
            //   child: Column(
            //     children: [
            //       VulcanXButtonSelector(
            //         options: const ['요소', '위젯'],
            //         onSelected: (index) {},
            //       ),
            //       const SizedBox(height: 8),
            //       const VulcanXTextField(hintText: '요소 검색', isSearchIcon: true),
            //     ],
            //   ),
            // ),
            Expanded(
              child: SingleChildScrollView(
                  key: const PageStorageKey<String>('element_panel'),
                  child: WrapExpansionPanelList(data: _data)),
            ),
          ],
        ),
        // Obx(
        //   () => controller.rxIsEditorStatus.value
        //       ? const SizedBox.shrink()
        //       : Container(
        //           height: double.infinity,
        //           color: Colors.grey.withAlpha(128),
        //         ),
        // ),
      ],
    );
  }
}

// 지연 로딩 위젯
class _LazyWidget extends StatefulWidget {
  final Widget Function() builder;
  final Widget placeholder;

  const _LazyWidget({
    required this.builder,
    required this.placeholder,
  });

  @override
  State<_LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<_LazyWidget> {
  Widget? _builtWidget;
  bool _isBuilding = false;

  @override
  void initState() {
    super.initState();
    // 위젯이 화면에 나타난 후 지연 빌드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildWidget();
    });
  }

  Future<void> _buildWidget() async {
    if (_isBuilding || _builtWidget != null) return;

    setState(() {
      _isBuilding = true;
    });

    // 짧은 지연으로 UI 우선 렌더링
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final builtWidget = widget.builder();
      if (mounted) {
        setState(() {
          _builtWidget = RepaintBoundary(child: builtWidget);
          _isBuilding = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _builtWidget = Container(
            height: 60,
            alignment: Alignment.center,
            // 로딩 실패
            child: Text('loading_failed'.tr,
                style: const TextStyle(color: Colors.red)),
          );
          _isBuilding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_builtWidget != null) {
      return _builtWidget!;
    }

    if (_isBuilding) {
      return Container(
        height: 60,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text("loading".tr, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return widget.placeholder;
  }
}
