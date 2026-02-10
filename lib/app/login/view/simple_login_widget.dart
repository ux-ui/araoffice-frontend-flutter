import 'package:app/app/home/view/home_page.dart';
import 'package:app/app/login/view/login_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class SimpleLoginWidget extends GetView<LoginController> {
  final BuildContext widgetContext;
  final Function() onClose;
  final Function() onLogin;
  const SimpleLoginWidget(
      {super.key,
      required this.widgetContext,
      required this.onClose,
      required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Column(
        children: [
          _buildLoadTextField(widgetContext),
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
              onPressed: () => loginProcess(widgetContext),
              child: Text('login'.tr,
                  style:
                      context.bodyLarge?.copyWith(color: context.onPrimary))),
        ],
      ),
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
                FocusScope.of(widgetContext)
                    .requestFocus(controller.passwordFocus);
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
            border: Border.all(color: widgetContext.outline, width: 1),
          ),
          child: Obx(() {
            return _LoginTextField(
              focusNode: controller.passwordFocus,
              textInputAction: TextInputAction.done,
              hintText: 'password_hint_text'.tr,
              onChanged: controller.onPasswordChanged,
              obscureText: controller.obscureText.value,
              onSubmitted: (_) => loginProcess(widgetContext),
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

  void loginProcess(BuildContext context) async {
    final result = await controller.loginAuth();

    if (!widgetContext.mounted) return;
    if (result) {
      controller.loginSessionToken.value = true;

      // URL 쿼리 파라미터에서 리다이렉트 경로 확인
      final uri = GoRouterState.of(widgetContext).uri;
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
      controller.clearPassword();
      widgetContext.go(targetPath);
    } else {
      controller.loginSessionToken.value = false;
      showLoginFailDialog(widgetContext, controller.loginErrorMessage.value);
    }
  }

  void showLoginFailDialog(BuildContext widgetContext, String errorMessage) {
    showDialog(
      context: widgetContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // 로그인 실패
          title: Text('login_fail'.tr),
          content: Text(errorMessage), // 실패 이유 표시
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
