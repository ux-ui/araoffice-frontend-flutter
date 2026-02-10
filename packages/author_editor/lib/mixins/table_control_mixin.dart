import 'package:author_editor/enum/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../engine/engines.dart';
import '../engine/extension_js_type/js_cell_format_option.dart';

/// 테이블 관련 기능을 관리하는 Mixin
mixin TableControlMixin on GetxController {
  Editor? get editor;

  // Table properties
  final rxTableRowCount = 1.obs;
  final rxTableColumnCount = 1.obs;
  final rxTableBackColor = Rx<Color>(Colors.transparent);

  // Table border properties
  final rxTableBorderWidth = 1.obs;
  final rxTableBorderColor = Rx<Color>(Colors.black);
  final rxTableBorderStyle = BorderStyleType.none.obs;

  // Table calculation options
  final rxTableCalculationAlign = TextAlignType.right.obs;
  final rxTableCalculationDecimalPlaces = 2.obs;
  final rxTableCalculationPrefix = ''.obs;
  final rxTableCalculationSuffix = ''.obs;
  final rxTableCalculationUseThousandSeparator = true.obs;

  /// 새로운 테이블을 삽입합니다
  void insertTable({required int row, required int column}) {
    editor?.insertTable(row, column);
  }

  /// 테이블 셀을 병합합니다
  void setMerge(TableCellMergeType type) {
    switch (type) {
      case TableCellMergeType.merge:
        editor?.mergeTableCell();
        break;
      case TableCellMergeType.divide:
        editor?.unmergeTableCell();
        break;
    }
  }

  /// 테이블에 셀을 삽입합니다
  void insertTableCell(TableCellInsertType type) {
    switch (type) {
      case TableCellInsertType.above:
      case TableCellInsertType.below:
        editor?.insertTableRow(type.name);
        break;
      case TableCellInsertType.left:
      case TableCellInsertType.right:
        editor?.insertTableColumn(type.name);
        break;
    }
  }

  /// 테이블에서 셀을 제거합니다
  void removeTableCell(TableCellRemoveType type) {
    switch (type) {
      case TableCellRemoveType.column:
        editor?.removeTableColumn(type.name);
        break;
      case TableCellRemoveType.row:
        editor?.removeTableRow(type.name);
        break;
    }
  }

  /// 테이블 스타일을 적용합니다
  void setTableStyle(int index) => editor?.applyTableClass(index);

  /// 테이블 셀을 분할합니다
  void splitTableCell() {
    editor?.splitTableCell(rxTableRowCount.value, rxTableColumnCount.value);
  }

  void calculateTableCellData(String type) {
    final option = JSCellFormatOption.create(type: type);
    editor?.calculateTableCellData(option);
  }

  /// 계산식 옵션을 적용하여 테이블 셀 데이터를 계산합니다
  void calculateTableCellDataWithOptions(String type) {
    final option = JSCellFormatOption.create(
      type: type,
      decimalPlaces: rxTableCalculationDecimalPlaces.value,
      align: rxTableCalculationAlign.value.translationKey,
      prefix: rxTableCalculationPrefix.value,
      suffix: rxTableCalculationSuffix.value,
      useThousandSeparator: rxTableCalculationUseThousandSeparator.value,
    );
    editor?.calculateTableCellData(option);
  }

  void transposeTable() {
    editor?.transposeTable();
  }

  void tableToTextbox() {
    editor?.tableToTextbox();
  }
}
