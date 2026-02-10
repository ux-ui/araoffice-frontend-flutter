import 'package:app/app/editor/editor_page.dart';
import 'package:app/app/home/controller/home_controller.dart';
import 'package:app/app/login/view/login_controller.dart';
import 'package:app/app/login/view/tenant_setting_controller.dart';
import 'package:app/app/project/controller/project_controller.dart';
import 'package:app/app/subscription/subscription_page.dart';
import 'package:app/app/template/template_page.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../plan/plan_page.dart';
import '../widget/drawer_app_logo.dart';
import '../widget/home_drawer_list_item.dart';

class HomeDrawerView extends GetWidget<HomeController> {
  HomeDrawerView({super.key});
  final ProjectController projectController = Get.find<ProjectController>();
  final LoginController loginController = Get.find<LoginController>();
  final TenantSettingController tenantSettingController =
      Get.find<TenantSettingController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.surfaceBright,
      width: 240,
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: kAppHorizontalSpace),
            child: DrawerAppLogo(),
          ),
          Obx(() {
            return Column(
              children: [
                HomeDrawerListItem(
                  prefixIcon: Row(
                    children: [
                      controller.isProjectExpanded.value
                          ? CommonAssets.icon.keyboardArrowUp
                              .svg(width: 20, height: 20)
                          : CommonAssets.icon.keyboardArrowDown
                              .svg(width: 20, height: 20),
                      CommonAssets.icon.accountBox.svg(
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                              context.primary, BlendMode.srcIn)),
                    ],
                  ),
                  title: 'home_drawer_own_project'
                      .trArgs([loginController.userDisplayName.value]),
                  onTap: () {
                    controller.isProjectExpanded.value =
                        !controller.isProjectExpanded.value;
                  },
                  suffixIcon: Container(
                    decoration: BoxDecoration(
                      color: context.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          'Free',
                          style: context.labelSmall?.apply(
                            color: context.primary,
                          ),
                        )),
                  ),
                ),
                if (controller.isProjectExpanded.value)
                  // ...controller.projects.map((project) {
                  ...projectController.rxRecentProjects.map((project) {
                    return HomeDrawerListItem(
                      prefixIcon: const SizedBox(width: 20),
                      title: project.name,
                      onTap: () =>
                          context.go('${EditorPage.route}?p=${project.id}'),
                    );
                  }),
              ],
            );
          }),
          const SizedBox(height: 16),
          const HorDivider(),
          const SizedBox(height: 16),
          Obx(
            () => Visibility(
              visible: tenantSettingController.templateMarketingStatus.value,
              child: HomeDrawerListItem(
                prefixIcon:
                    CommonAssets.icon.category.svg(width: 20, height: 20),
                title: 'template_market'.tr,
                onTap: () => context.go(TemplatePage.route),
                suffixIcon:
                    CommonAssets.icon.arrowForward.svg(width: 20, height: 20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Visibility(
              visible: tenantSettingController.authorPlanStatus.value,
              child: const Column(
                children: [
                  HorDivider(),
                  SizedBox(height: 16),
                ],
              ))),
          // const SizedBox(height: 16),
          // 일반 설정 페이지 추가 시 사용
          // HomeDrawerListItem(
          //     prefixIcon: CommonAssets.icon.pageInfo.svg(width: 20, height: 20),
          //     title: 'general_settings'.tr,
          //     onTap: () => context.go(SettingsPage.route)),
          // 사용자 관리 페이지 추가 시 사용
          // HomeDrawerListItem(
          //     prefixIcon:
          //         CommonAssets.icon.accountCircle.svg(width: 20, height: 20),
          //     title: 'user_menagement'.tr,
          //     onTap: () => context.go(AccountsPage.route)),
          Obx(
            () => Visibility(
              visible: tenantSettingController.authorPlanStatus.value,
              child: HomeDrawerListItem(
                  prefixIcon:
                      CommonAssets.icon.diamond.svg(width: 20, height: 20),
                  title: 'author_plan'.tr,
                  onTap: () => context.go(PlanPage.route)),
            ),
          ),
          Obx(
            () => Visibility(
              visible: tenantSettingController.subscribeManagementStatus.value,
              child: HomeDrawerListItem(
                  prefixIcon: CommonAssets.icon.paid.svg(width: 20, height: 20),
                  title: 'subscriptions_management'.tr,
                  onTap: () => context.go(SubscriptionPage.route)),
            ),
          ),
          // 리소스 관리 페이지 추가 시 사용
          // HomeDrawerListItem(
          //     prefixIcon: CommonAssets.icon.box.svg(width: 20, height: 20),
          //     title: 'resource_management'.tr,
          //     onTap: () => context.go(ResourcePage.route)),
          Obx(
            () => Visibility(
              visible: tenantSettingController.helpCenterStatus.value,
              child: HomeDrawerListItem(
                prefixIcon: CommonAssets.icon.help.svg(width: 20, height: 20),
                title: 'help_center'.tr,
                // TODO: FAQ 페이지
                // onTap: () => context.go(QuestionPage.route),
                onTap: () async {
                  final url = controller.getFAQUrl();
                  await launchUrl(Uri.parse(url));
                },
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: tenantSettingController.termsOfServiceStatus.value,
              child: HomeDrawerListItem(
                prefixIcon: CommonAssets.icon.info.svg(width: 20, height: 20),
                title: 'info_terms_of_service'.tr,
                onTap: () async {
                  final url = controller.getUrlTerms();
                  await launchUrl(Uri.parse(url));
                },
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: tenantSettingController.privacyPolicyStatus.value,
              child: HomeDrawerListItem(
                prefixIcon: CommonAssets.icon.info.svg(width: 20, height: 20),
                title: 'info_privacy_policy'.tr,
                onTap: () async {
                  final url = controller.getUrlPrivacyPolicy();
                  await launchUrl(Uri.parse(url));
                },
              ),
            ),
          ),
          Visibility(
            visible: AutoConfig.instance.domainType.isDferiDomain
                ? false
                : tenantSettingController.youthProtectionPolicyStatus.value,
            child: HomeDrawerListItem(
              prefixIcon: CommonAssets.icon.info.svg(width: 20, height: 20),
              title: 'info_youth_protection_policy'.tr,
              onTap: () async {
                final url = controller.getUrlYouthProtectionPolicy();
                await launchUrl(Uri.parse(url));
              },
            ),
          ),
        ],
      ),
    );
  }
}
