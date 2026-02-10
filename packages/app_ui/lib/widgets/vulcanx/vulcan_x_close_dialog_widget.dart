import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../app_ui.dart';

enum VulcanCloseDialogType { ok, cancel, close }

class VulcanCloseDialogWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget content;
  late final String confirmText;
  late final String cancelText;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isShowClose;
  final bool isShowConfirm;
  final bool isShowCancel;

  // 다이얼로그를 닫기 위한 BuildContext 저장
  BuildContext? _dialogContext;

  VulcanCloseDialogWidget({
    this.title,
    this.titleWidget,
    required this.content,
    String? confirmText,
    String? cancelText,
    this.width,
    this.height,
    this.borderRadius = 16.0,
    this.isShowClose = true,
    this.isShowConfirm = false,
    this.isShowCancel = false,
  }) {
    this.confirmText = confirmText ?? 'confirm'.tr;
    this.cancelText = cancelText ?? 'cancel'.tr;
  }

  // 외부에서 다이얼로그를 닫을 수 있는 메서드
  void close([VulcanCloseDialogType type = VulcanCloseDialogType.close]) {
    if (_dialogContext != null) {
      Navigator.of(_dialogContext!).pop(type);
    }
  }

  Future<VulcanCloseDialogType?> show(BuildContext context) async {
    return await showDialog<VulcanCloseDialogType>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // BuildContext 저장
        _dialogContext = dialogContext;

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: PointerInterceptor(
            child: Container(
              width: width,
              height: height,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: title != null
                            ? Text(
                                title!,
                                style: context.titleMedium
                                    ?.apply(color: context.onSurface),
                              )
                            : titleWidget ?? const SizedBox(),
                      ),
                      if (isShowClose)
                        IconButton(
                          iconSize: 20,
                          icon: const Icon(Icons.close),
                          onPressed: () => close(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  content,
                  if (isShowConfirm || isShowCancel) ...[
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isShowCancel)
                          TextButton(
                            child: Text(cancelText),
                            onPressed: () =>
                                close(VulcanCloseDialogType.cancel),
                          ),
                        if (isShowConfirm)
                          TextButton(
                            child: Text(confirmText),
                            onPressed: () => close(VulcanCloseDialogType.ok),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
