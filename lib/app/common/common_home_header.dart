import 'package:app/app/common/common_settings_content_view.dart';
import 'package:app/app/login/view/login_controller.dart';
import 'package:app/app/user_setting/account/account_setting_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common_view_type.dart';

class CommonHomePageHeader extends StatelessWidget {
  final ViewType? viewType;
  final LoginController controller = Get.find<LoginController>();
  final AccountSettingController accountSettingController =
      Get.put(AccountSettingController());

  /// 홈 페이지 우측 화면 상단바
  /// - 각 페이지의 상태에 따라 상단 내용을 관리하는 페이지
  CommonHomePageHeader({super.key, this.viewType});

  @override
  Widget build(BuildContext context) {
    const userId = 'bititon';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 80),
      child: switch (viewType) {
        ViewType.none => const Center(
            child: CircularProgressIndicator(),
          ),
        // 사용자 관리 페이지 추가 시 사용
        // ViewType.account => HomePageHeaderWidget(
        //     userId: userId,
        //     //사용자 관리
        //     title: 'user_menagement'.tr,
        //   ),
        ViewType.plan => HomePageHeaderWidget(
            userId: userId,
            //오서 플랜
            title: 'author_plan'.tr,
          ),
        ViewType.subscription => HomePageHeaderWidget(
            userId: userId,
            //구독 관리
            title: 'subscriptions_management'.tr,
          ),
        // 일반 설정 페이지 추가 시 사용
        // ViewType.setting => HomePageHeaderWidget(
        //     userId: userId,
        //     //일반 설정
        //     title: 'general_settings'.tr,
        //   ),
        ViewType.question => HomePageHeaderWidget(
            userId: userId,
            isSearch: true,
            //검색어를 입력해주세요
            searchHintText: 'input_hint_message'.tr,
          ),
        ViewType.project => const HomePageHeaderWidget(
            userId: userId,
            //isSearch: true,
            //searchHintText: 'hint_text_file_project_search'.tr,
          ),
        ViewType.template => const HomePageHeaderWidget(userId: userId),
        // 리소스 관리 페이지 추가 시 사용
        // ViewType.resource => HomePageHeaderWidget(
        //     userId: userId,
        //     //리소스 관리
        //     title: 'resource_management'.tr,
        //   ),
        _ => const SizedBox(),
      },
    );
  }
}

class HomePageHeaderWidget extends StatefulWidget {
  final String userId;
  final String? title;
  final bool? isSearch;
  final String? searchHintText;

  ///
  /// 페이지 타이틀, 검색, 플랜 업그레이드, 알림, 사용자 아이콘을 표시해주는 widget
  const HomePageHeaderWidget(
      {super.key,
      required this.userId,
      this.title,
      this.isSearch,
      this.searchHintText});

  @override
  State<HomePageHeaderWidget> createState() => _HomePageHeaderWidgetState();
}

class _HomePageHeaderWidgetState extends State<HomePageHeaderWidget> {
  final LoginController controller = Get.find<LoginController>();
  final AccountSettingController accountSettingController =
      Get.put(AccountSettingController());
  final isHovered = false.obs;

