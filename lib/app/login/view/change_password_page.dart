import 'package:app/app/login/view/login_page.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'find_account_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  static const String route = '/change-password';

  const ChangePasswordPage({
    super.key,
    required this.userId,
    required this.email,
  });

  final String userId;
  final String email;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final controller = Get.find<FindAccountController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.newPasswordController.text = '';
      controller.newPasswordConfirmController.text = '';
      controller.newPassword.value = '';
      controller.confirmPassword.value = '';
      controller.isPasswordValid.value = false;
      controller.idFindEmailAuthCodeController.text = widget.email;
      controller.passwordFindIdController.text = widget.userId;
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
                CommonAssets.icon.loginBrand.svg(),
                const SizedBox(height: 32),
                Text(
                  'find_account_password_change'.tr,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                Obx(
                  () => VulcanXTextField(
                    hintText: 'find_account_password_change_message'.tr,
                    obscureText: !controller.isPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        controller.isPasswordVisible.value =
                            !controller.isPasswordVisible.value;
                      },
                    ),
                    onChanged: (value) {
                      controller.newPassword.value = value;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => VulcanXTextField(
                    hintText: 'find_account_password_change_confirm_message'.tr,
                    obscureText: !controller.isPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        controller.isPasswordVisible.value =
                            !controller.isPasswordVisible.value;
                      },
                    ),
                    onChanged: (value) {
                      controller.confirmPassword.value = value;
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                  () => VulcanXOutlinedButton(
                    onPressed: controller.isPasswordValid.value
                        ? () async {
                            if (controller.newPassword.value !=
                                controller.confirmPassword.value) {
                              VulcanCloseDialogWidget(
                                title: 'find_account_info_title'.tr,
                                content: Text(
                                    'find_account_password_change_error'.tr),
                              ).show(context);
                              return;
                            }
                            final result = await controller.resetPassword(
                              userId: widget.userId,
                              email: widget.email,
                              newPassword: controller.newPassword.value,
                              newPasswordConfirm:
                                  controller.confirmPassword.value,
                            );
                            if (result) {
                              if (!context.mounted) return;
                              VulcanCloseDialogWidget(
                                width: 250,
                                title: 'find_account_info_title'.tr,
                                content: Text(
                                    'find_account_password_change_success'.tr),
                              ).show(context).then((value) {
                                if (!context.mounted) return;
                                context.go(LoginPage.route);
                              });
                            }
                          }
                        : null,
                    child: Text('find_account_password_change'.tr,
                        style: context.bodyMedium),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
