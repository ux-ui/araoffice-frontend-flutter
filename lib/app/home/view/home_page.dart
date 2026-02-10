import 'package:app/app/home/controller/home_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/common_home_content_view.dart';
import '../../common/common_home_drawer.dart';

class HomePage extends GetView<HomeController> {
  static const String route = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // debugPrint('homePage hascode : $hashCode');
    // build 메서드에서 매번 호출하지 않음 (onInit에서 처리)
    // controller.loginController.checkUserSignStatus(context);
    controller.loginController.checkUserShareId(context);
    // controller.apiService.get200ErrorResponse();

    final viewType = controller.viewType.value;

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
