import 'package:auto_size_text/auto_size_text.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

import '../../app_ui.dart';
import 'vulcan_x_stateful_widget.dart';

class VulcanXSvgButtonSelector<T extends Enum?> extends VulcanXStatefulWidget {
  final double? width;
  final double? height;
  final List<SvgGenImage> svgAssets;
  final List<T>? enumValues;
  final Function(T?) onSelectedEnum;
  final Function(List<T>)? onMultiSelectedEnum;
  final Function(int?)? onSelectedIndex;
  final Function(List<int>)? onMultiSelectedIndex;
  final String? label;
  final T? initialEnum;
  final List<T>? initialEnums;
  final int? initialIndex;
  final List<int>? initialIndices;
  final bool multiSelect;
  final bool isButtonMode;
  final bool disabled; // 추가된 disabled 속성
  final double? gapSize; // 추가된 gapSize 속성
  final bool? isAutoSizeText;

  const VulcanXSvgButtonSelector({
    super.key,
    this.width,
    this.height = 40,
    required this.svgAssets,
    this.enumValues,
    this.onSelectedEnum = _defaultEnumCallback,
    this.onMultiSelectedEnum,
    this.onSelectedIndex,
    this.onMultiSelectedIndex,
    this.label,
    this.initialEnum,
    this.initialEnums,
    this.initialIndex,
    this.initialIndices,
    this.multiSelect = false,
    this.isButtonMode = false,
    this.disabled = false, // 기본값은 false
    this.gapSize, // 생성자에 gapSize 매개변수 추가
    this.isAutoSizeText = false,
  }) : assert(
          (enumValues == null &&
                  (onSelectedIndex != null || onMultiSelectedIndex != null)) ||
              (enumValues != null && enumValues.length == svgAssets.length),
          'If enumValues is provided, its length must match svgAssets length',
        );

  static void _defaultEnumCallback(dynamic _) {}

  @override
  VulcanXState<VulcanXSvgButtonSelector<T>> createState() =>
      _VulcanSvgButtonSelectorState<T>();
}

