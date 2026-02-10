import 'package:app/app/login/view/login_controller.dart';
import 'package:app/app/setting/language_enum.dart';
import 'package:app/app/user_setting/account/account_setting_controller.dart';
import 'package:app/app/user_setting/account/chage_share_id_dialog.dart';
import 'package:app/app/user_setting/common_settins_item.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as web;

class AccountSettingsView extends StatefulWidget {
  const AccountSettingsView({super.key});

  @override
  State<AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
  // final LoginController loginController = Get.find<LoginController>();
  final AccountSettingController controller =
      Get.find<AccountSettingController>();
  final LoginController loginController = Get.find<LoginController>();
  @override
  void initState() {
    controller.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          // SettingsItem(
          //   title: Row(
          //     children: [
          //       CircleAvatar(
          //         backgroundColor: context.primaryContainer,
          //         radius: 24,
          //         child: Text(
          //             controller.userDisplayName.value
          //                 .toUpperCase()
          //                 .characters
          //                 .first,
          //             style: context.titleLarge?.apply(color: context.primary)),
          //       ),
          //       const SizedBox(width: 10),
          //       Text(
          //         '이미지는 500*500픽셀 이상이어야 합니다. \nJPG, PNG, SVG 형식만 지원합니다.',
          //         style:
          //             context.bodySmall?.apply(color: context.outlineVariant),
          //       )
          //     ],
          //   ),
          //   action: VulcanXTwoSvgIconOutlinedButton(
          //     text: '이미지 변경',
          //     onPressed: () async {
          //       await _pickerFiles(context);
          //     },
          //   ),
          //   border: true,
          //   padding: const EdgeInsets.symmetric(vertical: 16),
          // ),
          SettingsItem(
            title: Text(
              'account_management_nickname'.tr,
            ),
            subTitle: controller.userDisplayName.value,
            action: VulcanXTwoSvgIconOutlinedButton(
              text: 'account_management_nickname_change'.tr,
              onPressed: () async {
                final result = await loginController.authSecureCheck();
                if (!context.mounted) return;
                if (result) {
                  await VulcanCloseDialogWidget(
                    width: 320,
                    title: 'account_management_nickname_change'.tr,
                    content: NickNameChangeDialog(onTap: (value) async {
                      Navigator.pop(context);
                      final result =
                          await controller.checkNicknameDuplicationMessage(
                              controller.nickNameEditingController.text);
                      if (result?.isDuplicate == false) {
                        await controller.changeDisplaykName(
                            controller.nickNameEditingController.text);
                        if (!context.mounted) return;
                        await VulcanCloseDialogWidget(
                          width: 320,
                          title: 'account_management_nickname_change'.tr,
                          content: Text(
                              'account_management_nickname_change_success'.tr),
                        ).show(context);
                      } else {
                        if (!context.mounted) return;

                        await VulcanCloseDialogWidget(
                          width: 320,
                          title: 'account_management_nickname_change'.tr,
                          content: Text(result?.message ?? ''),
                        ).show(context);
                      }
                    }),
                  ).show(context);
                } else {
                  context.go('/login');
                }
              },
            ),
            border: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          SettingsItem(
            title: Text(
              'account_management_email'.tr,
            ),
            subTitle: controller.userEmail.value,
            action: VulcanXTwoSvgIconOutlinedButton(
              text: 'account_management_email_change'.tr,
              onPressed: () async {
                final result = await loginController.authSecureCheck();
                if (!context.mounted) return;
                if (result) {
                  await VulcanCloseDialogWidget(
                    width: 320,
                    title: 'account_management_email_change'.tr,
                    content: EmailChangeDialog(onTap: (value) async {
                      final result =
                          await controller.checkEmailDuplicationMessage();
                      if (result?.isDuplicate == false) {
                        await controller.changeEmail(value);
                        if (!context.mounted) return;
                        await VulcanCloseDialogWidget(
                          width: 320,
                          title: 'account_management_email_change'.tr,
                          content: Text(
                              'account_management_email_change_success'.tr),
                        ).show(context);
                      } else {
                        if (!context.mounted) return;
                        await VulcanCloseDialogWidget(
                          width: 320,
                          title: 'account_management_email_change'.tr,
                          content: Text(result?.message ?? ''),
                        ).show(context);
                      }
                    }),
                  ).show(context).then(
                    (value) {
                      controller.emailEditingController.clear();
                      controller.subEmailEditingController.clear();
                      controller.authCode.value = '';
                      controller.isAuthCodeValid.value = false;
                      controller.showAuthCodeInput.value = false;
                      controller.authCodeTimerStatus.value = false;
                      controller.emailSendAuthBtnStatus.value = true;
                      controller.beforeEmailAuth.value = false;
                    },
                  );
                } else {
                  context.go('/login');
                }
              },
            ),
            border: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          SettingsItem(
            title: Text(
              'share_id'.tr,
            ),
            subTitle: controller.userShareId.value,
            border: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            onTap: () {
              VulcanCloseDialogWidget(
                width: 320,
                title: 'share_id'.tr,
                content: ShareIdChangeDialog(
                    loginController: loginController,
                    onConfirm: (value) async {
                      final result = await controller.changeShareId(value);
                      if (result) {
                        EasyLoading.showSuccess('share_id_change_success'.tr);
                      }
                    }),
              ).show(context);
            },
            action: IconButton(
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: controller.userShareId.value));
                EasyLoading.showSuccess('copy_success'.tr);
              },
              // VulcanCloseDialogWidget(
              //   width: 320,
              //   title: 'share_id'.tr,
              //   content: ShareIdChangeDialog(
              //       loginController: loginController,
              //       onConfirm: (value) async {
              //         final result = await controller.changeShareId(value);
              //         if (result) {
              //           EasyLoading.showSuccess('share_id_change_success'.tr);
              //         }
              //       }),
              // ).show(context);
              // },
              icon: CommonAssets.icon.contentCopy.svg(),
            ),
          ),
          SettingsItem(
            title: Text(
              'account_management_password'.tr,
            ),
            action: VulcanXTwoSvgIconOutlinedButton(
              text: 'account_management_password_change'.tr,
              onPressed: () async {
                final result = await loginController.authSecureCheck();
                if (!context.mounted) return;
                if (result) {
                  await VulcanCloseDialogWidget(
                    width: 320,
                    title: 'account_management_password_change'.tr,
                    content: PasswordChangeDialog(onTap: (value) async {
                      final result = await controller.changePassword();
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      if (result) {
                        await VulcanCloseDialogWidget(
                          width: 320,
                          title: 'account_management_password_change'.tr,
                          content: Text(
                              'account_management_password_change_success'.tr),
                        ).show(context);
                      } else {
                        await VulcanCloseDialogWidget(
                          width: 320,
                          title: 'account_management_password_change'.tr,
                          content: Text(controller.errorMessages.value),
                        ).show(context);
                      }
                    }),
                  ).show(context).then((value) {
                    controller.currentPasswordEditingController.clear();
                    controller.newPasswordEditingController.clear();
                    controller.newPasswordConfirmEditingController.clear();
                    controller.errorMessages.value = '';
                    controller.checkPassWord.value = false;
                    controller.passwordValidate.value = false;
                    controller.passwordCompareValidate.value = false;
                  });
                } else {
                  context.go('/login');
                }
              },
            ),
            border: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          SettingsItem(
            title: Text(
              'account_management_language'.tr,
            ),
            action: SizedBox(
              width: 150,
              height: 40,
              child: VulcanXDropdown<String>(
                value: _currentLanguage,
                enumItems: LanguageType.values.map((e) => e.name).toList(),
                onChanged: (value) async {
                  if (value != null) {
                    final language = LanguageType.values
                        .firstWhere((element) => element.name == value);
                    Get.updateLocale(language.locale);
                    await controller.saveLanguagePreference(value);
                  }
                },
                hintText: 'account_management_language_hint'.tr,
                hintIcon: Icons.language,
              ),
            ),

            // VulcanXTwoSvgIconOutlinedButton(
            //   text: 'account_management_language_kr'.tr,
            //   onPressed: () {},
            // ),
            border: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          SettingsItem(
            // 마케팅 수신동의 토글
            title: Row(
              children: [
                Text(
                  'account_management_marketing'.tr,
                ),
                IconButton(
                  onPressed: () {
                    // VulcanCloseDialogWidget(
                    //   width: 500,
                    //   // height: 320,
                    //   // title: '마케팅 수신 동의'.tr,
                    //   content: SizedBox(
                    //     width: MediaQuery.of(context).size.width * 0.5,
                    //     height: MediaQuery.of(context).size.height * 0.7,
                    //     child: TermsView(
                    //       title: '마케팅 수신 동의'.tr,
                    //       htmlPath: 'assets/terms/marketing-policy.html',
                    //     ),
                    //   ),
                    // ).show(context);
                    final url = controller.getUrlMarketingPolicy();
                    web.window.open(url, '_blank');
                  },
                  icon: const Icon(Icons.info_outline, color: Colors.grey),
                ),
              ],
            ),
            subTitle: controller.isMarketingAgreementChecked.value
                ? 'account_management_marketing_agree'.tr
                : 'account_management_marketing_disagree'.tr,
            subTitle2: controller.isMarketingAgreementChecked.value
                ? 'account_management_marketing_time'.trArgs([
                    controller.marketingTime.value,
                  ])
                : null,
            action: Switch(
              value: controller.isMarketingAgreementChecked.value,
              onChanged: (value) {
                controller.isMarketingAgreementChecked.value = value;
                controller.checkMarketingAgreement(value);
              },
              activeColor: context.primary,
            ),
            border: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          SettingsItem(
            title: Text(
              'account_management_delete_account'.tr,
            ),
            subTitle: 'account_management_delete_account_message'.tr,
            // action: VulcanXTwoSvgIconOutlinedButton(
            //   text: 'account_management_delete_account_contact'.tr,
            //   onPressed: () {},
            // ),
            action: TextButton(
              onPressed: () {
                VulcanCloseDialogWidget(
                  width: 320,
                  // title: 'account_management_delete_account_contact'.tr,
                  content: Text(
                      'account_management_delete_account_contact_message'.tr),
                ).show(context);
              },
              child: Text('account_management_delete_account_contact'.tr,
                  style: context.bodyMedium?.copyWith(color: context.primary)),
            ),
            border: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ],
      ),
    );
  }

