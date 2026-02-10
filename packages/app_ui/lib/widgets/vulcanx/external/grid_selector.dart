import 'package:flutter/material.dart';

class GridSelector extends StatefulWidget {
  final Function(int rows, int cols) onChanged;
  final Function(int rows, int cols) onSelection;
  final double? width;
  final double? height;
  final int maxRows;
  final int maxCols;
  final Color selectedColor;
  final Color? selectedBorderColor;
  final Color? selectedBodyColor;
  final Color unselectedColor;

  const GridSelector({
    super.key,
    this.width,
    this.height,
    required this.onChanged,
    required this.onSelection,
    this.maxRows = 8,
    this.maxCols = 8,
    this.selectedColor = Colors.lightBlueAccent,
    this.selectedBorderColor,
    this.selectedBodyColor,
    this.unselectedColor = Colors.grey,
  });

  @override
  State<GridSelector> createState() => _GridSelectorState();
}

class _GridSelectorState extends State<GridSelector> {
  int selectedRows = 0;
  int selectedCols = 0;
  int finalRows = 0;
  int finalCols = 0;

  void _updateSelection(Offset position) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final cellWidth = size.width / widget.maxCols;
    final cellHeight = size.height / widget.maxRows;

    final localPosition = position - renderBox.localToGlobal(Offset.zero);

    // 마우스가 위젯 영역을 벗어났을 때 처리
    if (localPosition.dx < 0 ||
        localPosition.dy < 0 ||
        localPosition.dx > size.width ||
        localPosition.dy > size.height) {
      if (selectedRows != 0 || selectedCols != 0) {
        setState(() {
          selectedRows = 0;
          selectedCols = 0;
        });
        widget.onChanged(0, 0);
      }
      return;
    }

    int cols = (localPosition.dx / cellWidth).ceil().clamp(1, widget.maxCols);
    int rows = (localPosition.dy / cellHeight).ceil().clamp(1, widget.maxRows);

    if (cols != selectedCols || rows != selectedRows) {
      setState(() {
        selectedRows = rows;
        selectedCols = cols;
      });
      widget.onChanged(selectedRows, selectedCols);
    }
  }

  void _handleTap(Offset position) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    // final cellWidth = size.width / widget.maxCols;
    // final cellHeight = size.height / widget.maxRows;

    final localPosition = position - renderBox.localToGlobal(Offset.zero);

    if (localPosition.dx < 0 ||
        localPosition.dy < 0 ||
        localPosition.dx > size.width ||
        localPosition.dy > size.height) {
      return;
    }

    setState(() {
      finalRows = selectedRows;
      finalCols = selectedCols;
    });
    widget.onSelection(finalRows, finalCols);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        _updateSelection(event.position);
      },
      onExit: (event) {
        setState(() {
          selectedRows = 0;
          selectedCols = 0;
        });
        widget.onChanged(0, 0);
      },
      child: GestureDetector(
        onTapDown: (details) {
          _handleTap(details.globalPosition);
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.maxCols,
                  childAspectRatio: 1,
                ),
                itemCount: widget.maxRows * widget.maxCols,
                itemBuilder: (context, index) {
                  final row = (index / widget.maxCols).floor() + 1;
                  final col = (index % widget.maxCols) + 1;
                  final isSelected = row <= selectedRows && col <= selectedCols;

                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      border: isSelected
                          ? Border.all(
                              color: widget.selectedBorderColor ??
                                  widget.selectedColor,
                              width: 1,
                            )
                          : null,
                      color: isSelected
                          ? widget.selectedBodyColor ?? widget.selectedColor
                          : widget.unselectedColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
