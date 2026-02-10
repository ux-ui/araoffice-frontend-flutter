import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';
import '../enum/text_align_type.dart';
import '../vulcan_editor_eventbus.dart';

class TableCellFunctionItem extends StatelessWidget with EditorEventbus {
  TableCellFunctionItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 계산 버튼들
          Row(
            children: [
              Expanded(
                child: VulcanXElevatedButton(
                  onPressed: () {
                    controller.calculateTableCellDataWithOptions('sum');
                  },
                  child: Text('calculate_cell_data_sum'.tr),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: VulcanXElevatedButton(
                  onPressed: () {
                    controller.calculateTableCellDataWithOptions('average');
                  },
                  child: Text('calculate_cell_data_average'.tr),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 계산식 옵션 설정
          Text(
            'table_calculation_options'.tr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // 정렬 설정
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('table_calculation_align'.tr),
              Obx(() => SizedBox(
                    width: 120,
                    child: VulcanXDropdown<TextAlignType>(
                      height: 40.0,
                      enumItems: TextAlignType.values,
                      onChanged: (TextAlignType? newValue) {
                        controller.rxTableCalculationAlign.value = newValue!;
                      },
                      hintText: '',
                      value: controller.rxTableCalculationAlign.value,
                      displayStringForOption: (type) => type.name,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 12),

          // 소수점 이하 자리수 설정
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('table_calculation_decimal_places'.tr),
              Obx(() => SizedBox(
                    width: 120,
                    child: VulcanXDropdown<int>(
                      height: 40.0,
                      enumItems: const [0, 1, 2, 3],
                      onChanged: (int? newValue) {
                        controller.rxTableCalculationDecimalPlaces.value =
                            newValue!;
                      },
                      hintText: '',
                      value: controller.rxTableCalculationDecimalPlaces.value,
                      displayStringForOption: (value) =>
                          value == 0 ? 'none'.tr : value.toString(),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          // Prefix 설정
          VulcanXLabelTextField(
            textFieldWidth: 120,
            label: 'table_calculation_prefix'.tr,
            hintText: 'table_calculation_prefix_hint'.tr,
            initialValue: '',
            onChanged: (value) {
              controller.rxTableCalculationPrefix.value = value;
            },
            focusNode: controller.focusTableCalculationPrefixNode,
          ),
          const SizedBox(height: 12),

          // Suffix 설정
          VulcanXLabelTextField(
            textFieldWidth: 120,
            label: 'table_calculation_suffix'.tr,
            hintText: 'table_calculation_suffix_hint'.tr,
            initialValue: '',
            onChanged: (value) {
              controller.rxTableCalculationSuffix.value = value;
            },
            focusNode: controller.focusTableCalculationSuffixNode,
          ),
          const SizedBox(height: 12),

          // 천단위 구분자 설정
          Obx(() => VulcanXSwitch(
                label: 'table_calculation_thousand_separator'.tr,
                value: controller.rxTableCalculationUseThousandSeparator.value,
                onChanged: (bool? value) {
                  controller.rxTableCalculationUseThousandSeparator.value =
                      value ?? false;
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
