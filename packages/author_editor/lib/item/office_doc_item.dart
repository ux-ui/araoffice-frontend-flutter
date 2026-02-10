import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../vulcan_editor_eventbus.dart';

@Deprecated('추후 제거 예정')
class OfficeDocItem extends StatelessWidget with EditorEventbus {
  OfficeDocItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          runSpacing: 10.0,
          spacing: 10.0,
          children: [
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                child: VulcanXSvgLabelIconWidget(
                  icon: CommonAssets.icon.officeHwp,
                  label: 'office_hwp'.tr,
                ),
              ),
              onTap: () => _showOfficeViewDialog(context, ['hwp']),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                child: VulcanXSvgLabelIconWidget(
                  icon: CommonAssets.icon.officeHwp,
                  label: 'office_hwpx'.tr,
                ),
              ),
              onTap: () => _showOfficeViewDialog(context, ['hwpx']),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                child: VulcanXSvgLabelIconWidget(
                  icon: CommonAssets.icon.officeDoc,
                  label: 'office_ms_doc'.tr,
                ),
              ),
              onTap: () => _showOfficeViewDialog(context, ['doc']),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                child: VulcanXSvgLabelIconWidget(
                  icon: CommonAssets.icon.officeDoc,
                  label: 'office_ms_docx'.tr,
                ),
              ),
              onTap: () => _showOfficeViewDialog(context, ['docx']),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                child: VulcanXSvgLabelIconWidget(
                  icon: CommonAssets.icon.officeOdt,
                  label: 'office_odt'.tr,
                ),
              ),
              onTap: () => _showOfficeViewDialog(context, ['odt']),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                child: VulcanXSvgLabelIconWidget(
                  icon: CommonAssets.icon.officeEpub,
                  label: 'office_epub'.tr,
                ),
              ),
              onTap: () => _showEpubViewDialog(context, 'epub'),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                child: VulcanXSvgLabelIconWidget(
                  icon: CommonAssets.icon.officeTxt,
                  label: 'office_txt'.tr,
                ),
              ),
              onTap: () => _showOfficeViewDialog(context, ['txt']),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                child: VulcanXSvgLabelIconWidget(
                  icon: CommonAssets.icon.officeXhtml,
                  label: 'office_xhtml'.tr,
                ),
              ),
              onTap: () => _showOfficeViewDialog(context, ['xhtml']),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(BuildContext context, String message) async {
    return controller.showDragDocsAlertDialog(context, message);
  }

  Future<void> _showOfficeViewDialog(
    BuildContext context,
    List<String> extensions,
  ) async {
    final file =
        await controller.pickDocumentFile(context, extensions: extensions);
    if (file != null && context.mounted) {
      return controller.showDragDocsWebViewDialog(
        context,
        fileBytes: file.bytes,
        fileName: file.name,
      );
    }
  }

  Future<void> _showEpubViewDialog(
    BuildContext context,
    String extension,
  ) async {
    return controller.showEpubViewerWebViewDialog(context);
  }
}
