import 'package:app_ui/widgets/widgets.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum NewDocumentType { emptyDocument, template }

class EditorNewDocumentDialog extends StatelessWidget {
  final Function(NewDocumentType type) onTap;
  const EditorNewDocumentDialog({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VulcanXRoundedContainer.grey(
          width: 238,
          height: 160,
          child: Center(
              child: VulcanXSvgLabelIconWidget(
            icon: CommonAssets.icon.emptyDocument,
            // 빈 문서
            label: 'empty_document'.tr,
          )),
          onTap: () => onTap.call(NewDocumentType.emptyDocument),
        ),
        const SizedBox(
          width: 8,
        ),
        VulcanXRoundedContainer.grey(
          width: 238,
          height: 160,
          child: Center(
            child: VulcanXSvgLabelIconWidget(
              icon: CommonAssets.icon.newTemplate,
              // 템플릿
              label: 'template'.tr,
            ),
          ),
          onTap: () => onTap.call(NewDocumentType.template),
        ),
      ],
    );
  }
}
