import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/common_home_content_view.dart';
import '../common/common_home_drawer.dart';
import 'controller/template_controller.dart';

class TemplatePage extends GetView<TemplateController> {
  static const String route = '/template';

  /// 템플릿 마켓 페이지
  const TemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewType = controller.viewType.value;
    debugPrint('viewType : $viewType');

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHomeDrawer(
            viewType: viewType,
          ),
          const VerDivider(),
          Expanded(
            child: SingleChildScrollView(
                child: CommonHomeContentView(
              viewType: viewType,
            )),
          ),
        ],
      ),
    );
  }
}
