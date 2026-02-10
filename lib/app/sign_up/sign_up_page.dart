import 'package:api/api.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as web;

import '../login/view/login_controller.dart';
import '../login/view/login_page.dart';
import 'sign_up_controller.dart';

class SignUpPage extends GetView<SignUpController> {
  static const String route = '/sign_up';
  static const double formWidth = 400;

  final LoginType? loginType;
  final UserData? userInfo;

  const SignUpPage({super.key, this.loginType, this.userInfo});

  @override
  Widget build(BuildContext context) {
    controller.reset();

    // 전달받은 loginType이 있으면 컨트롤러에 설정
    if (loginType != null) {
      controller.setLoginType(loginType!);
      if (userInfo?.userId != null) {
        controller.setUserInfo(userInfo!);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              CommonAssets.icon.loginBrand.svg(),
              const SizedBox(height: 20),
              _buildSignUpForm(context),
              const SizedBox(height: 16),
              _buildUserInfoForm(context),
              const SizedBox(height: 16),
              _emailAuthForm(context),
              const SizedBox(height: 16),
              _termAndConditionForm(context),
              const SizedBox(height: 16),
              _additionalInfoForm(context),
              const SizedBox(height: 16),
              _buildButtons(context),
              const SizedBox(height: 40),
              const SizedBox(width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }

  // 폼 컨테이너
  Widget _buildFormContainer({
    required BuildContext context,
    required Widget child,
    required bool showError,
    required bool isFocused,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: formWidth,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: showError
            ? Border.all(color: context.error, width: 1)
            : Border.lerp(
                Border.all(color: context.outline, width: 1),
                Border.all(color: context.primary, width: 2.0),
                isFocused ? 1.0 : 0.0,
              ),
      ),
      child: child,
    );
  }

  Widget _buildErrorText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child:
          Text(text, style: context.bodyMedium?.copyWith(color: context.error)),
    );
  }

