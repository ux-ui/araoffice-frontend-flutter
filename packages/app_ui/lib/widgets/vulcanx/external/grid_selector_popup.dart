import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../app_ui.dart';

class GridSelectorPopup extends StatelessWidget {
  final Widget child;
  final Function(int rows, int cols) onSelection;

  const GridSelectorPopup({
    super.key,
    required this.child,
    required this.onSelection,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      offset: const Offset(100, 10),
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(
        minWidth: 400,
        maxWidth: 400,
        minHeight: 450, // 텍스트 공간을 위해 높이 증가
        maxHeight: 450,
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: GridSelectorContent(
            onSelection: onSelection,
          ),
        ),
      ],
      child: child,
    );
  }
}

class GridSelectorContent extends StatefulWidget {
  final Function(int rows, int cols) onSelection;

  const GridSelectorContent({
    super.key,
    required this.onSelection,
  });

  @override
  State<GridSelectorContent> createState() => _GridSelectorContentState();
}

class _GridSelectorContentState extends State<GridSelectorContent> {
  int currentRows = 0;
  int currentCols = 0;

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              '$currentRows x $currentCols',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: GridSelector(
              width: 350,
              height: 350,
              onChanged: (rows, cols) {
                setState(() {
                  currentRows = rows;
                  currentCols = cols;
                });
                debugPrint('Hovering: $rows rows x $cols columns');
              },
              onSelection: (rows, cols) {
                widget.onSelection(rows, cols);
                Navigator.pop(context);
              },
              maxRows: 8,
              maxCols: 8,
              selectedColor: Colors.lightBlueAccent,
              unselectedColor: Colors.grey,
              selectedBorderColor: context.primary,
              selectedBodyColor: context.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
