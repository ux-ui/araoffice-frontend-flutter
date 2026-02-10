// ignore_for_file: deprecated_member_use

import 'package:app/app/guide/guide_page.dart';
import 'package:app/app/home/controller/home_controller.dart';
import 'package:app/app/home/widget/drawer_app_logo.dart';
import 'package:app/app/home/widget/home_drawer_list_item.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../common/common_view_type.dart';
import '../../home/view/home_page.dart';
import '../question_page.dart';

class QuestionDrawerView extends GetWidget<HomeController> {
  const QuestionDrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 240,
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: kAppHorizontalSpace),
            child: DrawerAppLogo(),
          ),
          Column(
            children: [
              HomeDrawerListItem(
                prefixIcon: const Icon(Icons.chevron_left),
                //홈으로 돌아가기
                title: 'back_home'.tr,
                onTap: () => context.go(HomePage.route),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const HorDivider(),
          const SizedBox(height: 16),
          HomeDrawerListItem(
            prefixIcon: CommonAssets.icon.help.svg(width: 20, height: 20),
            // 도움말
            title: 'help'.tr,
            onTap: () {},
          ),
          VulcanXExpansionPanelList(
            //expansionCallback: (panelIndex, isExpanded) {},
            children: [
              VulcanXExpansionPanel(
                isExpanded: true,
                headerBuilder: (context, isExpanded) {
                  return VulcanXText(
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),

                    //제작 가이드
                    text: 'making_guide'.tr,
                    style: context.bodyLarge,
                    prefixIcon: CommonAssets.icon.developerGuide
                        .svg(width: 20, height: 20),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.only(left: 45.0, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSubCategory(
                          // 시작하기
                          label: 'start'.tr,
                          onTap: () => context.go(
                              '${QuestionPage.route}${GuidePage.route}/guide-start')),
                      _buildSubCategory(
                          // 다운로드
                          label: 'download'.tr,
                          onTap: () => context.go(
                              '${QuestionPage.route}${GuidePage.route}/guide-download')),
                      // 프로젝트 생성
                      _buildSubCategory(
                          label: 'create_project'.tr, onTap: () {}),
                      // 파일 및 프로젝트
                      _buildSubCategory(
                          label: 'file_and_project'.tr, onTap: () {}),
                    ],
                  ),
                ),
              ),
            ],
          ),
          HomeDrawerListItem(
            prefixIcon: CommonAssets.icon.contract.svg(width: 20, height: 20),
            // 튜토리얼
            title: 'tutorial'.tr,
            onTap: () {
              controller.updateViewType(ViewType.setting);
            },
          ),
          HomeDrawerListItem(
            prefixIcon: CommonAssets.icon.box.svg(width: 20, height: 20),
            // 자주묻는 질문
            title: 'faq'.tr,
            onTap: () {
              controller.updateViewType(ViewType.setting);
            },
          ),
          const HorDivider(),
        ],
      ),
    );
  }

  Widget _buildSubCategory(
      {required String label, required VoidCallback onTap}) {
    return VulcanXText(
      text: label,
      height: 40.0,
      padding: const EdgeInsets.only(left: 10),
      onTap: () => onTap.call(),
    );
  }
}
