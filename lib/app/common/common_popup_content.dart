import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class CommonPopupContent extends StatefulWidget {
  final String? title;
  final Widget? headerWidget;
  final String message;
  final Function onConfirm;
  const CommonPopupContent(
      {this.title,
      this.headerWidget,
      required this.message,
      required this.onConfirm,
      super.key});

  @override
  State<CommonPopupContent> createState() => _CommonPopupContentState();
}

class _CommonPopupContentState extends State<CommonPopupContent> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 300,
        height: 150,
        child: PointerInterceptor(
          child: Column(
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.headerWidget != null) widget.headerWidget!,
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: context.titleLarge,
                    ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        widget.onConfirm();
                      },
                      icon: const Icon(
                        Icons.close_outlined,
                        size: 24,
                      )),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                widget.message,
                style: context.bodyMedium,
              )
              // Text('로그인 정보가 만료되었습니다. \n 로그인 페이지로 이동합니다.')
            ],
          ),
        ));
  }
}
