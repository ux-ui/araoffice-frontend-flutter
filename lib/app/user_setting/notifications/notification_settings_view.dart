import 'package:app/app/user_setting/common_settins_item.dart';
import 'package:app_ui/widgets/bto/switch_button.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsItem(
          title: Text(
            'notification_update_notice'.tr,
          ),
          action: BtoSwitchBtn(
            initValue: true,
            onChanged: (value) {},
            // disabled: true,
          ),
          subTitle: (AutoConfig.instance.domainType.isDferiDomain)
              ? 'non_ara_notification_update_notice_message'.tr
              : 'notification_update_notice_message'.tr,
          border: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        SettingsItem(
          title: Text(
            'notification_newsletter'.tr,
          ),
          subTitle: 'notification_newsletter_message'.tr,
          action: BtoSwitchBtn(
            initValue: true,
            onChanged: (value) {},
            // disabled: true,
          ),
          border: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        SettingsItem(
          title: Text(
            'subscription_info'.tr,
          ),
          subTitle: 'subscription_info_message'.tr,
          action: BtoSwitchBtn(
            initValue: true,
            onChanged: (value) {},
            // disabled: true,
          ),
          border: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        SettingsItem(
          title: Text(
            'event_notice'.tr,
          ),
          subTitle: (AutoConfig.instance.domainType.isDferiDomain)
              ? 'non_ara_event_notice_message'.tr
              : 'event_notice_message'.tr,
          action: BtoSwitchBtn(
            initValue: true,
            onChanged: (value) {},
            // disabled: true,
          ),
          border: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        SettingsItem(
          title: Text(
            (AutoConfig.instance.domainType.isDferiDomain)
                ? 'non_ara_araxo_activity_notice'.tr
                : 'araxo_activity_notice'.tr,
          ),
          subTitle: (AutoConfig.instance.domainType.isDferiDomain)
              ? 'non_ara_araxo_activity_notice_message'.tr
              : 'araxo_activity_notice_message'.tr,
          action: BtoSwitchBtn(
            initValue: true,
            onChanged: (value) {},
            // disabled: true,
          ),
          border: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ],
    );
  }
}
