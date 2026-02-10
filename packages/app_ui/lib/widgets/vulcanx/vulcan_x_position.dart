import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

import 'vulcan_x_stateful_widget.dart';

class VulcanXPosition<T extends Enum?> extends VulcanXStatefulWidget {
  final Function(int row, int col, T? enumValue)? onPositionSelected;
  final List<T>? enumValues;
  final int? initialRow;
  final int? initialCol;
  final T? initialEnumValue;

  const VulcanXPosition({
    super.key,
    this.onPositionSelected,
    this.enumValues,
    this.initialRow,
    this.initialCol,
    this.initialEnumValue,
  });

  @override
  VulcanXState<VulcanXPosition<T>> createState() => _VulcanXPositionState<T>();
}

class _VulcanXPositionState<T extends Enum?>
    extends VulcanXState<VulcanXPosition<T>> {
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    // 초기 선택값 설정
    if (widget.initialRow != null && widget.initialCol != null) {
      // row, col로 직접 설정
      selectedRow = widget.initialRow;
      selectedCol = widget.initialCol;
    } else if (widget.initialEnumValue != null && widget.enumValues != null) {
      // enum 값으로 위치 찾기
      final index = widget.enumValues!.indexOf(widget.initialEnumValue!);
      if (index != -1) {
        selectedRow = index ~/ 3; // 행 계산
        selectedCol = index % 3; // 열 계산
      }
    }
  }

  T? _getEnumForPosition(int row, int col) {
    if (widget.enumValues == null) return null;

    // 3x3 그리드 인덱스를 1차원 인덱스로 변환
    final index = row * 3 + col;

    // enum 값이 충분하지 않으면 첫 번째 값 반환
    if (index < widget.enumValues!.length) {
      return widget.enumValues![index];
    } else {
      return widget.enumValues!.first;
    }
  }

  void _onPositionTap(int row, int col) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });

    final enumValue = _getEnumForPosition(row, col);
    widget.onPositionSelected?.call(row, col, enumValue);
  }

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: List.generate(3, (row) {
            return Expanded(
              child: Row(
                children: List.generate(3, (col) {
                  final isSelected = selectedRow == row && selectedCol == col;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onPositionTap(row, col),
                      child: isSelected
                          ? CommonAssets.icon.positionButton.svg(
                              width: 24,
                              height: 24,
                            )
                          : CommonAssets.icon.circleButton.svg(
                              width: 24,
                              height: 24,
                            ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
