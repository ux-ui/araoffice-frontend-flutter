import 'package:flutter/material.dart';

import '../../app_ui.dart';

class BtoBottomSheet extends StatelessWidget {
  final Widget? header;
  final Widget? body;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? bottomPadding;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final String? bottomBtn;
  final Function? bottomOnPressed;
  final Function? onClosedBtnPressed;
  final bool? isFull;
  final bool isDraggable;
  final bool isBottomBtn;
  final bool isClosedBtn;
  final bool automaticallyImplyHeader;

  const BtoBottomSheet({
    super.key,
    this.header,
    this.body,
    this.height,
    this.padding,
    this.contentPadding,
    this.headerPadding,
    this.bottomPadding,
    this.borderRadius,
    this.backgroundColor,
    this.bottomBtn,
    this.bottomOnPressed,
    this.onClosedBtnPressed,
    this.isFull,
    this.isDraggable = true,
    this.isBottomBtn = true,
    this.isClosedBtn = false,
    this.automaticallyImplyHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter bottomState) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius ??
              const BorderRadius.vertical(
                top: Radius.circular(20.0),
              ),
          color: backgroundColor ?? Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
                width: 40,
                height: 6,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    color: Color(0xFF79747E))),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
                width: double.maxFinite,
                height: height ?? 450,
                child: Column(
                  children: [
                    automaticallyImplyHeader
                        ? _buildHeader(context)
                        : const SizedBox(),
                    Expanded(
                      child: SingleChildScrollView(
                          physics: isDraggable
                              ? const AlwaysScrollableScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          child: Padding(
                            padding:
                                contentPadding ?? const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                body ?? const SizedBox(),
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    isBottomBtn
                        ? Column(
                            children: [
                              BottomButton(
                                text: bottomBtn,
                                bottomPadding: bottomPadding,
                                onPressed: () {
                                  bottomOnPressed?.call();
                                },
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                )),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: headerPadding ?? const EdgeInsets.all(8.0),
          child: header ?? const SizedBox(),
        ),
        isClosedBtn
            ? Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    onClosedBtnPressed?.call();
                  },
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class BottomButton extends StatelessWidget {
  final String? text;
  final Function? onPressed;
  final EdgeInsetsGeometry? bottomPadding;
  const BottomButton(
      {this.text, this.onPressed, this.bottomPadding, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, color: Colors.black12),
        Padding(
          padding: bottomPadding ?? const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              onPressed?.call();
            },
            child: Text(
              text ?? '닫기',
              style: context.bodyLarge
                  ?.apply(color: context.onSurfaceVariant.withAlpha(179)),
            ),
          ),
        )
      ],
    );
  }
}
