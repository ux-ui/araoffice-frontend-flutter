import 'dart:async';
import 'dart:math';

import 'package:api/api.dart';
import 'package:app/app/user_setting/duplicate_response_model.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../login/view/login_controller.dart';

class SignUpController extends GetxController {
  final apiClient = Get.find<LoginApiClient>();
  final apiService = Get.find<LoginApiService>();

  final id = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final name = ''.obs;
  final email = ''.obs;
  final phoneNumber = ''.obs;
  final gender = Rxn<bool>(); // 남자: true, 여자: false
  final birthDate = ''.obs;
  final isAdult = false.obs;
  final isForeigner = false.obs;
  final agreeTerms = false.obs;
  final agreeMarketing = false.obs;
  final agreePrivacy = false.obs;

  final isIdValid = false.obs;
  final isFixedId = false.obs;
  final isIdDuplicationChecked = false.obs; // 아이디 중복 체크 완료 여부
  final isPasswordValid = false.obs;
  final isConfirmPasswordValid = false.obs;
  final isNameValid = false.obs;
  final isEmailValid = false.obs;
  final isBirthDateValid = false.obs;
  final canSignUp = false.obs;

  final isIdBoxFocused = false.obs;
  final isPasswordBoxFocused = false.obs;
  final isConfirmPasswordBoxFocused = false.obs;
  final isNameBoxFocused = false.obs;
  final isEmailBoxFocused = false.obs;
  final isBirthDateBoxFocused = false.obs;

  final isIdChecked = false.obs;
  final isPasswordChecked = false.obs;
  final isConfirmPasswordChecked = false.obs;
  final isNameChecked = false.obs;
  final isEmailChecked = false.obs;
  final isBirthDateChecked = false.obs;

  final errorIdText = ''.obs;
  final errorPasswordText = ''.obs;
  final errorConfirmPasswordText = ''.obs;
  final errorNameText = ''.obs;
  final errorBirthDateText = ''.obs;
  final errorEmailText = ''.obs;
  final reSendLimitMessage = ''.obs;
  final isEmailAuthValid = false.obs;
  final passwordObscure = true.obs;
  final confirmPasswordObscure = true.obs;
  final signUpErrorMessage = ''.obs;

  final isTermAndConditionAllChecked = false.obs;
  final isTermAndConditionList1 = false.obs;
  final isTermAndConditionList2 = false.obs;

  final isMarketingAgreementChecked = false.obs;
  final isMarketingAgreementList1 = false.obs;
  final FocusNode idFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode birthDateFocus = FocusNode();

  final birthDateController = TextEditingController();

  final isPhoneNumberValid = false.obs;
  final isPhoneNumberBoxFocused = false.obs;
  final isPhoneNumberChecked = false.obs;
  final FocusNode phoneNumberFocus = FocusNode();

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

  // 로그인 타입
  final Rx<LoginType?> loginType = Rx<LoginType?>(null);

  @override
  void onInit() {
    super.onInit();
    reset(); // 초기화 메서드 호출
    getUrlTerms();
    ever(id, (_) => validateId());
    ever(password, (_) => validatePassword());
    ever(confirmPassword, (_) => validateConfirmPassword());
    ever(name, (_) => validateName());
    ever(email, (_) => validateEmail());
    ever(birthDate, (_) => validateBirthDate());
    ever(phoneNumber, (_) => validatePhoneNumber());
    everAll([
      isIdValid,
      isPasswordValid,
      isConfirmPasswordValid,
      isNameValid,
      isEmailValid,
      isBirthDateValid,
      isPhoneNumberValid,
    ], (_) => updateCanSignUp());
  }

