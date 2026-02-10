import 'package:api/api.dart';
import 'package:app/app/login/view/find_account_page.dart';
import 'package:app/app/login/view/sso_login_page.dart';
import 'package:app/app/login/view/tenant_setting_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:author_editor/enum/user_login_type.dart';
import 'package:common_assets/common_assets.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../home/view/home_page.dart';
import '../../sign_up/sign_up_page.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  final tenantSettingController = Get.find<TenantSettingController>();
  static const String route = '/';

  LoginPage({super.key});

  // final testSsoString = 'naverWorks'.obs;
  // final testSsoString = 'brity';
  // final testSsoString = 'araService';

  @override
  Widget build(BuildContext context) {
    final domainType = AutoConfig.instance.domainType;

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
                GestureDetector(
                  onDoubleTap: AutoConfig.instance.domainType.isLocalDevDomain
                      ? () => controller.logout()
                      : null,
                  child: AutoConfig.instance.domainType.isDferiDomain
                      ? Column(
                          children: [
                            CommonAssets.image.booknaviLogo.image(),
                            const SizedBox(width: 8),
                            Text('dferi_app_name'.tr,
                                style: context.headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold))
                          ],
                        )
                      : CommonAssets.icon.loginBrand.svg(),
                ),
                const SizedBox(height: 20),
                // Obx(
                //   () => tenantSettingController.provider.value ==
                //           UserLoginType.ara
                //       ? _buildCommonLogin(context)
                //       : SsoLoginPage(
                //           ssoType: tenantSettingController.provider.value),
                // ),

                // if ((!domainType.isLocalDevDomain ||
                //         domainType.isStandardDomain ||
                //         (domainType.isGovDomain &&
                //             !domainType.isGovDomainWithoutTenant) ||
                //         domainType.isMoisDomain ||
                //         domainType.isMsitDomain ||
                //         domainType.isMfdsDomain ||
                //         domainType.isDferiDomain) &&
                //     !domainType.isAraDomain)
                if (controller.isLoginPageSsoSetting.value)
                  SsoLoginPage(
                      ssoType: tenantSettingController.userLoginType.value,
                      tenantType: tenantSettingController.tenantType.value)
                else
                  _buildCommonLogin(context)

                // IconButton(
                //   onPressed: () => showDialog(
                //       context: context,
                //       builder: (BuildContext context) => SsoSignUpPopup()),
                //   icon: Icon(Icons.person_add),
                // ),
                // TextButton(
                //   onPressed: () => controller.ssotypeString.value = 'common',
                //   child: Text('common'.tr),
                // ),
                // TextButton(
                //   onPressed: () =>
                //       controller.ssotypeString.value = 'naverWorks',
                //   child: Text('naverWorks'.tr),
                // ),
                // TextButton(
                //   onPressed: () => controller.ssotypeString.value = 'brity',
                //   child: Text('brity'.tr),
                // ),
                // TextButton(
                //   onPressed: () =>
                //       controller.ssotypeString.value = 'araService',
                //   child: Text('araService'.tr),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommonLogin(BuildContext context) {
    return Column(
      children: [
        _buildLoadTextField(context),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: Obx(
            () => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LabelRectangleCheckbox(
                  //     // 자동 로그인
                  //     label: 'auto_login'.tr,
                  //     isChecked:
                  //         controller.rememberAutoLoginEnabled.value,
                  //     onChanged: (value) async {
                  //       await controller.toggleAutoLogin(value);
                  //     }),
                  // const SizedBox(width: 16),
                  LabelRectangleCheckbox(
                      label: 'id_remember'.tr,
                      isChecked: controller.rememberIdEnabled.value,
                      onChanged: (value) async {
                        await controller.toggleRememberId(value);
                      }),
                ]),
          ),
        ),
        const SizedBox(height: 16),
        VulcanXElevatedButton(
            width: double.infinity,
            customStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primary),
              foregroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.onPrimary),
              textStyle: WidgetStateProperty.all(
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      )),
            ),
            height: 56.0,
            onPressed: () => loginProcess(context),
            child: Text('login'.tr,
                style: context.bodyLarge?.copyWith(color: context.onPrimary))),
        const SizedBox(height: 8),
        VulcanXOutlinedButton(
            width: double.infinity,
            height: 56.0,
            onPressed: () =>
                context.go(SignUpPage.route, extra: LoginType.idPassword),
            // 회원가입
            child: Text('join_membership'.tr, style: context.bodyLarge)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이디 찾기
            TextButton(
              onPressed: () => context.push(FindAccountPage.route, extra: true),
              child: Text('find_id'.tr,
                  style:
                      context.bodyMedium?.copyWith(color: context.surfaceDim)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('|',
                  style:
                      context.bodyMedium?.copyWith(color: context.surfaceDim)),
            ),
            // 비밀번호 찾기
            TextButton(
              onPressed: () =>
                  context.push(FindAccountPage.route, extra: false),
              child: Text('find_password'.tr,
                  style:
                      context.bodyMedium?.copyWith(color: context.surfaceDim)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const HorDivider(),
        const SizedBox(height: 16),
        // 간편 로그인
        Text('easy_login'.tr,
            style: context.bodyMedium?.copyWith(color: context.surfaceDim)),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아라이북 연동
            Visibility(
              visible: AutoConfig.instance.domainType.isAraDomain ||
                  AutoConfig.instance.domainType.isLocalDevDomain,
              child: IconButton(
                  onPressed: () => _showSocialLoginDialog(
                      context, LoginType.araService, controller.userData.value),
                  icon: AutoConfig.instance.domainType.isDferiDomain
                      ? CommonAssets.image.dferiLogo.svg(width: 48, height: 48)
                      : CommonAssets.image.araCircleLogo.svg(
                          width: 48,
                          height: 48,
                        )),
            ),
            // 네이버웍스 연동: 서버에서 구분해서 API 호출
            // IconButton(
            //     onPressed: () => _handleNaverWorksLogin(context),
            //     icon: CommonAssets.image.naverWorksLogo.image(
            //       width: 48,
            //       height: 48,
            //     )),
            // // TODO 간편로그인
            // IconButton(
            //     onPressed: () => _handleNaverLogin(context),
            //     icon: CommonAssets.image.naver.image(
            //       width: 1,
            //       height: 1,
            //     )),
            // IconButton(
            //     onPressed: () => _showSocialLoginDialog(context),
            //     icon: CommonAssets.image.google.svg()),
            // IconButton(
            //     onPressed: () => _showSocialLoginDialog(context),
            //     icon: CommonAssets.image.apple.svg()),
          ],
        ),
        const SizedBox(height: 16),
        // 테넌트별 테스트 로그인 버튼
        // _buildTenantTestLoginButton(context),
      ],
    );
  }

  void loginProcess(BuildContext context) async {
    final result = await controller.loginAuth();

    if (!context.mounted) return;
    if (result) {
      controller.loginSessionToken.value = true;

      // URL 쿼리 파라미터에서 리다이렉트 경로 확인
      final uri = GoRouterState.of(context).uri;
      final redirectParam = uri.queryParameters['redirect'];

      String targetPath = HomePage.route;
      if (redirectParam != null && redirectParam.isNotEmpty) {
        try {
          targetPath = Uri.decodeComponent(redirectParam);
          controller.clearPassword();
          logger.d('로그인 성공, 쿼리 파라미터에서 리다이렉트 경로 발견: $targetPath');
        } catch (e) {
          logger.e('리다이렉트 경로 디코딩 실패: $e');
          targetPath = HomePage.route;
        }
      } else {
        logger.d('로그인 성공, 기본 홈으로 이동');
        controller.clearPassword();
      }

      logger.d('로그인 성공, 최종 리다이렉트 경로: $targetPath');
      final isUserSignStatus = await controller.checkUserSignStatus(context);
      if (isUserSignStatus) {
        context.go(targetPath);
      }
    } else {
      controller.loginSessionToken.value = false;
      // 남은 로그인 시도 횟수 가져오기
      final remainingAttempts = await controller.getRemainingLoginAttempts();
      showLoginFailDialog(
          context, controller.loginErrorMessage.value, remainingAttempts);
    }
  }

  // 로그인 성공 시 호출할 함수
  void showLoginSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('login_success'.tr),
          content: Text('login_success_message'.tr),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(HomePage.route);
              },
              child: Text('confirm'.tr),
            ),
          ],
        );
      },
    );
  }

  void showLoginFailDialog(BuildContext context, String errorMessage,
      [int? remainingAttempts]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // 남은 시도 횟수 확인
        final hasRemainingAttempts =
            remainingAttempts != null && remainingAttempts > 0;

        return AlertDialog(
          // 로그인 실패
          title: Text('login_fail'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorMessage), // 실패 이유 표시
              if (hasRemainingAttempts) ...[
                const SizedBox(height: 12),
                Text(
                  'login_remaining_attempts'
                      .tr
                      .replaceAll('{count}', remainingAttempts.toString()),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그만 닫기 (로그인 페이지 유지)
              },
              // 확인
              child: Text('confirm'.tr),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadTextField(
    BuildContext context,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.outline, width: 1),
          ),
          child: Obx(() {
            return _LoginTextField(
              controller: controller.idController,
              focusNode: controller.emailFocus,
              textInputAction: TextInputAction.next,
              hintText: 'id_input_hint_text'.tr,
              onChanged: controller.onEmailChanged,
              obscureText: false,
              onSubmitted: (_) {
                controller.emailFocus.unfocus();
                FocusScope.of(context).requestFocus(controller.passwordFocus);
              },
              showError:
                  !controller.isIdValid.value && controller.id.value.isNotEmpty,
            );
          }),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.outline, width: 1),
          ),
          child: Obx(() {
            return _LoginTextField(
              focusNode: controller.passwordFocus,
              textInputAction: TextInputAction.done,
              hintText: 'password_hint_text'.tr,
              onChanged: controller.onPasswordChanged,
              obscureText: controller.obscureText.value,
              onSubmitted: (_) => loginProcess(context),
              showError: !controller.isPasswordValid.value &&
                  controller.password.value.isNotEmpty,
              isPasswordField: true,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureText.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  controller.obscureText.value = !controller.obscureText.value;
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSimpleLoginTextField(
    BuildContext context,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.outline, width: 1),
          ),
          child: Obx(() {
            return _LoginTextField(
              controller: controller.simpleLoginIdController,
              focusNode: controller.simpleLoginIdFocus,
              textInputAction: TextInputAction.next,
              hintText: 'id_input_hint_text'.tr,
              onChanged: controller.onSimpleLoginIdChanged,
              obscureText: false,
              onSubmitted: (_) {
                controller.simpleLoginIdFocus.unfocus();
                FocusScope.of(context)
                    .requestFocus(controller.simpleLoginPasswordFocus);
              },
              showError: !controller.isSimpleLoginIdValid.value &&
                  controller.simpleLoginId.value.isNotEmpty,
            );
          }),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.outline, width: 1),
          ),
          child: Obx(() {
            return _LoginTextField(
              controller: controller.simpleLoginPasswordController,
              focusNode: controller.simpleLoginPasswordFocus,
              textInputAction: TextInputAction.done,
              hintText: 'password_hint_text'.tr,
              onChanged: controller.onSimpleLoginPasswordChanged,
              obscureText: controller.obscureSimpleLoginPassword.value,
              onSubmitted: (_) => _handleSimpleLogin(context),
              showError: !controller.isSimpleLoginPasswordValid.value &&
                  controller.simpleLoginPassword.value.isNotEmpty,
              isPasswordField: true,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureSimpleLoginPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  controller.obscureSimpleLoginPassword.value =
                      !controller.obscureSimpleLoginPassword.value;
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        VulcanXElevatedButton(
          width: double.infinity,
          customStyle: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
            foregroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.onPrimary),
            textStyle: WidgetStateProperty.all(
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    )),
          ),
          height: 56.0,
          onPressed: () => _handleSimpleLogin(context),
          child: Text('login'.tr,
              style: context.bodyLarge?.copyWith(color: context.onPrimary)),
        ),
      ],
    );
  }

  // 간편 로그인 처리 함수
  void _handleSimpleLogin(BuildContext context) async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text('simple_login_process_message'.tr),
            ],
          ),
        );
      },
    );

    try {
      final result = await controller.simpleAraServiceLoginAuth();

      if (!context.mounted) return;
      Navigator.pop(context); // 로딩 다이얼로그 닫기

      if (result) {
        // 로그인 성공 시 홈 페이지로 이동
        Navigator.pop(context); // 간편 로그인 다이얼로그 닫기

        if (controller.isRegistered.value) {
          // 기존 회원 정보 있음 - 리다이렉트 경로 확인
          final uri = GoRouterState.of(context).uri;
          final redirectParam = uri.queryParameters['redirect'];

          String targetPath = HomePage.route;
          if (redirectParam != null && redirectParam.isNotEmpty) {
            try {
              targetPath = Uri.decodeComponent(redirectParam);
              logger.d('간편 로그인 성공, 쿼리 파라미터에서 리다이렉트 경로 발견: $targetPath');
            } catch (e) {
              logger.e('리다이렉트 경로 디코딩 실패: $e');
              targetPath = HomePage.route;
            }
          }

          final isUserSignStatus =
              await controller.checkUserSignStatus(context);
          if (isUserSignStatus) {
            context.go(targetPath);
          }
        } else if (!controller.isRegistered.value) {
          // 기존 회원 정보 없음 (가입 필)
          // 회원가입이 필요함 showdialog - 고지 후 회원가입 페이지로 이동
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('simple_login_need_sign_up'.tr),
                content: Text('simple_login_need_sign_up_message'.tr),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(SignUpPage.route, extra: {
                        'loginType': LoginType.araService,
                        'userInfo': controller.userData.value,
                      });
                    },
                    child: Text('sign_up_title'.tr),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // 실패 시 에러 메시지 표시
        showLoginFailDialog(context, controller.loginErrorMessage.value);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // 로딩 다이얼로그 닫기

      // 에러 메시지 표시
      showLoginFailDialog(context, 'simple_login_fail_message'.tr);
    }
  }

  // 간편 로그인 다이얼로그를 표시하는 함수
  void _showSocialLoginDialog(
      BuildContext context, LoginType loginType, UserData userData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('simple_login_title'.tr),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('simple_login_message'.tr,
                    style: context.bodyMedium
                        ?.copyWith(color: context.surfaceDim)),
                const SizedBox(height: 20),
                _buildSimpleLoginTextField(context),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(SignUpPage.route);
                // context.go(SignUpPage.route, extra: {
                //   'loginType': loginType.value,
                //   'userInfo': userData,
                // }
                // );
              },
              child: Text('sign_up_title'.tr),
            ),
          ],
        );
      },
    );
  }

  // 소셜 로그인 버튼 위젯
  Widget _buildSocialLoginButton(
    BuildContext context, {
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: icon,
          ),
          const SizedBox(height: 8),
          Text(label, style: context.bodySmall),
        ],
      ),
    );
  }

  // 네이버 로그인 처리 함수
  void _handleNaverLogin(BuildContext context) async {
    try {
      // 컨트롤러의 네이버 로그인 메서드 호출 (현재 페이지에서 리다이렉트)
      await controller.naverLogin();

      // 리다이렉트 성공 시 네이버 로그인 페이지로 이동됨
      // 로그인 완료 후 백엔드가 /login/oauth?success=true로 리다이렉트
    } catch (e) {
      if (!context.mounted) return;
      showLoginFailDialog(context, 'naver_login_fail_message'.tr);
    }
  }

  // 네이버 웍스 로그인 처리 함수 - 주석처리
  void _handleNaverWorksLogin(BuildContext context) async {
    try {
      // 컨트롤러의 네이버 웍스 로그인 메서드 호출 (현재 페이지에서 리다이렉트)
      final result = await controller.naverWorksLogin();
      debugPrint(
          '#### [${AutoConfig.instance.domainType}]: _handleNaverWorksLogin: result: $result');

      // 리다이렉트 성공 시 네이버 웍스 로그인 페이지로 이동됨
      // 로그인 완료 후 백엔드가 /login/oauth?success=true로 리다이렉트
    } catch (e) {
      if (!context.mounted) return;
      showLoginFailDialog(context, 'naver_works_login_fail_message'.tr);
    }
  }

  // 소셜 로그인 처리 함수
  // void _handleSocialLogin(BuildContext context, LoginType loginType) async {
  //   Navigator.pop(context); // 다이얼로그 닫기

  //   // 로딩 표시
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: Row(
  //           children: [
  //             CircularProgressIndicator(),
  //             SizedBox(width: 20),
  //             Text('로그인 중...'.tr),
  //           ],
  //         ),
  //       );
  //     },
  //   );

  //   try {
  //     // 컨트롤러의 소셜 로그인 메서드 호출
  //     final result = await controller.socialLogin(loginType);

  //     if (!context.mounted) return;
  //     Navigator.pop(context); // 로딩 다이얼로그 닫기

  //     if (result) {
  //       // 로그인 성공 시 홈 페이지로 이동
  //       context.go(HomePage.route);
  //     } else {
  //       // 실패 시 에러 메시지 표시
  //       showLoginFailDialog(context, controller.loginErrorMessage.value);
  //     }
  //   } catch (e) {
  //     if (!context.mounted) return;
  //     Navigator.pop(context); // 로딩 다이얼로그 닫기

  //     // 에러 메시지 표시
  //     showLoginFailDialog(context, '소셜 로그인에 실패했습니다'.tr);
  //   }
  // }

  // 테넌트별 테스트 로그인 버튼
  Widget _buildTenantTestLoginButton(BuildContext context) {
    UserLoginType? selectedType;

    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'tenant_test_login_button'.tr,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                // 드롭다운
                DropdownButtonFormField<UserLoginType>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'select_login_type'.tr,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  items: UserLoginType.values.map((type) {
                    return DropdownMenuItem<UserLoginType>(
                      value: type,
                      child: Text(_getLoginTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // 액션 버튼
                if (selectedType != null) ...[
                  VulcanXElevatedButton(
                    width: double.infinity,
                    height: 48,
                    onPressed: () => _handleTestLoginAction(
                      context,
                      selectedType!,
                    ),
                    child: Text(
                      'execute_test_login'.tr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLoginTypeLabel(UserLoginType type) {
    switch (type) {
      case UserLoginType.araEbook:
        return 'ARA EBOOK 로그인';
      case UserLoginType.kakao:
        return '카카오 로그인';
      case UserLoginType.naver:
        return '네이버 로그인';
      case UserLoginType.naverWorks:
      case UserLoginType.naver_works:
        return '네이버 웍스 로그인';
      case UserLoginType.brityWorks:
        return '브리티 로그인';
      default:
        return 'ARA 로그인';
    }
  }

  void _handleTestLoginAction(BuildContext context, UserLoginType loginType) {
    logger.i('테스트 로그인 실행: ${loginType.name}');

    switch (loginType) {
      case UserLoginType.araEbook:
        // SSO 로그인 페이지로 이동
        controller.ssotypeString.value = 'araService';
        _showSocialLoginDialog(
            context, LoginType.araService, controller.userData.value);
        break;
      case UserLoginType.kakao:
        // 카카오 로그인
        controller.loginKakao();
        break;
      case UserLoginType.naver:
        // 기존 네이버 로그인 메서드 호출
        _handleNaverLogin(context);
        break;
      case UserLoginType.naverWorks:
      case UserLoginType.naver_works:
        // 기존 네이버 웍스 로그인 메서드 호출
        _handleNaverWorksLogin(context);
        break;
      case UserLoginType.brityWorks:
        // SSO 로그인 페이지로 이동
        controller.ssotypeString.value = 'brity';
        break;
      default:
        // 일반 로그인 처리
        loginProcess(context);
        break;
    }
  }
}

class _LoginTextField extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController? controller;
  final TextInputAction textInputAction;
  final String hintText;
  final Function(String) onChanged;
  final bool obscureText;
  final Function(String)? onSubmitted;
  final bool showError;
  final bool isPasswordField;
  final IconButton? suffixIcon;
  const _LoginTextField({
    required this.focusNode,
    required this.textInputAction,
    required this.hintText,
    required this.onChanged,
    required this.obscureText,
    this.controller,
    this.onSubmitted,
    this.showError = false,
    this.isPasswordField = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      focusNode: focusNode,
      obscureText: obscureText,
      textInputAction: textInputAction,
      textAlign: TextAlign.start,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintText: hintText,
        error: showError ? const SizedBox.shrink() : null,
        hintStyle: context.bodyMedium?.apply(
          color: context.outlineVariant,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        suffixIcon: suffixIcon,
        // isDense: true,
      ),
    );
  }
}
