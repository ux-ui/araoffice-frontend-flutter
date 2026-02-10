import 'dart:async';

import 'package:api/api.dart';
import 'package:app/app/common/common_popup_content.dart';
import 'package:app/app/login/view/tenant_setting_controller.dart';
import 'package:app/app/setting/language_enum.dart';
import 'package:app/app/sign_up/sso_sign_up_popup.dart';
import 'package:app/app/user_setting/account/chage_share_id_dialog.dart';
import 'package:app_ui/app_ui.dart';
import 'package:author_editor/enum/user_login_type.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// /**
//  * flutter 3.35.0
//  * dart:html is deprecated.
//  * Use package:web and dart:js_interop instead.
//  */
// import 'dart:html' as html;
import 'package:web/web.dart' as web;

enum LoginType {
  idPassword('idPassword'),
  kakao('kakao'),
  naver('naver'),
  naverWorks('naverWorks'),
  araService('araService');

  final String value;
  const LoginType(this.value);

  factory LoginType.fromString(String tag) {
    return LoginType.values.firstWhere(
      (type) => type.value == tag,
      orElse: () => LoginType.idPassword,
    );
  }
}

class LoginStatusResult {
  final bool isLoggedIn;
  final String userLoginType;

  LoginStatusResult({
    required this.isLoggedIn,
    required this.userLoginType,
  });
}

class LoginController extends GetxController {
  final apiClient = Get.find<LoginApiClient>();
  final apiService = Get.find<LoginApiService>();
  final nickNameApiService = Get.find<NickNameApiService>();
  // final tenantSettingApiService = Get.find<TenantSettingApiService>();

  // TenantSettingController를 지연 로딩 (순환 의존성 회피)
  TenantSettingController get tenantSettingController =>
      Get.find<TenantSettingController>();

  final isLoginPageSsoSetting = false.obs;

  final loginUserInfo = Rx<UserModel?>(null);
  final id = ''.obs;
  final password = ''.obs;
  final isIdValid = false.obs;
  final isPasswordValid = false.obs;
  final canLogin = false.obs;
  final isProgress = false.obs;
  final findAccountEmail = ''.obs;
  static const String kUserId = 'remembered_user_id';
  static const String kRememberId = 'remember_id_enabled';
  static const String kUserLoginType = 'saved_user_login_type';
  static const int kMaxLoginAttempts = 5; // 최대 로그인 시도 횟수

  final sessionId = Rxn<String>();
  final userInfo = ''.obs;

  final userId = ''.obs;
  final userEmail = ''.obs;
  final userDisplayName = ''.obs;
  final userShareId = ''.obs;

  // getUser API 호출 캐싱을 위한 변수
  DateTime? _lastGetUserCall;
  static const Duration _getUserCacheDuration = Duration(seconds: 5); // 5초 캐시
  bool _isGettingUser = false; // 중복 호출 방지 플래그
  // final userLoginType = UserLoginType.ara.obs;
  final userLoginType = TenantType.ara.obs; // 유저 타입
  final savedUserLoginType = UserLoginType.ara.obs; // 유저 로그인 저장 타입
  final userPersonalInfoAgree = false.obs;
  final tenantType = TenantType.ara.obs;

  final loginErrorMessage = 'login_fail'.obs;
  final obscureText = true.obs;
  final RxBool rememberIdEnabled = false.obs;
  final RxBool rememberAutoLoginEnabled = false.obs;
  final Throttle _loginActionThrottle = Throttle(milliseconds: 200);
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController findAccountEmailController =
      TextEditingController();
  final TextEditingController idFindEmailAuthCodeController =
      TextEditingController();
  final TextEditingController passwordFindIdController =
      TextEditingController();
  final TextEditingController passwordFindEmailAuthCodeController =
      TextEditingController();

  // 아이디/비밀번호 찾기 관련 변수
  final isFindingId = true.obs;
  final isFindingPassword = false.obs;
  final emailController = TextEditingController();
  final findAccountErrorMessage = ''.obs;
  final hashPassword = ''.obs;
  final authCode = ''.obs;
  final idFindEmailStatus = false.obs;
  final passwordFindEmailStatus = false.obs;
  final isIdAuthCodeValid = false.obs;
  final isPasswordAuthCodeValid = false.obs;
  final findIdResult = ''.obs;

