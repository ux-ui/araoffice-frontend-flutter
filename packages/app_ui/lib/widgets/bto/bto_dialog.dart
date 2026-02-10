import 'package:flutter/material.dart';

import '../../app_ui.dart';

class BtoDialog extends StatelessWidget {
  final String? title;
  final double? width;
  final Widget? titleWidget;
  final Widget message;
  final double buttonHeight;
  final String? textConfirm;
  final String? textCancel;
  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry closePadding;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry buttonPadding;
  final bool? closeIcon;
  final Function? onCancel;
  final Function? onConfirm;
  final Color? backgroundColor;
  final Color? confirmTextColor;

  const BtoDialog({
    super.key,
    this.title,
    this.titleWidget,
    required this.message,
    this.buttonHeight = 45,
    this.textConfirm,
    this.textCancel,
    this.titlePadding = const EdgeInsets.only(top: 22, left: 24),
    this.closePadding = const EdgeInsets.only(top: 22, right: 24),
    this.contentPadding = const EdgeInsets.all(20),
    this.buttonPadding = const EdgeInsets.only(top: 20),
    this.onCancel,
    this.onConfirm,
    this.backgroundColor,
    this.confirmTextColor,
    this.closeIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: backgroundColor ?? context.background,
      ),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (titleWidget != null) titleWidget!,
          if (titleWidget == null && title != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: titlePadding,
                  child: Text(
                    title ?? '',
                    style:
                        context.titleLarge?.apply(color: context.onBackground),
                  ),
                ),
                Padding(
                    padding: closePadding,
                    child: IconButton(
                        onPressed: () {
                          if (onCancel != null) onCancel?.call();
                        },
                        icon: const Icon(Icons.close, color: Colors.black)))
              ],
            ),
          Padding(
            padding: contentPadding,
            child: message,
          ),
          if (textConfirm != null || textCancel != null)
            const Divider(height: 1, color: Colors.black12),
          Row(
            children: [
              if (textCancel != null)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (onCancel != null) onCancel?.call();
                    },
                    child: SizedBox(
                      height: buttonHeight,
                      child: Center(
                        child: Text(textCancel!,
                            style: context.bodyLarge
                                ?.apply(color: context.onSurfaceVariant)),
                      ),
                    ),
                  ),
                ),
              if (textCancel != null)
                SizedBox(
                  height: buttonHeight,
                  child: const VerticalDivider(width: 1, color: Colors.black12),
                ),
              if (textConfirm != null)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      onConfirm?.call();
                    },
                    child: SizedBox(
                      height: buttonHeight,
                      child: Center(
                        child: Text(
                          textConfirm!,
                          style: context.bodyLarge?.apply(
                            color: confirmTextColor ?? context.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