  String get _currentLanguage {
    if (Get.locale == LanguageType.korean.locale) {
      return 'Korean';
    } else if (Get.locale == LanguageType.indonesia.locale) {
      return 'Indonesia';
    }
    return 'English';
  }

  // Future<void> _pickerFiles(BuildContext context) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.image,
  //     allowMultiple: true,
  //   );

  //   if (result != null && result.files.isNotEmpty) {
  //     // String fileNames = result.files.map((file) => file.name).join(', ');

  //     final uploadSuccess = await EditorMultiUploadDialog.show(
  //       context,
  //       files: result.files,
  //       onUpload: (file) async {
  //         // await controller.fileUpload(file);
  //       },
  //     );
  //   }
  // }
}

class NickNameChangeDialog extends StatelessWidget {
  final ValueChanged<String> onTap;
  final AccountSettingController controller =
      Get.find<AccountSettingController>();
  NickNameChangeDialog({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        VulcanXTextField(
            controller: controller.nickNameEditingController,
            height: 60,
            maxLength: 20,
            hintText: 'account_management_nickname_change_message'.tr),
        const SizedBox(height: 14),
        Text('account_management_nickname_change_hint'.tr,
            style: context.bodySmall?.apply(color: context.outlineVariant)),
        const SizedBox(height: 14),
        VulcanXElevatedButton(
            width: double.infinity,
            onPressed: () =>
                onTap.call(controller.nickNameEditingController.text),
            //변경하기
            child: Text('account_management_nickname_change'.tr)),
      ],
    );
  }
}

