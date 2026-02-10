import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../vulcan_editor_eventbus.dart';

class TableItem extends StatelessWidget with EditorEventbus {
  TableItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          GridSelectorPopup(
              onSelection: (rows, cols) {
                debugPrint('Final Selection: $rows rows x $cols columns');
                controller.insertTable(row: rows, column: cols);
              },
              child:
                  VulcanXElevatedButton.nullStyle(child: Text('add_table'.tr))),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