  // 모든 상태를 초기화하는 메서드
  void reset() {
    id.value = '';
    password.value = '';
    confirmPassword.value = '';
    name.value = '';
    email.value = '';
    phoneNumber.value = '';
    gender.value = null;
    birthDate.value = '';
    isAdult.value = false;
    isForeigner.value = false;
    agreeTerms.value = false;
    agreeMarketing.value = false;
    agreePrivacy.value = false;

    isIdValid.value = false;
    isFixedId.value = false;
    isIdDuplicationChecked.value = false;
    isPasswordValid.value = false;
    isConfirmPasswordValid.value = false;
    isNameValid.value = false;
    isEmailValid.value = false;
    isBirthDateValid.value = false;
    canSignUp.value = false;

    isIdBoxFocused.value = false;
    isPasswordBoxFocused.value = false;
    isConfirmPasswordBoxFocused.value = false;
    isNameBoxFocused.value = false;
    isEmailBoxFocused.value = false;
    isBirthDateBoxFocused.value = false;

    isIdChecked.value = false;
    isPasswordChecked.value = false;
    isConfirmPasswordChecked.value = false;
    isNameChecked.value = false;
    isEmailChecked.value = false;
    isBirthDateChecked.value = false;

    errorIdText.value = '';
    errorPasswordText.value = '';
    errorConfirmPasswordText.value = '';
    errorNameText.value = '';
    errorBirthDateText.value = '';
    errorEmailText.value = '';

    isEmailAuthValid.value = false;
    passwordObscure.value = true;
    confirmPasswordObscure.value = true;
    signUpErrorMessage.value = '';

    isTermAndConditionAllChecked.value = false;
    isTermAndConditionList1.value = false;
    isTermAndConditionList2.value = false;

    isMarketingAgreementChecked.value = false;
    isMarketingAgreementList1.value = false;

    showAuthCodeInput.value = false;
    authCode.value = '';
    isAuthCodeValid.value = false;
    emailSendAuthBtnStatus.value = true;
    authCodeTimer.value = 180;
    authCodeTimerStatus.value = false;
    _authCodeTimer?.cancel();
  }

  @override
  void onClose() {
    idFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    birthDateFocus.dispose();
    birthDateController.dispose();
    phoneNumberFocus.dispose();
    authCodeFocus.dispose();
    _authCodeTimer?.cancel();
    reset(); // 컨트롤러가 닫힐 때도 초기화
    super.onClose();
  }

  void onIdChanged(String value) {
    // 아이디가 변경되면 중복 체크 상태 초기화
    if (id.value != value) {
      isIdDuplicationChecked.value = false;
      isFixedId.value = false;
    }
    id.value = value;
  }

  void onPasswordChanged(String value) {
    password.value = value;
    // 비밀번호가 변경되면 비밀번호 확인도 실시간으로 다시 검증
    validateConfirmPassword();
  }

  void onConfirmPasswordChanged(String value) {
    confirmPassword.value = value;
    // 비밀번호 확인이 변경되면 실시간으로 검증
    validateConfirmPassword();
  }

  void onNameChanged(String value) {
    name.value = value;
  }

  void onEmailChanged(String value) {
    email.value = value;
  }

  void onBirthDateChanged(String value) {
    birthDate.value = value;
  }

  void onBirthDateFocusChange(bool hasFocus) {
    isBirthDateBoxFocused.value = hasFocus;
  }

  void onIdFocusChange(bool hasFocus) {
    isIdBoxFocused.value = hasFocus;
  }

  void onPasswordFocusChange(bool hasFocus) {
    isPasswordBoxFocused.value = hasFocus;
  }

  void onConfirmPasswordFocusChange(bool hasFocus) {
    isConfirmPasswordBoxFocused.value = hasFocus;
  }

  void onNameFocusChange(bool hasFocus) {
    isNameBoxFocused.value = hasFocus;
  }

  void onEmailFocusChange(bool hasFocus) {
    isEmailBoxFocused.value = hasFocus;
  }

  void onPhoneNumberChanged(String value) {
    // 숫자만 추출
    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    // 전화번호 형식으로 변환 (010-1234-5678)
    if (numericValue.length >= 10) {
      final formatted =
          '${numericValue.substring(0, 3)}-${numericValue.substring(3, 7)}-${numericValue.substring(7, min(11, numericValue.length))}';
      phoneNumber.value = formatted;
    } else if (numericValue.length >= 7) {
      final formatted =
          '${numericValue.substring(0, 3)}-${numericValue.substring(3, 7)}-${numericValue.substring(7)}';
      phoneNumber.value = formatted;
    } else if (numericValue.length >= 3) {
      final formatted =
          '${numericValue.substring(0, 3)}-${numericValue.substring(3)}';
      phoneNumber.value = formatted;
    } else {
      phoneNumber.value = numericValue;
    }
  }

  void onPhoneNumberFocusChange(bool hasFocus) {
    isPhoneNumberBoxFocused.value = hasFocus;
  }

  void validateId() {
    // 아이디 길이 체크만 수행 (중복 체크는 별도로 수행)
    // 중복 체크가 완료되지 않았으면 유효성 검사는 false로 유지
    if (id.value.length < 4) {
      isIdValid.value = false;
    }
    // 길이가 4 이상이어도 중복 체크가 완료되지 않았으면 false
    // 중복 체크 완료 여부는 checkIdDuplicationMessage에서 설정됨
  }

