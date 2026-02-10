import 'package:app/app/login/view/login_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:author_editor/enum/enums.dart';
import 'package:common_assets/common_assets.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SsoLoginPage extends StatefulWidget {
  final UserLoginType ssoType;
  final TenantType tenantType;
  const SsoLoginPage(
      {super.key, required this.ssoType, required this.tenantType});

  @override
  State<SsoLoginPage> createState() => _SsoLoginPageState();
}

class _SsoLoginPageState extends State<SsoLoginPage> {
  final LoginController controller = Get.find<LoginController>();
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    debugPrint(
        '####@@@INIT STATE: SsoLoginPage: tenantType: ${widget.tenantType}, widget.ssoType: ${widget.ssoType}');
    // 네이버 웍스 타입일 때만 리다이렉트 체크
    if (widget.tenantType == TenantType.mois ||
        widget.tenantType == TenantType.gov ||
        widget.tenantType == TenantType.standard ||
        widget.tenantType == TenantType.msit ||
        widget.tenantType == TenantType.mfds ||
        widget.tenantType == TenantType.dferi ||
        widget.tenantType == TenantType.mpb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndRedirect();
      });
    }
  }

  /// 로그인 상태를 확인하고 필요시에만 리다이렉트
  Future<void> _checkAndRedirect() async {
    // 이미 리다이렉트했으면 다시 하지 않음
    if (_hasRedirected) {
      return;
    }

    // 컨트롤러 초기화 완료 대기 (새로고침 시 getUser가 완료될 때까지 대기)
    //딜레이 타임 0.5초
    int waitCount = 0;
    while (waitCount < 2) {
      // userId가 설정되어 있으면 초기화 완료로 간주
      if (controller.userId.value.isNotEmpty) {
        debugPrint(
            '####@@@ checkAndRedirect: controller Break Count: $waitCount, userId=${controller.userId.value}');
        break;
      }
      // 로그인 세션 토큰이 있으면 초기화 완료로 간주
      if (controller.loginSessionToken.value) {
        debugPrint(
            '####@@@ checkAndRedirect: controller Break Count: $waitCount, loginSessionToken=${controller.loginSessionToken.value}');
        break;
      }
      await Future.delayed(const Duration(milliseconds: 50));
      waitCount++;
    }

    // 사용자 정보를 다시 한 번 가져와서 최신 상태 확인
    // (새로고침 시 getUser가 완료되었는지 확인)
    try {
      await controller.getUser();
      // 상태 업데이트 대기
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      logger.w('사용자 정보 가져오기 실패: $e');
    }

    // 로그인 상태 확인 - 이미 로그인되어 있으면 리다이렉트하지 않음
    final isLoggedIn = controller.loginSessionToken.value ||
        controller.userId.value.isNotEmpty;

    if (isLoggedIn) {
      debugPrint(
          '####@@@ 이미 로그인되어 있어 리다이렉트하지 않음: userId=${controller.userId.value}, loginSessionToken=${controller.loginSessionToken.value}');
      return;
    }

    // 로그인되어 있지 않을 때만 리다이렉트
    _hasRedirected = true;
    debugPrint('####@@@ checkAndRedirect: 리다이렉트 시작');
    await controller.handleLoginRedirect();
    debugPrint('####@@@ checkAndRedirect: 리다이렉트 완료');
  }

  /// 로그인 상태를 확인하고 필요시에만 리다이렉트
  // Future<void> _naverWorksLoginRedirect() async {
  //   logger.i('####@@@@@  네이버 호출출ㅊ룿루');
  //   // 이미 리다이렉트했으면 다시 하지 않음
  //   if (_hasRedirected) {
  //     return;
  //   }

  //   // 컨트롤러 초기화 완료 대기 (새로고침 시 getUser가 완료될 때까지 대기)
  //   // 최대 3초 대기 (30번 * 100ms)
  //   int waitCount = 0;
  //   while (waitCount < 5) {
  //     // userId가 설정되어 있으면 초기화 완료로 간주
  //     if (controller.userId.value.isNotEmpty) {
  //       break;
  //     }
  //     // 로그인 세션 토큰이 있으면 초기화 완료로 간주
  //     if (controller.loginSessionToken.value) {
  //       break;
  //     }
  //     await Future.delayed(const Duration(milliseconds: 50));
  //     waitCount++;
  //   }

  //   // 사용자 정보를 다시 한 번 가져와서 최신 상태 확인
  //   // (새로고침 시 getUser가 완료되었는지 확인)
  //   try {
  //     await controller.getUser();
  //     // 상태 업데이트 대기
  //     await Future.delayed(const Duration(milliseconds: 50));
  //   } catch (e) {
  //     logger.w('사용자 정보 가져오기 실패: $e');
  //   }

  //   // 로그인 상태 확인 - 이미 로그인되어 있으면 리다이렉트하지 않음
  //   final isLoggedIn = controller.loginSessionToken.value ||
  //       controller.userId.value.isNotEmpty;

  //   if (isLoggedIn) {
  //     logger.i(
  //         '이미 로그인되어 있어 리다이렉트하지 않음: userId=${controller.userId.value}, loginSessionToken=${controller.loginSessionToken.value}');
  //     return;
  //   }

  //   // 로그인되어 있지 않을 때만 리다이렉트
  //   _hasRedirected = true;
  //   await _handleNaverWorksLogin(context);
  // }

  @override
  Widget build(BuildContext context) {
    debugPrint('#### 웍스 SsoLoginPage: ssoType: ${widget.ssoType}');

    // 네이버 웍스 타입일 때는 리다이렉트되므로 로딩 메시지만 표시
    // if (widget.ssoType == UserLoginType.naverWorks) {
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    // 다른 타입들은 기존대로
    return Column(children: [
      CommonAssets.image.mainBanner.image(
        width: double.infinity,
        height: 250,
      ),
      const SizedBox(height: 20),
      // if (widget.ssoType == UserLoginType.naverWorks ||
      //     widget.ssoType == UserLoginType.naver_works)
      //   _buildNaverWorksLogin(context),
      if (widget.ssoType == UserLoginType.brityWorks) _buildBrityLogin(context),
      if (widget.ssoType == UserLoginType.araEbook)
        _buildAraServiceLogin(context),
      const SizedBox(height: 8),
    ]);
  }

  /// 네이버 웍스 로그인 처리 함수 - login_page.dart의 _handleNaverWorksLogin과 동일한 방식
  Future<void> _handleNaverWorksLogin(BuildContext context) async {
    try {
      // 사용자 정보를 다시 한 번 확인 (로그인 완료 후 돌아온 경우 대비)
      try {
        await controller.getUser();
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        logger.w('사용자 정보 확인 중 오류: $e');
      }

      // 다시 한 번 로그인 상태 확인 (이중 체크)
      final isLoggedIn = controller.loginSessionToken.value ||
          controller.userId.value.isNotEmpty;

      if (isLoggedIn) {
        logger.i(
            '리다이렉트 전 로그인 상태 확인: 이미 로그인됨, 리다이렉트 중단 - userId=${controller.userId.value}');
        return;
      }

      // 컨트롤러의 네이버 웍스 로그인 메서드 호출 (현재 페이지에서 리다이렉트)
      final result = await controller.naverWorksLogin();
      debugPrint(
          '#### [${AutoConfig.instance.domainType}]: _handleNaverWorksLogin: result: $result');

      // 리다이렉트 성공 시 네이버 웍스 로그인 페이지로 이동됨
      // 로그인 완료 후 백엔드가 리다이렉트하고 RouteGuard가 홈페이지로 이동시킴
    } catch (e) {
      if (!context.mounted) return;
      showLoginFailDialog(context, 'naver_works_login_fail_message'.tr);
    }
  }

  Widget _buildNaverWorksLogin(BuildContext context) {
    return VulcanXOutlinedButton(
      width: double.infinity,
      height: 56.0,
      onPressed: () => _handleNaverWorksLogin(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonAssets.image.naverWorksLogo.image(
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 16),
          Text('sso_login_button'.trArgs([widget.ssoType.name]),
              style: context.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildBrityLogin(BuildContext context) {
    return VulcanXOutlinedButton(
      width: double.infinity,
      height: 56.0,
      onPressed: () => () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonAssets.image.naverWorksLogo.image(
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 16),
          Text('sso_login_button'.trArgs([widget.ssoType.name]),
              style: context.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildAraServiceLogin(BuildContext context) {
    return VulcanXOutlinedButton(
      width: double.infinity,
      height: 56.0,
      onPressed: () => () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoConfig.instance.domainType.isDferiDomain
              ? CommonAssets.image.dferiLogo.svg(width: 24, height: 24)
              : CommonAssets.image.araCircleLogo.svg(
                  width: 24,
                  height: 24,
                ),
          const SizedBox(width: 16),
          Text('sso_login_button'.trArgs([widget.ssoType.name]),
              style: context.bodyLarge),
        ],
      ),
    );
  }

  void showLoginFailDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
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
