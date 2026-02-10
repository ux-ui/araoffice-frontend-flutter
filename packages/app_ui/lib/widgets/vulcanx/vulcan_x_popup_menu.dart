import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// VulcanX 스타일의 팝업 메뉴 위젯
class VulcanXPopupMenu extends StatelessWidget {
  /// 팝업 메뉴 아이템 목록
  final List<VulcanXPopupMenuItem> items;

  /// 메뉴를 열기 위한 아이콘
  final Widget? icon;

  /// 아이콘 크기
  final double? iconSize;

  /// 메뉴가 열릴 때 오프셋
  final Offset offset;

  /// 아이콘 클릭 시 콜백
  final VoidCallback? onTap;

  /// 팝업 메뉴 배경색
  final Color? backgroundColor;

  /// 툴팁 텍스트
  final String? tooltip;

  /// 팝업 메뉴 버튼의 패딩
  final EdgeInsetsGeometry padding;

  /// 메뉴 아이템 선택 시 콜백
  final Function(dynamic)? onSelected;

  /// 메뉴 취소 시 콜백
  final VoidCallback? onCanceled;

  const VulcanXPopupMenu({
    super.key,
    required this.items,
    this.icon,
    this.iconSize,
    this.offset = const Offset(0, 0),
    this.onTap,
    this.backgroundColor,
    this.tooltip,
    this.padding = EdgeInsets.zero,
    this.onSelected,
    this.onCanceled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton(
      offset: offset,
      tooltip: tooltip ?? 'menu'.tr,
      padding: padding,
      color: backgroundColor ?? theme.scaffoldBackgroundColor,
      iconSize: iconSize,
      icon: icon ?? Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
      itemBuilder: (context) {
        return items;
      },
      onSelected: (value) {
        onTap?.call();
        onSelected?.call(value);
      },
      onOpened: () => onTap?.call(),
      onCanceled: () => onCanceled?.call(),
    );
  }
}

/// VulcanX 스타일의 팝업 메뉴 아이템
class VulcanXPopupMenuItem<T> extends PopupMenuItem<T> {
  const VulcanXPopupMenuItem({
    super.key,
    super.value,
    super.onTap,
    super.enabled = true,
    super.height,
    super.padding,
    super.textStyle,
    super.mouseCursor,
    required super.child,
  });
}
