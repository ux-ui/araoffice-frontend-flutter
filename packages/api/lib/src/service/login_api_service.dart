import 'package:api/api.dart';
import 'package:flutter/foundation.dart';

class LoginApiService {
  final LoginApiClient _apiClient;

  LoginApiService(this._apiClient);

  // Future<ProjectResult?> fetchProject(String projectId) async {
  //   try {
  //     final response = await _apiClient.fetchProject(projectId);

  //     if (response != null) {
  //       return ProjectResult.fromJson(response.toJson());
  //     }
  //     return null;
  //   } catch (e) {
  //     debugPrint('Error fetching project: $e');
  //     return null;
  //   }
  // }

  Future<Map<String, dynamic>?> logout() async {
    try {
      final response = await _apiClient.logout();

      return response;
    } catch (e) {
      debugPrint('Error logout : $e');
      return null;
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final response = await _apiClient.getUser();
      return response;
    } catch (e) {
      debugPrint('Error get User : $e');
      return null;
    }
  }

  Future<bool> updatePersonalInfoAgreement({
    required bool isPersonalInfoAgree,
  }) async {
    final response = await _apiClient.updatePersonalInfoAgreement(
      isPersonalInfoAgree: isPersonalInfoAgree,
    );
    if (response?.data["statusCode"] == 200) {
      return true;
    }
    return false;
  }

  Future<String?> getUserMarketingAgreement({
    required String userId,
  }) async {
    try {
      final response =
          await _apiClient.getUserMarketingAgreement(userId: userId);

      if (response?.data["statusCode"] == 200) {
        return response?.data["marketingTime"];
      }
      return null;
    } catch (e) {
      debugPrint('Error get User Marketing Agreement : $e');
      return null;
    }
  }

  Future<bool> updateUser({
    required String displayName,
    required String email,
    required String profileImage,
    required String shareId,
  }) async {
    try {
      final response = await _apiClient.updateUser(
        displayName: displayName,
        email: email,
        profileImage: profileImage,
        shareId: shareId,
      );

      if (response?.data["statusCode"] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error update User : $e');
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error change Password : $e');
      return false;
    }
  }

  Future<bool> checkUserId({
    required String userId,
  }) async {
    final response = await _apiClient.checkUserId(userId: userId);

    if (response?.data["statusCode"] == 200) {
      return true;
    }
    return false;
  }

  Future<SignUpDuplicateModel?> checkUserIdMessage({
    required String userId,
  }) async {
    final response = await _apiClient.checkUserId(userId: userId);

    if (response?.data["statusCode"] == 200) {
      return SignUpDuplicateModel.fromJson(response?.data);
    } else if (response?.data["statusCode"] == 400) {
      return SignUpDuplicateModel(
        isAvailable: false,
        isDuplicate: false,
        message: response?.data["data"],
      );
    }
    return null;
  }

  Future<bool> checkEmail({
    required String email,
  }) async {
    final response = await _apiClient.checkEmail(email: email);

    if (response?.data["isDuplicate"] == false) {
      return false;
    }
    return true;
  }

  Future<SignUpDuplicateModel?> checkEmailMessage({
    required String email,
  }) async {
    final response = await _apiClient.checkEmail(email: email);

    if (response?.data["statusCode"] == 200) {
      return SignUpDuplicateModel.fromJson(response?.data);
    }
    return null;
  }

  Future<bool> checkDisplayName({
    required String displayName,
  }) async {
    final response =
        await _apiClient.checkDisplayName(displayName: displayName);

    if (response?.data["statusCode"] == 200) {
      return true;
    }
    return false;
  }

  Future<SignUpDuplicateModel?> checkDisplayNameMessage({
    required String displayName,
  }) async {
    final response =
        await _apiClient.checkDisplayName(displayName: displayName);

    if (response?.data["statusCode"] == 200) {
      return SignUpDuplicateModel.fromJson(response?.data);
    }
    return null;
  }

  Future<bool> changeMarketingAgreement({
    required String userId,
    required bool isMarketingAgree,
  }) async {
    final response = await _apiClient.changeMarketingAgreement(
        userId: userId, isMarketingAgree: isMarketingAgree);

    if (response?.data["statusCode"] == 200) {
      return true;
    }
    return false;
  }

  Future<String?> lookupUserId({
    required String email,
  }) async {
    final response = await _apiClient.lookupUserId(email: email);

    if (response?.data["statusCode"] == 200) {
      return response?.data["userId"];
    } else if (response?.data["statusCode"] == 400) {
      return response?.data["data"];
    }
    return null;
  }

  Future<bool> lookupUserPasswordCheck({
    required String userId,
    required String email,
  }) async {
    final response =
        await _apiClient.lookupUserPasswordCheck(userId: userId, email: email);

    if (response?.data["statusCode"] == 200) {
      return true;
    }
    return false;
  }

  Future<bool> resetPassword({
    required String userId,
    required String email,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final response = await _apiClient.resetPassword(
        userId: userId,
        email: email,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm);

    if (response?.data["statusCode"] == 200) {
      return true;
    }
    return false;
  }

  Future<bool> signUp({
    required String userId, // id
    required String name,
    required String password,
    required String passwordConfirm,
    required String email,
    required String phoneNumber,
    required String birthDate,
    required bool gender,
    required bool isAdult,
    required bool isForeigner,
    required bool agreeTerms,
    required bool agreeMarketing,
    required bool agreePrivacy,
  }) async {
    try {
      final response = await _apiClient.signUp(
        userId: userId,
        name: name,
        password: password,
        passwordConfirm: passwordConfirm,
        email: email,
        phoneNumber: phoneNumber,
        gender: gender,
        birthDate: birthDate,
        isAdult: isAdult,
        isForeigner: isForeigner,
        agreeTerms: agreeTerms,
        agreeMarketing: agreeMarketing,
        agreePrivacy: agreePrivacy,
      );
      if (response?.data["statusCode"] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error signUp : $e');
      return false;
    }
  }

  Future<bool> araServiceLogin({
    required String userId,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await _apiClient.araServiceLogin(
        userId: userId, password: password, rememberMe: rememberMe);

    if (response?.data["statusCode"] == 200) {
      return true;
    }
    return false;
  }

  Future<AraLoginResponse?> checkAraServiceLogin({
    required String userId,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await _apiClient.araServiceLogin(
        userId: userId, password: password, rememberMe: rememberMe);

    if (response?.data["statusCode"] == 200) {
      return AraLoginResponse.fromJson(response?.data);
    }
    return null;
  }

  Future<LoginUserResponse?> getLoginToken() async {
    final response = await _apiClient.getLoginToken();

    if (response?.data["statusCode"] == 200) {
      return LoginUserResponse.fromJson(response?.data);
    }
    return null;
  }
}
