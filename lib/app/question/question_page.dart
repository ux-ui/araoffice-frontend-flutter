import 'package:app/app/question/controller/question_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/common_home_content_view.dart';
import '../common/common_home_drawer.dart';

class QuestionPage extends GetView<QuestionController> {
  static const String route = '/question';

  const QuestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewType = controller.viewType.value;
    debugPrint('viewType : $viewType');

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