class EmailChangeDialog extends StatefulWidget {
  final ValueChanged<String> onTap;

  const EmailChangeDialog({super.key, required this.onTap});

  @override
  State<EmailChangeDialog> createState() => _EmailChangeDialogState();
}

class _EmailChangeDialogState extends State<EmailChangeDialog> {
  final AccountSettingController controller =
      Get.find<AccountSettingController>();
  final validateMessage = false.obs;
  late TextEditingController authCodeController;

  @override
  void initState() {
    super.initState();
    authCodeController = TextEditingController();
  }

  @override
  void dispose() {
    authCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        VulcanXTextField(
            controller: controller.emailEditingController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              if (!EmailValidator.validate(value)) {
                validateMessage.value = false;
              } else {
                validateMessage.value = true;
              }
            },
            hintText: 'account_management_email_change_message'.tr),
        const SizedBox(height: 10),
        VulcanXTextField(
            controller: controller.subEmailEditingController,
            hintText: 'account_management_email_change_sub_message'.tr),
        const SizedBox(height: 14),
        Obx(
          () => Text(
              controller.emailEditingController.text.isEmpty
                  ? 'account_management_email_change_message'.tr
                  : validateMessage.value
                      ? 'account_management_email_change_validate'.tr
                      : 'account_management_email_change_validate_error'.tr,
              style: context.bodySmall?.apply(
                  color:
                      validateMessage.value ? context.primary : context.error)),
        ),
        const SizedBox(height: 14),