  // 버튼 컨테이너
  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => VulcanXElevatedButton(
            width: 400,
            customStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  !controller.canSignUp.value
                      ? context.outline
                      : context.primary),
              foregroundColor: WidgetStateProperty.all(
                  !controller.canSignUp.value
                      ? context.outline
                      : context.onPrimary),
              textStyle: WidgetStateProperty.all(
                context.bodyMedium?.copyWith(color: context.onPrimary),
              ),
            ),
            height: 56.0,
            onPressed: () => signUpProcess(context),
            child: Text('sign_up_title'.tr,
                style: context.bodyLarge?.copyWith(color: context.onPrimary)),
          ),
        ),
        const SizedBox(height: 8),
        VulcanXOutlinedButton(
          width: 400,
          height: 56.0,
          onPressed: () => context.go(LoginPage.route),
          child: Text('sign_up_back_to_login'.tr, style: context.bodyLarge),
        ),
      ],
    );
  }

  // 유저 정보 폼
  Widget _buildUserInfoForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameInfoForm(context),
        _buildBirthDayInfoForm(context),
        _buildPhoneNumberInfoForm(context),
        _buildUserInfoErrors(context),
      ],
    );
  }

  // 유저 정보 폼 에러
  Widget _buildUserInfoErrors(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (controller.isNameChecked.value && !controller.isNameValid.value) {
            return _buildErrorText(context, 'sign_up_confirm_required_name'.tr);
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          if (controller.isBirthDateChecked.value &&
              !controller.isBirthDateValid.value) {
            return _buildErrorText(
                context, 'sign_up_confirm_required_birth_date'.tr);
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          if (controller.isPhoneNumberChecked.value &&
              !controller.isPhoneNumberValid.value) {
            return _buildErrorText(
                context, 'sign_up_confirm_required_phone_number'.tr);
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // 이름 입력 필드
  Widget _buildNameInfoForm(BuildContext context) {
    return Obx(
      () => _buildFormContainer(
        context: context,
        showError: controller.isNameChecked.value &&
            !controller.isNameValid.value &&
            !controller.isNameBoxFocused.value,
        isFocused: controller.isNameBoxFocused.value,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        child: _SignUpTextField(
          initialValue: controller.name.value,
          focusNode: controller.nameFocus,
          prefixIcon: const Icon(Icons.person_outline),
          textInputAction: TextInputAction.next,
          hintText: 'sign_up_name_input'.tr,
          onChanged: controller.onNameChanged,
          obscureText: false,
          onTap: () => controller.isNameChecked.value = true,
          onSubmitted: (_) {
            controller.nameFocus.unfocus();
            FocusScope.of(context).requestFocus(controller.emailFocus);
          },
          onFocusChange: controller.onNameFocusChange,
        ),
      ),
    );
  }

  // 생년월일 입력 필드
  Widget _buildBirthDayInfoForm(BuildContext context) {
    return Obx(
      () => _buildFormContainer(
        context: context,
        showError: controller.isBirthDateChecked.value &&
            !controller.isBirthDateValid.value &&
            !controller.isBirthDateBoxFocused.value,
        isFocused: controller.isBirthDateBoxFocused.value,
        child: _SignUpTextField(
          initialValue: controller.birthDate.value,
          focusNode: controller.birthDateFocus,
          prefixIcon: const Icon(Icons.calendar_month),
          textInputAction: TextInputAction.done,
          hintText: 'sign_up_birth_date_input'.tr,
          onChanged: controller.onBirthDateChanged,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          obscureText: false,
          onTap: () => controller.isBirthDateChecked.value = true,
          onFocusChange: controller.onBirthDateFocusChange,
        ),
      ),
    );
  }

  // 전화번호 입력 필드
  Widget _buildPhoneNumberInfoForm(BuildContext context) {
    return Obx(
      () => _buildFormContainer(
        context: context,
        showError: controller.isPhoneNumberChecked.value &&
            !controller.isPhoneNumberValid.value &&
            !controller.isPhoneNumberBoxFocused.value,
        isFocused: controller.isPhoneNumberBoxFocused.value,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        child: _SignUpTextField(
          maxLength: 11,
          initialValue: controller.phoneNumber.value,
          focusNode: controller.phoneNumberFocus,
          prefixIcon: const Icon(Icons.phone_android),
          textInputAction: TextInputAction.next,
          hintText: 'sign_up_phone_number_input'.tr,
          onChanged: controller.onPhoneNumberChanged,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          obscureText: false,
          onTap: () => controller.isPhoneNumberChecked.value = true,
          onFocusChange: controller.onPhoneNumberFocusChange,
        ),
      ),
    );
  }

  Widget _additionalInfoForm(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.outline, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('sign_up_select_info'.tr, style: context.titleMedium),
          ),
          HorDivider(color: context.outline),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _ToggleButtonGroup(
                            leftText: 'sign_up_select_info_male'.tr,
                            rightText: 'sign_up_select_info_female'.tr,
                            value: controller.gender.value,
                            onChanged: (value) =>
                                controller.gender.value = value,
                          )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => _ToggleButtonGroup(
                            leftText: 'sign_up_select_info_domestic'.tr,
                            rightText: 'sign_up_select_info_foreign'.tr,
                            value: controller.isForeigner.value,
                            onChanged: (value) =>
                                controller.isForeigner.value = value ?? false,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
          HorDivider(color: context.outline),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => Checkbox(
                      value: controller.isAdult.value,
                      onChanged: (value) => controller.isAdult.value = value!,
                    )),
                Text('sign_up_select_info_adult'.tr, style: context.bodyMedium),
                IconButton(
                  onPressed: () {
                    final url = controller.getUrlYouthProtectionPolicy();
                    web.window.open(url, '_blank');
                  },
                  icon: const Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _termAndConditionForm(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.outline, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => ExpansionTile(
                title: Row(
                  children: [
                    Checkbox(
                      shape: const CircleBorder(),
                      value: controller.isTermAndConditionAllChecked.value,
                      onChanged: (value) {
                        // controller.isTermAndConditionAllChecked.value =
                        //     value ?? false;
                        controller.checkAllTerms(value ?? false);
                      },
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'sign_up_select_info_required'.tr,
                            style: context.bodyMedium?.copyWith(
                              color: context.primary,
                            ),
                          ),
                          TextSpan(
                            text: 'sign_up_select_info_term_and_condition'.tr,
                            style: context.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.isTermAndConditionList1.value =
                                !controller.isTermAndConditionList1.value;
                            controller.checkTermAndCondition();
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: controller.isTermAndConditionList1.value
                                    ? context.primary
                                    : context.surfaceDim,
                              ),
                              const SizedBox(width: 8),
                              Text('account_management_terms_of_service'.tr,
                                  style: context.bodyMedium?.copyWith(
                                      color: controller
                                              .isTermAndConditionList1.value
                                          ? context.primary
                                          : context.surfaceDim)),
                              IconButton(
                                onPressed: () {
                                  final url = controller.getUrlTerms();
                                  web.window.open(url, '_blank');
                                },
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color:
                                      controller.isTermAndConditionList1.value
                                          ? context.primary
                                          : context.surfaceDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.isTermAndConditionList2.value =
                                !controller.isTermAndConditionList2.value;
                            controller.checkTermAndCondition();
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: controller.isTermAndConditionList2.value
                                    ? context.primary
                                    : context.surfaceDim,
                              ),
                              const SizedBox(width: 8),
                              Text('account_management_privacy_policy'.tr,
                                  style: context.bodyMedium?.copyWith(
                                      color: controller
                                              .isTermAndConditionList2.value
                                          ? context.primary
                                          : context.surfaceDim)),
                              IconButton(
                                onPressed: () {
                                  final url = controller.getUrlPrivacyPolicy();
                                  web.window.open(url, '_blank');
                                },
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color:
                                      controller.isTermAndConditionList2.value
                                          ? context.primary
                                          : context.surfaceDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          HorDivider(color: context.outline),
          Obx(() => ExpansionTile(
                title: Row(
                  children: [
                    Checkbox(
                      shape: const CircleBorder(),
                      value: controller.isMarketingAgreementChecked.value,
                      onChanged: (value) {
                        controller.checkAllMarketingAgreement(value ?? false);
                      },
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'sign_up_select_info_optional'.tr,
                            style: context.bodyMedium?.copyWith(
                              color: context.primary,
                            ),
                          ),
                          TextSpan(
                            text: 'sign_up_select_info_marketing'.tr,
                            style: context.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () {
                        controller.isMarketingAgreementList1.value =
                            !controller.isMarketingAgreementList1.value;
                        controller.checkMarketingAgreement();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: controller.isMarketingAgreementList1.value
                                ? context.primary
                                : context.surfaceDim,
                          ),
                          const SizedBox(width: 8),
                          Text('account_management_marketing'.tr,
                              style: context.bodyMedium?.copyWith(
                                  color:
                                      controller.isMarketingAgreementList1.value
                                          ? context.primary
                                          : context.surfaceDim)),
                          IconButton(
                            onPressed: () {
                              final url = controller.getUrlMarketingPolicy();
                              // web.window.open(url, '_blank');
                              web.window.open(url, '_blank');
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: controller.isTermAndConditionList1.value
                                  ? context.primary
                                  : context.surfaceDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _emailAuthForm(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.outline, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Text('sign_up_email_auth_title'.tr, style: context.titleMedium),
          ),
          HorDivider(color: context.outline),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: context.outline, width: 1),
                      ),
                    ),
                    child: _SignUpTextField(
                      initialValue: controller.email.value,
                      focusNode: controller.emailFocus,
                      textInputAction: TextInputAction.done,
                      hintText: 'sign_up_email_auth_input'.tr,
                      prefixIcon: const Icon(Icons.email_outlined),
                      onChanged: controller.onEmailChanged,
                      obscureText: false,
                      onSubmitted: (_) => signUpProcess(context),
                      showError: !controller.isEmailValid.value &&
                          controller.email.value.isNotEmpty,
                      errorText: 'sign_up_email_auth_input_error_message'.tr,
                      onFocusChange: controller.onEmailFocusChange,
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: Obx(
                  () => VulcanXOutlinedButton(
                    disabled: !controller.emailSendAuthBtnStatus.value,
                    width: 120,
                    height: 40,
                    onPressed: () async {
                      if (!controller.isEmailValid.value) {
                        controller.signUpErrorMessage.value =
                            'sign_up_confirm_required_email_format'.tr;
                        return;
                      }
                      final result =
                          await controller.checkEmailDuplicationMessage();
                      if (result?.isDuplicate == true) {
                        // showSignUpErrorDialog(
                        //     context, 'sign_up_email_auth_duplicate_message'.tr);
                        if (!context.mounted) return;
                        VulcanCloseDialogWidget(
                          width: 320,
                          title: 'sign_up_email_auth_duplicate_message'.tr,
                          content: Text(result?.message ?? ''),
                        ).show(context);
                      } else {
                        EasyLoading.show(
                          status: 'sign_up_email_auth_button_loading'.tr,
                          dismissOnTap: false,
                        );
                        final result = await controller.emailAuth();

                        if (!result) {
                          if (!context.mounted) return;
                          VulcanCloseDialogWidget(
                            width: 320,
                            title: 'info_title'.tr,
                            content: Text(
                              controller.beforeEmailAuth.value
                                  ? controller.reSendLimitMessage.value
                                  : 'sign_up_email_auth_send_error_message'.tr,
                            ),
                          ).show(context);
                        }
                      }
                    },
                    child: Text(
                        controller.emailSendAuthBtnStatus.value &&
                                controller.showAuthCodeInput.value
                            ? 'sign_up_email_auth_button_disabled'.tr
                            : 'sign_up_email_auth_button'.tr,
                        style: !controller.emailSendAuthBtnStatus.value
                            ? context.bodyMedium?.copyWith(
                                color: context.outline.withAlpha(77),
                              )
                            : context.bodyMedium),
                  ),
                ),
              ),
            ],
          ),
          // 인증 코드 입력 필드
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: controller.showAuthCodeInput.value ? 90 : 0,
                child: controller.showAuthCodeInput.value
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: context.outline),
                                        ),
                                      ),
                                      child: _SignUpTextField(
                                        focusNode: controller.authCodeFocus,
                                        textInputAction: TextInputAction.done,
                                        hintText:
                                            'sign_up_email_auth_code_input'.tr,
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                        onChanged: controller.onAuthCodeChanged,
                                        obscureText: false,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 120,
                                    height: 40,
                                    child: Obx(() => VulcanXOutlinedButton(
                                          onPressed:
                                              controller.isEmailAuthValid.value
                                                  ? null // 인증 완료 시 버튼 비활성화
                                                  : () async {
                                                      final result =
                                                          await controller
                                                              .verifyAuthCode();
                                                      if (!result) {
                                                        if (!context.mounted)
                                                          return;
                                                        VulcanCloseDialogWidget(
                                                          width: 320,
                                                          title:
                                                              'sign_up_email_auth_fail_message'
                                                                  .tr,
                                                          content: Text(
                                                              'sign_up_email_auth_error_message'
                                                                  .tr),
                                                        ).show(context);
                                                      }
                                                    },
                                          child: Text(
                                              controller.isEmailAuthValid.value
                                                  ? 'sign_up_email_auth_verified'
                                                      .tr // 인증 완료 시 텍스트 변경
                                                  : 'sign_up_email_auth_code_verified'
                                                      .tr,
                                              style: context.bodyMedium),
                                        )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Obx(
                                () => (controller.authCodeTimerStatus.value &&
                                        !controller.isEmailAuthValid.value)
                                    ? Text(
                                        'sign_up_email_auth_code_required_message_sub'
                                            .trArgs([
                                          controller.authCodeTimer.value
                                              .toString(),
                                        ]),
                                        style: context.bodySmall,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
              )),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.isEmailAuthValid.value
                          ? context.primary
                          : context.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.isEmailAuthValid.value
                        ? 'sign_up_email_auth_success_message'.tr
                        : 'sign_up_confirm_required_email_auth'.tr,
                    style: context.bodySmall?.copyWith(
                      color: controller.isEmailAuthValid.value
                          ? context.primary
                          : context.error,
                    ),
                  ),
                  const Spacer(),
                  if (controller.isEmailAuthValid.value)
                    VulcanXOutlinedButton(
                      width: 120,
                      height: 40,
                      onPressed: () {
                        // 이메일 인증 관련 텍스트, 인증 상황 초기화
                        controller.resetEmailAuth();
                      },
                      child: Text('sign_up_email_change_button'.tr,
                          style: context.bodySmall),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIdField(context),
        _buildPasswordField(context),
        _buildConfirmPasswordField(context),
        _buildSignUpFormErrors(context),
      ],
    );
  }

  // 아이디 입력 필드
  Widget _buildIdField(BuildContext context) {
    return Obx(
      () => _buildFormContainer(
        context: context,
        showError: controller.isIdChecked.value &&
            controller.isIdDuplicationChecked.value &&
            !controller.isIdValid.value &&
            !controller.isIdBoxFocused.value,
        isFocused: controller.isIdBoxFocused.value,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        child: _SignUpTextField(
          focusNode: controller.idFocus,
          initialValue: controller.id.value,
          prefixIcon: const Icon(Icons.person_outline),
          isAvailable: controller.isFixedId.value,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            // 문자와 숫자만 가능하도록
            FilteringTextInputFormatter.deny(RegExp(r'[^\w]')),
          ],
          hintText: 'sign_up_id_input'.tr,
          onChanged: controller.onIdChanged,
          onTap: () => controller.isIdChecked.value = true,
          obscureText: false,
          onSubmitted: (_) {
            controller.idFocus.unfocus();
            FocusScope.of(context).requestFocus(controller.passwordFocus);
          },
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: VulcanXOutlinedButton(
              disabled: controller.isFixedId.value,
              width: 65,
              height: 20,
              onPressed: () async {
                // final checkId = await controller.checkIdDuplication();
                final checkIdMessage =
                    await controller.checkIdDuplicationMessage();
                if (checkIdMessage?.isDuplicate == true) {
                  if (!context.mounted) return;
                  debugPrint('sign_up_id_duplicate_message'.tr);
                  VulcanCloseDialogWidget(
                    width: 320,
                    title: 'sign_up_id_duplicate_message'.tr,
                    content: Text(checkIdMessage?.message ?? ''),
                  ).show(context);
                } else {
                  if (!context.mounted) return;
                  debugPrint('sign_up_id_available_message'.tr);
                  VulcanCloseDialogWidget(
                    width: 320,
                    // title: 'sign_up_id_available_message'.tr,
                    title: checkIdMessage?.isAvailable == true
                        ? 'sign_up_id_available_message'.tr
                        : 'sign_up_id_unavailable_message'.tr,
                    content: Text(checkIdMessage?.message ?? ''),
                  ).show(context);
                }
              },
              child: Text('sign_up_id_check'.tr, style: context.bodySmall),
            ),
          ),
          onFocusChange: controller.onIdFocusChange,
        ),
      ),
    );
  }

  // 비밀번호 입력 필드
  Widget _buildPasswordField(BuildContext context) {
    return Obx(
      () => _buildFormContainer(
        context: context,
        showError: controller.isPasswordChecked.value &&
            !controller.isPasswordValid.value &&
            !controller.isPasswordBoxFocused.value,
        isFocused: controller.isPasswordBoxFocused.value,
        child: _SignUpTextField(
          focusNode: controller.passwordFocus,
          prefixIcon: const Icon(Icons.lock_outline),
          textInputAction: TextInputAction.next,
          hintText: 'sign_up_password_input'.tr,
          onChanged: controller.onPasswordChanged,
          onTap: () => controller.isPasswordChecked.value = true,
          obscureText: controller.passwordObscure.value,
          inputFormatters: [
            // 영어, 숫자, 특수문자만 허용 (한글 차단)
            // ASCII 인쇄 가능 문자 범위 사용 (공백 제외: 33-126)
            FilteringTextInputFormatter.allow(RegExp(r'[\x21-\x7E]')),
          ],
          onSubmitted: (_) {
            controller.passwordFocus.unfocus();
            FocusScope.of(context)
                .requestFocus(controller.confirmPasswordFocus);
          },
          suffixIcon: IconButton(
            icon: Icon(
              controller.passwordObscure.value
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () => controller.passwordObscure.value =
                !controller.passwordObscure.value,
          ),
          onFocusChange: controller.onPasswordFocusChange,
        ),
      ),
    );
  }

  // 비밀번호 확인 입력 필드
  Widget _buildConfirmPasswordField(BuildContext context) {
    return Obx(
      () => _buildFormContainer(
        context: context,
        showError: controller.isConfirmPasswordChecked.value &&
            !controller.isConfirmPasswordValid.value &&
            !controller.isConfirmPasswordBoxFocused.value,
        isFocused: controller.isConfirmPasswordBoxFocused.value,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        child: _SignUpTextField(
          focusNode: controller.confirmPasswordFocus,
          prefixIcon: const Icon(Icons.lock_outline),
          textInputAction: TextInputAction.next,
          hintText: 'sign_up_password_check'.tr,
          onChanged: controller.onConfirmPasswordChanged,
          onTap: () => controller.isConfirmPasswordChecked.value = true,
          obscureText: controller.confirmPasswordObscure.value,
          inputFormatters: [
            // 영어, 숫자, 특수문자만 허용 (한글 차단)
            // ASCII 인쇄 가능 문자 범위 사용 (공백 제외: 33-126)
            FilteringTextInputFormatter.allow(RegExp(r'[\x21-\x7E]')),
          ],
          onSubmitted: (_) {
            controller.confirmPasswordFocus.unfocus();
            FocusScope.of(context).requestFocus(controller.nameFocus);
          },
          suffixIcon: IconButton(
            icon: Icon(
              controller.confirmPasswordObscure.value
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () => controller.confirmPasswordObscure.value =
                !controller.confirmPasswordObscure.value,
          ),
          onFocusChange: controller.onConfirmPasswordFocusChange,
        ),
      ),
    );
  }

  // 회원가입 폼 에러 표시
  Widget _buildSignUpFormErrors(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          // 중복 체크를 완료했고, 유효하지 않을 때만 에러 표시 (포커스 여부와 관계없이)
          if (controller.isIdChecked.value &&
              controller.isIdDuplicationChecked.value &&
              !controller.isIdValid.value) {
            return _buildErrorText(context, 'sign_up_id_required'.tr);
          }
          // 중복 체크를 하지 않았을 때는 별도 메시지 표시 (포커스 여부와 관계없이)
          if (controller.isIdChecked.value &&
              !controller.isIdDuplicationChecked.value &&
              controller.id.value.length >= 4) {
            return _buildErrorText(
                context, 'sign_up_id_duplication_check_required'.tr);
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          if (controller.isPasswordChecked.value) {
            // 비밀번호가 8자리 미만일 때만 표시 (포커스 여부와 관계없이)
            if (controller.password.value.isNotEmpty &&
                controller.password.value.length < 8) {
              return _buildErrorText(
                  context, 'sign_up_password_length_required'.tr);
            }
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          if (controller.isConfirmPasswordChecked.value) {
            // 비밀번호 확인 필드: 비밀번호와 일치 여부만 체크 (8자리 이상일 때만)
            // 비밀번호가 8자리 이상이고 일치하지 않을 때만 표시 (포커스 여부와 관계없이)
            if (controller.password.value.length >= 8 &&
                !controller.isConfirmPasswordValid.value) {
              return _buildErrorText(
                  // context, 'sign_up_password_confirm_required'.tr);
                  context,
                  'sign_up_password_duplicate_message'.tr);
            }
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // 회원가입 프로세스
  void signUpProcess(BuildContext context) async {
    // if (!controller.canSignUp.value) {
    //   showSignUpErrorDialog(context, '모든 필드를 올바르게 입력해주세요.'.tr);
    //   return;
    // }

    final result = await controller.signUp();

    if (!context.mounted) return;
    if (result != null) {
      if (result.data["statusCode"] == 200) {
        showSignUpSuccessDialog(context);
      } else {
        showSignUpErrorDialog(context, result.data["data"]);
      }
    } else {
      showSignUpErrorDialog(context, controller.signUpErrorMessage.value);
    }
  }

  // 회원가입 성공 대화 상자
  void showSignUpSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('sign_up_success_message'.tr),
          content: Text('sign_up_success_message_sub_sub'.tr),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(LoginPage.route);
              },
              child: Text('confirm'.tr),
            ),
          ],
        );
      },
    );
  }

  // 회원가입 실패 대화 상자
  void showSignUpErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('sign_up_fail_message'.tr),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('confirm'.tr),
            ),
          ],
        );
      },
    );
  }
}

