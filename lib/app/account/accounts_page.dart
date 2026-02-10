import 'package:app_ui/app_ui.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/common_home_content_view.dart';
import '../common/common_home_drawer.dart';
import 'controller/accounts_controller.dart';

class AccountsPage extends GetView<AccountsController> {
  static const String route = '/accounts';

  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewType = controller.viewType.value;
    logger.i('viewType : $viewType');

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHomeDrawer(viewType: viewType),
          const VerDivider(),
          Expanded(
            child: SingleChildScrollView(
                child: CommonHomeContentView(viewType: viewType)),
          ),
        ],
      ),
    );
  }
}
