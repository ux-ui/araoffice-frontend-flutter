import 'package:app/app/user_setting/account/account_setting_controller.dart';
import 'package:app/app/user_setting/common_settins_item.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectionSettingsView extends StatefulWidget {
  const ConnectionSettingsView({super.key});

  @override
  State<ConnectionSettingsView> createState() => _ConnectionSettingsViewState();
}

class _ConnectionSettingsViewState extends State<ConnectionSettingsView> {
  final AccountSettingController controller =
      Get.find<AccountSettingController>();

  List<ConnectionData> connectionDataList = [
    ConnectionData('201.101.67.128', 'Chrome', true,
        location: 'Jongro-Gu, South Korea',
        environment: 'Windows',
        lastConnectionDate: '2024.07.01 14:28'),
    ConnectionData('No IP address found', '-', false,
        location: '위치 알 수 없음',
        environment: '-',
        lastConnectionDate: '2024.07.01 14:28'),
    ConnectionData('201.101.67.128', 'Chrome', false,
        location: 'Jongro-Gu, South Korea',
        environment: 'Windows',
        lastConnectionDate: '2024.07.01 14:28'),
    ConnectionData('201.101.67.128', 'Chrome', false,
        location: 'Jongro-Gu, South Korea',
        environment: 'Windows',
        lastConnectionDate: '2024.07.01 14:28'),
    ConnectionData('201.101.67.128', 'Chrome', false,
        location: 'Jongro-Gu, South Korea',
        environment: 'Windows',
        lastConnectionDate: '2024.07.01 14:28')
  ];
  @override
  void initState() {
    controller.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SettingsItem(
          title: Text(
            'connection_info_message'.tr,
          ),
          // action: SizedBox(),
          border: false,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'connection_info_location'.tr,
                style: context.bodySmall?.apply(color: context.outlineVariant),
              ),
              Text(
                'connection_info_environment'.tr,
                style: context.bodySmall?.apply(color: context.outlineVariant),
              ),
              Text(
                'connection_info_last_access'.tr,
                style: context.bodySmall?.apply(color: context.outlineVariant),
              ),
              Text(
                'connection_info_manage'.tr,
                style: context.bodySmall?.apply(color: context.outlineVariant),
              ),
            ],
          ),
        ),
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: connectionDataList.length,
            itemBuilder: (context, index) {
              return ConnectionItem(data: connectionDataList[index]);
            })
      ],
    );
  }
}

class ConnectionItem extends StatelessWidget {
  final ConnectionData data;
  const ConnectionItem({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  data.location ?? 'connection_info_location_unknown'.tr,
                  style: context.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  data.ip ?? 'connection_info_ip_unknown'.tr,
                  style:
                      context.bodySmall?.apply(color: context.outlineVariant),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.environment ?? '-',
                  style: context.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  data.browser ?? '-',
                  style:
                      context.bodySmall?.apply(color: context.outlineVariant),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.lastConnectionDate ?? '-',
                  style: context.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  data.lastConnectionDate ?? '-',
                  style:
                      context.bodySmall?.apply(color: context.outlineVariant),
                ),
              ],
            ),
            Text(
              data.checkState ?? false
                  ? 'connection_info_disconnect'.tr
                  : 'connection_info_logout'.tr,
              style: data.checkState ?? false
                  ? context.bodySmall?.apply(color: context.error)
                  : context.bodySmall?.apply(
                      color: context.outlineVariant,
                    ),
            )
          ],
        ));
  }
}

class ConnectionData {
  final String? location;
  final String? ip;
  final String? environment;
  final String? browser;
  final String? lastConnectionDate;
  final bool? checkState;

  ConnectionData(this.ip, this.browser, this.checkState,
      {this.location, this.environment, this.lastConnectionDate});
}