class _VulcanSvgButtonSelectorState<T extends Enum?>
    extends VulcanXState<VulcanXSvgButtonSelector<T>> {
  Set<int> _selectedIndices = {};
  Set<T> _selectedEnums = {};
  final Set<int> _pressedIndices = {};

  @override
  void initState() {
    super.initState();
    _initializeSelection();
  }

  @override
  void didUpdateWidget(VulcanXSvgButtonSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // initialEnum이나 initialEnums가 변경되었을 때만 초기화
    if ((widget.multiSelect && widget.initialEnums != oldWidget.initialEnums) ||
        (!widget.multiSelect && widget.initialEnum != oldWidget.initialEnum) ||
        (widget.initialIndex != oldWidget.initialIndex) ||
        (widget.initialIndices != oldWidget.initialIndices)) {
      _initializeSelection();
    }
  }

  void _initializeSelection() {
    if (widget.multiSelect) {
      if (widget.initialEnums != null &&
          widget.initialEnums!.isNotEmpty &&
          widget.enumValues != null) {
        _selectedEnums = widget.initialEnums!.toSet();
        _selectedIndices = widget.initialEnums!
            .map((e) => widget.enumValues!.indexOf(e))
            .where((index) => index != -1)
            .toSet();
      } else if (widget.initialIndices != null) {
        _selectedIndices = widget.initialIndices!.toSet();
      } else {
        _selectedIndices = {};
      }
    } else {
      if (widget.initialEnum != null &&
          widget.initialEnum!.toString().isNotEmpty &&
          widget.enumValues != null) {
        final index = widget.enumValues!.indexOf(widget.initialEnum as T);
        if (index != -1) {
          _selectedIndices = {index};
          _selectedEnums = {widget.initialEnum as T};
        }
      } else if (widget.initialIndex != null) {
        _selectedIndices = {widget.initialIndex!};
      } else {
        _selectedIndices = {};
      }
    }
  }

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    Widget selectorContainer = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.disabled
            ? Colors.grey[200]
            : Colors.white, // disabled 상태일 때 배경색 변경
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.disabled ? Colors.grey[300]! : context.outline,
          width: 1.0,
        ),
      ),
      child: Opacity(
        opacity: widget.disabled ? 0.5 : 1.0, // disabled 상태일 때 전체적으로 투명도 적용
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(
              widget.svgAssets.length,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 2,
                    right: index == widget.svgAssets.length - 1 ? 0 : 2,
                  ),
                  child: _buildSvgButton(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Row(
      children: [
        if (widget.label != null) ...[
          if (widget.isAutoSizeText == true)
            AutoSizeText(
              widget.label!,
              style: themeData.textTheme.bodyMedium?.copyWith(
                color: widget.disabled
                    ? Colors.grey
                    : null, // disabled 상태일 때 라벨 색상 변경
              ),
              maxLines: 1,
              minFontSize: 10,
              maxFontSize: 10,
            )
          else
            Text(
              widget.label!,
              style: themeData.textTheme.bodyMedium?.copyWith(
                color: widget.disabled
                    ? Colors.grey
                    : null, // disabled 상태일 때 라벨 색상 변경
              ),
            ),
          widget.gapSize != null
              ? SizedBox(width: widget.gapSize)
              : const Spacer()
        ],
        if (widget.width == null)
          Expanded(child: selectorContainer)
        else
          selectorContainer,
      ],
    );
  }

  Widget _buildSvgButton(int index) {
    final isSelected = widget.isButtonMode
        ? _pressedIndices.contains(index)
        : _selectedIndices.contains(index);

    return GestureDetector(
      onTapDown: widget.disabled
          ? null
          : widget.isButtonMode
              ? (details) {
                  setState(() {
                    _pressedIndices.add(index);
                    if (widget.enumValues != null) {
                      widget.onSelectedEnum(widget.enumValues![index]);
                    } else {
                      widget.onSelectedIndex?.call(index);
                    }
                  });
                }
              : null,
      onTapUp: widget.disabled
          ? null
          : widget.isButtonMode
              ? (details) {
                  setState(() {
                    _pressedIndices.remove(index);
                  });
                }
              : null,
      onTapCancel: widget.disabled
          ? null
          : widget.isButtonMode
              ? () {
                  setState(() {
                    _pressedIndices.remove(index);
                  });
                }
              : null,
      onTap: widget.disabled
          ? null
          : !widget.isButtonMode
              ? () {
                  setState(() {
                    if (widget.multiSelect) {
                      if (isSelected) {
                        _selectedIndices.remove(index);
                        if (widget.enumValues != null) {
                          final enumValue = widget.enumValues![index];
                          _selectedEnums.remove(enumValue);
                          widget.onMultiSelectedEnum
                              ?.call(_selectedEnums.toList());
                        } else {
                          widget.onMultiSelectedIndex
                              ?.call(_selectedIndices.toList());
                        }
                      } else {
                        _selectedIndices.add(index);
                        if (widget.enumValues != null) {
                          final enumValue = widget.enumValues![index];
                          _selectedEnums.add(enumValue);
                          widget.onMultiSelectedEnum
                              ?.call(_selectedEnums.toList());
                        } else {
                          widget.onMultiSelectedIndex
                              ?.call(_selectedIndices.toList());
                        }
                      }
                    } else {
                      if (isSelected) {
                        _selectedIndices.clear();
                        _selectedEnums.clear();
                        if (widget.enumValues != null) {
                          widget.onSelectedEnum(null);
                        } else {
                          widget.onSelectedIndex?.call(null);
                        }
                      } else {
                        _selectedIndices = {index};
                        if (widget.enumValues != null) {
                          _selectedEnums = {widget.enumValues![index]};
                          widget.onSelectedEnum(_selectedEnums.first);
                        } else {
                          widget.onSelectedIndex?.call(index);
                        }
                      }
                    }
                  });
                }
              : null,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? context.secondaryFixedDim : context.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: widget.svgAssets[index].svg(width: 20, height: 20),
        ),
      ),
    );
  }
}