        // 이메일 인증 코드 전송 버튼
        Obx(() => VulcanXElevatedButton(
              width: double.infinity,
              onPressed: controller.emailSendAuthBtnStatus.value &&
                      validateMessage.value
                  ? () async {
                      final success = await controller.sendEmailAuthCode();
                      if (success) {
                        EasyLoading.showSuccess(
                            'account_management_email_change_auth_code_send_success'
                                .tr);
                      } else {
                        EasyLoading.showError(
                            'account_management_email_change_auth_code_send_error'
                                .tr);
                      }
                    }
                  : null,
              child: Text('account_management_email_change_auth_code_send'.tr),
            )),

        // 인증 코드 입력 필드 (인증 코드 전송 후 표시)
        Obx(() => controller.showAuthCodeInput.value
            ? Column(
                children: [
                  const SizedBox(height: 14),
                  VulcanXTextField(
                    controller: authCodeController,
                    onChanged: (value) {
                      controller.authCode.value = value;
                      setState(() {}); // UI 업데이트를 위해 setState 호출
                    },
                    hintText:
                        'account_management_email_change_auth_code_send_message'
                            .tr,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  // 인증 코드 확인 버튼
                  Obx(() => VulcanXElevatedButton(
                        width: double.infinity,
                        onPressed: controller.isAuthCodeValid.value
                            ? null // 인증 완료 시 버튼 비활성화
                            : () async {
                                final success =
                                    await controller.verifyEmailAuthCode();
                                if (success) {
                                  EasyLoading.showSuccess(
                                      'account_management_email_change_auth_code_check_success');
                                } else {
                                  EasyLoading.showError(
                                      'account_management_email_change_auth_code_check_error'
                                          .tr);
                                }
                              },
                        child: Text(
                          controller.isAuthCodeValid.value
                              ? 'account_management_email_change_auth_code_check_success'
                                  .tr
                              : 'account_management_email_change_auth_code_check'
                                  .tr,
                        ),
                      )),
                  const SizedBox(height: 10),
                  // 타이머 표시
                  Obx(() => controller.authCodeTimerStatus.value
                      ? Text(
                          '남은 시간: ${(controller.authCodeTimer.value ~/ 60).toString().padLeft(2, '0')}:${(controller.authCodeTimer.value % 60).toString().padLeft(2, '0')}',
                          style:
                              context.bodySmall?.apply(color: context.primary),
                        )
                      : const SizedBox()),
                ],
              )
            : const SizedBox()),

        const SizedBox(height: 14),

        // 이메일 변경 버튼 (인증 완료 후에만 활성화)
        Obx(() => VulcanXElevatedButton(
            width: double.infinity,
            onPressed: controller.isAuthCodeValid.value
                ? () {
                    widget.onTap.call(controller.emailEditingController.text);
                    controller.emailEditingController.clear();
                    controller.subEmailEditingController.clear();
                  }
                : null,
            child: Text(
              'account_management_email_change'.tr,
              style: context.bodyMedium?.apply(color: context.primary),
            ))),
        const SizedBox(height: 5),
      ],
    );
  }
}

