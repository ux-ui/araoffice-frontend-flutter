import 'package:app/app/login/view/login_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 로그아웃 완료 페이지
/// SSO 로그아웃 후 리다이렉트되는 페이지
class LogoutCompletePage extends StatelessWidget {
  static const String route = '/logout/complete';

  const LogoutCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: context.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'logout_complete_title'.tr,
                style: context.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'logout_complete_message'.tr,
                style:
                    context.bodyLarge?.apply(color: context.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: VulcanXElevatedButton(
                  onPressed: () => _goToLogin(context),
                  child: Text('back_to_login'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToLogin(BuildContext context) {
    // 로그인 컨트롤러 정리
    if (Get.isRegistered<LoginController>()) {
      final loginController = Get.find<LoginController>();
      loginController.handleLogout();
    }

    // 로그인 페이지로 이동
    Get.offAllNamed('/login');
  }
}