class _SignUpTextField extends StatefulWidget {
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final String? initialValue;
  final String hintText;
  final Function(String) onChanged;
  final bool obscureText;
  final Function(String)? onSubmitted;
  final bool showError;
  final bool? isAvailable;
  final String errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function()? onTap;
  final Function(bool)? onFocusChange;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _SignUpTextField({
    required this.focusNode,
    required this.textInputAction,
    required this.hintText,
    required this.onChanged,
    required this.obscureText,
    this.initialValue,
    this.onSubmitted,
    this.showError = false,
    this.errorText = '',
    this.isAvailable = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.onFocusChange,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  State<_SignUpTextField> createState() => _SignUpTextFieldState();
}

class _SignUpTextFieldState extends State<_SignUpTextField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (widget.onFocusChange != null) {
      widget.onFocusChange!(widget.focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: widget.initialValue,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          obscureText: widget.obscureText,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          readOnly: widget.isAvailable ?? false,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintText: widget.hintText,
            hintStyle: context.bodyMedium?.apply(
              color: context.outlineVariant,
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
          ),
        ),
        if (widget.showError)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              widget.errorText,
              style: context.bodySmall?.copyWith(color: context.error),
            ),
          ),
      ],
    );
  }
}

class _ToggleButtonGroup extends StatelessWidget {
  final String leftText;
  final String rightText;
  final bool? value;
  final Function(bool?) onChanged;

  const _ToggleButtonGroup({
    required this.leftText,
    required this.rightText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onChanged(value == false ? null : false),
              child: Container(
                decoration: BoxDecoration(
                  color: value == false ? context.primary : Colors.transparent,
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(7)),
                ),
                alignment: Alignment.center,
                child: Text(
                  leftText,
                  style: context.bodyMedium?.copyWith(
                    color:
                        value == false ? context.onPrimary : context.onSurface,
                  ),
                ),
              ),
            ),
          ),
          VerticalDivider(color: context.outline, width: 1),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(value == true ? null : true),
              child: Container(
                decoration: BoxDecoration(
                  color: value == true ? context.primary : Colors.transparent,
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(7)),
                ),
                alignment: Alignment.center,
                child: Text(
                  rightText,
                  style: context.bodyMedium?.copyWith(
                    color:
                        value == true ? context.onPrimary : context.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
