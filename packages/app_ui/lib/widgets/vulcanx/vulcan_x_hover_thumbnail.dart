import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_ui.dart';

class VulcanXHoverThumbnail extends StatefulWidget {
  final double width;
  final double height;
  final String? text;
  final Widget? child;
  final Widget? previewChild;
  final VoidCallback? onApply;
  final VoidCallback? onPreview;

  const VulcanXHoverThumbnail({
    super.key,
    this.width = 171,
    this.height = 180,
    this.text,
    this.onApply,
    this.onPreview,
    this.previewChild,
    this.child,
  });

  @override
  State<VulcanXHoverThumbnail> createState() => _VulcanXHoverThumbnailState();
}

class _VulcanXHoverThumbnailState extends State<VulcanXHoverThumbnail> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Stack(
            children: [
              VulcanXRoundedContainer.grey(
                width: widget.width,
                height: widget.height,
                child: widget.child,
              ),
              if (_isHovering)
                SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VulcanXElevatedButton.primary(
                            width: 73,
                            onPressed: widget.onApply,
                            //적용하기
                            child: Text('apply'.tr)),
                        const SizedBox(height: 4),
                        widget.previewChild ??
                            VulcanXElevatedButton(
                                width: 73,
                                onPressed: widget.onPreview,
                                //미리보기
                                child: Text('preview'.tr)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(widget.text ?? '', style: context.titleSmall),
      ],
    );
  }
}
