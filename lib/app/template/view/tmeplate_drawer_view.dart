import 'package:app/app/home/controller/home_controller.dart';
import 'package:app/app/home/widget/drawer_app_logo.dart';
import 'package:app/app/home/widget/home_drawer_list_item.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../home/view/home_page.dart';

class TemplateDrawerView extends GetWidget<HomeController> {
  const TemplateDrawerView({super.key});

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
                title: 'back_home'.tr,
                onTap: () {
                  context.go(HomePage.route);
                },
              ),
            ],
          ),
          // const SizedBox(height: 16),
          // const HorDivider(),
          // const SizedBox(height: 16),
          // 카테고리 페이지 추가 시 사용
          // HomeDrawerListItem(
          //   title: 'category'.tr,
          //   onTap: () {},
          // ),
          // const SizedBox(height: 16),
          // const HorDivider(),
          // const SizedBox(height: 16),
          // 라이선스 페이지 추가 시 사용
          // HomeDrawerListItem(
          //   title: 'license'.tr,
          //   onTap: () {},
          // ),
        ],
      ),
    );
  }
}
