import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class EditorDocumentSetting extends StatefulWidget {
  final String width;
  final String height;
  final ValueChanged<bool> onShowGrid;
  final ValueChanged<bool> onShowRuler;
  final ValueChanged<bool> onEnableSnapToGrid;
  final ValueChanged<String> onChangedWidth;
  final ValueChanged<String> onChangedHeight;
  final ValueChanged<bool> onMenuStateChanged;
  const EditorDocumentSetting({
    super.key,
    required this.width,
    required this.height,
    required this.onShowGrid,
    required this.onShowRuler,
    required this.onEnableSnapToGrid,
    required this.onChangedWidth,
    required this.onChangedHeight,
    required this.onMenuStateChanged,
  });

  @override
  State<EditorDocumentSetting> createState() => _EditorDocumentSettingState();
}

class _EditorDocumentSettingState extends State<EditorDocumentSetting> {
  final width = '600'.obs;
  final height = '800'.obs;

  @override
  void initState() {
    super.initState();
    width.value = widget.width;
    height.value = widget.height;
  }

  @override
  void didUpdateWidget(EditorDocumentSetting oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 기존 코드를 WidgetsBinding.instance.addPostFrameCallback으로 감싸기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (width.value != widget.width) {
        width.value = widget.width;
      }
      if (height.value != widget.height) {
        height.value = widget.height;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'document_setting'.tr,
      child: PopupMenuBar(
        content: _buildMoreMenuContent(context),
        child: CommonAssets.icon.moreMenuIcon.svg(),
        onMenuStateChanged: (showMenu) async {
          if (showMenu == true) {
            widget.onMenuStateChanged.call(true);
          }
          return true;
        },
      ),
    );
  }

  Widget _buildMoreMenuContent(BuildContext context) {
    return VulcanXRoundedContainer(
      width: 240,
      isBoxShadow: true,
      child: PointerInterceptor(
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                //문서 설정
                child: Text('document_setting'.tr, style: context.titleSmall),
              ),
              const HorDivider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => VulcanXLabelTextField(
                        label: 'width'.tr,
                        textFieldWidth: 150,
                        unit: 'px',
                        initialValue: width.value,
                        textAlign: TextAlign.right,
                        onChanged: (value) => widget.onChangedWidth.call(value),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => VulcanXLabelTextField(
                        label: 'height'.tr,
                        textFieldWidth: 150,
                        unit: 'px',
                        initialValue: height.value,
                        textAlign: TextAlign.right,
                        onChanged: (value) =>
                            widget.onChangedHeight.call(value),
                      ),
                    ),
                  ],
                ),
              ),
              const HorDivider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 눈금자 보이기
                    LabelRectangleCheckbox(
                        label: 'show_ruler'.tr,
                        isChecked: true,
                        onChanged: (value) => widget.onShowRuler.call(value)),
                    const SizedBox(height: 8),
                    // 눈금선 보이기
                    LabelRectangleCheckbox(
                        label: 'show_grid'.tr,
                        isChecked: true,
                        onChanged: (value) => widget.onShowGrid.call(value)),
                    const SizedBox(height: 8),
                    // 눈금선에 끌어당김
                    LabelRectangleCheckbox(
                        label: 'grid_snap'.tr,
                        isChecked: true,
                        onChanged: (value) =>
                            widget.onEnableSnapToGrid.call(value))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
