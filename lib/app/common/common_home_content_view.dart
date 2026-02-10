import 'package:app/app/guide/contents/guide_start_content.dart';
import 'package:flutter/material.dart';

import '../account/view/accounts_view.dart';
import '../plan/view/plan_view.dart';
import '../project/view/project_view.dart';
import '../question/view/question_view.dart';
import '../resource/view/resource_view.dart';
import '../setting/view/settings_view.dart';
import '../subscription/view/subscription_view.dart';
import '../template/view/template_view.dart';
import 'common_home_header.dart';
import 'common_view_type.dart';

class CommonHomeContentView extends StatelessWidget {
  final ViewType? viewType;
  const CommonHomeContentView({super.key, this.viewType});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        CommonHomePageHeader(viewType: viewType),
        switch (viewType) {
          ViewType.none => const Center(
              child: CircularProgressIndicator(),
            ),
          ViewType.template => const TemplateView(),
          ViewType.question => const QuestionView(),
          ViewType.guide => const GuideStartContent(),
          ViewType.setting => const SettingsView(),
          ViewType.account => const AccountsView(),
          ViewType.plan => const PlanView(),
          ViewType.subscription => const SubscriptionView(),
          ViewType.resource => const ResourceView(),
          _ => ProjectView(),
        },
      ],
    );
  }
}
