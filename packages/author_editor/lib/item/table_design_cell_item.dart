import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';
import '../vulcan_editor_eventbus.dart';
import 'items.dart';

class TableDesignCellItem extends StatelessWidget with EditorEventbus {
  TableDesignCellItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SizeItem(
            textFieldWidth: 113,
            padding: EdgeInsets.zero,
            focusWidthNode: controller.focusCellWidthNode,
            focusHeightNode: controller.focusCellHeightNode,
          ),
          BackgroundItem(),
          const SizedBox(height: 8.0),
          BackgroundImageItem(
            backgroundType: ObjectType.table,
          ),
          const SizedBox(height: 8.0),
          BorderItem(focusNode: controller.focusCellBorderWidthNode),
          Obx(
            () => VulcanXSvgButtonSelector<BorderPositionType>(
              disabled: controller.rxDisabledTextbox.value,
              enumValues: BorderPositionType.values,
              isButtonMode: true,
              svgAssets: [
                CommonAssets.icon.borderLeft,
                CommonAssets.icon.borderRight,
                CommonAssets.icon.borderTop,
                CommonAssets.icon.borderBottom,
              ],
              onSelectedEnum: (type) => controller.setBorderPosition(type!),
            ),
          ),
          const SizedBox(height: 8.0),
          VulcanXSvgButtonSelector<TableCellMergeType>(
              isButtonMode: true,
              width: 148,
              //병합
              label: 'merge'.tr,
              enumValues: TableCellMergeType.values,
              svgAssets: [
                CommonAssets.icon.combineColumns,
                CommonAssets.icon.divideColumns,
              ],
              onSelectedEnum: (value) => controller.setMerge(value!)),
          const SizedBox(height: 16.0),
          Obx(() => CounterWidget(
                //가로줄 개수
                text: 'table_row_count'.tr,
                minValue: 1,
                focusNode: controller.focusTableRowCountNode,
                initialValue: controller.rxTableRowCount.value.toString(),
                inputFormatters: [
                  // 숫자만 입력
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  int count = int.tryParse(value) ?? 1;
                  controller.rxTableRowCount.value = count;
                },
              )),
          const SizedBox(height: 8.0),
          Obx(() => CounterWidget(
                //세로줄 개수
                initialValue: controller.rxTableColumnCount.value.toString(),
                text: 'table_column_count'.tr,
                minValue: 1,
                focusNode: controller.focusTableColumnCountNode,
                inputFormatters: [
                  // 숫자만 입력
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  int count = int.tryParse(value) ?? 1;
                  controller.rxTableColumnCount.value = count;
                },
              )),
          const SizedBox(height: 16.0),
          VulcanXOutlinedButton(
              width: double.infinity,
              onPressed: () => controller.splitTableCell(),
              child: Text('table_cell_split'.tr)),
          const SizedBox(height: 16.0),
          VulcanXSvgButtonSelector<TableCellInsertType>(
              isButtonMode: true,
              width: 220,
              //삽입
              label: 'insert'.tr,
              enumValues: TableCellInsertType.values,
              svgAssets: [
                CommonAssets.icon.addRowAbove,
                CommonAssets.icon.addRowBelow,
                CommonAssets.icon.addColumnLeft,
                CommonAssets.icon.addColumnRight,
              ],
              onSelectedEnum: (value) => controller.insertTableCell(value!)),
          const SizedBox(height: 16.0),
          VulcanXSvgButtonSelector<TableCellRemoveType>(
              isButtonMode: true,
              width: 220,
              //삭제
              label: 'remove'.tr,
              enumValues: TableCellRemoveType.values,
              svgAssets: [
                CommonAssets.icon.removeColumn,
                CommonAssets.icon.removeRow,
              ],
              onSelectedEnum: (value) => controller.removeTableCell(value!)),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
