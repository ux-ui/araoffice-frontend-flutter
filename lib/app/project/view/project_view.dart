import 'package:api/api.dart';
import 'package:app/app/dialog/folder_create_dialog.dart';
import 'package:app/app/editor/editor_page.dart';
import 'package:app/app/login/view/login_controller.dart';
import 'package:app/app/login/view/tenant_setting_controller.dart';
import 'package:app/app/project/controller/cloud_controller.dart';
import 'package:app/app/project/controller/project_controller.dart';
import 'package:app/app/project/view/cloud_list_view.dart';
import 'package:app/app/project/view/project_list_view.dart';
import 'package:app_ui/app_ui.dart';
import 'package:author_editor/mixins/cloud_connection_mixin.dart';
import 'package:common_assets/common_assets.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../office/office_page.dart';

class ProjectView extends GetView<ProjectController> with CloudConnectionMixin {
  final LoginController loginController = Get.find<LoginController>();
  final CloudController cloudController = Get.find<CloudController>();
  final TenantSettingController tenantSettingController =
      Get.find<TenantSettingController>();

  ProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 80),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //____________________
          //전체 프로젝트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('title_all_projrects'.tr, style: context.headlineSmall),
              // 네이버웍스 클라우드 드롭다운

              // TODO: 클라우드 타입에 따른 연결 상태 확인
              // Obx(() => cloudController.rxIsNaverWorksConnected.isTrue
              //     ? _buildCloudDrive(context)
              //     : const SizedBox.shrink()),

              // 테넌트 설정에 따른 클라우드 설정 on off
              Obx(() => tenantSettingController.cloudLinkStatus.value
                  ? _buildCloudDrive(context)
                  : const SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return isWide
                  ? Row(
                      children: [
                        Expanded(child: _buildProjectButton(context)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFolderButton(context)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildProjectButton(context),
                        const SizedBox(height: 16),
                        _buildFolderButton(context),
                      ],
                    );
            },
          ),
          // _buildNicknameButton(context),
          const SizedBox(height: 24),
          _buildProjectView(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Widget _buildNicknameButton(BuildContext context) {
  //   // 닉네임 생성 버튼 (닉네임을 보여주는 칸이 존재하며, 재생성 버튼, 확인 버튼이 존재, 여러 후보들 중 선택하는 기능도 존재)
  //   return VulcanXTwoSvgIconOutlinedButton(
  //     height: 56,
  //     iconWidth: 24,
  //     iconHeight: 24,
  //     text: '닉네임 생성',
  //     prefixIcon: CommonAssets.icon.newProjectIcon,
  //     suffixIcon: CommonAssets.icon.add,
  //     onPressed: () async {
  //       final result = await loginController.authSecureCheck();
  //       if (!context.mounted) return;

  //       if (result) {
  //         await VulcanCloseDialogWidget(
  //           width: 600,
  //           title: '닉네임 생성',
  //           // content: _NicknameGenerateDialog(
  //           content: ShareIdChangeDialog(
  //             loginController: loginController,
  //             onConfirm: (nickname) {
  //               if (nickname.isNotEmpty) {
  //                 // 닉네임을 사용자 정보에 업데이트하는 로직
  //                 // 예: loginController.updateDisplayName(nickname);
  //                 debugPrint('선택된 닉네임: $nickname');
  //               }
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ).show(context);
  //       } else {
  //         context.go('/login');
  //       }
  //     },
  //   );
  // }

  // 네이버웍스 클라우드 드롭다운
  Widget _buildCloudDrive(BuildContext context) {
    if (cloudController.supportedCloudTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Visibility(
      visible: (
          // AutoConfig.instance.domainType.isMsitDomain ||
          AutoConfig.instance.domainType.isMoisDomain ||
              AutoConfig.instance.domainType.isMfdsDomain ||
              AutoConfig.instance.domainType.isLocalDevDomain ||
              AutoConfig.instance.domainType.isMoisLocalDomain),
      child: VulcanXDropdown<CloudType>(
        width: 180,
        height: 40,
        hintText: 'cloud_title'.tr,
        displayStringForOption: (option) => option.displayName,
        value: cloudController.rxCurrentCloudType.value,
        items: cloudController.supportedCloudTypes
            .map((type) => VulcanXIconDropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      type.icon,
                      const SizedBox(width: 8),
                      Text(type.title),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (value) async {
          if (value == null) return;
          final isConnected = await handleCloudConnection(
            context,
            onConnect: () {
              debugPrint(
                  '[CloudConnection] onConnect: ${GoRouter.of(context).state.uri}');
              final loginController = Get.find<LoginController>();
              loginController.naverWorksLogin();
            },
          );
          if (isConnected != true) {
            return;
          }

          await cloudController.changeCloudType(value);
          await cloudController.loadFilesOnInit();
          VulcanCloseDialogWidget(
            width: 980,
            titleWidget: Row(
              children: [
                value.icon,
                const SizedBox(width: 8),
                Text(value.title),
              ],
            ),
            // title: 'cloud_title'.tr,
            content: CloudFileTreePage(
              baseUrl: ApiDio.apiHostAppServer,
              controller: cloudController,
              onCloseDialog: (CloudFileModel file) {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (context.mounted) {
                    context.go(OfficePage.route, extra: {'file': file});
                  }
                });
              },
            ),
          ).show(context);
        },
      ),
    );
  }

  Widget _buildProjectView() {
    return FileTreePage(
      baseUrl: ApiDio.apiHostAppServer,
      controller: controller,
    );
  }

  Widget _buildProjectButton(BuildContext context) {
    return VulcanXTwoSvgIconOutlinedButton(
      height: 56,
      iconWidth: 24,
      iconHeight: 24,
      // text: loginController.userLoginType.value != TenantType.dferi
      text: AutoConfig.instance.domainType.isAraDomain
          ? 'create_project_title'.tr
          : 'non_ara_create_project_title'.tr,
      prefixIcon: CommonAssets.icon.newProjectIcon,
      suffixIcon: CommonAssets.icon.add,
      onPressed: () async {
        final result = await loginController.authSecureCheck();
        if (!context.mounted) return;

        if (result) {
          final folderId = controller.rxFolderInfo.value?.id;
          context.go(
            EditorPage.route,
            extra: {'displayType': 'create', 'folderId': folderId},
          );
        } else {
          context.go('/login');
        }
      },
    );
  }

  Widget _buildFolderButton(BuildContext context) {
    return VulcanXTwoSvgIconOutlinedButton(
      height: 56,
      iconWidth: 24,
      iconHeight: 24,
      text: 'create_folder_title'.tr,
      prefixIcon: CommonAssets.icon.newFolderIcon,
      suffixIcon: CommonAssets.icon.add,
      onPressed: () async {
        final result = await loginController.authSecureCheck();
        if (!context.mounted) return;

        if (result) {
          await VulcanCloseDialogWidget(
            width: 320,
            title: 'create_folder_title'.tr,
            content: FolderCreateDialog(onTap: (value) {
              controller.createFolder(
                  targetFolderId: controller.rxFolderInfo.value?.id ?? 'root',
                  name: value);
              context.pop();
            }),
          ).show(context);
        } else {
          context.go('/login');
        }
      },
    );
  }
}