class PasswordChangeDialog extends StatefulWidget {
  final ValueChanged<String> onTap;

  const PasswordChangeDialog({super.key, required this.onTap});

  @override
  State<PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<PasswordChangeDialog> {
  final AccountSettingController controller =
      Get.find<AccountSettingController>();

  bool _obscureText = true;
  bool _obscureConfirmText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        VulcanXTextField(
            obscureText: true,
            onChanged: (value) {
              setState(() {
                // controller.checkCurrentPassWord(value);
              });
            },
            // suffixIcon:
            //     controller.currentPasswordEditingController.text.isNotEmpty
            //         ? Icon(
            //             controller.checkPassWord.value
            //                 ? Icons.check_sharp
            //                 : Icons.error,
            //             color: controller.checkPassWord.value
            //                 ? context.primary
            //                 : context.error,
            //           )
            //         : null,
            controller: controller.currentPasswordEditingController,
            hintText: 'account_management_current_password'.tr),
        const SizedBox(height: 10),
        VulcanXTextField(
            obscureText: _obscureText,
            controller: controller.newPasswordEditingController,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            onChanged: (value) {
              setState(() {
                controller.checkValidatePassWord(value);
                // 새 비밀번호가 변경되면 확인 비밀번호도 다시 검증
                controller.comaprePassword();
              });
            },
            hintText: 'account_management_new_password'.tr),
        const SizedBox(height: 10),
        Obx(
          () => VulcanXTextField(
              readOnly: !controller.passwordValidate.value,
              obscureText: _obscureConfirmText,
              onChanged: (value) {
                controller.comaprePassword();
              },
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmText = !_obscureConfirmText;
                  });
                },
              ),
              controller: controller.newPasswordConfirmEditingController,
              hintText: 'account_management_new_password_confirm'.tr),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            controller.newPasswordEditingController.text.isEmpty
                ? const SizedBox()
                : Icon(
                    controller.passwordValidate.value
                        ? Icons.check_circle
                        : Icons.error,
                    color: controller.passwordValidate.value
                        ? context.primary
                        : context.error,
                  ),
            const SizedBox(width: 10),
            SizedBox(
              width: 240,
              child: Text(
                  controller.currentPasswordEditingController.text.isEmpty
                      ? 'account_management_password_input_message'.tr
                      : controller.passwordValidateText.value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style:
                      context.bodyMedium?.apply(color: context.outlineVariant)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(
          () => Row(
            children: [
              controller.newPasswordConfirmEditingController.text.isEmpty
                  ? const SizedBox()
                  : Icon(
                      controller.passwordCompareValidate.value
                          ? Icons.check_circle
                          : Icons.error,
                      color: controller.passwordCompareValidate.value
                          ? context.primary
                          : context.error,
                    ),
              const SizedBox(width: 10),
              SizedBox(
                width: 240,
                child: Text(controller.passwordCompareValidateText.value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: context.bodyMedium
                        ?.apply(color: context.outlineVariant)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        VulcanXElevatedButton(
            width: double.infinity,
            onPressed: () =>
                controller.checkBtnEnable() ? widget.onTap.call('') : null,
            //변경하기
            child: Text('change'.tr)),
      ],
    );
  }
}