  final _storage = const FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'auth_storage',
    ),
  );

  final isPasswordVisible = false.obs;
  final newPassword = ''.obs;
  final confirmPassword = ''.obs;

  final loginSessionToken = false.obs; // 로그인 세션 체크 토큰
  bool _isInitializing = false; // 초기화 중 플래그 (새로고침 시 로그아웃 방지)
  final savedRedirectUrl = Rxn<String>(); // 302 응답 시 저장할 원래 URL
  bool _isSessionExpiredPopupShowing = false; // 세션 만료 팝업 표시 중 플래그
  bool loginSuccess = false; // 로그인 성공 여부 플래그 (401 응답 처리 시 사용)

  // final ssotypeString = 'naverWorks'.obs;
  final ssotypeString = 'ara'.obs;

  // 간편로그인 관련 변수
  final isSimpleLogin = false.obs;
  final simpleLoginType = ''.obs;
  final simpleLoginId = ''.obs;
  final simpleLoginPassword = ''.obs;
  final TextEditingController simpleLoginIdController = TextEditingController();
  final TextEditingController simpleLoginPasswordController =
      TextEditingController();
  final FocusNode simpleLoginIdFocus = FocusNode();
  final FocusNode simpleLoginPasswordFocus = FocusNode();
  final isSimpleLoginIdValid = false.obs;
  final isSimpleLoginPasswordValid = false.obs;
  final obscureSimpleLoginPassword = true.obs;
  final isRegistered = false.obs;
  final userData = Rx<UserData>(
    UserData(
      userName: '',
      email: '',
      birthDate: '',
      gender: '',
      phoneNumber: '',
      userId: '',
      uuid: '',
    ),
  );

  // 닉네임 관련 변수
  final nickname = ''.obs;
  final nicknameCandidates = <String>[].obs;
  final uniqueNicknameCandidates = <String>[].obs;
  final isNicknameValid = false.obs;
  final isUniqueNicknameValid = false.obs;
  final isNicknameDuplicate = false.obs;
  final isUniqueNicknameDuplicate = false.obs;
  final isNicknameCandidatesGenerated = false.obs;
  final isUniqueNicknameCandidatesGenerated = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(id, (_) => validateId());
    ever(password, (_) => validatePassword());
    ever(simpleLoginId, (_) => validateSimpleLoginId());
    ever(simpleLoginPassword, (_) => validateSimpleLoginPassword());
    everAll([isIdValid, isPasswordValid], (_) => updateCanLogin());
    settingLoginPageSetting();
    _loadSavedData();
    logger.i('login controller init');
    _asyncLoadSavedData();
    ever(newPassword, (_) => validatePassword());
    ever(confirmPassword, (_) => validatePassword());
    initializeLanguage();
    // getUserId();
    getUser();
    // tenantSettingController.getAutoConfigSetting();
    // WidgetsBinding.instance.addPostFrameCallbacsk((_) {
    // });
  } // 컨트롤러 dispose 시 처리

  @override
  void onClose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    simpleLoginIdFocus.dispose();
    simpleLoginPasswordFocus.dispose();
    clearPassword();
    idController.dispose();
    passwordController.dispose();
    simpleLoginIdController.dispose();
    simpleLoginPasswordController.dispose();
    findAccountEmailController.dispose();
    idFindEmailAuthCodeController.dispose();
    passwordFindEmailAuthCodeController.dispose();
    passwordFindIdController.dispose();
    super.onClose();
  }

  @override
  void dispose() {
    super.dispose();
    idController.dispose();
    passwordController.dispose();
    simpleLoginIdController.dispose();
    simpleLoginPasswordController.dispose();
    findAccountEmailController.dispose();
    idFindEmailAuthCodeController.dispose();
    passwordFindEmailAuthCodeController.dispose();
    passwordFindIdController.dispose();
  }

  void settingLoginPageSetting() {
    // sso 연동 유무 설정
    if (AutoConfig.instance.domainType.isLocalDevDomain) {
      isLoginPageSsoSetting.value = false;
      debugPrint('####@@@settingLoginPageSetting: isLocalDevDomain');
      return;
    } else if (AutoConfig.instance.domainType.isAraDemoDomain) {
      isLoginPageSsoSetting.value = false;
      debugPrint('####@@@settingLoginPageSetting: isAraDemoDomain');
      return;
    } else if (AutoConfig.instance.domainType.isMfdsNormalDomain) {
      isLoginPageSsoSetting.value = false;
      debugPrint('####@@@settingLoginPageSetting: isMfdsNormalDomain');
      return;
    } else if (AutoConfig.instance.domainType.isMoisAraepubDomain) {
      isLoginPageSsoSetting.value = false;
      debugPrint('####@@@settingLoginPageSetting: isMoisAraepubDomain');
      return;
    } else if (AutoConfig.instance.domainType.isStandardDomain) {
      isLoginPageSsoSetting.value = true;
      debugPrint('####@@@settingLoginPageSetting: isStandardDomain');
      return;
    } else if (AutoConfig.instance.domainType.isGovDomain) {
      isLoginPageSsoSetting.value = true;
      debugPrint('####@@@settingLoginPageSetting: isGovDomain');
      return;
    } else if (AutoConfig.instance.domainType.isMoisDomain) {
      isLoginPageSsoSetting.value = true;
      debugPrint('####@@@settingLoginPageSetting: isMoisDomain');
      return;
    } else if (AutoConfig.instance.domainType.isMsitDomain) {
      isLoginPageSsoSetting.value = true;
      debugPrint('####@@@settingLoginPageSetting: isMsitDomain');
      return;
    } else if (AutoConfig.instance.domainType.isMfdsDomain) {
      isLoginPageSsoSetting.value = true;
      debugPrint('####@@@settingLoginPageSetting: isMfdsDomain');
      return;
    } else if (AutoConfig.instance.domainType.isMpbDomain) {
      isLoginPageSsoSetting.value = true;
      debugPrint('####@@@settingLoginPageSetting: isMpbDomain');
      return;
    } else if (AutoConfig.instance.domainType.isDferiDomain) {
      isLoginPageSsoSetting.value = true;
      debugPrint('####@@@settingLoginPageSetting: isDferiDomain');
      return;
    } else if (AutoConfig.instance.domainType.isAraDomain) {
      isLoginPageSsoSetting.value = false;
      debugPrint('####@@@settingLoginPageSetting: isAraDomain');
      return;
    } else if (AutoConfig.instance.domainType.isGovDomainWithoutTenant) {
      isLoginPageSsoSetting.value = false;
      debugPrint('####@@@settingLoginPageSetting: isGovDomainWithoutTenant');
      return;
    } else if (AutoConfig.instance.domainType.isMoisLocalDomain) {
      isLoginPageSsoSetting.value = true;
      debugPrint('####@@@settingLoginPageSetting: isMoisLocalDomain');
      return;
    } else {
      isLoginPageSsoSetting.value = false;
      debugPrint('####@@@settingLoginPageSetting: default');
      return;
    }
  }

  // tenant setting api
  // Future<void> getCurrentTenantSetting() async {
  //   final result = await tenantSettingApiService.getCurrentTenantSetting();
  //   if (result != null) {
  //     debugPrint('####@@@getCurrentTenantSetting: ${result.toJson()}');
  //   }
  // }

  // admin의 visible on/off 셋팅
  Future<void> setAdminVisible(bool visible) async {
    //   final result = await apiService.setAdminVisible(visible);
    //   if (result != null) {
    //     return result;
    //   }
    //   return null;
  }

  Future<String?> generateUniqueNickname() async {
    final result = await nickNameApiService.generateUniqueNickname();
    if (result != null) {
      nickname.value = result.nickname;
      return nickname.value;
    }
    return null;
  }

  Future<String?> generateRandomNickname() async {
    final result = await nickNameApiService.generateRandomNickname();
    if (result != null) {
      nickname.value = result.nickname;
      return nickname.value;
    }
    return null;
  }

  Future<String?> regenerateNickname() async {
    final result = await nickNameApiService.regenerateNickname();
    if (result != null) {
      nickname.value = result.nickname;
      return nickname.value;
    }
    return null;
  }

  Future<String?> checkNicknameDuplicate(String nickname) async {
    final result =
        await nickNameApiService.checkNicknameDuplicate(nickname: nickname);
    if (result != null) {
      isNicknameDuplicate.value = result.isDuplicate;
      return result.value;
    }
    return null;
  }

  Future<List<String>?> generateNicknameCandidates(int count) async {
    final result =
        await nickNameApiService.generateNicknameCandidates(count: count);
    if (result != null) {
      nicknameCandidates.value = result.candidates;
      return nicknameCandidates.value;
    }
    return null;
  }

  Future<List<String>?> generateUniqueNicknameCandidates(int count) async {
    final result =
        await nickNameApiService.generateUniqueNicknameCandidates(count: count);
    if (result != null) {
      uniqueNicknameCandidates.value = result.candidates;
      return uniqueNicknameCandidates.value;
    }
    return null;
  }

  Future<bool> updatePersonalInfoAgreement(bool isPersonalInfoAgree) async {
    try {
      final result = await apiService.updatePersonalInfoAgreement(
        isPersonalInfoAgree: isPersonalInfoAgree,
      );
      return result;
    } catch (e) {
      debugPrint('Error update Personal Info Agreement : $e');
      return false;
    }
  }

  void initOfficeViewer(BuildContext context) async {
    tenantSettingController.setTenantSetting();
    await getUser();
    // await checkLoginSignStatus(context);
  }

  Future<bool> checkUserShareId(BuildContext context) async {
    if (loginSessionToken.value) {
      if (loginUserInfo.value?.userId?.isNotEmpty ?? false) {
        return await checkUserShareIdStatus(context);
      } else {
        return false;
      }
    }
    return false;
  }

  Future<bool> checkUserShareIdStatus(BuildContext context) async {
    // 사용자 정보가 없으면 먼저 가져오기 (캐시된 정보 사용)
    if (loginUserInfo.value == null || userId.value.isEmpty) {
      await getUser();
    }

    if (loginUserInfo.value?.userId == null) {
      return true;
    }

    if (userShareId.value == '' || userShareId.value.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      final result = await _presentShareIdPopup(context);
      // 회원가입 완료 시 true, 취소 또는 다른 방식으로 닫힌 경우 false
      return result;
    }
    return true;
  }

  Future<bool> _presentShareIdPopup(BuildContext context) async {
    try {
      // nickNameApiService가 초기화되었는지 확인
      if (!Get.isRegistered<NickNameApiService>()) {
        logger.w('NickNameApiService가 등록되지 않았습니다.');
        return false;
      }

      FocusManager.instance.primaryFocus?.unfocus();

      final dialogContext = Get.context ?? context;

      // 위젯 빌드 완료 후 다이얼로그 표시
      final completer = Completer<bool>();
      VulcanCloseDialogWidget? dialogWidget;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          dialogWidget = VulcanCloseDialogWidget(
            isShowClose: false,
            width: 320,
            title: 'share_id'.tr,
            content: Column(
              children: [
                Text(
                  'share_id_change_popup_title'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                ShareIdChangeDialog(
                    loginController: this,
                    onConfirm: (value) async {
                      try {
                        final result = await apiService.updateUser(
                            displayName: '',
                            email: '',
                            profileImage: '',
                            shareId: value);
                        if (result) {
                          userShareId.value = value;
                        }
                        // 업데이트 완료 후 다이얼로그 닫기
                        dialogWidget?.close(VulcanCloseDialogType.ok);
                        await getUser();
                      } catch (e) {
                        logger.e('ShareId 업데이트 실패: $e');
                      }
                    }),
              ],
            ),
          );

          final result = await dialogWidget!.show(dialogContext);

          // 다이얼로그가 정상적으로 닫혔는지 확인
          if (!completer.isCompleted) {
            completer.complete(result != null);
          }
        } catch (e) {
          logger.e('ShareId 팝업 표시 중 오류: $e');
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        }
      });

      return completer.future;
    } catch (e) {
      logger.e('ShareId 팝업 초기화 중 오류: $e');
      return false;
    }
  }

  Future<bool> checkLoginSignStatus(BuildContext context) async {
    // if (loginSessionToken.value) {
    //   if (loginUserInfo.value?.userId?.isNotEmpty ?? false) {
    //     return await checkUserSignStatus(context);
    //   } else {
    //     return false;
    //   }
    // }
    // return false;
    return true;
  }

  Future<bool> checkUserSignStatus(BuildContext context) async {
    // 사용자 정보가 없으면 먼저 가져오기 (캐시된 정보 사용)
    // if (loginUserInfo.value == null && userId.value.isEmpty) {
    //   await getUser();
    // }

    // common 로그인이 아닌경우 유저의 가입 여부를 체크하여 가입되어 있지 않으면 sso 가입 팝업을 띄워야 함
    debugPrint(
        '#####@@@ checkUserSignStatus: userLoginType: ${userLoginType.value.name}');
    // if (loginUserInfo.value?.userId == null) {
    //   return true;
    // }
    // if (userLoginType.value == TenantType.ara ||
    //     userLoginType.value == TenantType.dferi) {
    //   return true;
    // }
    // if (userPersonalInfoAgree.value != true) {
    //   FocusManager.instance.primaryFocus?.unfocus();
    //   final result = await _presentSsoPopup(context);
    //   // 회원가입 완료 시 true, 취소 또는 다른 방식으로 닫힌 경우 false
    //   return result;
    // }
    return true;
  }

  // 팝업을 빌드 완료 후에 안전하게 띄우기 위한 헬퍼
  Future<bool> _presentSsoPopup(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final completer = Completer<bool>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await SsoSignUpPopup.show(
        context,
        onSignUpComplete: (
          isPersonalInfoAgree,
          isMarketingAgree,
        ) async {
          final ok = await updatePersonalInfoAgreement(isPersonalInfoAgree);

          if (!ok) {
            Future.microtask(() async {
              await sessionLogout();
              if (context.mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go('/');
                });
              }
            });
          } else {
            // await getUserId();
            await getUser();
          }
        },
        onClose: () {
          Future.microtask(() async {
            await sessionLogout();
            if (context.mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/');
              });
            }
          });
        },
      );
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    });
    return completer.future;
  }

  Future<void> _loadSavedData() async {
    try {
      // 체크박스 상태 로드
      final rememberId = await _storage.read(key: kRememberId);
      rememberIdEnabled.value = rememberId == 'true';
      final autoLogin = await _storage.read(key: 'autoLogin');
      rememberAutoLoginEnabled.value = autoLogin == 'true';

      // 체크박스가 체크된 경우에만 저장된 ID 로드
      if (rememberIdEnabled.value) {
        final savedId = await _storage.read(key: kUserId);
        if (savedId != null && savedId.isNotEmpty) {
          id.value = savedId;
        }
      }

      // 저장된 userLoginType 불러오기
      final savedLoginType = await _storage.read(key: kUserLoginType);
      if (savedLoginType != null && savedLoginType.isNotEmpty) {
        try {
          // userLoginType.value = UserLoginType.fromString(savedLoginType);
          userLoginType.value = TenantType.fromString(savedLoginType);
          logger.i('저장된 로그인 타입 복원: ${userLoginType.value.name}');
        } catch (e) {
          logger.w('저장된 로그인 타입 파싱 실패: $e');
          // 파싱 실패 시 기본값 유지
        }
      }
    } catch (e) {
      logger.e('Error loading saved data', e);
      rememberIdEnabled.value = false;
      id.value = '';
    }
    idController.text = id.value;
  }

  _asyncLoadSavedData() async {
    _isInitializing = true;
    logger.i('login init');
    userInfo.value = await _storage.read(key: 'loginInfo') ?? '';
    logger.i('저장된 유저 정보: $userInfo');
    if (userInfo.value.isNotEmpty) {
      sessionId.value = userInfo.value;
      logger.i('세션 복원 시도: $userInfo');

      // 세션 유효성 검증 및 사용자 정보 복원
      try {
        final userModel = await getUser();
        if (userModel != null && userId.value.isNotEmpty) {
          // 세션 복원 성공
          logger
              .i('세션 복원 성공: userId=${userId.value}, email=${userEmail.value}');
          // 세션 복원 성공 시 loginSessionToken 명시적으로 설정
          // (GoRouter의 refreshListenable이 변경을 감지하도록)
          loginSessionToken.value = true;

          Future.microtask(() {
            loginSessionToken.value = false;
            Future.microtask(() {
              loginSessionToken.value = true;
            });
          });

          tenantSettingController.setTenantSetting();
        } else {
          // 사용자 정보가 없으면 세션이 만료된 것으로 판단
          logger.w('세션 만료: 사용자 정보 없음');
          await _clearSessionData();
        }
      } catch (e) {
        // 세션 만료 시 정리
        logger.w('세션 만료 또는 오류, 세션 정리: $e');
        await _clearSessionData();
      }
    } else {
      userInfo.value = '';
      _isInitializing = false;
      return;
    }
    _isInitializing = false;
  }

  /// 세션 데이터 정리 (로그아웃 처리)
  Future<void> _clearSessionData() async {
    await _storage.delete(key: 'loginInfo');
    userInfo.value = '';
    sessionId.value = null;
    userId.value = '';
    userEmail.value = '';
    userDisplayName.value = '';
    loginSessionToken.value = false;
  }

  Future<UserModel?> getUser({bool forceRefresh = false}) async {
    // 이미 사용자 정보가 있고 캐시가 유효하면 반환
    if (!forceRefresh &&
        loginUserInfo.value != null &&
        _lastGetUserCall != null &&
        DateTime.now().difference(_lastGetUserCall!) < _getUserCacheDuration) {
      debugPrint('#### getUser: 캐시된 사용자 정보 반환');
      return loginUserInfo.value;
    }

    // 이미 API 호출 중이면 대기
    if (_isGettingUser) {
      debugPrint('#### getUser: 이미 호출 중이므로 대기');
      // 최대 3초 대기
      int waitCount = 0;
      while (_isGettingUser && waitCount < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
      // 대기 후에도 사용자 정보가 있으면 반환
      if (loginUserInfo.value != null) {
        return loginUserInfo.value;
      }
    }

    _isGettingUser = true;
    _lastGetUserCall = DateTime.now();

    try {
      final result = await apiService.getUser();
      _isGettingUser = false;

      if (result != null) {
        loginUserInfo.value = result;
        final displayName = result.displayName;
        final email = result.email;
        final userIdString = result.userId;
        final shareId = result.shareId;
        if (userIdString != null) {
          userId.value = userIdString;
        }
        if (email != null) {
          userEmail.value = email;
        }
        if (displayName != null) {
          userDisplayName.value = displayName;
        }
        if (shareId != null) {
          userShareId.value = shareId;
        }
        // else if (shareId == null) {
        //   await VulcanCloseDialogWidget(
        //     width: 320,
        //     title: 'share_id'.tr,
        //     content: ShareIdChangeDialog(
        //         loginController: this,
        //         onConfirm: (value) async {
        //           final result = await apiService.updateUser(
        //               displayName: '',
        //               email: '',
        //               profileImage: '',
        //               shareId: value);
        //           if (result) {
        //             userShareId.value = value;
        //           }
        //         }),
        //   ).show(Get.context!);
        // }
        final userLoginTypeString = result.provider;
        final isPersonalInfoAgree = result.isPersonalInfoAgree;

        debugPrint(
            '###@@getUser: userIdString=$userIdString, userLoginTypeString=$userLoginTypeString');
        debugPrint(
            '###@@getUser: userLoginType=${TenantType.fromString(userLoginTypeString ?? '')}');
        // '###@@getUser: userLoginType=${UserLoginType.fromString(userLoginTypeString ?? '')}');
        // userId는 필수, 나머지는 선택적으로 처리
        if (userIdString != null && userIdString.isNotEmpty) {
          loginSessionToken.value = true;
          loginSuccess = true; // 로그인 성공 플래그 설정
          userDisplayName.value = displayName ?? '';
          userId.value = userIdString;
          userEmail.value = email ?? '';

          // provider가 있으면 로그인 타입 설정, 없으면 저장된 타입 사용
          if (userLoginTypeString != null && userLoginTypeString.isNotEmpty) {
            savedUserLoginType.value =
                UserLoginType.fromString(userLoginTypeString);
            userLoginType.value = TenantType.fromString(userLoginTypeString);
            tenantType.value = TenantType.fromString(userLoginTypeString);
            try {
              await _storage.write(
                key: kUserLoginType,
                value: userLoginType.value.name,
              );
              logger.i('로그인 타입 저장: ${userLoginType.value.name}');
            } catch (e) {
              logger.e('로그인 타입 저장 실패: $e');
            }
          }

          // isPersonalInfoAgree는 null일 수 있으므로 false로 기본값 설정
          userPersonalInfoAgree.value = isPersonalInfoAgree ?? false;

          logger.i(
              '사용자 정보 설정 성공: userId=${userId.value}, email=${userEmail.value}, loginType=${userLoginType.value.name}, isPersonalInfoAgree=${userPersonalInfoAgree.value}');

          // 로그인 상태가 확인되었으므로 세션 정보가 없으면 저장
          // 이곳에서 에러가 나면 루트가드로 반복되므로 방어적으로 수정하기
          final storedLoginInfo = await _storage.read(key: 'loginInfo');
          if (storedLoginInfo == null || storedLoginInfo.isEmpty) {
            try {
              // userId를 세션 값으로 사용
              await _storage.write(key: 'loginInfo', value: userId.value);
              userInfo.value = userId.value;
              sessionId.value = userId.value;
              logger.i('세션 정보 자동 저장: ${userId.value}');
            } catch (e) {
              logger.e('세션 정보 자동 저장 실패: $e');
            }
          } else {
            // 이미 저장된 세션 정보가 있으면 업데이트
            userInfo.value = storedLoginInfo;
            sessionId.value = storedLoginInfo;
          }

          tenantSettingController.getAutoConfigSetting();
          return result;
        } else {
          logger.w('getUser: userId가 null이거나 비어있음');
          // loginSessionToken.value = false;
          return null;
        }
      } else {
        logger.w('getUser: API 응답이 null');
        loginSessionToken.value = false;
        _isGettingUser = false;
        return null;
      }
    } catch (e) {
      logger.e('getUser 오류: $e');
      loginSessionToken.value = false;
      _isGettingUser = false;
      return null;
    }
  }

  // Future<UserProfile?> checkLoginStatus() async {
  //   final result = await apiClient.userInfo();
  //   if (result != null) {
  //     return result;
  //   }
  //   return null;
  // }

  // ID 기억하기 토글
  Future<void> toggleRememberId(bool? value) async {
    if (value == null) return;

    try {
      rememberIdEnabled.value = value;
      await _storage.write(key: kRememberId, value: value.toString());

      if (value) {
        // 체크박스 활성화 시 현재 ID 저장
        if (id.value.isNotEmpty) {
          await _storage.write(key: kUserId, value: id.value);
        }
      } else {
        // 체크박스 비활성화 시 저장된 ID 삭제
        await _storage.delete(key: kUserId);
      }
    } catch (e) {
      logger.e('Error toggling remember ID', e);
      rememberIdEnabled.value = !value; // 에러 시 상태 롤백
    }
  }

  // 자동로그인 토글
  Future<void> toggleAutoLogin(bool? value) async {
    if (value == null) return;

    try {
      rememberAutoLoginEnabled.value = value;
      await _storage.write(key: 'autoLogin', value: value.toString());
      if (value) {
      } else {
        // 체크박스 비활성화 시 저장된 ID 삭제
        await _storage.delete(key: 'loginInfo');
        logger.i('자동로그인 해제');
      }
    } catch (e) {
      logger.e('Error toggling auto login', e);
      rememberAutoLoginEnabled.value = !value; // 에러 시 상태 롤백
    }
  }

  // 로그인 성공 시 ID 저장
  Future<void> saveUserId(String inputId) async {
    try {
      id.value = inputId;
      // 체크박스가 체크된 경우에만 ID 저장
      if (rememberIdEnabled.value) {
        await _storage.write(key: kUserId, value: inputId);
      }
    } catch (e) {
      logger.e('Error saving user ID', e);
    }
  }

  void updateUserId(String value) {
    id.value = value;
    // ID가 변경될 때마다, 체크박스가 체크되어 있다면 자동 저장
    if (rememberIdEnabled.value) {
      saveUserId(value);
    }
  }

  void updatePassword(String value) {
    password.value = value;
  }

  Future<void> clearUserId() async {
    try {
      id.value = '';
      // ID를 지울 때 저장소에서도 제거
      await _storage.delete(key: kUserId);
    } catch (e) {
      logger.e('Error clearing user ID', e);
    }
  }

  void clearPassword() {
    password.value = '';
  }

  Future<void> handleLogout() async {
    try {
      loginSuccess = false; // 로그아웃 시 플래그 해제
      clearPassword();
      // ID 기억하기가 체크되어 있지 않으면 ID도 초기화
      if (!rememberIdEnabled.value) {
        await clearUserId();
      }
    } catch (e) {
      logger.e('Error in logout', e);
    }
  }

  void onEmailChanged(String value) {
    id.value = value;
  }

  void onPasswordChanged(String value) {
    password.value = value;
  }

  void validateId() {
    isIdValid.value = id.isNotEmpty;
  }

  void validatePassword() {
    final password = newPassword.value;
    final confirm = confirmPassword.value;
    isPasswordValid.value = password.isNotEmpty &&
        confirm.isNotEmpty &&
        password == confirm &&
        password.length >= 8;
  }

  void updateCanLogin() {
    canLogin.value = isIdValid.value && isPasswordValid.value;
  }

  void loginKakao() async {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _loginActionThrottle.run(() async {
      isProgress.value = true;
      // try {
      //   final result = await _userStore.loginWithKaKao();
      //   isProgress.value = false;
      //   if (result != null) {
      //     Get.offAllNamed(HomePage.route);
      //   } else {
      //     Get.showSnackbar(GetSnackBar(
      //       message: 'login_check_id_password'.tr,
      //       duration: const Duration(seconds: 2),
      //     ));
      //   }
      // } on NoAccountException {
      //   isProgress.value = false;
      //   await _showSignUpDialog(LoginType.kakao);
      // } catch (e) {
      //   isProgress.value = false;
      //   Get.showSnackbar(GetSnackBar(
      //     message: 'login_check_id_password'.tr,
      //     duration: const Duration(seconds: 2),
      //   ));
      // }
    });
  }

  // 로그인 시도 횟수 가져오기
  Future<int> _getLoginAttempts(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attempts = prefs.getInt('login_attempts_$userId') ?? 0;
      return attempts;
    } catch (e) {
      logger.e('로그인 시도 횟수 가져오기 실패: $e');
      return 0;
    }
  }

  // 현재 아이디의 남은 로그인 시도 횟수 가져오기 (public)
  Future<int> getRemainingLoginAttempts() async {
    if (id.value.isEmpty) return kMaxLoginAttempts;
    final currentAttempts = await _getLoginAttempts(id.value);
    return kMaxLoginAttempts - currentAttempts;
  }

  // 로그인 시도 횟수 저장하기
  Future<void> _setLoginAttempts(String userId, int attempts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (attempts == 0) {
        await prefs.remove('login_attempts_$userId');
      } else {
        await prefs.setInt('login_attempts_$userId', attempts);
      }
    } catch (e) {
      logger.e('로그인 시도 횟수 저장 실패: $e');
    }
  }

  // 로그인 시도 횟수 증가
  Future<int> _incrementLoginAttempts(String userId) async {
    final currentAttempts = await _getLoginAttempts(userId);
    final newAttempts = currentAttempts + 1;
    await _setLoginAttempts(userId, newAttempts);
    return newAttempts;
  }

  // 로그인 시도 횟수 초기화
  Future<void> _resetLoginAttempts(String userId) async {
    await _setLoginAttempts(userId, 0);
  }

  // {required String id,required String password}
  Future<bool> loginAuth() async {
    // 로그인 시도 횟수 확인
    final currentAttempts = await _getLoginAttempts(id.value);
    if (currentAttempts >= kMaxLoginAttempts) {
      loginErrorMessage.value = 'login_attempts_exceeded'.tr;
      logger.w('로그인 시도 횟수 초과: $currentAttempts/$kMaxLoginAttempts');
      return false;
    }

    // md5
    // final hashPassword = converHash(password.value);

    // sha256
    // final hashPassword = converShaHash(password.value);
    final result = await apiClient.login(
        userId: id.value,
        password: password.value,
        // password: hashPassword,
        rememberMe: rememberAutoLoginEnabled.value);

    if (result['result'] == true) {
      // 로그인 성공 시 시도 횟수 초기화
      await _resetLoginAttempts(id.value);
      logger.i('로그인 성공, 시도 횟수 초기화');

      await saveUserId(id.value);
      // await getUserId(); // await 추가!
      final userModel = await getUser();

      // getUser() 성공 후 세션 정보 저장
      if (userModel != null && userId.value.isNotEmpty) {
        // 세션 정보 저장 (자동로그인이 활성화되어 있거나, 로그인 성공 시 항상 저장)
        try {
          // result['data'][0]가 있으면 사용하고, 없으면 userId를 사용
          final sessionValue = result['data'] != null &&
                  (result['data'] as List).isNotEmpty &&
                  result['data'][0] != null
              ? result['data'][0].toString()
              : userId.value; // userId를 세션 값으로 사용

          await _storage.write(key: 'loginInfo', value: sessionValue);
          userInfo.value = sessionValue;
          sessionId.value = sessionValue;
          logger.i('로그인 정보 저장 성공: $sessionValue');
        } catch (e) {
          logger.e('로그인 정보 저장 실패: $e');
        }
      }

      tenantSettingController.setTenantSetting();
      // 일반 로그인(ARA)의 경우 userLoginType을 명시적으로 설정 및 저장
      // getUserId()에서 API 응답으로 설정되지만, 명시적으로도 저장
      if (savedUserLoginType.value == UserLoginType.ara) {
        // if (userLoginType.value == UserLoginType.ara) {
        try {
          await _storage.write(
            key: kUserLoginType,
            value: TenantType.ara.name,
            // value: UserLoginType.ara.name,
          );
        } catch (e) {
          logger.e('ARA 로그인 타입 저장 실패: $e');
        }
      }

      loginSuccess = true; // 로그인 성공 플래그 설정
      initializeLanguage();
      return true;
    } else if (result['result'] == false) {
      // 로그인 실패 시 시도 횟수 증가
      loginSuccess = false; // 로그인 실패 플래그 해제
      final newAttempts = await _incrementLoginAttempts(id.value);
      logger.w('로그인 실패, 시도 횟수: $newAttempts/$kMaxLoginAttempts');

      if (newAttempts >= kMaxLoginAttempts) {
        loginErrorMessage.value = 'login_attempts_exceeded'.tr;
      } else {
        final remainingAttempts = kMaxLoginAttempts - newAttempts;
        loginErrorMessage.value = 'find_password_id_or_password_error'.tr;
        // 남은 시도 횟수 정보 추가 (선택사항)
        logger.i('남은 로그인 시도 횟수: $remainingAttempts');
      }
      return false;
    } else {
      // 로그인 실패 시 시도 횟수 증가
      loginSuccess = false; // 로그인 실패 플래그 해제
      final newAttempts = await _incrementLoginAttempts(id.value);
      logger.w('로그인 실패, 시도 횟수: $newAttempts/$kMaxLoginAttempts');

      if (newAttempts >= kMaxLoginAttempts) {
        loginErrorMessage.value = 'login_attempts_exceeded'.tr;
      } else {
        loginErrorMessage.value = 'login_fail'.tr;
      }
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final result = await apiClient.logout();

      // 로그아웃 시 사용자 정보 초기화
      userId.value = '';
      userEmail.value = '';
      userDisplayName.value = '';
      sessionId.value = null;
      userLoginType.value = TenantType.ara;
      savedUserLoginType.value = UserLoginType.ara;
      // userLoginType.value = UserLoginType.ara;

      // 저장소에서 로그인 타입 정보만 삭제 (자동 로그인 정보는 유지)
      await _storage.delete(key: kUserLoginType);
      logger.i('로그아웃: 저장된 로그인 타입 삭제 완료');

      // result가 Map인 경우에만 data 접근
      if (result is Map<String, dynamic>) {
        final data = result['data'];
        if (data is Map<String, dynamic> && data.containsKey('redirectUrl')) {
          final redirectUrl = data['redirectUrl'];
          logger.i('로그아웃 후 리다이렉트 URL: $redirectUrl');

          // 브라우저 리다이렉트 수행
          if (kIsWeb && redirectUrl != null && redirectUrl.isNotEmpty) {
            loginSessionToken.value = false; // 리다이렉트 전에 토큰 false 설정
            // html.window.location.href = redirectUrl;
            web.window.location.href = redirectUrl;
            return true;
          }
        }
      }

      // 일반 로그아웃 처리 - result가 null이 아닌 경우 성공
      if (result != null) {
        handleLogout();
        loginSessionToken.value = false;
        if (rememberIdEnabled.value != true) {
          idController.clear();
        }
        logger.i('로그아웃 완료');
        return true;
      } else {
        loginSessionToken.value = false; // 로그아웃 실패 시에도 false 설정
        return false;
      }
    } catch (e) {
      logger.e('로그아웃 처리 중 오류: $e');
      // 예외 발생 시에도 로그인 타입 삭제 시도
      try {
        await _storage.delete(key: kUserLoginType);
        logger.i('예외 발생 시 저장된 로그인 타입 삭제 완료');
      } catch (storageError) {
        logger.e('저장소 삭제 중 오류: $storageError');
      }
      loginSessionToken.value = false; // 예외 발생 시에도 false 설정
      return false;
    }
  }

  // Future<String?> getUserId() async {
  //   try {
  //     final result = await apiClient.userInfo();
  //     logger.d('getUserId API 응답: $result');

  //     if (result != null) {
  //       // API 응답 구조에 따라 접근 방식 수정
  //       loginUserInfo.value = result;
  //       final displayName = result.displayName ?? result.displayName;
  //       final email = result.email ?? result.email;
  //       final userIdString = result.userId ?? result.userId;
  //       final userLoginTypeString = result.provider ?? result.provider;
  //       final isPersonalInfoAgree =
  //           result.isPersonalInfoAgree ?? result.isPersonalInfoAgree;

  //       if (displayName != null &&
  //           email != null &&
  //           userIdString != null &&
  //           userLoginTypeString != null &&
  //           isPersonalInfoAgree != null) {
  //         loginSessionToken.value = true;
  //         userDisplayName.value = displayName;
  //         userId.value = userIdString;
  //         userEmail.value = email;
  //         userLoginType.value = UserLoginType.fromString(userLoginTypeString);
  //         userPersonalInfoAgree.value = isPersonalInfoAgree;
  //         // userLoginType을 저장소에 저장
  //         try {
  //           await _storage.write(
  //             key: kUserLoginType,
  //             value: userLoginType.value.name,
  //           );
  //           logger.i('로그인 타입 저장: ${userLoginType.value.name}');
  //         } catch (e) {
  //           logger.e('로그인 타입 저장 실패: $e');
  //         }

  //         logger.i(
  //             '사용자 정보 설정 성공: userId=${userId.value}, email=${userEmail.value}, loginType=${userLoginType.value.name}');
  //         return displayName;
  //       }
  //     }

  //     logger.w('getUserId: API 응답이 null이거나 user 정보 없음');
  //     loginSessionToken.value = false;
  //     return null;
  //   } catch (e) {
  //     logger.e('getUserId 오류: $e');
  //     return null;
  //   }
  // }

  Future<String?> getUserId() async {
    try {
      final result = await apiClient.userInfo();
      logger.d('getUserId API 응답!!!!: ${result?.toJson()}');

      if (result != null) {
        // API 응답 구조에 따라 접근 방식 수정
        loginUserInfo.value = result;
        final displayName = result.displayName ?? result.displayName;
        final userIdString = result.userId ?? result.userId;

        if (displayName != null && userIdString != null) {
          loginSessionToken.value = true;
          userDisplayName.value = displayName;
          userId.value = userIdString;
          // userLoginType을 저장소에 저장
        }
        return userIdString;
      }
      logger.w('getUserId: API 응답이 null이거나 user 정보 없음');
      // loginSessionToken.value = false;
      return null;
    } catch (e) {
      logger.e('getUserId 오류: $e');
      return null;
    }
  }

  Future<bool> authSecureCheck() async {
    // final result = await apiClient.checkSecurity();
    final result = await apiClient.userInfo();
    if (result != null && result.userId != null) {
      // if (result!.email != null) {
      // getUserId();
      getUser();
      return true;
    } else {
      return false;
    }
  }

  void login() async {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _loginActionThrottle.run(() async {
      final result = await apiClient.login(
          userId: 'admin', password: '1234', rememberMe: true);
      logger.i('result : $result');
      // if (canLogin.value) {
      //   isProgress.value = true;
      //   final result = await _userStore.loginWithIdPassword(
      //       id: id.value, password: password.value);
      //   isProgress.value = false;
      //   if (result != null) {
      //     Get.offAllNamed(HomePage.route);
      //   } else {
      //     Get.showSnackbar(GetSnackBar(
      //       message: 'login_check_id_password'.tr,
      //       duration: const Duration(seconds: 2),
      //     ));
      //   }
      // } else {
      //   Get.showSnackbar(GetSnackBar(
      //     message: 'login_check_id_password'.tr,
      //     duration: const Duration(seconds: 2),
      //   ));
      // }
    });
  }

  // Future<void> _showSignUpDialog(LoginType type) async {
  //   final context = Get.context;
  //   if (context == null) {
  //     return;
  //   }

  //   final result = await Get.dialog(
  //     AlertDialog(
  //       elevation: 8,
  //       contentPadding: EdgeInsets.zero,
  //       backgroundColor: context.background,
  //       content: BtoDialog(
  //         title: 'sign_up_request_dialog_title'.tr,
  //         message: Text('sign_up_request_dialog_content_${type.value}'.tr),
  //         textCancel: 'cancel'.tr,
  //         textConfirm: 'confirm'.tr,
  //         confirmTextColor: context.primary,
  //         contentPadding: const EdgeInsets.all(20),
  //         onCancel: () {
  //           context.pop();
  //         },
  //         onConfirm: () {
  //           context.pop(true);
  //         },
  //       ),
  //     ),
  //   );

  //   if (result == true) {
  //     //launchUrlString('https://www.araebook.com/user/login');
  //   }
  // }

  Future<bool> verifyIdAuthCode() async {
    try {
      if (idFindEmailAuthCodeController.text.isEmpty ||
          passwordFindEmailAuthCodeController.text.isEmpty) {
        debugPrint('sign_up_email_auth_code_required'.tr);
        return false;
      }

      final response = await apiClient.verifyAuthCode(
        email: idFindEmailAuthCodeController.text,
        authCode: authCode.value,
      );

      if (response?.data['statusCode'] == 200) {
        isIdAuthCodeValid.value = true;
        debugPrint('sign_up_email_auth_success_message'.tr);
        return true;
      } else {
        isIdAuthCodeValid.value = false;
        debugPrint('sign_up_email_auth_error_message'.tr);
        return false;
      }
    } catch (e) {
      debugPrint('$e');
      return false;
    }
  }

  // 언어 설정 저장 함수
  Future<void> saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    if (id.value.isNotEmpty) {
      await prefs.setString('${id.value}_language', language);
    }
  }

  // 언어 설정 불러오기 함수
  Future<String?> getLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${id.value}_language');
  }

  // 브라우저 언어 가져오기
  String getBrowserLanguage() {
    final locale = Get.deviceLocale;
    if (locale?.languageCode == 'ko') {
      return 'Korean';
    } else if (locale?.languageCode == 'id') {
      return 'Indonesia';
    }
    return 'English';
  }

  // 언어 설정 초기화 함수
  Future<void> initializeLanguage() async {
    final savedLanguage = await getLanguagePreference();
    if (savedLanguage != null) {
      final language = LanguageType.values.firstWhere(
        (element) => element.name == savedLanguage,
        orElse: () => LanguageType.korean,
      );
      Get.updateLocale(language.locale);
    } else {
      final browserLanguage = getBrowserLanguage();
      final language = LanguageType.values.firstWhere(
        (element) => element.name == browserLanguage,
        orElse: () => LanguageType.korean,
      );
      Get.updateLocale(language.locale);
      await saveLanguagePreference(browserLanguage);
    }
  }

  // 네이버 로그인 처리 (브라우저 리다이렉트)
  Future<bool> naverLogin() async {
    try {
      isProgress.value = true;

      // 네이버 로그인 타입을 미리 저장
      try {
        savedUserLoginType.value = UserLoginType.naver;
        // userLoginType.value = UserLoginType.naver;
        await _storage.write(
          key: kUserLoginType,
          value: UserLoginType.naver.name,
        );
        logger.i('네이버 로그인 타입 저장: ${savedUserLoginType.value.name}');
      } catch (e) {
        logger.e('네이버 로그인 타입 저장 실패: $e');
      }

      // 네이버 OAuth2 인증 URL 가져오기
      final naverLoginUrl = getNaverLoginUrl();

      // 현재 페이지에서 네이버 로그인 페이지로 리다이렉트
      final uri = Uri.parse(naverLoginUrl);

      if (await canLaunchUrl(uri)) {
        // 현재 탭에서 열기 (새 탭이 아님)
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_self', // 현재 탭에서 열기
        );

        // 리다이렉트 후에는 앱으로 돌아오지 않으므로
        // 여기서는 단순히 성공 반환
        isProgress.value = false;
        return true;
      } else {
        isProgress.value = false;
        loginErrorMessage.value = 'naver_login_url_error'.tr;
        return false;
      }
    } catch (e) {
      isProgress.value = false;
      loginErrorMessage.value = 'naver_login_fail_message'.tr;
      logger.e('네이버 로그인 오류: $e');
      return false;
    }
  }

  // 네이버 로그인 URL 가져오기
  String getNaverLoginUrl() {
    final baseUrl = AutoConfig.instance.apiUrl.replaceAll('/api/v1/', '');
    return '$baseUrl/oauth2/authorization/naver';
  }

  // 네이버 웍스 로그인 URL 가져오기
  String getNaverWorksLoginUrl() {
    final baseUrl = AutoConfig.instance.apiUrl.replaceAll('/api/v1/', '');

    // 현재 URL에서 redirect 파라미터 추출
    String? redirectUrl;

    // 브라우저의 현재 URL에서 redirect 파라미터 가져오기 (fragment 포함)
    if (kIsWeb) {
      try {
        // JavaScript의 window.location.href를 사용하여 fragment까지 포함한 전체 URL 가져오기
        // final fullUrl = html.window.location.href;
        final fullUrl = web.window.location.href;
        logger.d('전체 URL: $fullUrl');

        // URL에 fragment(#)가 있는지 확인
        if (fullUrl.contains('#')) {
          // fragment 부분에서 쿼리 파라미터 추출
          final fragmentPart = fullUrl.split('#')[1];
          logger.d('Fragment 부분: $fragmentPart');

          // fragment에 쿼리 파라미터가 있는지 확인
          if (fragmentPart.contains('?')) {
            // 첫 번째 ?의 위치를 찾아서 그 이후 전체를 쿼리 파트로 사용
            final firstQuestionMarkIndex = fragmentPart.indexOf('?');
            final queryPart = fragmentPart
                .substring(firstQuestionMarkIndex + 1)
                .replaceAll('redirect=', '');
            logger.d('쿼리 파트: $queryPart');

            logger.d(
                'Redirecting to login: not logged in accessing private route');
            final encodedPath = Uri.encodeComponent(queryPart);
            logger.d('Saved redirect path as query param: $queryPart');

            // redirect 파라미터를 직접 파싱 (값에 추가 파라미터가 있을 수 있음)
            redirectUrl = encodedPath;
            logger.d('Fragment에서 추출한 redirect: $redirectUrl');
          } else {
            redirectUrl = fragmentPart;
            // redirectUrl가 home이라면 null로 처리
            // if (redirectUrl == 'home') {
            //   redirectUrl = null;
            // }
            // debugPrint(
            //     '###@@@ getNaverWorksLoginUrl: redirectUrl: $redirectUrl');
            logger.d('Fragment에서 추출한 redirect: $redirectUrl');
          }
        }
        debugPrint('###@@@ getNaverWorksLoginUrl: baseUrl: $baseUrl');
        debugPrint('###@@@ getNaverWorksLoginUrl: redirectUrl: $redirectUrl');
      } catch (e) {
        debugPrint('###@@@ getNaverWorksLoginUrl: error: $e');
        logger.e('URL 파싱 오류: $e');
      }
    }

    // redirect 파라미터가 있으면 realUrl로 추가
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      logger.i('네이버 웍스 로그인 URL에 realUrl 추가: $redirectUrl');
      return '$baseUrl/oauth2/authorization/naverworks?realUrl=$redirectUrl';
    } else {
      return '$baseUrl/oauth2/authorization/naverworks';
    }
  }

  // 네이버 웍스 로그인 URL 가져오기
  String getNaverWorksLoginUrlWithRedirectUrl() {
    final baseUrl = AutoConfig.instance.apiUrl.replaceAll('/api/v1/', '');

    // 저장된 리다이렉트 URL이 있으면 우선 사용
    String? redirectUrl = savedRedirectUrl.value;

    // 저장된 URL이 없으면 현재 URL에서 redirect 파라미터 추출
    if (redirectUrl == null || redirectUrl.isEmpty) {
      // 브라우저의 현재 URL에서 redirect 파라미터 가져오기 (fragment 포함)
      if (kIsWeb) {
        try {
          // JavaScript의 window.location.href를 사용하여 fragment까지 포함한 전체 URL 가져오기
          // final fullUrl = html.window.location.href;
          final fullUrl = web.window.location.href;
          logger.d('전체 URL: $fullUrl');

          // URL에 fragment(#)가 있는지 확인
          if (fullUrl.contains('#')) {
            // fragment 부분에서 쿼리 파라미터 추출
            final fragmentPart = fullUrl.split('#')[1];
            logger.d('Fragment 부분: $fragmentPart');

            // fragment에 쿼리 파라미터가 있는지 확인
            if (fragmentPart.contains('?')) {
              // 첫 번째 ?의 위치를 찾아서 그 이후 전체를 쿼리 파트로 사용
              final firstQuestionMarkIndex = fragmentPart.indexOf('?');
              final queryPart = fragmentPart
                  .substring(firstQuestionMarkIndex + 1)
                  .replaceAll('redirect=', '');
              logger.d('쿼리 파트: $queryPart');

              logger.d(
                  'Redirecting to login: not logged in accessing private route');
              final encodedPath = Uri.encodeComponent(queryPart);
              logger.d('Saved redirect path as query param: $queryPart');

              // redirect 파라미터를 직접 파싱 (값에 추가 파라미터가 있을 수 있음)
              redirectUrl = encodedPath;
              logger.d('Fragment에서 추출한 redirect: $redirectUrl');
            }
          }
        } catch (e) {
          logger.e('URL 파싱 오류: $e');
        }
      }
    } else {
      logger.i('저장된 리다이렉트 URL 사용: $redirectUrl');
    }

    // redirect 파라미터가 있으면 realUrl로 추가
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      logger.i('네이버 웍스 로그인 URL에 realUrl 추가: $redirectUrl');
      return '$baseUrl/oauth2/authorization/naverworks?realUrl=$redirectUrl';
    } else {
      return '$baseUrl/oauth2/authorization/naverworks';
    }
  }

  // 네이버 웍스 로그인 처리 (브라우저 리다이렉트)
  Future<bool> naverWorksLogin() async {
    debugPrint('####@@@ 5555 naverWorksLogin');
    try {
      isProgress.value = true;

      // 네이버 웍스 로그인 타입을 미리 저장

      // 네이버 웍스 OAuth2 인증 URL 가져오기
      final naverWorksLoginUrl = getNaverWorksLoginUrl();
      debugPrint(
          '###@@@ Call Login Controller: naverWorksLogin: naverWorksLoginUrl $naverWorksLoginUrl');
      // final naverWorksLoginUrl = getNaverWorksLoginUrlWithRedirectUrl();

      // 현재 페이지에서 네이버 웍스 로그인 페이지로 리다이렉트
      final uri = Uri.parse(naverWorksLoginUrl);
      debugPrint('####@@@ 8888 call naverWorksLoginUrl');
      debugPrint(
          '####@@@ 6666 redirect url: naverWorksLoginUrl: $naverWorksLoginUrl');
      debugPrint('####@@@ 7777 redirect url: uri: $uri');

      if (await canLaunchUrl(uri)) {
        // 현재 탭에서 열기 (새 탭이 아님)
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_self', // 현재 탭에서 열기
        );

        // 리다이렉트 후에는 앱으로 돌아오지 않으므로
        // 여기서는 단순히 성공 반환
        isProgress.value = false;
        try {
          loginSessionToken.value = true;
          loginSuccess = true; // 로그인 성공 플래그 설정
          savedUserLoginType.value = UserLoginType.naverWorks;
          // userLoginType.value = TenantType.naverWorks;
          await _storage.write(
            key: kUserLoginType,
            value: UserLoginType.naverWorks.name,
          );
          tenantSettingController.setTenantSetting();

          debugPrint(
              '####@@ loginSessionToken.value: ${loginSessionToken.value}');
          logger.i('네이버 웍스 로그인 타입 저장: ${userLoginType.value.name}');
        } catch (e) {
          loginSessionToken.value = false;
          loginSuccess = false; // 로그인 실패 시 플래그 해제
          logger.e('네이버 웍스 로그인 타입 저장 실패: $e');
        }

        return true;
      } else {
        isProgress.value = false;
        loginErrorMessage.value = 'naver_works_login_url_error'.tr;
        loginSessionToken.value = false;
        return false;
      }
    } catch (e) {
      isProgress.value = false;
      loginSessionToken.value = false;
      loginErrorMessage.value = 'naver_works_login_fail_message'.tr;
      logger.e('네이버 웍스 로그인 오류: $e');
      return false;
    }
  }

  // 302 응답 처리: 현재 URL 저장 후 네이버 웍스 로그인 실행
  Future<void> handle302Redirect(String? responseMessage) async {
    try {
      // 현재 URL 저장
      // if (kIsWeb) {
      final currentUrl = web.window.location.href;
      // savedRedirectUrl.value = currentUrl;
      savedRedirectUrl.value = 'www.google.com';
      // debugPrint('###@@@ 302 응답: 현재 URL 저장 - $currentUrl');
      debugPrint('###@@@ 302 응답: 네이버 웍스 로그인 페이지로 이동');
      debugPrint('###@@@ 302 응답: responseMessage: $responseMessage');
      // 네이버 웍스 로그인 실행
      await naverWorksLogin();
      // } else {
      //   debugPrint('###@@@ 302 응답: 웹 환경이 아니므로 처리 불가');
      // }
    } catch (e) {
      debugPrint('###@@@ 302 응답 처리 중 오류: $e');
      savedRedirectUrl.value = null;
    }
  }

  // 저장된 URL로 리다이렉트 (로그인 성공 후 호출)
  Future<void> redirectToSavedUrl() async {
    if (savedRedirectUrl.value != null && savedRedirectUrl.value!.isNotEmpty) {
      try {
        final url = savedRedirectUrl.value!;
        logger.i('저장된 URL로 리다이렉트: $url');

        if (kIsWeb) {
          web.window.location.href = url;
        } else {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
        }

        // 리다이렉트 후 저장된 URL 초기화
        savedRedirectUrl.value = null;
      } catch (e) {
        logger.e('저장된 URL로 리다이렉트 중 오류: $e');
        savedRedirectUrl.value = null;
      }
    }
  }

  // 소셜 로그인 처리
  Future<bool> socialLogin(LoginType loginType) async {
    try {
      isProgress.value = true;

      // 실제 구현에서는 각 플랫폼별 SDK를 사용하여 로그인 처리
      // 여기서는 예시로 delay 후 성공 반환
      await Future.delayed(const Duration(seconds: 2));

      switch (loginType) {
        case LoginType.kakao:
          // 로그인 구현
          break;
        case LoginType.naver:
          return await naverLogin();
        case LoginType.naverWorks:
          return await naverWorksLogin();
        case LoginType.idPassword:
          // 일반 로그인은 다른 메서드에서 처리
          break;
        case LoginType.araService:
          final result = await apiService.checkAraServiceLogin(
              userId: id.value,
              password: password.value,
              rememberMe: rememberAutoLoginEnabled.value);
          if (result != null) {
            userData.value = result.data;
          }
          break;
      }

      isProgress.value = false;
      return true;
    } catch (e) {
      isProgress.value = false;
      loginErrorMessage.value = 'simple_login_fail_message'.tr;
      return false;
    }
  }

  void onSimpleLoginIdChanged(String value) {
    simpleLoginId.value = value;
    validateSimpleLoginId();
  }

  void onSimpleLoginPasswordChanged(String value) {
    simpleLoginPassword.value = value;
    validateSimpleLoginPassword();
  }

  void validateSimpleLoginId() {
    isSimpleLoginIdValid.value = simpleLoginId.value.isNotEmpty;
  }

  void validateSimpleLoginPassword() {
    isSimpleLoginPasswordValid.value = simpleLoginPassword.value.isNotEmpty;
  }

  Future<bool> simpleAraServiceLoginAuth() async {
    final result = await apiClient.araServiceLogin(
        userId: simpleLoginId.value,
        password: simpleLoginPassword.value,
        rememberMe: rememberAutoLoginEnabled.value);
    if (result != null) {
      if (result.data["statusCode"] == 200) {
        // ARA 서비스 로그인 타입 저장 (ARA 서비스는 ara 타입으로 저장)
        try {
          userLoginType.value = TenantType.ara;
          // userLoginType.value = UserLoginType.ara;
          await _storage.write(
            key: kUserLoginType,
            value: UserLoginType.ara.name,
          );
          logger.i('ARA 서비스 로그인 타입 저장: ${userLoginType.value.name}');
        } catch (e) {
          logger.e('ARA 서비스 로그인 타입 저장 실패: $e');
        }

        // getUserId();
        // initializeLanguage();
        userData.value = UserData.fromJson(result.data['data']);
        isRegistered.value = result.data['isRegistered'];
        loginSessionToken.value = true; // 간편로그인 성공 시 토큰 설정
        loginSuccess = true; // 로그인 성공 플래그 설정
        tenantSettingController.setTenantSetting();
        return true;
      } else {
        loginSuccess = false; // 로그인 실패 플래그 해제
        loginErrorMessage.value = 'login_fail'.tr;
        return false;
      }
    }
    loginSuccess = false; // 로그인 실패 플래그 해제
    return false;
  }

  Future<String?> getLoginToken() async {
    final result = await apiClient.getLoginToken();
    if (result != null) {
      return LoginUserResponse.fromJson(result.data).accessToken; // 토큰 반환
    }
    return null;
  }

  Future<bool> sessionLogout() async {
    // 초기화 중에는 로그아웃 처리하지 않음 (새로고침 시 로그아웃 방지)
    if (_isInitializing) {
      logger.i('초기화 중이므로 로그아웃 처리 건너뜀');
      return false;
    }

    // 로그아웃 시작 시 토큰 false 설정하여 추가 401 응답 방지
    loginSessionToken.value = false;
    loginSuccess = false; // 로그인 성공 플래그 해제
    _isSessionExpiredPopupShowing = false; // 팝업 플래그 리셋

    try {
      final result = await apiClient.logout();

      userId.value = '';
      userEmail.value = '';
      userDisplayName.value = '';
      sessionId.value = null;

      if (result is Map<String, dynamic>) {
        final data = result['data'];
        if (data is Map<String, dynamic> && data.containsKey('redirectUrl')) {
          final redirectUrl = data['redirectUrl'];
          logger.i('로그아웃 후 리다이렉트 URL: $redirectUrl');

          if (kIsWeb && redirectUrl != null && redirectUrl.isNotEmpty) {
            // loginSessionToken.value = false; // 리다이렉트 전에 토큰 false 설정
            // html.window.location.href = redirectUrl;
            web.window.location.href = redirectUrl;
            return true;
          }
        }
      }

      // 일반 로그아웃 처리 - result가 null이 아닌 경우 성공
      if (result != null) {
        handleLogout();
        // loginSessionToken.value = false; // 세션 로그아웃 시 토큰 false 설정
        if (rememberIdEnabled.value != true) {
          idController.clear();
        }
        // userLoginType은 저장소에서 유지되므로 삭제하지 않음
        logger.i('로그아웃 완료, userLoginType 유지: ${userLoginType.value.name}');
        return true;
      } else {
        // loginSessionToken.value = false; // 로그아웃 실패 시에도 false 설정
        return false;
      }
    } catch (e) {
      logger.e('로그아웃 처리 중 오류: $e');
      // loginSessionToken.value = false; // 예외 발생 시에도 false 설정
      return false;
    }
  }

  Future<void> handleLoginRedirect() async {
    final domainType = AutoConfig.instance.domainType;
    final oauth2Url = domainType.oauth2Url;

    // @chanhee22 - oauth2Url로 리다이렉트 하는 경우 확인바람
    if (domainType.isStandardDomain ||
        domainType.isGovDomain ||
        (domainType.isMoisDomain) ||
        domainType.isMsitDomain ||
        domainType.isMfdsDomain ||
        domainType.isMoisLocalDomain ||
        domainType.isMpbDomain) {
      // 리다이렉트 하는 경우
      debugPrint(
          '####@@@@@ handleLoginRedirect: ${AutoConfig.instance.domainType.name}');
      debugPrint('####@@@@@ handleLoginRedirect: url: $oauth2Url');
      debugPrint('####@@@@@ 리다이렉트 하는 경우 : $oauth2Url');
      String? redirectUrl;
      String? redirectLoginUrl;
      try {
        // JavaScript의 window.location.href를 사용하여 fragment까지 포함한 전체 URL 가져오기
        // final fullUrl = html.window.location.href;
        final fullUrl = web.window.location.href;
        logger.d('전체 URL: $fullUrl');

        // URL에 fragment(#)가 있는지 확인
        if (fullUrl.contains('#')) {
          // fragment 부분에서 쿼리 파라미터 추출
          final fragmentPart = fullUrl.split('#')[1];
          logger.d('Fragment 부분: $fragmentPart');

          // fragment에 쿼리 파라미터가 있는지 확인
          if (fragmentPart.contains('?')) {
            // 첫 번째 ?의 위치를 찾아서 그 이후 전체를 쿼리 파트로 사용
            final firstQuestionMarkIndex = fragmentPart.indexOf('?');
            final queryPart = fragmentPart
                .substring(firstQuestionMarkIndex + 1)
                .replaceAll('redirect=', '');
            logger.d('쿼리 파트: $queryPart');

            logger.d(
                'Redirecting to login: not logged in accessing private route');
            final encodedPath = Uri.encodeComponent(queryPart);
            logger.d('Saved redirect path as query param: $queryPart');

            // redirect 파라미터를 직접 파싱 (값에 추가 파라미터가 있을 수 있음)
            redirectUrl = encodedPath;
            logger.d('Fragment에서 추출한 redirect: $redirectUrl');
          } else {
            redirectUrl = fragmentPart;
            logger.d('Fragment에서 추출한 redirect: $redirectUrl');
          }
        }
      } catch (e) {
        logger.e('URL 파싱 오류: $e');
      }

      // 주석 처리 테스트 예정
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        redirectLoginUrl = '$oauth2Url?realUrl=$redirectUrl';
      } else {
        redirectLoginUrl = oauth2Url;
      }

      // redirectLoginUrl = oauth2Url;

      if (kIsWeb) {
        // web.window.location.href = oauth2Url;
        web.window.location.href = redirectLoginUrl;
        // ?realUrl=$redirectUrl
      } else {
        // 모바일 환경에서는 기존 방식 사용
        final uri = Uri.parse(redirectLoginUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      }
    } else if (domainType.isDferiDomain) {
      // Dferi 도메인일 경우  https://www.edunavi.kr/booknavi 로 리다이렉트
      final redirectUrl = 'https://www.edunavi.kr/booknavi';
      debugPrint('####@@@@@ Dferi 도메인일 경우 리다이렉트 : $redirectUrl');
      if (kIsWeb) {
        web.window.location.href = redirectUrl;
      } else {
        final uri = Uri.parse(redirectUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      }
      return;
    } else {
      // 리다이렉트 하지 않는 경우
      debugPrint('####@@@@@ 리다이렉트 하지 않는 경우 : $oauth2Url');
      return;
    }

    // if (AutoConfig.instance.domainType.isLocalDevDomain) {
    //   // local dev일 경우 리다이렉트 하지 않음
    //   debugPrint('####@@@@@ local dev일 경우 리다이렉트 하지 않음');
    //   return;
    // }
    // 웹 환경에서는 현재 창에서 리다이렉트
    // if (kIsWeb) {
    //   web.window.location.href = oauth2Url;
    // } else {
    //   // 모바일 환경에서는 기존 방식 사용
    //   final uri = Uri.parse(oauth2Url);
    //   if (await canLaunchUrl(uri)) {
    //     await launchUrl(uri, mode: LaunchMode.platformDefault);
    //   }
    // }
  }

  // login_controller.dart

// // ------------ 웹뷰 dialog 로그인 처리 ------------
//   Future<bool> naverWorksLoginWithIframeDialog(BuildContext context) async {
//     debugPrint('####@@@ naverWorksLoginWithIframeDialog 시작');
//     try {
//       isProgress.value = true;

//       final naverWorksLoginUrl = getNaverWorksLoginUrl();
//       final callbackPattern = '/login/oauth2/code/naver-works';

//       debugPrint('###@@@ iframe Dialog 로그인 URL: $naverWorksLoginUrl');

//       // final context = Get.context;
//       // if (context == null) {
//       //   debugPrint('####@@@ Context가 null입니다');
//       //   isProgress.value = false;
//       //   return false;
//       // }

//       if (context == null) {
//         debugPrint('####@@@ Context가 null입니다');
//         isProgress.value = false;
//         return false;
//       }

//       // Completer로 Dialog 결과를 기다림
//       final completer = Completer<bool>();

//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           // return NaverWorksIframeDialog(
//           return NaverWorksStackedLoginDialog(
//             loginUrl: naverWorksLoginUrl,
//             callbackUrlPattern: callbackPattern,
//             onAuthComplete: (bool success, Map<String, dynamic>? data) async {
//               debugPrint('####@@@ iframe 인증 완료: success=$success, data=$data');

//               if (success) {
//                 try {
//                   // 약간의 딜레이를 주어 백엔드에서 세션 설정 완료 대기
//                   await Future.delayed(const Duration(milliseconds: 500));

//                   // 사용자 정보 가져오기
//                   final userIdResult = await getUserId();

//                   if (userIdResult != null && userIdResult.isNotEmpty) {
//                     loginSessionToken.value = true;
//                     savedUserLoginType.value = UserLoginType.naverWorks;
//                     await _storage.write(
//                       key: kUserLoginType,
//                       value: UserLoginType.naverWorks.name,
//                     );
//                     tenantSettingController.setTenantSetting();

//                     debugPrint('####@@ 네이버 웍스 로그인 성공');
//                     logger.i('네이버 웍스 로그인 완료: userId=$userIdResult');

//                     completer.complete(true);
//                   } else {
//                     debugPrint('####@@ 사용자 정보 가져오기 실패');
//                     completer.complete(false);
//                   }
//                 } catch (e) {
//                   debugPrint('####@@ 로그인 후처리 에러: $e');
//                   logger.e('네이버 웍스 로그인 후처리 실패: $e');
//                   completer.complete(false);
//                 }
//               } else {
//                 debugPrint('####@@ 네이버 웍스 로그인 취소/실패');
//                 loginSessionToken.value = false;
//                 completer.complete(false);
//               }
//             },
//           );
//         },
//       );

//       final result = await completer.future;
//       isProgress.value = false;

//       if (!result) {
//         loginErrorMessage.value = 'naver_works_login_fail_message'.tr;
//       }

//       return result;
//     } catch (e) {
//       isProgress.value = false;
//       loginSessionToken.value = false;
//       loginErrorMessage.value = 'naver_works_login_fail_message'.tr;
//       logger.e('네이버 웍스 로그인 오류: $e');
//       return false;
//     }
//   }

  void redirectToDferi() async {
    final redirectUrl = 'https://www.edunavi.kr/booknavi';
    if (kIsWeb) {
      web.window.location.href = redirectUrl;
    } else {
      final uri = Uri.parse(redirectUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    }
  }

  Future<LoginStatusResult?> checkLoginStatus(
      Map<String, dynamic>? message) async {
    // 초기화 중에는 세션 복원을 기다림 (새로고침 시 로그아웃 방지)
    if (_isInitializing) {
      logger.i('초기화 중이므로 로그인 상태 확인 대기');
      // 초기화 완료까지 대기 (최대 3초)
      int waitCount = 0;
      while (_isInitializing && waitCount < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
      // 초기화 완료 후 사용자 정보 확인
      if (userId.value.isNotEmpty) {
        return LoginStatusResult(
          isLoggedIn: true,
          userLoginType: userLoginType.value.name,
        );
      }
    }

    // message가 null이거나 message['message']가 null인 경우 안전하게 처리
    // debugPrint('#### checkLoginStatus: message: $message');
    if (message == null) {
      debugPrint('#### checkLoginStatus: message is null');
      // userId가 있으면 로그인 상태로 판단
      if (userId.value.isNotEmpty) {
        return LoginStatusResult(
          isLoggedIn: true,
          userLoginType: userLoginType.value.name,
        );
      }
      return LoginStatusResult(
        isLoggedIn: false,
        userLoginType: userLoginType.value.name,
      );
    }

    final messageText = message['message'];

    if (messageText != null) {
      final messageString = messageText.toString();
      // anonymous || 익명
      // status code로 변경해야 함
      final contains =
          // statusCode == 2000 || messageString.contains('Anonymous');
          messageString.contains('Anonymous') || messageString.contains('익명');
      // messageString.contains('Anonymous') || messageString.contains('익명');
      if (contains) {
        debugPrint(
            '####@@ "익명", status code 2000 포함됨, loginSessionToken.value: ${loginSessionToken.value}, loginSuccess: $loginSuccess');

        // 이전에 로그인 성공 상태였을 때만 세션 만료 처리
        if (loginSuccess && !_isSessionExpiredPopupShowing) {
          debugPrint(
              '####@@ 세션이 만료되었습니다, loginSessionToken.value: ${loginSessionToken.value}, loginSuccess: $loginSuccess');
          _isSessionExpiredPopupShowing = true; // 팝업 표시 중 플래그 설정

          // 기존 EasyLoading이 있으면 먼저 닫기
          EasyLoading.dismiss();

          // UI가 준비된 후 실행
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // 로그인 페이지로 이동
            final ctx = Get.context;
            if (ctx != null) {
              try {
                ctx.go('/');
              } catch (e) {
                debugPrint('####@@ 로그인 페이지 이동 실패: $e');
              }
            }

            // 페이지 이동 후 팝업 표시를 위해 짧은 딜레이
            Future.delayed(const Duration(milliseconds: 400), () {
              // 팝업 표시
              EasyLoading.show(
                  indicator: CommonPopupContent(
                      title: 'simple_login_expired'.tr,
                      headerWidget: const Icon(Icons.error),
                      message: 'simple_login_expired_message'.tr,
                      onConfirm: () {
                        EasyLoading.dismiss();
                        loginSessionToken.value =
                            false; // 로그아웃 전에 토큰 false 설정하여 추가 401 응답 방지
                        loginSuccess = false; // 로그인 성공 플래그 해제
                        sessionLogout(); // 세션 만료 시 스토리지 삭제는 건너 뜀
                        _isSessionExpiredPopupShowing = false; // 팝업 닫힘 플래그 해제
                      })).then((value) {
                debugPrint('####@@ EasyLoading 닫힘');
                _isSessionExpiredPopupShowing = false; // 팝업 닫힘 플래그 해제
              });
            });
          });

          // if (userLoginType.value == UserLoginType.naverWorks || userLoginType.value == UserLoginType.naver_works) {
          //   debugPrint('####@@ 네이버 웍스 로그인 타입 입니다, naverWorksLogin 호출');
          //   naverWorksLogin();
          // }

          // EasyLoading.show(
          //     indicator: Container(
          //   padding: const EdgeInsets.all(20),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(12),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withAlpha(26),
          //         blurRadius: 10,
          //         spreadRadius: 2,
          //         offset: const Offset(0, 4),
          //       )
          //     ],
          //   ),
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       // Row(
          //       //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       //   children: [
          //       //     Text('simple_login_expired'.tr),
          //       //     IconButton(
          //       //       onPressed: () {
          //       //         EasyLoading.dismiss();
          //       //       },
          //       //       icon: const Icon(Icons.close),
          //       //     ),
          //       //   ],
          //       // ),
          //       const SizedBox(height: 16),
          //       SimpleLoginWidget(
          //         widgetContext: Get.context!,
          //         onClose: () {
          //           EasyLoading.dismiss();
          //         },
          //         onLogin: () {
          //           EasyLoading.dismiss();
          //         },
          //       ),
          //     ],
          //   ),
          // ));

          return LoginStatusResult(
            isLoggedIn: true,
            userLoginType: userLoginType.value.name,
          );
        } else {
          debugPrint(
              '#### loginSuccess가 false여서 세션 만료 처리를 건너뜀 (loginSuccess: $loginSuccess)');
          return LoginStatusResult(
            isLoggedIn: false,
            userLoginType: userLoginType.value.name,
          );
        }
      }
    }
    // 로그인 성공 등의 케이스에서(익명이 아닌 경우), 동의 여부를 확인하여 네비게이션 여부를 결정
    final ctx = Get.context;
    if (loginSessionToken.value && ctx != null) {
      final allowed = await checkUserSignStatus(ctx);

      // 로그인 성공 시 저장된 URL로 리다이렉트 (302 응답으로 인한 로그인인 경우)
      if (allowed &&
          savedRedirectUrl.value != null &&
          savedRedirectUrl.value!.isNotEmpty) {
        Future.microtask(() async {
          await redirectToSavedUrl();
        });
      }

      return LoginStatusResult(
        isLoggedIn: allowed,
        userLoginType: userLoginType.value.name,
      );
    }
    // return LoginStatusResult(
    //   isLoggedIn: false,
    //   userLoginType: userLoginType.value.name,
    // );
  }

  // GoRouter와 연동을 위한 Listenable 제공
  static Listenable get authStateListenable {
    if (!Get.isRegistered<LoginController>()) {
      // 컨트롤러가 없으면 더미 Listenable 반환
      return ValueNotifier(false);
    }
    final controller = Get.find<LoginController>();
    return _AuthStateNotifier(controller);
  }
}

// GetX RxString을 Listenable로 변환하는 순수한 어댑터
class _AuthStateNotifier extends ChangeNotifier {
  final LoginController _controller;
  Worker? _userIdWorker;
  Worker? _userEmailWorker;
  Worker? _loginSessionTokenWorker;

  _AuthStateNotifier(this._controller) {
    // 인증 관련 상태들을 모두 listen
    _userIdWorker = ever(_controller.userId, (_) => notifyListeners());
    _userEmailWorker = ever(_controller.userEmail, (_) => notifyListeners());
    _loginSessionTokenWorker =
        ever(_controller.loginSessionToken, (_) => notifyListeners());
  }

  @override
  void dispose() {
    _userIdWorker?.dispose();
    _userEmailWorker?.dispose();
    _loginSessionTokenWorker?.dispose();
    super.dispose();
  }
}

class LoginPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}