  void validatePassword() {
    // 비밀번호는 8자리 이상이어야 함
    final isValid = password.value.length >= 8;
    isPasswordValid.value = isValid;
    // 비밀번호가 변경되면 비밀번호 확인도 다시 검증
    validateConfirmPassword();
  }

  void validateConfirmPassword() {
    // 비밀번호와 비밀번호 확인이 일치하는지 확인
    // 중요: 비밀번호가 8자리 이상이어야 하고, 비밀번호 확인이 비밀번호와 일치해야 함
    // 8자리 미만이면 무조건 false
    if (password.value.isEmpty || password.value.length < 8) {
      isConfirmPasswordValid.value = false;
      return;
    }
    // 8자리 이상일 때만 일치 여부 확인
    isConfirmPasswordValid.value = confirmPassword.value == password.value;
  }

  void validateName() {
    isNameValid.value = name.value.length >= 2;
  }

  void validateEmail() {
    isEmailValid.value = EmailValidator.validate(email.value);
  }

  void validateBirthDate() {
    final RegExp birthDateRegex = RegExp(r'^\d{8}$');
    isBirthDateValid.value = birthDateRegex.hasMatch(birthDate.value);
  }

  void validatePhoneNumber() {
    final RegExp phoneRegex = RegExp(r'^\d{3}-\d{3,4}-\d{4}$');
    isPhoneNumberValid.value = phoneRegex.hasMatch(phoneNumber.value);
  }

  void updateCanSignUp() {
    canSignUp.value = isIdValid.value &&
        isPasswordValid.value &&
        isConfirmPasswordValid.value &&
        isNameValid.value &&
        isEmailValid.value &&
        isBirthDateValid.value &&
        isPhoneNumberValid.value;
  }

  void checkAllTerms(bool value) {
    isTermAndConditionAllChecked.value = value;
    isTermAndConditionList1.value = value;
    isTermAndConditionList2.value = value;
  }

  void checkTermAndCondition() {
    if (isTermAndConditionList1.value && isTermAndConditionList2.value) {
      isTermAndConditionAllChecked.value = true;
    } else {
      isTermAndConditionAllChecked.value = false;
    }
  }

  void checkAllMarketingAgreement(bool value) {
    isMarketingAgreementChecked.value = value;
    isMarketingAgreementList1.value = value;
  }

  void checkMarketingAgreement() {
    if (isMarketingAgreementList1.value) {
      isMarketingAgreementChecked.value = true;
    } else {
      isMarketingAgreementChecked.value = false;
    }
  }

