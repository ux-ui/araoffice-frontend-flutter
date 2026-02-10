import 'package:app/app/login/view/login_page.dart';
import 'package:app_ui/app_ui.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'find_account_controller.dart';

class FindAccountPage extends StatefulWidget {
  final bool? initialPage;
  const FindAccountPage({super.key, this.initialPage});

  static const String route = '/find-account';

  @override
  State<FindAccountPage> createState() => _FindAccountPageState();
}

class _FindAccountPageState extends State<FindAccountPage> {
  final FindAccountController controller = Get.find<FindAccountController>();

  @override
  void initState() {
    super.initState();
    controller.resetControllers();
    if (widget.initialPage != null) {
      final initialType =
          widget.initialPage! ? FindAccountType.id : FindAccountType.password;
      controller.updateType(initialType);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _switchTab(FindAccountType type) {
    setState(() {
      controller.updateType(type);
      controller.resetControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // CommonAssets.image.loginBrand.svg(),
                Obx(() => Text(
                    controller.currentType.value == FindAccountType.id
                        ? 'find_id'.tr
                        : 'find_password'.tr,
                    style: context.titleLarge)),
                const SizedBox(height: 32),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      VulcanXSelectableButton(
                        text: 'find_id'.tr,
                        isSelected:
                            controller.currentType.value == FindAccountType.id,
                        onTap: () => _switchTab(FindAccountType.id),
                      ),
                      VulcanXSelectableButton(
                        text: 'find_password'.tr,
                        isSelected: controller.currentType.value ==
                            FindAccountType.password,
                        onTap: () => _switchTab(FindAccountType.password),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.currentType.value ==
                            FindAccountType.password) ...[
                          Text('find_id_title'.tr, style: context.bodyMedium),
                          const SizedBox(height: 8),
                          _buildTextField(
                            context,
                            controller: controller.passwordFindIdController,
                            hintText: 'find_password_id_required'.tr,
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text('account_management_email'.tr,
                            style: context.bodyMedium),
                        const SizedBox(height: 8),
                        _buildTextField(
                          context,
                          controller: controller.findAccountEmailController,
                          hintText: 'find_id_email_required'.tr,
                        ),
                        const SizedBox(height: 8),
                        if (controller.currentEmailStatus)
                          _buildTextField(
                            context,
                            controller: controller.currentAuthCodeController,
                            hintText:
                                'find_account_email_auth_code_required'.tr,
                            suffixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Obx(() => VulcanXOutlinedButton(
                                    onPressed: controller.currentAuthCodeValid
                                        ? null // 인증 성공 시 버튼 비활성화
                                        : () async {
                                            final result = await controller
                                                .verifyCurrentAuthCode();
                                            if (result) {
                                              if (controller
                                                      .currentType.value ==
                                                  FindAccountType.id) {
                                                final userId = await controller
                                                    .lookupUserId();
                                                controller
                                                    .setCurrentAuthCodeValid(
                                                        true);
                                                controller.findIdResult.value =
                                                    userId ?? '';
                                                if (!context.mounted) return;
                                                VulcanCloseDialogWidget(
                                                  width: 250,
                                                  title:
                                                      'find_account_info_title'
                                                          .tr,
                                                  content: Text(userId ?? ''),
                                                ).show(context);
                                              } else {
                                                controller
                                                    .setCurrentAuthCodeValid(
                                                        true);
                                                if (!context.mounted) return;
                                                VulcanCloseDialogWidget(
                                                  width: 250,
                                                  title:
                                                      'find_account_info_title'
                                                          .tr,
                                                  content: Text(
                                                      'find_account_email_auth_code_check'
                                                          .tr),
                                                ).show(context);
                                                context.push('/change-password',
                                                    extra: {
                                                      'userId': controller
                                                          .passwordFindIdController
                                                          .text,
                                                      'email': controller
                                                          .findAccountEmailController
                                                          .text,
                                                    });
                                              }
                                            } else {
                                              if (!context.mounted) return;
                                              VulcanCloseDialogWidget(
                                                width: 250,
                                                title: 'find_account_info_title'
                                                    .tr,
                                                content: Text(
                                                    'find_account_email_auth_code_check_error'
                                                        .tr),
                                              ).show(context);
                                            }
                                          },
                                    child: Text(
                                      controller.currentAuthCodeValid
                                          ? 'sign_up_email_auth_code_verified'
                                              .tr // 인증 완료 시 텍스트 변경
                                          : 'sign_up_email_auth_code_check'.tr,
                                      style: context.bodyMedium,
                                    ),
                                  )),
                            ),
                          ),
                        if (controller.currentEmailStatus)
                          Obx(
                            () => controller.authCodeTimerStatus.value
                                ? Text(
                                    'sign_up_email_auth_code_required_message_sub'
                                        .trArgs([
                                      controller.authCodeTimer.value.toString(),
                                    ]),
                                    style: context.bodySmall,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        const SizedBox(height: 16),
                        // if (controller.currentAuthCodeValid &&
                        //     controller.currentType.value == FindAccountType.id)
                        //   Obx(
                        //     () => Text(
                        //         'User ID: ${controller.findIdResult.value}',
                        //         style: context.bodyMedium),
                        // ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: VulcanXElevatedButton(
                            customStyle: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                              foregroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.onPrimary),
                              textStyle: WidgetStateProperty.all(
                                  Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      )),
                            ),
                            height: 56.0,
                            onPressed: () => _handleFind(context),
                            child: Obx(() => Text(
                                  controller.currentType.value ==
                                          FindAccountType.id
                                      ? 'find_id'.tr
                                      : 'find_password'.tr,
                                  style: context.bodyLarge?.copyWith(
                                    color: context.onPrimary,
                                  ),
                                )),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: VulcanXOutlinedButton(
                            height: 56.0,
                            onPressed: () => context.go(LoginPage.route),
                            child:
                                Text('goto_login'.tr, style: context.bodyLarge),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildTabButton(
  //   BuildContext context,
  //   String text,
  //   bool isSelected,
  //   VoidCallback onPressed,
  // ) {
  //   return TextButton(
  //     onPressed: onPressed,
  //     style: TextButton.styleFrom(
  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //       backgroundColor: isSelected ? context.primary : Colors.transparent,
  //       foregroundColor: isSelected ? context.onPrimary : context.onSurface,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //     ),
  //     child: Text(text),
  //   );
  // }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.outline, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixIcon != null) prefixIcon,
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                hintStyle: context.bodyMedium?.apply(
                  color: context.outlineVariant,
                ),
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }

  void _handleFind(BuildContext context) async {
    final email = controller.findAccountEmailController.text;
    if (!EmailValidator.validate(email)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('find_account_password_find_error'.tr),
          content: Text('find_password_email_required'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('confirm'.tr),
            ),
          ],
        ),
      );
      return;
    }

    // 간단한 분기 처리 - 컨트롤러의 새로운 메서드 사용
    final isSignUp = await controller.checkDuplicateEmail();
    if (!isSignUp) {
      EasyLoading.showInfo('find_acoount_email_not_sign_up'.tr);
      return;
    } else {
      switch (controller.currentType.value) {
        case FindAccountType.id:
          EasyLoading.showInfo('sign_up_email_auth_button_loading'.tr);
        case FindAccountType.password:
          {
            final result = await controller.checkPasswordFindId();
            if (!result) {
            } else {
              EasyLoading.showInfo('sign_up_email_auth_button_loading'.tr);
            }
            if (!result) {
              EasyLoading.showInfo(
                  'find_account_password_change_not_possible'.tr);
              return;
            }
          }
      }
      final success = await controller.sendCurrentEmailAuth();

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(success
              ? 'find_account_info_title'.tr
              : 'find_account_info_title'.tr),
          content: Text(
            success
                ? switch (controller.currentType.value) {
                    FindAccountType.id =>
                      'find_account_email_auth_code_send_success'.tr,
                    FindAccountType.password =>
                      'find_account_email_auth_code_send_success'.tr,
                  }
                : controller.beforeEmailAuth.value
                    ? controller.reSendLimitMessage.value
                    : switch (controller.currentType.value) {
                        FindAccountType.id => 'find_account_id_find_error'.tr,
                        FindAccountType.password =>
                          'find_account_password_find_error'.tr,
                      },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // if (success) context.pop();
              },
              child: Text('confirm'.tr),
            ),
          ],
        ),
      );
    }
  }
}
