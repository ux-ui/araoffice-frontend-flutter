import '../../api.dart';

class NickNameApiClient {
  final ApiDio _dio;
  NickNameApiClient(this._dio);

  /// 고유한 닉네임 생성 (중복 체크 포함)
  Future<ApiResponse> generateUniqueNickname() async {
    return await _dio.get('/nickname/generate');
  }

  /// 랜덤 닉네임 생성 (중복 체크 없음)
  Future<ApiResponse> generateRandomNickname() async {
    return await _dio.get('/nickname/random');
  }

  /// 닉네임 재생성
  Future<ApiResponse> regenerateNickname() async {
    return await _dio.get('/nickname/regenerate');
  }

  /// 닉네임 중복 확인
  Future<ApiResponse> checkNicknameDuplicate({
    required String nickname,
  }) async {
    return await _dio.post(
      '/nickname/check',
      queryParameters: {
        'nickname': nickname,
      },
    );
  }

  /// 여러 닉네임 후보 생성 (중복 체크 없음)
  Future<ApiResponse> generateNicknameCandidates({
    int count = 5,
  }) async {
    return await _dio.get(
      '/nickname/candidates',
      queryParameters: {
        'count': count,
      },
    );
  }

  /// 여러 고유 닉네임 후보 생성 (중복 체크 포함)
  Future<ApiResponse> generateUniqueNicknameCandidates({
    int count = 5,
  }) async {
    return await _dio.get(
      '/nickname/candidates/unique',
      queryParameters: {
        'count': count,
      },
    );
  }

  /// 고유한 shareId 생성 (중복 체크 포함)
  Future<ApiResponse> generateUniqueShareId({
    String? baseShareId,
  }) async {
    return await _dio.get(
      '/nickname/shareid/generate',
      queryParameters: baseShareId != null
          ? {
              'baseShareId': baseShareId,
            }
          : null,
    );
  }

  /// 여러 고유 shareId 후보 생성 (중복 체크 포함)
  Future<ApiResponse> generateUniqueShareIdCandidates({
    int count = 5,
  }) async {
    return await _dio.get(
      '/nickname/shareid/candidates',
      queryParameters: {
        'count': count,
      },
    );
  }
}
