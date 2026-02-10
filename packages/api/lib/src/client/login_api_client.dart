import 'package:flutter/material.dart';

import '../../api.dart';

class LoginApiClient {
  final ApiDio _dio;
  LoginApiClient(this._dio);

  // Future<bool> login({
  //   required String userId,
  //   required String password,
  // }) async {
  //   final result = await _dio.post(
  //     '/login',
  //     data: {
  //       'userId': userId,
  //       'password': password,
  //     },
  //   );

  //   if (result.isError) {
  //     return false;
  //   }

  //   return true;
  // }

  // Future<Map<String, dynamic>?> login({
  //   required String userId,
  //   required String password,
  // }) async {
  //   final result = await _dio.post('/login',
  //       data: {
  //         'userId': userId,
  //         'password': password,
  //       },
  //       loginErrorHandling: true);

  //   if (result.isError) {
  //     return null;
  //   }

  //   return [result.data['data'], result.data['message']];
  // }

  Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await _dio.post('/login', data: {
        'userId': userId,
        'password': password,
        'rememberMe': rememberMe,
      });

      if (response.statusCode == 200) {
        final result = response.data;
        final Map<String, dynamic> processedData = {
          'result': true,
          'message': result['message'],
        };
        return processedData;
      } else if (response.statusCode == 441) {
        final result = response.data;
        final Map<String, dynamic> processedData = {
          'result': false,
          'message': result['message'],
        };
        return processedData;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<ApiResponse?> updateUser({
    required String displayName,
    required String email,
    required String profileImage,
    required String shareId,
  }) async =>
      await _dio.patch('/user', data: {
        'displayName': displayName,
        'email': email,
        'profileImage': profileImage,
        'shareId': shareId,
      });

  Future<Map<String, dynamic>?> logout() async {
    try {
      final result = await _dio.get('/logout');

      if (result.isError) {
        return null;
      }

      // 백엔드에서 JSON 응답을 반환하럼겨 그대로 전달
      return result.data;
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkSession() async {
    final result = await _dio.get('/check-session');

    if (result.isError) {
      return false;
    }

    return true;
  }

  Future<String?> checkLoginStatus() async {
    final result = await _dio.get('/users');

    if (result.isError) {
      return null;
    }

    return result.data['data'];
  }

  // Future<bool> checkSecurity() async {
  //   final result = await _dio.get('/check-security');

  //   if (result.isError) {
  //     return false;
  //   }

  //   return true;
  // }

  Future<UserModel?> userInfo() async {
    try {
      final response = await _dio.get('/user');
      if (response.statusCode == 200) {
        if (response.data['user'] != null) {
          return UserModel.fromJson(response.data['user']);
        } else if (response.data['user'] == null) {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
      return null;
    }
    return null;
  }

  Future<ApiResponse?> getUserMarketingAgreement({
    required String userId,
  }) async {
    final result = await _dio.get(
      '/marketing/$userId',
      // queryParameters: {'userId': userId}, useAuthDio: true
    );
    return result;
  }

  Future<ApiResponse?> updatePersonalInfoAgreement({
    required bool isPersonalInfoAgree,
  }) async =>
      await _dio.post('/user/personal-info-agreement', data: {
        'agreePersonalInfo': isPersonalInfoAgree,
      });

  // Future<ApiResponse?> getUser() async {
  //   final result = await _dio.get('/user');
  //   final response = ApiResponse.fromJson(result.toJson());
  //   logger.d('데이터확인 : --------- ${response.toString()}');
  //   return result;
  // }

  Future<UserModel?> getUser() async {
    final result = await _dio.get('/user');
    final data = result.data;
    if (data == null || data is! Map<String, dynamic>) {
      return null;
    }
    final userData = data['user'];
    if (userData == null || userData is! Map<String, dynamic>) {
      return null;
    }
    return UserModel.fromJson(userData);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final result = await _dio.patch('/user/pwd', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });

    if (result.isError) {
      return false;
    }

    return true;
  }

  Future<ApiResponse> changePasswordData({
    required String currentPassword,
    required String newPassword,
  }) async =>
      await _dio.patch(
        '/user/pwd',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

  Future<ApiResponse?> checkUserId({
    required String userId,
  }) async =>
      await _dio.post('/check/userid', queryParameters: {
        'userId': userId,
      });

  Future<ApiResponse?> checkEmail({
    required String email,
  }) async =>
      await _dio.post('/check/email', queryParameters: {
        'email': email,
      });

  Future<ApiResponse?> checkDisplayName({
    required String displayName,
  }) async =>
      await _dio.post('/check/displayname', queryParameters: {
        'displayName': displayName,
      });

  Future<ApiResponse?> changeMarketingAgreement({
    required String userId,
    required bool isMarketingAgree,
  }) async =>
      await _dio.post('/marketing/$userId', queryParameters: {
        'marketingAgree': isMarketingAgree,
      });

  Future<ApiResponse?> sendAuthCode({
    required String email,
  }) async =>
      await _dio.post('/email/send-verification', data: {
        'email': email,
      });

  Future<ApiResponse?> verifyAuthCode({
    required String email,
    required String authCode,
  }) async =>
      await _dio.post('/email/verify-code', data: {
        'email': email,
        'code': authCode,
      });

  Future<ApiResponse?> lookupUserId({
    required String email,
  }) async =>
      await _dio.post('/auth/lookup/userid', data: {
        'email': email,
      });

  Future<ApiResponse?> lookupUserPasswordCheck({
    required String userId,
    required String email,
  }) async =>
      await _dio.post('/auth/lookup/password', data: {
        'userId': userId,
        'email': email,
      });

  Future<ApiResponse?> resetPassword({
    required String userId,
    required String email,
    required String newPassword,
    required String newPasswordConfirm,
  }) async =>
      await _dio.patch('/auth/password', data: {
        'userId': userId,
        'email': email,
        'newPassword': newPassword,
        'newPasswordConfirm': newPasswordConfirm,
      });

  Future<ApiResponse?> signUp({
    required String userId, // id
    required String name,
    required String password,
    required String passwordConfirm,
    required String email,
    required String phoneNumber,
    required bool gender,
    required String birthDate,
    required bool isAdult,
    required bool isForeigner,
    required bool agreeTerms,
    required bool agreeMarketing,
    required bool agreePrivacy,
  }) async =>
      await _dio.post(
        '/register',
        data: {
          'userId': userId,
          'displayName': name,
          'password': password,
          'passwordConfirm': passwordConfirm,
          'email': email,
          'phone': phoneNumber,
          'gender': gender,
          'birthDate': birthDate,
          'isAdult': isAdult,
          'isForeigner': isForeigner,
          'agreeTerms': agreeTerms,
          'agreeMarketing': agreeMarketing,
          'agreePrivacy': agreePrivacy,
        },
      );

  Future<ApiResponse?> araServiceLogin({
    required String userId,
    required String password,
    required bool rememberMe,
  }) async =>
      await _dio.post('/ara/login', data: {
        'userId': userId,
        'password': password,
        'rememberMe': rememberMe,
      });

  Future<ApiResponse?> getAraServiceUserInfo() async =>
      await _dio.get('/ara/user-info');

  // 네이버 로그인 처리 (브라우저 리다이렉트)
  Future<bool> naverLogin() async {
    // 네이버 OAuth2 인증 URL
    // 실제로는 url_launcher로 브라우저에서 열어야 함
    // 여기서는 URL만 반환
    return true;
  }

  Future<ApiResponse?> getLoginToken() async => await _dio.get('/auth/token');

  /// 현재 사용자의 액세스 토큰 정보 조회
  Future<ApiResponse?> getUserAccessToken() async =>
      await _dio.get('/auth/token');
}
