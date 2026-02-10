import 'package:app/app/user_setting/account/account_setting_controller.dart';
import 'package:app/app/user_setting/account/account_settings_view.dart';
import 'package:app/app/user_setting/connection/connection_settings_view.dart';
import 'package:app/app/user_setting/notifications/notification_settings_view.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonSettingsContentView extends StatefulWidget {
  final int initialIndex;
  final AccountSettingController accountsController =
      Get.find<AccountSettingController>();

  CommonSettingsContentView({super.key, required this.initialIndex});

  @override
  CommonSettingsContentViewState createState() =>
      CommonSettingsContentViewState();
}

class CommonSettingsContentViewState extends State<CommonSettingsContentView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialIndex);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTab(
      {required IconData icon, required String title, required int index}) {
    return InkWell(
      onTap: () {
        widget.accountsController.titleText.value = title;
        _tabController.animateTo(index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: _tabController.index == index
              ? context.surfaceContainer
              : context.surfaceContainerLowest,
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color:
                    _tabController.index == index ? Colors.blue : Colors.black),
            const SizedBox(width: 16),
            SizedBox(
              width: 76,
              child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      color: _tabController.index == index
                          ? Colors.blue
                          : Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // const double minLeftWidth = 200.0; // 왼쪽 탭 영역 최소 너비
        // const double minRightWidth = 400.0; // 오른쪽 콘텐츠 영역 최소 너비
        // const double minTotalWidth =
        //     minLeftWidth + minRightWidth + 16; // 16은 중간 간격

        return Scrollable(
          viewportBuilder: (context, viewportOffset) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽 탭바
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    color: context.surfaceContainerLowest,
                  ),
                  // width: constraints.maxWidth * 0.3,
                  height: constraints.maxHeight,
                  child: IntrinsicWidth(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch, // 추가
                        children: [
                          _buildTab(
                            icon: Icons.account_circle_outlined,
                            title: 'account_management_settings'.tr,
                            index: 0,
                          ),
                          // _buildTab(
                          //   icon: Icons.drafts_outlined,
                          //   title: '알림 설정',
                          //   index: 1,
                          // ),
                          // _buildTab(
                          //   icon: Icons.info_outline,
                          //   title: '연결 설정',
                          //   index: 2,
                          // ),

                          // const Spacer()
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 오른쪽 탭바 뷰
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: constraints.maxHeight,
                      width: constraints.maxWidth,
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: const [
                          SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: AccountSettingsView(),
                            ),
                          ),
                          SingleChildScrollView(
                            child: Padding(
                                padding: EdgeInsets.all(16),
                                child: NotificationSettingsView()),
                          ),
                          SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: ConnectionSettingsView(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
