import 'package:api/api.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../editor/editor_page.dart';

class TemplatePreviewDialog extends StatelessWidget {
  final String templateUrl;
  final TemplateModel templateModel;

  const TemplatePreviewDialog(
      {required this.templateUrl, required this.templateModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          templateModel.name,
          style: context.titleMedium,
        ),
        const SizedBox(height: 16),
        previewBody(context),
        const SizedBox(height: 16),
        VulcanXElevatedButton.primary(
            onPressed: () => context.go(EditorPage.route, extra: {
                  'displayType': 'create',
                  'templateId': templateModel.id
                }),
            //템플릿 적용하여 새프로젝트 만들기
            child: Text('create_from_template'.tr)),
      ],
    );
  }

  Widget previewBody(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 16, // 가로 간격
        runSpacing: 16, // 세로 간격
        children: templateModel.pages.map(
          (page) {
            final url = '$templateUrl${templateModel.id}/${page.thumbnail}';
            return VulcanXRoundedContainer.grey(
              width: 200,
              height: 300,
              child: Image.network(
                url,
                width: 200,
                height: 300,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.grey),
                  );
                },
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