  Future<void> selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      birthDate.value =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      birthDateController.text = birthDate.value;
    }
  }

  String formatBirthDate(String birthDate) {
    if (birthDate.length != 8) return birthDate;

    final year = birthDate.substring(0, 4);
    final month = birthDate.substring(4, 6);
    final day = birthDate.substring(6, 8);

    return '$year-$month-$day';
  }

  Future<ApiResponse?> signUp() async {
    // 필수 정보 검증
    if (id.value.isEmpty) {
      signUpErrorMessage.value = 'find_password_id_required'.tr;
      return null;
    }
    if (password.value.isEmpty) {
      signUpErrorMessage.value = 'password_hint_text'.tr;
      return null;
    }
    // 비밀번호는 8자리 이상이어야 함
    if (password.value.length < 8) {
      signUpErrorMessage.value = 'sign_up_confirm_required_password_length'.tr;
      return null;
    }
    if (confirmPassword.value.isEmpty) {
      signUpErrorMessage.value = 'sign_up_confirm_password_required'.tr;
      return null;
    }
    // 비밀번호와 비밀번호 확인이 일치해야 함
    if (password.value != confirmPassword.value) {
      signUpErrorMessage.value = 'sign_up_confirm_required_password_match'.tr;
      return null;
    }
    if (name.value.isEmpty) {
      signUpErrorMessage.value = 'sign_up_confirm_required_name'.tr;
      return null;
    }
    if (email.value.isEmpty) {
      signUpErrorMessage.value = 'find_password_email_required'.tr;
      return null;
    }
    if (!isEmailAuthValid.value) {
      signUpErrorMessage.value = 'sign_up_confirm_required_email_auth'.tr;
      return null;
    }
    // if (gender.value == false) {
    //   signUpErrorMessage.value = '성별을 선택해주세요.'.tr;
    //   return null;
    // }
    if (birthDate.value.isEmpty) {
      signUpErrorMessage.value = 'sign_up_confirm_required_birth_date'.tr;
      return null;
    }
    if (!isAdult.value) {
      signUpErrorMessage.value = 'sign_up_confirm_required_adult'.tr;
      return null;
    }
    if (!isTermAndConditionAllChecked.value) {
      signUpErrorMessage.value =
          'sign_up_confirm_required_term_and_condition'.tr;
      return null;
    }
    if (!isTermAndConditionList2.value) {
      signUpErrorMessage.value = 'sign_up_confirm_required_privacy_policy'.tr;
      return null;
    }

    // 유효성 검사
    // 아이디 중복확인 체크
    if (!isIdDuplicationChecked.value) {
      signUpErrorMessage.value = 'sign_up_id_duplication_check_required'.tr;
      return null;
    }
    if (!isIdValid.value) {
      signUpErrorMessage.value = 'sign_up_confirm_required_id_length'.tr;
      return null;
    }
    if (!isPasswordValid.value) {
      signUpErrorMessage.value = 'sign_up_confirm_required_password_length'.tr;
      return null;
    }
    if (!isConfirmPasswordValid.value) {
      signUpErrorMessage.value = 'sign_up_confirm_required_password_match'.tr;
      return null;
    }
    if (!isNameValid.value) {
      signUpErrorMessage.value = 'sign_up_confirm_required_name_length'.tr;
      return null;
    }
    if (!isEmailValid.value) {
      signUpErrorMessage.value = 'sign_up_confirm_required_email_format'.tr;
      return null;
    }

    try {
      final result = await apiClient.signUp(
        userId: id.value,
        name: name.value,
        password: password.value,
        passwordConfirm: confirmPassword.value,
        email: email.value,
        phoneNumber: phoneNumber.value,
        // null 설정
        gender: !(gender.value ?? false),
        birthDate: formatBirthDate(birthDate.value),
        isAdult: isAdult.value,
        isForeigner: isForeigner.value,
        agreeTerms: isTermAndConditionAllChecked.value,
        agreeMarketing: isMarketingAgreementChecked.value,
        agreePrivacy: isTermAndConditionList2.value,
      );
      return result;
    } catch (e) {
      signUpErrorMessage.value = 'sign_up_error_message'.tr;
      return null;
    }
  }

  Future<bool> checkIdDuplication() async {
    try {
      final response = await apiService.checkUserId(
        userId: id.value,
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
      final response = await apiService.checkUserIdMessage(
        userId: id.value,
      );
      // 중복 체크 완료 표시
      isIdDuplicationChecked.value = true;

      if (response?.isDuplicate == true) {
        isIdValid.value = false;
        isFixedId.value = false;
        return SignUpResponse(
            isDuplicate: true,
            isAvailable: false,
            message: response?.message ?? '');
      } else if (response?.isAvailable == false) {
        isIdValid.value = false;
        isFixedId.value = false;
        return SignUpResponse(
            isDuplicate: false,
            isAvailable: false,
            message: response?.message ?? '');
      } else if (response?.isAvailable == true) {
        isIdValid.value = true;
        isFixedId.value = true; // 중복 체크 완료 후 아이디 고정
        return SignUpResponse(
            isDuplicate: false,
            isAvailable: true,
            message: response?.message ?? '');
      }
      // 응답이 null인 경우도 중복 체크는 완료된 것으로 처리
      isIdDuplicationChecked.value = true;
      return null;
    } catch (e) {
      // 에러 발생 시 중복 체크 완료 상태는 유지하지 않음
      return null;
    }
  }

  Future<bool> checkNicknameDuplication() async {
    try {
      final response = await apiService.checkDisplayName(
        displayName: name.value,
      );

      if (response) {
        return false; // 중복되지 않음
      }
      return true; // 중복됨
    } catch (e) {
      return true; // 에러 발생 시 중복으로 처리
    }
  }

  // 이메일 중복 체크
  Future<bool> checkEmailDuplication() async {
    try {
      final response = await apiClient.checkEmail(
        email: email.value,
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
    final response = await apiService.checkEmailMessage(
      email: email.value,
    );
    if (response?.isDuplicate == true) {
      return SignUpDuplicateModel(
          isDuplicate: true, message: response?.message ?? '');
    }
    return SignUpDuplicateModel(
        isDuplicate: false, message: response?.message ?? '');
  }

  // 이메일 인증 코드 요청
  Future<bool> emailAuth() async {
    try {
      //이메일 형식 검증
      // 이메일 인증 코드 요청 API 호출
      final response = await apiClient.sendAuthCode(
        email: email.value,
      );

      if (response?.data['statusCode'] == 200) {
        // 인증 코드 요청 성공
        showAuthCodeInput.value = true;
        emailSendAuthBtnStatus.value = false;
        // stopAuthCodeTimer();
        beforeEmailAuth.value = false;
        startAuthCodeTimer();
        EasyLoading.dismiss();
        return true;
      } else if (response?.data['statusCode'] == 429) {
        beforeEmailAuth.value = true;
        // 인증 코드 요청 실패 이전 코드 활성화
        reSendLimitMessage.value = response?.data['message'] ??
            'sign_up_email_auth_code_required_message'.tr;
        EasyLoading.dismiss();
        return false;
      } else {
        // 인증 코드 요청 실패
        debugPrint('sign_up_email_auth_send_error_message');
        emailSendAuthBtnStatus.value = true;
        beforeEmailAuth.value = false;
        EasyLoading.dismiss();
        return false;
      }
    } catch (e) {
      debugPrint('$e');
      EasyLoading.dismiss();
      return false;
    }
  }

  // response?.message ?? 'sign_up_email_auth_error_message'.tr

  // 인증 코드 입력 처리
  void onAuthCodeChanged(String value) {
    authCode.value = value;
    if (value.length == 6) {
      verifyAuthCode();
    }
  }

  // 인증 코드 검증
  Future<bool> verifyAuthCode() async {
    try {
      if (email.value.isEmpty || authCode.value.isEmpty) {
        debugPrint('sign_up_email_auth_code_required'.tr);
        return false;
      }

      final response = await apiClient.verifyAuthCode(
        email: email.value,
        authCode: authCode.value,
      );

      if (response?.data['statusCode'] == 200) {
        isEmailAuthValid.value = true;
        emailSendAuthBtnStatus.value = false;
        debugPrint('sign_up_email_auth_success_message'.tr);
        return true;
      } else {
        emailSendAuthBtnStatus.value = true;
        debugPrint('sign_up_email_auth_error_message'.tr);
        return false;
      }
    } catch (e) {
      debugPrint('$e');
      return false;
    }
  }

  String getBaseUrl() {
    final baseUrl = ApiDio.apiHostAppServer.replaceAll('/api/v1', '');
    return baseUrl;
  }

  String getUrlTerms() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/term-of-use';
  }

  String getUrlYouthProtectionPolicy() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/term-of-youth';
  }

  String getUrlMarketingPolicy() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/term-of-marketing';
  }

  String getUrlPrivacyPolicy() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/privacy-policy';
  }

  String getUrl() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/privacy-policy';
  }

  // 타이머 시작 함수
  void startAuthCodeTimer() {
    authCodeTimer.value = 600; // 10분
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
        showAuthCodeInput.value = false;

        // 시간 초과 시 처리
        if (!isEmailAuthValid.value) {
          EasyLoading.showError('인증 시간이 만료되었습니다. 다시 시도해주세요.');
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

  // LoginType 설정 메서드
  Future<void> setLoginType(LoginType type) async {
    loginType.value = type;
    // final result = await apiService.getAraServiceUserInfo();
    debugPrint('SignUp with LoginType: ${type.value}');
    // 로그인 타입에 따른 분기 처리 예정
  }

  void resetEmailAuth() {
    isEmailAuthValid.value = false;
    emailSendAuthBtnStatus.value = true;
    authCodeTimer.value = 180;
    authCodeTimerStatus.value = false;
    _authCodeTimer?.cancel();
    showAuthCodeInput.value = false;
    authCode.value = '';
    isAuthCodeValid.value = false;
  }

  void setUserInfo(UserData userInfo) {
    if (userInfo.userId.isNotEmpty) {
      id.value = userInfo.userId;
      isFixedId.value = true;
    }
    if (userInfo.email.isNotEmpty) {
      email.value = userInfo.email;
      isEmailAuthValid.value = true;
    }
    name.value = userInfo.userName;
    isIdChecked.value = true;
    phoneNumber.value = userInfo.phoneNumber;
    birthDate.value = userInfo.birthDate;

    if (userInfo.gender == 'MALE') {
      gender.value = true;
    } else if (userInfo.gender == 'FEMALE') {
      gender.value = false;
    } else {
      gender.value = null;
    }
    // gender.value = userInfo.gender;
    // isAdult.value = userInfo.isAdult;
  }
}

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpController());
  }
}
