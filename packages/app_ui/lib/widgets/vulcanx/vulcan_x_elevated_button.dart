import 'package:flutter/material.dart';

import 'vulcan_x_stateless_widget.dart';

class VulcanXElevatedButton extends VulcanXStatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final ButtonStyle? customStyle;
  final bool maintainThemeOnNull;
  final bool isPrimary; // primary 스타일 적용 여부를 결정하는 새 플래그

  const VulcanXElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 36,
    this.padding,
    this.customStyle,
    this.maintainThemeOnNull = false,
    this.isPrimary = false, // 기본값은 false
  }) : icon = null;

  const VulcanXElevatedButton.icon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.child,
    this.width,
    this.height = 36,
    this.padding,
    this.customStyle,
    this.maintainThemeOnNull = false,
    this.isPrimary = false, // 기본값은 false
  });

  // onPressed가 null 이면 button style이 disabled 되는데
  // popup menu에서는 onPressed도 null 이고 style도 기본 style을 사용하기 위해서 사용된다.
  factory VulcanXElevatedButton.nullStyle({
    Key? key,
    required Widget child,
    double? width,
    double height = 36,
    EdgeInsetsGeometry? padding,
  }) {
    return VulcanXElevatedButton(
      key: key,
      onPressed: null,
      width: width,
      height: height,
      padding: padding,
      maintainThemeOnNull: true, // null일 때도 테마 유지
      child: child,
    );
  }

  factory VulcanXElevatedButton.nullStyleIcon({
    Key? key,
    required Widget icon,
    required Widget child,
    double? width,
    double height = 36,
    EdgeInsetsGeometry? padding,
  }) {
    return VulcanXElevatedButton.icon(
      key: key,
      onPressed: null,
      icon: icon,
      width: width,
      height: height,
      padding: padding,
      maintainThemeOnNull: true, // null일 때도 테마 유지
      child: child,
    );
  }

  factory VulcanXElevatedButton.primary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
    double height = 36,
    EdgeInsetsGeometry? padding,
  }) {
    return VulcanXElevatedButton(
      key: key,
      onPressed: onPressed,
      width: width,
      height: height,
      padding: padding,
      isPrimary: true, // primary 스타일 사용 플래그 설정
      child: child,
    );
  }

  factory VulcanXElevatedButton.primaryIcon({
    Key? key,
    required VoidCallback? onPressed,
    required Widget icon,
    required Widget child,
    double? width,
    double height = 36,
    EdgeInsetsGeometry? padding,
  }) {
    return VulcanXElevatedButton.icon(
      key: key,
      onPressed: onPressed,
      icon: icon,
      width: width,
      height: height,
      padding: padding,
      isPrimary: true, // primary 스타일 사용 플래그 설정
      child: child,
    );
  }

  // 기본 그레이 색상에 호버 시 primary 색상으로 변경되는 버튼
  factory VulcanXElevatedButton.gray({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
    double height = 36,
    EdgeInsetsGeometry? padding,
  }) {
    return VulcanXElevatedButton(
      key: key,
      onPressed: onPressed,
      width: width,
      height: height,
      padding: padding,
      customStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return null; // 호버 시 기본 primary 색상 사용
          }
          return Colors.grey[50]; // 기본 그레이 색상
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.black87; // 호버 시 텍스트는 흰색
          }
          return Colors.black87; // 기본 상태에서는 어두운 텍스트
        }),
      ),
      child: child,
    );
  }

  // 기본 그레이 색상에 호버 시 primary 색상으로 변경되는 아이콘 버튼
  factory VulcanXElevatedButton.grayIcon({
    Key? key,
    required VoidCallback? onPressed,
    required Widget icon,
    required Widget child,
    double? width,
    double height = 36,
    EdgeInsetsGeometry? padding,
  }) {
    return VulcanXElevatedButton.icon(
      key: key,
      onPressed: onPressed,
      icon: icon,
      width: width,
      height: height,
      padding: padding,
      customStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return null; // 호버 시 기본 primary 색상 사용
          }
          return Colors.grey[300]; // 기본 그레이 색상
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.white; // 호버 시 텍스트와 아이콘은 흰색
          }
          return Colors.black87; // 기본 상태에서는 어두운 텍스트와 아이콘
        }),
      ),
      child: child,
    );
  }

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    final defaultStyle = themeData.elevatedButtonTheme.style?.copyWith(
          minimumSize:
              WidgetStateProperty.all(Size(width ?? double.infinity, height)),
          padding: WidgetStateProperty.all(padding ?? EdgeInsets.zero),
        ) ??
        ButtonStyle(
          minimumSize:
              WidgetStateProperty.all(Size(width ?? double.infinity, height)),
          padding: WidgetStateProperty.all(padding ?? EdgeInsets.zero),
        );

    // isPrimary 플래그가 true인 경우의 스타일 설정
    ButtonStyle? primaryButtonStyle;
    if (isPrimary) {
      primaryButtonStyle = defaultStyle.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey[300]; // 비활성화 상태일 때 회색으로 변경
          }
          return Theme.of(context).colorScheme.primary; // 활성화 상태일 때 primary 색상
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey[600]; // 비활성화 상태일 때 텍스트 색상
          }
          return Theme.of(context).colorScheme.onPrimary; // 활성화 상태일 때 텍스트 색상
        }),
        textStyle: WidgetStateProperty.all(
          Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
      );
    }

    final buttonStyle = isPrimary
        ? primaryButtonStyle // primary 스타일 적용
        : customStyle != null
            ? defaultStyle.copyWith(
                backgroundColor: customStyle?.backgroundColor,
                foregroundColor: customStyle?.foregroundColor,
                textStyle: customStyle?.textStyle,
                elevation: customStyle?.elevation,
              )
            : defaultStyle.copyWith(
                backgroundColor: maintainThemeOnNull
                    ? WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.disabled)) {
                          // disabled 상태일 때의 배경색
                          return Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withAlpha(77); // 투명도를 조절하여 비활성화 표현
                        }
                        return Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(77); // 활성화 상태 색상
                      })
                    : null,
                foregroundColor: maintainThemeOnNull
                    ? WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.disabled)) {
                          // disabled 상태일 때의 텍스트/아이콘 색상
                          return Theme.of(context).colorScheme.primary;
                        }
                        return Theme.of(context).colorScheme.onPrimary;
                      })
                    : null,

                // 비활성화 상태의 elevation 설정
                elevation: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return 0; // disabled 상태일 때 elevation
                  }
                  return 2; // 기본 elevation
                }),
              );

    final buttonChild = icon == null
        ? child
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              child,
            ],
          );

    return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: buttonChild,
        ));
  }
}
