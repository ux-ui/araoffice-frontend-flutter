import 'package:api/api.dart';
import 'package:app/app/common/common_popup_content.dart';
import 'package:app/router/route_guard.dart';
import 'package:app_localization/app_localization.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'app/login/view/login_controller.dart';
import 'router/router.dart';

class App extends StatelessWidget {
  App({super.key});
  final goRouter = GoRouter(
    routes: AppRouter.routes,
    redirect: RouteGuard.checkAuth, // RouteGuard 활성화!
    refreshListenable: LoginController.authStateListenable, // GetX 상태 연동
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.toString()}'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    Locale deviceLocale = View.of(context).platformDispatcher.locale;
    return GetMaterialApp.router(
      title: 'ARA Office',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: const AppTheme().themeData,
      darkTheme: const AppDarkTheme().themeData,
      translations: AppTranslations(),
      locale: deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider,
      builder: (buildercontext, child) {
        child = EasyLoading.init()(buildercontext, child);
        ApiDio.setServerErrorListener(() {
          EasyLoading.show(
              indicator: CommonPopupContent(
                  title: 'error_title'.tr,
                  message: 'error_server_error_message'.tr,
                  onConfirm: () {
                    EasyLoading.dismiss();
                  }));
        });
        ApiDio.setLoginStatusListener((message) {
          if (Get.isRegistered<LoginController>()) {
            Get.find<LoginController>()
                .checkLoginStatus(message)
                .then((result) {
              if (result != null) {
                debugPrint(
                    'Login status - isLoggedIn: ${result.isLoggedIn}, userLoginType: ${result.userLoginType}');
                // 로그인 성공 시 현재 경로가 로그인 페이지가 아니면 리다이렉트하지 않음
                if (result.isLoggedIn) {
                  final currentLocation =
                      goRouter.routerDelegate.currentConfiguration.uri.path;
                  debugPrint(
                      'Login status - current location: $currentLocation');
                  // 로그인 페이지에 있을 때만 홈으로 리다이렉트
                  if (currentLocation == '/') {
                    debugPrint(
                        'Login status - redirecting to home from login page');
                    goRouter.go('/home');
                  } else {
                    debugPrint(
                        'Login status - staying on current page: $currentLocation');
                  }
                }
              }
            });
          } else {
            LoginController().checkLoginStatus(message).then((result) {
              if (result != null) {
                debugPrint(
                    'Login status - isLoggedIn: ${result.isLoggedIn}, userLoginType: ${result.userLoginType}');
                // 로그인 성공 시 현재 경로가 로그인 페이지가 아니면 리다이렉트하지 않음
                if (result.isLoggedIn) {
                  final currentLocation =
                      goRouter.routerDelegate.currentConfiguration.uri.path;
                  debugPrint(
                      'Login status - current location: $currentLocation');
                  // 로그인 페이지에 있을 때만 홈으로 리다이렉트
                  if (currentLocation == '/') {
                    debugPrint(
                        'Login status - redirecting to home from login page');
                    goRouter.go('/home');
                  } else {
                    debugPrint(
                        'Login status - staying on current page: $currentLocation');
                  }
                }
              }
            });
          }
        });
        ApiDio.setErrorListenerWithData((message) {
          switch (message["statusCode"]) {
            case 302:
              // naver works api 응답 예외처리
              // sso 인증정보로 네이버 웍스 로그인 인증 시도
              if (Get.isRegistered<LoginController>()) {
                Get.find<LoginController>().handle302Redirect(
                  message["message"],
                );
              } else {
                LoginController().handle302Redirect(
                  message["message"],
                );
              }
              break;

            case 401:
              EasyLoading.show(
                  indicator: CommonPopupContent(
                      // title: 'error 401'.tr,
                      headerWidget: const Icon(Icons.error),
                      message: //\n error code ${message["statusCode"]
                          '${message["message"]} }',
                      onConfirm: () {
                        EasyLoading.dismiss();
                        Future.delayed(const Duration(seconds: 1), () {
                          goRouter.go('/');
                        });
                      }));
              break;
            case 500:
              EasyLoading.show(
                  indicator: CommonPopupContent(
                      title: 'error'.tr,
                      message:
                          'error code ${message["statusCode"]} : ${message["message"]}',
                      onConfirm: () {
                        EasyLoading.dismiss();
                      }));
              break;
            default:
              EasyLoading.show(
                  indicator: CommonPopupContent(
                      title: 'error'.tr,
                      message:
                          'error code ${message["statusCode"]} : ${message["message"]}',
                      onConfirm: () {
                        EasyLoading.dismiss();
                      }));
              break;
          }
        });
        return child;
      },
    );
  }
}
