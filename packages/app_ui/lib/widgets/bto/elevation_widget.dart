import 'package:flutter/material.dart';

class ElevationWiddget extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  const ElevationWiddget(
      {this.child, this.width, this.height, this.decoration, super.key});

  factory ElevationWiddget.elevation2({Widget? child}) {
    return ElevationWiddget(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)), // 테두리 둥글게
        boxShadow: [
          BoxShadow(
            // color: Colors.grey.withOpacity(0.5), // 그림자 색상
            color: const Color(0xff000026).withAlpha(39),
            spreadRadius: 1, // 그림자 확산 거리
            blurRadius: 6, // 그림자 흐림 정도
            offset: const Offset(0, 2), // 그림자 위치
          ),
        ],
      ),
      child: child,
    );
  }

  factory ElevationWiddget.elevation3({Widget? child}) {
    return ElevationWiddget(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)), // 테두리 둥글게
        boxShadow: [
          BoxShadow(
            // color: Colors.grey.withOpacity(0.5), // 그림자 색상
            color: const Color(0xff000026).withAlpha(39),
            spreadRadius: 2, // 그림자 확산 거리
            blurRadius: 6, // 그림자 흐림 정도
            offset: const Offset(0, 4), // 그림자 위치
          ),
        ],
      ),
      child: child,
    );
  }

  factory ElevationWiddget.elevation4({Widget? child}) {
    return ElevationWiddget(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)), // 테두리 둥글게
        boxShadow: [
          BoxShadow(
            // color: Colors.grey.withOpacity(0.5), // 그림자 색상
            color: const Color(0xff000026).withAlpha(39),
            spreadRadius: 3, // 그림자 확산 거리
            blurRadius: 6, // 그림자 흐림 정도
            offset: const Offset(0, 6), // 그림자 위치
          ),
        ],
      ),
      child: child,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 50,
      height: height ?? 50,
      decoration: decoration ??
          BoxDecoration(
            color: Colors.white,
            borderRadius:
                const BorderRadius.all(Radius.circular(10)), // 테두리 둥글게
            boxShadow: [
              BoxShadow(
                // color: Colors.grey.withOpacity(0.5), // 그림자 색상
                color: const Color(0xff000026).withAlpha(39),
                spreadRadius: 1, // 그림자 확산 거리
                blurRadius: 2, // 그림자 흐림 정도
                offset: const Offset(0, 2), // 그림자 위치
              ),
            ],
          ),
      child: child,
    );
  }
}
