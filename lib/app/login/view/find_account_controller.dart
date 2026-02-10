import 'dart:async';

import 'package:api/api.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

enum FindAccountType { id, password }

class FindAccountController extends GetxController {
  final apiClient = Get.find<LoginApiClient>();
  final apiService = Get.find<LoginApiService>();

  // final id = ''.obs;
  // final password = ''.obs;
  // final isIdValid = false.obs;
  // final isPasswordValid = false.obs;
  final isProgress = false.obs;

  // final Throttle _loginActionThrottle = Throttle(milliseconds: 200);
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
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newPasswordConfirmController =
      TextEditingController();

  // 아이디/비밀번호 찾기 관련 변수
  final currentType = FindAccountType.id.obs;
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
  final reSendLimitMessage = ''.obs;
  final isSignUpAccount = false.obs;

  // 이메일 인증 타이머 관련 상태
  final authCodeTimer = 180.obs;
  Timer? _authCodeTimer;
  final authCodeTimerStatus = false.obs;
  final emailSendAuthBtnStatus = true.obs;
  final beforeEmailAuth = false.obs;

  final isPasswordVisible = false.obs;
  final newPassword = ''.obs;
  final confirmPassword = ''.obs;
  final isPasswordValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    resetControllers();
    logger.i('login controller init');
    debounce(newPassword, (_) => validatePassword(),
        time: const Duration(milliseconds: 300));
    debounce(confirmPassword, (_) => validatePassword(),
        time: const Duration(milliseconds: 300));
  }

  void validatePassword() {
    final password = newPassword.value;
    final confirm = confirmPassword.value;
    isPasswordValid.value = password.isNotEmpty &&
        confirm.isNotEmpty &&
        password == confirm &&
        password.length >= 8;
  }

  // 현재 타입에 따른 상태 업데이트
  void updateType(FindAccountType type) {
    currentType.value = type;
    isFindingId.value = type == FindAccountType.id;
    isFindingPassword.value = type == FindAccountType.password;
  }

  // 현재 타입에 따른 이메일 인증 상태 가져오기
  bool get currentEmailStatus {
    return switch (currentType.value) {
      FindAccountType.id => idFindEmailStatus.value,
      FindAccountType.password => passwordFindEmailStatus.value,
    };
  }

  // 현재 타입에 따른 인증 코드 컨트롤러 가져오기
  TextEditingController get currentAuthCodeController {
    return switch (currentType.value) {
      FindAccountType.id => idFindEmailAuthCodeController,
      FindAccountType.password => passwordFindEmailAuthCodeController,
    };
  }

  // 현재 타입에 따른 인증 코드 검증 상태 가져오기
  bool get currentAuthCodeValid {
    return switch (currentType.value) {
      FindAccountType.id => isIdAuthCodeValid.value,
      FindAccountType.password => isPasswordAuthCodeValid.value,
    };
  }

  // 현재 타입에 따른 인증 코드 검증 상태 설정
  void setCurrentAuthCodeValid(bool value) {
    switch (currentType.value) {
      case FindAccountType.id:
        isIdAuthCodeValid.value = value;
        break;
      case FindAccountType.password:
        isPasswordAuthCodeValid.value = value;
        break;
    }
  }

  // 현재 타입에 따른 이메일 인증 상태 설정
  void setCurrentEmailStatus(bool value) {
    switch (currentType.value) {
      case FindAccountType.id:
        idFindEmailStatus.value = value;
        break;
      case FindAccountType.password:
        passwordFindEmailStatus.value = value;
        break;
    }
  }

  // 현재 타입에 따른 이메일 인증 전송
  Future<bool> sendCurrentEmailAuth() async {
    return switch (currentType.value) {
      FindAccountType.id => findIdSendEmailAuth(),
      FindAccountType.password => findPasswordSendEmailAuth(),
    };
  }

  // 현재 타입에 따른 인증 코드 검증
  Future<bool> verifyCurrentAuthCode() async {
    return switch (currentType.value) {
      FindAccountType.id => verifyIdAuthCode(),
      FindAccountType.password => verifyPasswordAuthCode(),
    };
  }

  void resetControllers() {
    idController.clear();
    passwordController.clear();
    emailController.clear();
    findAccountEmailController.clear();
    idFindEmailAuthCodeController.clear();
    passwordFindEmailAuthCodeController.clear();
    passwordFindIdController.clear();
    newPasswordController.clear();
    newPasswordConfirmController.clear();

    // 상태값도 초기화
    // isFindingId.value = true;
    // isFindingPassword.value = false;
    idFindEmailStatus.value = false;
    passwordFindEmailStatus.value = false;
    isIdAuthCodeValid.value = false;
    isPasswordAuthCodeValid.value = false;
    findIdResult.value = '';
    findAccountErrorMessage.value = '';
    newPassword.value = '';
    confirmPassword.value = '';
    isPasswordValid.value = false;

    // 타이머 관련 상태 초기화
    authCodeTimer.value = 180;
    authCodeTimerStatus.value = false;
    emailSendAuthBtnStatus.value = true;
    beforeEmailAuth.value = false;
    _authCodeTimer?.cancel();
  }

  @override
  void onClose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    idController.dispose();
    passwordController.dispose();
    emailController.dispose();
    findAccountEmailController.dispose();
    idFindEmailAuthCodeController.dispose();
    passwordFindEmailAuthCodeController.dispose();
    passwordFindIdController.dispose();
    newPasswordController.dispose();
    newPasswordConfirmController.dispose();
    _authCodeTimer?.cancel();
    super.onClose();
  }

  // 타이머 시작 함수
  void startAuthCodeTimer() {
    authCodeTimer.value = 600; // 3분
    _authCodeTimer?.cancel(); // 기존 타이머가 있다면 취소
    authCodeTimerStatus.value = true;
    emailSendAuthBtnStatus.value = false;

    _authCodeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (authCodeTimer.value > 0) {
        authCodeTimer.value--;
      } else {
        timer.cancel();
        authCodeTimerStatus.value = false;
        emailSendAuthBtnStatus.value = true;
        idFindEmailStatus.value = false;
        passwordFindEmailStatus.value = false;

        // 시간 초과 시 처리
        if (!isIdAuthCodeValid.value && !isPasswordAuthCodeValid.value) {
          EasyLoading.showError('sign_up_email_auth_code_expired'.tr);
        }
      }
    });
  }

  // 타이머 중지 함수
  void stopAuthCodeTimer() {
    _authCodeTimer?.cancel();
    authCodeTimerStatus.value = false;
    emailSendAuthBtnStatus.value = true;
  }

  Future<bool> checkDuplicateEmail() async {
    final isSignUp =
        await apiService.checkEmail(email: findAccountEmailController.text);
    isSignUpAccount.value = isSignUp;
    return isSignUp;
  }

  // 아이디/비밀번호 찾기 관련 메서드

  Future<bool> findIdSendEmailAuth() async {
    try {
      if (findAccountEmailController.text.isEmpty) {
        findAccountErrorMessage.value = 'find_account_email_required'.tr;
        return false;
      }
      // final isSignUp =
      //     await apiService.checkEmail(email: findAccountEmailController.text);
      // if (!isSignUp) { // !isSignUp = 중복 아닌 계정으로 등록되지 않은 이메일
      //   // false = 중복 아닌 계정으로 등록되지 않은 이메일
      //   isSignUpAccount.value = false;
      //   return false;
      // } else {
      isSignUpAccount.value = true;
      final result = await apiClient.sendAuthCode(
        email: findAccountEmailController.text,
      );

      // API 응답이 null인 경우 처리
      if (result == null || result.data == null) {
        findAccountErrorMessage.value = 'find_account_api_error'.tr;
        EasyLoading.dismiss();
        return false;
      }

      if (result.data['statusCode'] == 200) {
        idFindEmailStatus.value = true;
        emailSendAuthBtnStatus.value = false;
        beforeEmailAuth.value = false;
        EasyLoading.dismiss();
        startAuthCodeTimer();
        return true;
      } else if (result.data['statusCode'] == 429) {
        beforeEmailAuth.value = true;
        emailSendAuthBtnStatus.value = true;
        reSendLimitMessage.value = result.data['message'] ??
            'sign_up_email_auth_code_required_message'.tr;
        // idFindEmailStatus.value = false;
        EasyLoading.dismiss();
        return false;
      } else {
        idFindEmailStatus.value = false;
        emailSendAuthBtnStatus.value = true;
        beforeEmailAuth.value = false;
        EasyLoading.dismiss();
        return false;
      }
    } catch (e) {
      findAccountErrorMessage.value = 'find_account_id_find_error'.tr;
      return false;
    }
  }

  Future<bool> checkPasswordFindId() async {
    //false = id - email 조회 실패
    //true = id - email 조회 성공
    try {
      final result = await lookupUserPasswordCheck();

      if (result) {
        // 성공 시 에러 메시지 초기화
        findAccountErrorMessage.value = '';
        return true;
      } else {
        // 실패 시 에러 메시지 설정
        findAccountErrorMessage.value =
            'find_account_password_change_not_possible'.tr;
        return false;
      }
    } catch (e) {
      debugPrint('checkPasswordFindId error: $e');
      findAccountErrorMessage.value =
          'find_account_password_change_not_possible'.tr;
      return false;
    }
  }

  Future<bool> findPasswordSendEmailAuth() async {
    try {
      if (passwordFindIdController.text.isEmpty) {
        findAccountErrorMessage.value = 'find_account_id_required'.tr;
        return false;
      }
      if (findAccountEmailController.text.isEmpty) {
        findAccountErrorMessage.value = 'find_account_email_required'.tr;
        return false;
      }
      final result = await apiClient.sendAuthCode(
        email: findAccountEmailController.text,
      );

      // API 응답이 null인 경우 처리
      if (result == null || result.data == null) {
        findAccountErrorMessage.value = 'find_account_api_error'.tr;
        EasyLoading.dismiss();
        return false;
      }

      if (result.data['statusCode'] == 200) {
        passwordFindEmailStatus.value = true;
        emailSendAuthBtnStatus.value = false;
        beforeEmailAuth.value = false;
        EasyLoading.dismiss();
        startAuthCodeTimer();
        return true;
      } else if (result.data['statusCode'] == 429) {
        beforeEmailAuth.value = true;
        emailSendAuthBtnStatus.value = true;
        // passwordFindEmailStatus.value = false;
        EasyLoading.dismiss();
        return false;
      } else {
        passwordFindEmailStatus.value = false;
        emailSendAuthBtnStatus.value = true;
        beforeEmailAuth.value = false;
        EasyLoading.dismiss();
        return false;
      }
    } catch (e) {
      findAccountErrorMessage.value =
          'find_account_password_change_not_possible'.tr;
      return false;
    }
  }

  // Future<bool> findId() async {
  //   try {
  //     if (emailController.text.isEmpty) {
  //       findAccountErrorMessage.value = '이메일을 입력해주세요.';
  //       return false;
  //     }
  //     // API 호출 구현
  //     await Future.delayed(const Duration(seconds: 1)); // 임시 딜레이
  //     return true;
  //   } catch (e) {
  //     findAccountErrorMessage.value = '아이디 찾기에 실패했습니다.';
  //     return false;
  //   }
  // }

  Future<bool> findPassword() async {
    try {
      if (passwordFindIdController.text.isEmpty ||
          findAccountEmailController.text.isEmpty) {
        findAccountErrorMessage.value = 'find_account_id_and_email_required'.tr;
        return false;
      }
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      findAccountErrorMessage.value = 'find_account_password_find_error'.tr;
      return false;
    }
  }

  // 인증 코드 검증
  Future<bool> verifyIdAuthCode() async {
    try {
      if (idFindEmailAuthCodeController.text.isEmpty) {
        EasyLoading.showInfo('sign_up_email_auth_code_required'.tr);
        return false;
      }

      final response = await apiClient.verifyAuthCode(
        email: findAccountEmailController.text,
        authCode: idFindEmailAuthCodeController.text,
      );

      // API 응답이 null인 경우 처리
      if (response == null || response.data == null) {
        debugPrint('API response is null');
        return false;
      }

      if (response.data['statusCode'] == 200) {
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

  Future<bool> verifyPasswordAuthCode() async {
    try {
      if (passwordFindEmailAuthCodeController.text.isEmpty) {
        EasyLoading.showInfo('sign_up_email_auth_code_required'.tr);
        debugPrint('sign_up_email_auth_code_required'.tr);
        return false;
      }

      final response = await apiClient.verifyAuthCode(
        email: findAccountEmailController.text,
        authCode: passwordFindEmailAuthCodeController.text,
      );

      // API 응답이 null인 경우 처리
      if (response == null || response.data == null) {
        debugPrint('API response is null');
        return false;
      }

      if (response.data['statusCode'] == 200) {
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

  Future<String> findId() async {
    await Future.delayed(const Duration(seconds: 1));
    findIdResult.value = 'testId';
    return 'testId';
  }

  Future<bool> changePassword() async {
    try {
      isProgress.value = true;
      await Future.delayed(const Duration(seconds: 1));
      isProgress.value = false;
      return true;
    } catch (e) {
      isProgress.value = false;
      return false;
    }
  }

  Future<String?> lookupUserId() async {
    final response =
        await apiService.lookupUserId(email: findAccountEmailController.text);
    if (response == null) {
      return null;
    }
    return response;
  }

  Future<bool> lookupUserPasswordCheck() async {
    try {
      if (passwordFindIdController.text.isEmpty ||
          findAccountEmailController.text.isEmpty) {
        debugPrint('lookupUserPasswordCheck: userId or email is empty');
        return false;
      }

      final response = await apiService.lookupUserPasswordCheck(
          userId: passwordFindIdController.text,
          email: findAccountEmailController.text);

      debugPrint('lookupUserPasswordCheck response: $response');
      return response ?? false;
    } catch (e) {
      debugPrint('lookupUserPasswordCheck error: $e');
      return false;
    }
  }

  Future<bool> resetPassword({
    required String userId,
    required String email,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final response = await apiService.resetPassword(
        userId: userId,
        email: email,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm);
    return response;
  }
}

class LoginPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FindAccountController());
  }
}
