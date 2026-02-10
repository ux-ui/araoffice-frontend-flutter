import 'dart:async';

import 'package:api/api.dart';
import 'package:app/app/login/view/login_controller.dart';
import 'package:app/app/user_setting/duplicate_response_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountSettingController extends GetxController {
  final LoginController loginController = Get.find<LoginController>();
  final userProfileImage = ''.obs;
  final userDisplayName = 'default'.obs;
  final userEmail = ''.obs;
  final userUserId = ''.obs;
  final isSettingPassword = false.obs;
  final languageTypr = 'Korean'.obs;
  final titleText = 'account_management_settings'.tr.obs;
  final passwordValidate = false.obs;
  final passwordValidateText = ''.obs;
  final passwordCompareValidate = false.obs;
  final passwordCompareValidateText = ''.obs;
  final checkPassWord = false.obs;
  final enableSubmit = false.obs;
  final errorMessages = ''.obs;
  final marketingTime = ''.obs;
  final nickNameEditingController = TextEditingController();

  final emailEditingController = TextEditingController();
  final subEmailEditingController = TextEditingController();

  final currentPasswordEditingController = TextEditingController();
  final newPasswordEditingController = TextEditingController();
  final newPasswordConfirmEditingController = TextEditingController();

  final isMarketingAgreementChecked = false.obs;

  // 이메일 인증 관련 상태
  final showAuthCodeInput = false.obs;
  final authCodeFocus = FocusNode();
  final authCode = ''.obs;
  final isAuthCodeValid = false.obs;
  final authCodeTimer = 180.obs;
  Timer? _authCodeTimer;
  final authCodeTimerStatus = false.obs;
  final emailSendAuthBtnStatus = true.obs;
  final beforeEmailAuth = false.obs;
  final userShareId = ''.obs;

  void init() {
    userSetting();
    updateStatus();
  }

  void userSetting() async {
    final result = await loginController.getUser();
    if (result != null) {
      userProfileImage.value = result.profileImage ?? 'emptyProfileImage';
      userDisplayName.value = result.displayName ?? 'emptyName';
      userEmail.value = result.email ?? 'emptyEmail';
      userUserId.value = result.userId ?? 'emptyUserId';
      isSettingPassword.value = false;
      isMarketingAgreementChecked.value = result.isMarketingAgree ?? false;
      userShareId.value = result.shareId ?? 'emptyShareId';
    }
    getUserMarketingAgreement(
      userUserId.value,
    );
  }

  // void checkCurrentPassWord(String password) {
  //   if (password == '1234') {
  //     checkPassWord.value = true;
  //   } else {
  //     checkPassWord.value = false;
  //   }
  // }

  Future<bool> checkMarketingAgreement(bool isMarketingAgree) async {
    final result = await loginController.apiService.changeMarketingAgreement(
        userId: userUserId.value, isMarketingAgree: isMarketingAgree);
    if (result) {
      getUserMarketingAgreement(userUserId.value);
      return true;
    } else {
      return false;
    }
  }

  void comaprePassword() {
    final newPassword = newPasswordEditingController.text;
    final confirmPassword = newPasswordConfirmEditingController.text;

    // 새 비밀번호 유효성 검사 (8자 이상, 특수문자 포함)
    bool isNewPasswordValid = passwordValidate.value;

    // 비밀번호 일치 확인
    bool isPasswordMatch = newPassword == confirmPassword;

    // 새 비밀번호가 유효하고 일치하는 경우에만 통과
    if (isNewPasswordValid && isPasswordMatch && confirmPassword.isNotEmpty) {
      passwordCompareValidate.value = true;
      passwordCompareValidateText.value = 'password_match'.tr;
    } else {
      passwordCompareValidate.value = false;
      if (!isNewPasswordValid) {
        passwordCompareValidateText.value = passwordValidateText.value;
      } else if (!isPasswordMatch) {
        passwordCompareValidateText.value = 'password_not_match'.tr;
      } else {
        passwordCompareValidateText.value = 'password_not_match'.tr;
      }
    }
  }

  String getBaseUrl() {
    final baseUrl = ApiDio.apiHostAppServer.replaceAll('/api/v1', '');
    return baseUrl;
  }

  String getUrlMarketingPolicy() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/term-of-marketing';
  }

  // 이메일 인증 코드 전송
  Future<bool> sendEmailAuthCode() async {
    try {
      if (emailEditingController.text.isEmpty) {
        return false;
      }

      final result = await loginController.apiClient.sendAuthCode(
        email: emailEditingController.text,
      );

      if (result?.data['statusCode'] == 200) {
        showAuthCodeInput.value = true;
        emailSendAuthBtnStatus.value = false;
        beforeEmailAuth.value = false;
        startAuthCodeTimer();
        return true;
      } else if (result?.data['statusCode'] == 429) {
        beforeEmailAuth.value = true;
        emailSendAuthBtnStatus.value = true;
        return false;
      } else {
        showAuthCodeInput.value = false;
        emailSendAuthBtnStatus.value = true;
        beforeEmailAuth.value = false;
        return false;
      }
    } catch (e) {
      debugPrint('sendEmailAuthCode error: $e');
      return false;
    }
  }

  // 인증 코드 검증
  Future<bool> verifyEmailAuthCode() async {
    try {
      if (emailEditingController.text.isEmpty || authCode.value.isEmpty) {
        return false;
      }

      final response = await loginController.apiClient.verifyAuthCode(
        email: emailEditingController.text,
        authCode: authCode.value,
      );

      if (response?.data['statusCode'] == 200) {
        isAuthCodeValid.value = true;
        emailSendAuthBtnStatus.value = false;
        return true;
      } else {
        isAuthCodeValid.value = false;
        emailSendAuthBtnStatus.value = true;
        return false;
      }
    } catch (e) {
      debugPrint('verifyEmailAuthCode error: $e');
      return false;
    }
  }

  // 타이머 시작 함수
  void startAuthCodeTimer() {
    authCodeTimer.value = 180; // 3분
    _authCodeTimer?.cancel();
    authCodeTimerStatus.value = true;
    emailSendAuthBtnStatus.value = false;

    _authCodeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (authCodeTimer.value > 0) {
        authCodeTimer.value--;
      } else {
        timer.cancel();
        authCodeTimerStatus.value = false;
        emailSendAuthBtnStatus.value = true;
        showAuthCodeInput.value = false;

        if (!isAuthCodeValid.value) {
          showAuthCodeInput.value = false;
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

  void checkValidatePassWord(String value) {
    List<String> validationMessages = [];
    bool hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    // 길이 체크 (8자 이상)
    if (value.length < 8 || value.length > 32) {
      validationMessages.add('password_length_error'.tr);
    }

    // 특수문자 필수 체크
    if (!hasSpecialChar) {
      validationMessages.add('password_combination_error'.tr);
    }

    if (validationMessages.isNotEmpty) {
      passwordValidateText.value =
          '${validationMessages.join(", ")} ${'password_include_error'.tr}';
      passwordValidate.value = false;
    } else {
      passwordValidateText.value = 'password_validate_success'.tr;
      passwordValidate.value = true;
    }
  }

  bool checkBtnEnable() {
    if (passwordValidate.value && passwordCompareValidate.value
        // &&checkPassWord.value
        ) {
      enableSubmit.value = true;
    } else {
      enableSubmit.value = false;
    }
    return enableSubmit.value;
  }

  // void changePassword() async{
  //   final result = await loginController.apiClient.changePassword(
  //       currentPassword: currentPasswordEditingController.text,
  //       newPassword: newPasswordEditingController.text);
  //   if(result != null){
  //     if(result.statusCode == 200){
  //       errorMessages.value = result.message;
  //     }else{
  //       errorMessages.value = result.message;
  //     }
  //   }
  //   // await api.changePassword();
  //   updateStatus();
  // }

  Future<bool> changePassword() async {
    // final currentPassword = converHash(currentPasswordEditingController.text);
    // final newPassword = converHash(newPasswordEditingController.text);
    // form data 형식으로 변환
    // final formData = FormData({
    //   'currentPassword': currentPassword,
    //   'newPassword': newPassword,
    // });

    //sha256
    // final currentPassword = converShaHash(currentPasswordEditingController.text);
    // final newPassword = converShaHash(newPasswordEditingController.text);

    final result = await loginController.apiClient.changePasswordData(
        currentPassword: currentPasswordEditingController.text,
        newPassword: newPasswordEditingController.text);
    if (result.data['statusCode'] == 200) {
      errorMessages.value = '';
      return true;
    } else {
      errorMessages.value = result.data['data'];
      return false;
    }
  }

  void changeLanguage() {
    // await api.changeLanguage();
    updateStatus();
  }

  Future<bool> changeDisplaykName(String nickName) async {
    // await api.changeNickName();
    if (nickName.length > 20) {
      nickName = nickName.substring(0, 20);
    }
    final result = await loginController.apiService.updateUser(
        displayName: nickName, email: '', profileImage: '', shareId: '');
    updateStatus();
    return result;
    // final result = await loginController.apiClient
    //     .updateUser(displayName: nickName, email: '', profileImage: '');
    // if (result != null) {
    //   loginController.userDisplayName.value = result.data['displayName'];
    //   return true;
    // } else {
    //   return false;
    // }
  }

  Future<bool> changeEmail(String email) async {
    // 이메일 인증이 완료된 경우에만 변경 가능
    if (!isAuthCodeValid.value) {
      return false;
    }

    final result = await loginController.apiService.updateUser(
        displayName: '', email: email, profileImage: '', shareId: '');
    if (result) {
      updateStatus();
      // 인증 상태 초기화
      isAuthCodeValid.value = false;
      showAuthCodeInput.value = false;
      authCode.value = '';
      stopAuthCodeTimer();
    }
    return result;
  }

  Future<bool> changeShareId(String shareId) async {
    final result = await loginController.apiService.updateUser(
        displayName: '', email: '', profileImage: '', shareId: shareId);
    if (result) {
      updateStatus();
    }
    return result;
  }

  void changeProfileImage() {
    // await api.changeProfileImage();
    loginController.apiClient
        .updateUser(displayName: '', email: '', profileImage: '', shareId: '');
    updateStatus();
  }

  void updateStatus() async {
    final result = await loginController.getUser();
    userDisplayName.value = result?.displayName ?? 'emptyName';
    userEmail.value = result?.email ?? 'emptyEmail';
    userProfileImage.value = result?.profileImage ?? 'emptyProfileImage';
    userUserId.value = result?.userId ?? 'emptyUserId';
  }

  Future<bool> checkIdDuplication() async {
    try {
      final response = await loginController.apiService.checkUserId(
        userId: nickNameEditingController.text,
      );

      if (response) {
        return false; // 중복되지 않음
      }
      return true; // 중복됨
    } catch (e) {
      return true; // 에러 발생 시 중복으로 처리
    }
  }

  Future<SignUpResponse?> checkIdDuplicationMessage() async {
    try {
      final response = await loginController.apiService.checkUserIdMessage(
        userId: nickNameEditingController.text,
      );
      if (response?.isDuplicate == true) {
        return SignUpResponse(
            isDuplicate: true,
            isAvailable: false,
            message: response?.message ?? '');
      }
      return SignUpResponse(
          isDuplicate: false,
          isAvailable: true,
          message: response?.message ?? '');
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkNicknameDuplication(String nickName) async {
    try {
      final response = await loginController.apiService.checkDisplayName(
        displayName: nickNameEditingController.text,
      );

      if (response) {
        return false; // 중복되지 않음
      }
      return true; // 중복됨
    } catch (e) {
      return true; // 에러 발생 시 중복으로 처리
    }
  }

  Future<SignUpDuplicateModel?> checkNicknameDuplicationMessage(
      String nickName) async {
    try {
      final response = await loginController.apiService.checkDisplayNameMessage(
        displayName: nickNameEditingController.text,
      );
      if (response?.isDuplicate == true) {
        return SignUpDuplicateModel(
            isDuplicate: true, message: response?.message ?? '');
      }
      return SignUpDuplicateModel(
          isDuplicate: false, message: response?.message ?? '');
    } catch (e) {
      return null;
    }
  }

  // 이메일 중복 체크
  Future<bool> checkEmailDuplication() async {
    try {
      final response = await loginController.apiClient.checkEmail(
        email: emailEditingController.text,
      );

      if (response?.data['statusCode'] == 200) {
        return false; // 중복되지 않음
      }
      return true; // 중복됨
    } catch (e) {
      return true; // 에러 발생 시 중복으로 처리
    }
  }

  Future<SignUpDuplicateModel?> checkEmailDuplicationMessage() async {
    final response = await loginController.apiService.checkEmailMessage(
      email: emailEditingController.text,
    );
    if (response?.isDuplicate == true) {
      return SignUpDuplicateModel(
          isDuplicate: true, message: response?.message ?? '');
    }
    return SignUpDuplicateModel(
        isDuplicate: false, message: response?.message ?? '');
  }

  Future<void> saveLanguagePreference(String language) async {
    loginController.saveLanguagePreference(language);
  }

  Future<String?> getLanguagePreference() async {
    return loginController.getLanguagePreference();
  }

  Future<String?> getUserMarketingAgreement(String userId) async {
    final result = await loginController.apiService.getUserMarketingAgreement(
      userId: userId,
    );
    if (result != null) {
      marketingTime.value = formatDate(result);
    }
    return '';
  }

  String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }
}
