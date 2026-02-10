import 'package:flutter/material.dart';

class VulcanXRoundedContainer extends StatelessWidget {
  final Widget? child;
  final double width;
  final double? height;
  final bool isBoxShadow;
  final Color color;
  final double borderRadius;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback? onTap; // onTap 콜백 추가

  const VulcanXRoundedContainer({
    super.key,
    this.child,
    this.width = 200,
    this.height,
    this.isBoxShadow = false,
    this.color = Colors.white,
    this.borderRadius = 8.0,
    this.borderColor = Colors.white,
    this.backgroundColor = Colors.white,
    this.onTap, // onTap 파라미터 추가
  });

  factory VulcanXRoundedContainer.defaultStyle({
    Widget? child,
    double width = 200,
    double height = 100,
    bool isBoxShadow = false,
    VoidCallback? onTap, // onTap 파라미터 추가
  }) {
    return VulcanXRoundedContainer(
      width: width,
      height: height,
      isBoxShadow: isBoxShadow,
      borderRadius: 8.0,
      borderColor: Colors.grey,
      backgroundColor: Colors.grey,
      onTap: onTap,
      child: child, // onTap 전달
    );
  }

  factory VulcanXRoundedContainer.grey({
    Widget? child,
    double width = 200,
    double height = 100,
    bool isBoxShadow = false,
    double borderRadius = 8.0,
    Color borderColor = const Color(0xffE9E9E9),
    Color backgroundColor = const Color(0xffF5F5F5),
    VoidCallback? onTap, // onTap 파라미터 추가
  }) {
    return VulcanXRoundedContainer(
      width: width,
      height: height,
      isBoxShadow: isBoxShadow,
      borderRadius: borderRadius,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: child, // onTap 전달
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: (!isBoxShadow)
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withAlpha(77),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: child,
    );

    // onTap이 제공되면 InkWell로 감싸기
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );
    }

    return container;
  }
}
