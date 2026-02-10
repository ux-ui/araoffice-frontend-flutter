import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../app/editor/editor_page.dart';
import '../app/login/view/change_password_page.dart';
import '../app/login/view/find_account_page.dart';
import '../app/login/view/login_controller.dart';
import '../app/sign_up/sign_up_page.dart';

class RouteGuard {
  // Public routes (인증 불필요)
  static const Set<String> publicRoutes = {
    '/', // LoginPage
    SignUpPage.route, // SignUpPage
    FindAccountPage.route, // FindAccountPage
    ChangePasswordPage.route, // ChangePasswordPage
    EditorPage.route, // EditorPage - 게스트 접근 허용
  };

  static String? checkAuth(BuildContext context, GoRouterState state) {
    try {
      final path = state.uri.path;
      // 원래 접근하려던 경로(쿼리 파라미터 포함)를 쿼리 파라미터로 전달
      final fullPath =
          state.uri.path + (state.uri.hasQuery ? '?${state.uri.query}' : '');

      final isPublicRoute = _isPublicRoute(path);

      // 인증 상태 확인
      final isLoggedIn = checkLoginStatus();

      logger.d(
          'RouteGuard: path=$path, isPublic=$isPublicRoute, isLoggedIn=$isLoggedIn');

      // 리다이렉트 로직
      return _determineRedirect(path, fullPath, isPublicRoute, isLoggedIn);
    } catch (e) {
      logger.e('RouteGuard error: $e');
      return '/'; // 에러 시 안전하게 로그인으로
    }
  }

  // Private helper methods
  static bool _isPublicRoute(String path) {
    return publicRoutes.contains(path) || path.startsWith('/change-password');
  }

  static bool checkLoginStatus() {
    // LoginController가 등록되어 있는지 확인
    if (!Get.isRegistered<LoginController>()) {
      return false;
    }

    final loginController = Get.find<LoginController>();
    loginController.getUser();
    // 세션 복원 완료 후 userId 체크
    final hasUserId = loginController.userId.value.isNotEmpty;
    logger.d('RouteGuard: 세션 복원 완료, userId 있음: $hasUserId');

    return hasUserId;
  }

  static String? _determineRedirect(
      String path, String fullPath, bool isPublicRoute, bool isLoggedIn) {
    // Case 1: 비로그인 상태에서 private route 접근
    if (!isLoggedIn && !isPublicRoute) {
      logger.d('Redirecting to login: not logged in accessing private route');
      final encodedPath = Uri.encodeComponent(fullPath);
      logger.d('Saved redirect path as query param: $fullPath');
      return '/?redirect=$encodedPath';
    }

    // Case 2: 로그인 상태에서 로그인 페이지 접근 (가장 먼저 체크)
    if (isLoggedIn && path == '/') {
      // redirect 쿼리 파라미터가 있으면 해당 경로로, 없으면 홈으로
      final uri = Uri.parse(fullPath);
      final redirectParam = uri.queryParameters['redirect'];

      if (redirectParam != null && redirectParam.isNotEmpty) {
        try {
          final decodedPath = Uri.decodeComponent(redirectParam);
          logger.d('Redirecting to saved path: $decodedPath');
          return decodedPath;
        } catch (e) {
          logger.e('리다이렉트 경로 디코딩 실패: $e');
          logger
              .d('Redirecting to home: already logged in accessing login page');
          return '/home';
        }
      } else {
        logger.d('Redirecting to home: already logged in accessing login page');
        return '/home';
      }
    }

    // Case 3: 정상 접근
    return null;
  }
}
