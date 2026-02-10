import 'package:app_ui/app_ui.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/common_home_drawer.dart';
import '../common/common_view_type.dart';
import 'controller/guide_controller.dart';
import 'view/guide_content_view.dart';

class GuidePage extends GetView<GuideController> {
  static const String route = '/guide';

  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewType = controller.viewType;
    logger.i('guidePage viewType : $viewType');

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHomeDrawer(viewType: ViewType.guide),
          const VerDivider(),
          Expanded(
            child: SingleChildScrollView(
                child: Obx(() => GuideContentView(
                    guideViewType: controller.viewType.value))),
          ),
        ],
      ),
    );
  }
}
