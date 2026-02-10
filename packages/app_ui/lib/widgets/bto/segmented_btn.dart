import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

import '../../app_ui.dart';

class SegmentedBtn extends StatefulWidget {
  final Function(int) onToggle;
  final int selected;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final List<SvgGenImage> icons;
  const SegmentedBtn(
      {super.key,
      this.width,
      this.height,
      this.padding,
      required this.onToggle,
      required this.icons,
      required this.selected});

  @override
  State<SegmentedBtn> createState() => _SegmentedBtnState();
}

class _SegmentedBtnState extends State<SegmentedBtn> {
  @override
  void initState() {
    super.initState();
    if (widget.selected == 0) {
      isLeftToggled = true;
    } else {
      isLeftToggled = false;
    }
  }

  @override
  void didUpdateWidget(covariant SegmentedBtn oldWidget) {
    if (widget.selected == 0) {
      isLeftToggled = true;
    } else {
      isLeftToggled = false;
    }
    super.didUpdateWidget(oldWidget);
  }

  bool isLeftToggled = true;

  void _toggleLeft() {
    setState(() {
      isLeftToggled = true;
    });
    widget.onToggle(0);
  }

  void _toggleRight() {
    setState(() {
      isLeftToggled = false;
    });
    widget.onToggle(1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: isLeftToggled ? null : _toggleLeft,
          child: Container(
            width: widget.width ?? 31,
            height: widget.height ?? 31,
            padding: widget.padding ?? const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isLeftToggled ? context.surface : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8), // 왼쪽 상단 모서리 둥글게
                bottomLeft: Radius.circular(8), // 왼쪽 하단 모서리 둥글게
              ),
              border: Border(
                top: BorderSide(color: context.outline, width: 1),
                bottom: BorderSide(color: context.outline, width: 1),
                left: BorderSide(color: context.outline, width: 1),
                right: BorderSide(color: context.outline, width: 0.5),
              ),
            ),
            child: widget.icons[0].svg(
              width: 16,
              height: 12,
              colorFilter: ColorFilter.mode(
                isLeftToggled ? context.primary : context.onSurface,
                BlendMode.srcIn,
              ),
            ),
            //color: isLeftToggled ? Colors.white : Colors.black,
          ),
        ),
        InkWell(
          onTap: isLeftToggled ? _toggleRight : null,
          child: Container(
            width: widget.width ?? 31,
            height: widget.height ?? 31,
            padding: widget.padding ?? const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isLeftToggled ? Colors.white : context.surface,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8), // 오른쪽 상단 모서리 둥글게
                bottomRight: Radius.circular(8), // 오른쪽 하단 모서리 둥글게
              ),
              border: Border(
                top: BorderSide(color: context.outline, width: 1),
                bottom: BorderSide(color: context.outline, width: 1),
                left: BorderSide(color: context.outline, width: 0.5),
                right: BorderSide(color: context.outline, width: 1),
              ),
            ),
            child: widget.icons[1].svg(
              width: 16,
              height: 12,
              colorFilter: ColorFilter.mode(
                isLeftToggled ? context.onSurface : context.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
