import '../entities/user_info.dart';

abstract class AuthRepository {
  /// 이메일과 비밀번호로 로그인합니다.
  Future<UserInfo> loginWithEmail({
    required String email,
    required String password,
  });

  /// 구글 계정으로 로그인합니다.
  Future<UserInfo> loginWithGoogle();

  /// 로그아웃합니다.
  Future<void> logout();

  /// 회원가입합니다.
  Future<UserInfo> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// 비밀번호를 변경합니다.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// 비밀번호를 잊어버렸을 때, 새로운 비밀번호를 설정합니다.
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });

  /// 회원 정보를 업데이트합니다.
  Future<UserInfo> updateUserInfo({
    required String name,
    required String profileImage,
  });

  /// 회원 정보를 가져옵니다.
  Future<UserInfo> fetchUserInfo();
}