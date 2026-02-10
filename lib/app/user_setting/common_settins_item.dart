import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final Widget title;
  final String? subTitle;
  final String? subTitle2;
  final Widget? action;
  final VoidCallback? onTap;
  final bool border;
  final EdgeInsetsGeometry? padding;

  const SettingsItem(
      {super.key,
      required this.title,
      this.subTitle,
      this.subTitle2,
      this.onTap,
      this.border = false,
      this.action,
      this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: border
            ? Border(bottom: BorderSide(color: Colors.grey[300]!))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 8),
              subTitle?.isNotEmpty ?? false
                  ? Text(
                      subTitle!,
                      style: context.bodySmall
                          ?.apply(color: context.outlineVariant),
                    )
                  : const SizedBox(),
              const SizedBox(height: 8),
              subTitle2?.isNotEmpty ?? false
                  ? Text(
                      subTitle2!,
                      style: context.bodySmall
                          ?.apply(color: context.outlineVariant),
                    )
                  : const SizedBox()
            ],
          ),
          if (action != null) ...[action!],
        ],
      ),
    );
  }
}