  @override
  void initState() {
    super.initState();
    controller.getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.title != null)
          Text(widget.title ?? '', style: context.headlineSmall),
        if (widget.isSearch == true)
          VulcanXTextField(
              width: 336, hintText: widget.searchHintText, isSearchIcon: true),
        const Spacer(),
        PopupMenuButton<String>(
            popUpAnimationStyle: const AnimationStyle(
              curve: Curves.easeInOutCirc,
              duration: Duration(milliseconds: 300),
            ),
            surfaceTintColor: Colors.transparent,
            // onOpened: () => controller.getUserId(),
            onOpened: () => controller.getUser(),
            color: Colors.white,
            offset: const Offset(0, 45), // 팝업 메뉴가 나타날 위치 조정
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(
              () {
                final displayName = controller.userDisplayName.value.isNotEmpty
                    ? controller.userDisplayName.value
                    : 'user';
                return CircleAvatar(
                  backgroundColor: context.primaryContainer,
                  radius: 16,
                  child: Text(displayName.toUpperCase().characters.first,
                      style: context.titleLarge?.apply(color: context.primary)),
                );
              },
            ),
            itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   controller.userLoginType.value.name ==
                          //           TenantType.ara.name
                          //       ? controller.userEmail.value
                          //       : controller.userDisplayName.value,
                          //   style: TextStyle(
                          //     color: Colors.grey[600],
                          //     fontSize: 14,
                          //   ),
                          // ),
                          // Text(
                          //   controller.userId.value,
                          //   style: const TextStyle(
                          //     color: Colors.black,
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 16,
                          //   ),
                          // ),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: 'email: ',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14)),
                            TextSpan(
                                text: controller.userLoginType.value.name ==
                                        TenantType.ara.name
                                    ? controller.userEmail.value
                                    : controller.userDisplayName.value,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14)),
                          ])),
                          const SizedBox(height: 4),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: 'ID: ',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14)),
                            TextSpan(
                                text: controller.userId.value,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ])),

                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: '공유 ID: ',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14)),
                            TextSpan(
                                text: controller.userShareId.value,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14)),
                          ]))
                        ],
                      ),
                    ),
                  ),
                  if (controller.userLoginType.value == TenantType.ara)
                    const PopupMenuItem(
                        padding: EdgeInsets.zero,
                        height: 1,
                        enabled: false,
                        child: Divider(
                          color: Color(0xffEFEFEF),
                        )),
                  if (controller.userLoginType.value == TenantType.ara)
                    CustomPopupItem(
                      icon: Icons.account_circle_outlined,
                      text: 'account_management_settings'.tr,
                      onTap: () async {
                        accountSettingController.titleText.value =
                            'account_management_settings'.tr;
                        await VulcanCloseDialogWidget(
                          // title: accountSettingController.titleText.value,
                          titleWidget: Obx(
                            () => Text(
                              accountSettingController.titleText.value,
                              style: context.titleMedium
                                  ?.apply(color: context.onSurface),
                            ),
                          ),
                          content: Flexible(
                            child: ConstrainedBox(
                              // constraints: BoxConstraints(
                              //   // maxWidth: 1000,
                              //   maxWidth: double.maxFinite,
                              //   minWidth: 500,
                              //   maxHeight:
                              //       MediaQuery.of(context).size.height * 0.8,
                              // ),
                              constraints: BoxConstraints(
                                maxWidth: double.maxFinite,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.8,
                                minWidth: 600, // Dialog의 최소 너비
                                minHeight: 400, // Dialog의 최소 높이
                              ),
                              child: CommonSettingsContentView(
                                initialIndex: 0,
                              ),
                            ),
                          ),
                        ).show(context);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  // CustomPopupItem(
                  //   icon: Icons.drafts_outlined,
                  //   text: '알림 설정',
                  //   onTap: () async {
                  //     accountSettingController.titleText.value = '알림 설정';
                  //     await VulcanCloseDialogWidget(
                  //       // title: accountSettingController.titleText.value,
                  //       titleWidget: Obx(
                  //         () => Text(
                  //           accountSettingController.titleText.value,
                  //           style: context.titleMedium
                  //               ?.apply(color: context.onSurface),
                  //         ),
                  //       ),
                  //       content: Flexible(
                  //         fit: FlexFit.tight,
                  //         child: ConstrainedBox(
                  //           constraints: BoxConstraints(
                  //             // maxWidth: double.maxFinite,
                  //             minWidth: 500,
                  //             maxHeight:
                  //                 MediaQuery.of(context).size.height * 0.8,
                  //           ),
                  //           child: CommonSettingsContentView(
                  //             initialIndex: 1,
                  //           ),
                  //         ),
                  //       ),
                  //     ).show(context);
                  //   },
                  // ),
                  // CustomPopupItem(
                  //   icon: Icons.info_outline,
                  //   text: '연결 설정',
                  //   onTap: () async {
                  //     accountSettingController.titleText.value = '연결 설정';
                  //     await VulcanCloseDialogWidget(
                  //       // title: accountSettingController.titleText.value,
                  //       titleWidget: Obx(
                  //         () => Text(
                  //           accountSettingController.titleText.value,
                  //           style: context.titleMedium
                  //               ?.apply(color: context.onSurface),
                  //         ),
                  //       ),
                  //       content: Flexible(
                  //         child: ConstrainedBox(
                  //           constraints: BoxConstraints(
                  //             maxWidth: double.maxFinite,
                  //             minWidth: 500,
                  //             maxHeight:
                  //                 MediaQuery.of(context).size.height * 0.8,
                  //           ),
                  //           child: CommonSettingsContentView(
                  //             initialIndex: 2,
                  //           ),
                  //         ),
                  //       ),
                  //     ).show(context);
                  //   },
                  // ),
                  const PopupMenuItem(
                      padding: EdgeInsets.zero,
                      height: 1,
                      enabled: false,
                      child: Divider(
                        color: Color(0xffEFEFEF),
                      )),
                  CustomPopupItem(
                    icon: Icons.logout,
                    text: 'connection_info_logout'.tr,
                    onTap: () async {
                      final result = await controller.logout();
                      // RouteGuard가 자동으로 리다이렉트 처리
                      if (!result) {
                        Get.snackbar('error'.tr, 'logout_failed'.tr);
                      }
                    },
                  ),
                ]),
      ],
    );
  }
}

class CustomPopupItem extends PopupMenuEntry<String> {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const CustomPopupItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  CustomPopupItemState createState() => CustomPopupItemState();

  @override
  double get height => throw UnimplementedError();

  @override
  bool represents(String? value) {
    throw UnimplementedError();
  }
}

class CustomPopupItemState extends State<CustomPopupItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
      mouseCursor: SystemMouseCursors.click,
      enabled: false,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isHovered ? context.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(widget.icon, color: Colors.black, size: 20),
                const SizedBox(width: 6),
                Text(
                  widget.text,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
