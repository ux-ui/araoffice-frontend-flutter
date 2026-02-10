import 'package:app_ui/app_ui.dart';
import 'package:author_editor/enum/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'items.dart';

class ImagePopupMenuItem extends StatelessWidget {
  final String? label;
  final Color backgroundColor;
  final Offset offset;
  final Widget? menuIcon;
  final double buttonWidth;
  final double buttonHeight;
  final double popupWidth;
  final double popupHeight;
  final Widget? child;
  final Widget? prefixIcon;
  final String? iconPath;
  final ObjectType? type;
  final ObjectType? type2;
  // final ObjectType? backgroundType;
  final VoidCallback onChanged;
  final VoidCallback? onCanceled;

  const ImagePopupMenuItem({
    super.key,
    this.label,
    this.backgroundColor = Colors.white,
    this.offset = const Offset(-300, 5),
    this.menuIcon,
    this.buttonWidth = double.infinity,
    this.buttonHeight = 40,
    this.popupWidth = 300,
    this.popupHeight = 500,
    this.child,
    this.prefixIcon,
    this.iconPath,
    this.type,
    this.type2,
    // this.backgroundType,
    required this.onChanged,
    this.onCanceled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(label!),
              if (prefixIcon != null) ...[
                const SizedBox(width: 8.0),
                prefixIcon!,
              ],
            ],
          ),
          const SizedBox(height: 8.0),
        ],
        VulcanXPopupMenu(
          backgroundColor: backgroundColor,
          offset: offset,
          icon: VulcanXOutlinedButton.icon(
            width: buttonWidth,
            height: buttonHeight,
            icon: menuIcon ?? const Icon(Icons.more_horiz),
            iconAlignment: IconAlignment.end,
            onPressed: null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(
                width: 200,
                child: Text(
                  iconPath ?? '',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          onTap: () => onChanged(),
          onCanceled: () => onCanceled?.call(),
          items: [
            VulcanXPopupMenuItem(
              enabled: false,
              child: PointerInterceptor(
                child: SizedBox(
                  width: popupWidth,
                  height: popupHeight,
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      SizedBox(
                        height: popupHeight - 60,
                        child: SingleChildScrollView(
                          child: child ??
                              ImageItem(
                                type: type,
                                type2: type2,
                                // backgroundType: backgroundType,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 수정된 부분: context 유효성 검사 추가
                      Builder(
                        builder: (builderContext) {
                          return VulcanXOutlinedButton(
                            width: double.infinity,
                            onPressed: () {
                              // context가 여전히 유효하고 mounted 상태인지 확인
                              if (builderContext.mounted) {
                                try {
                                  Navigator.pop(builderContext);
                                } catch (e) {
                                  debugPrint('Error closing popup: $e');
                                  // 대안적 방법으로 Get.back() 사용
                                  if (Get.isDialogOpen == true ||
                                      Get.isBottomSheetOpen == true) {
                                    Get.back();
                                  }
                                }
                              }
                            },
                            child: Text('close'.tr),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
