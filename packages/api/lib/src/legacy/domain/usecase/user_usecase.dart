import 'package:api/src/legacy/domain/entities/user_info.dart';
import 'package:api/src/legacy/domain/repository/auth_repository.dart';
import 'package:rxdart/subjects.dart';

class UserUsecase {
  final AuthRepository _authRepository;

  /// 현재 로그인한 사용자 정보
  BehaviorSubject<UserInfo?> currentUser = BehaviorSubject.seeded(null);

  UserUsecase(this._authRepository);

  Future<void> loadUserInfo() async {
    currentUser.add(await _authRepository.fetchUserInfo());
  }

  Future<void> logout() async {
    await _authRepository.logout();
    currentUser.add(null);
  }

  Future<UserInfo> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _authRepository.loginWithEmail(
      email: email,
      password: password,
    );
  }
}
