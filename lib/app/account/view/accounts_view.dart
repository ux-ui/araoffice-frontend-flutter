import 'package:app/app/account/controller/accounts_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountsView extends StatefulWidget {
  const AccountsView({super.key});
  @override
  State<AccountsView> createState() => _AccountsViewState();
}

class _AccountsViewState extends State<AccountsView> {
  final AccountsController controller = AccountsController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'account_management_message'.tr,
            style: context.titleMedium?.copyWith(color: context.onSurface),
          ),
          const SizedBox(height: 12),
          const ListHeader(),
          const SizedBox(height: 12),
          SizedBox(
            // 임시 사이즈 지정
            height: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.accountsList.length,
              itemBuilder: (context, index) {
                final account = controller.accountsList[index];
                return AccountsItem(
                  name: account.name,
                  email: account.email,
                  role: account.role,
                  projectCount: account.projectCount,
                  lastActivity: account.lastActivity,
                  avatarText: account.avatarText,
                  avatarColor: account.avatarColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ListHeader extends StatelessWidget {
  const ListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _textIconRow(context, 'account_management_name'.tr, null),
          ),
          Expanded(
            flex: 2,
            child: _textIconRow(context, 'account_management_role'.tr, null),
          ),
          Expanded(
              flex: 2,
              child: _textIconRow(
                  context, 'account_management_project_count'.tr, null)),
          Expanded(
              flex: 2,
              child: _textIconRow(
                  context, 'account_management_last_activity'.tr, null)),
        ],
      ),
    );
  }

  Widget _textIconRow(BuildContext context, String text, Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            text,
            style: context.bodyMedium?.copyWith(color: context.onSurface),
          ),
          const SizedBox(width: 4),
          CommonAssets.icon.swapVert.svg(width: 9, height: 12),
        ],
      ),
    );
  }
}

class AccountsItem extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final int projectCount;
  final String lastActivity;
  final String avatarText;
  final Color avatarColor;

  const AccountsItem({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.projectCount,
    required this.lastActivity,
    required this.avatarText,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // 이름과 이메일 섹션
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: avatarColor,
                  radius: 16,
                  child: Text(
                    avatarText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 권한
          Expanded(
            flex: 2,
            child: Text(role),
          ),
          // 프로젝트 수
          Expanded(
            flex: 2,
            child: Text(projectCount.toString()),
          ),
          // 최근 활동
          Expanded(
            flex: 2,
            child: Text(lastActivity),
          ),
          // 메뉴 버튼
          PopupMenuButton(
            iconSize: 14,
            tooltip: 'popup Tooltip',
            color: context.background,
            surfaceTintColor: context.background,
            icon: Icon(
              Icons.more_vert,
              color: context.onSurface,
            ),
            itemBuilder: (context) {
              return [
                CustomPopupMenuItem(
                  value: 'profile',
                  child: Text('account_management_profile_view'.tr),
                ),
                CustomPopupMenuItem(
                  value: 'remove',
                  child: Text('account_management_remove_user'.tr),
                ),
              ];
            },
            onSelected: (value) {},
          ),
        ],
      ),
    );
  }
}
