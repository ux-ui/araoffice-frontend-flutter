import 'package:flutter/material.dart';

import '../home/view/home_drawer_view.dart';
import '../question/view/question_drawer_view.dart';
import '../template/view/tmeplate_drawer_view.dart';
import 'common_view_type.dart';

class CommonHomeDrawer extends StatelessWidget {
  final ViewType? viewType;
  const CommonHomeDrawer({super.key, this.viewType});

  @override
  Widget build(BuildContext context) {
    // 템플릿화면에 해당하는 Drawer를 구현합니다.
    switch (viewType) {
      case ViewType.template:
        return const TemplateDrawerView();
      case ViewType.question || ViewType.guide:
        return const QuestionDrawerView();
      case ViewType.setting:
        return HomeDrawerView();
      case ViewType.account:
        return HomeDrawerView();
      case ViewType.plan:
        return HomeDrawerView();
      case ViewType.subscription:
        return HomeDrawerView();
      case ViewType.resource:
        return HomeDrawerView();
      default:
        return HomeDrawerView();
    }
  }
}
