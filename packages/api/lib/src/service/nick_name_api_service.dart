import 'package:api/api.dart';
import 'package:flutter/foundation.dart';

class NickNameApiService {
  final NickNameApiClient _apiClient;

  NickNameApiService(this._apiClient);

  /// 고유한 닉네임 생성 (중복 체크 포함)
  Future<NicknameResponse?> generateUniqueNickname() async {
    try {
      final response = await _apiClient.generateUniqueNickname();

      if (response.statusCode == 200 && response.data != null) {
        return NicknameResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error generating unique nickname: $e');
      return null;
    }
  }

  /// 랜덤 닉네임 생성 (중복 체크 없음)
  Future<NicknameResponse?> generateRandomNickname() async {
    try {
      final response = await _apiClient.generateRandomNickname();

      if (response.statusCode == 200 && response.data != null) {
        return NicknameResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error generating random nickname: $e');
      return null;
    }
  }

  /// 닉네임 재생성
  Future<NicknameResponse?> regenerateNickname() async {
    try {
      final response = await _apiClient.regenerateNickname();

      if (response.statusCode == 200 && response.data != null) {
        return NicknameResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error regenerating nickname: $e');
      return null;
    }
  }

  /// 닉네임 중복 확인
  Future<NicknameDuplicateCheckResponse?> checkNicknameDuplicate({
    required String nickname,
  }) async {
    try {
      final response = await _apiClient.checkNicknameDuplicate(
        nickname: nickname,
      );

      if (response.statusCode == 200 && response.data != null) {
        return NicknameDuplicateCheckResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error checking nickname duplicate: $e');
      return null;
    }
  }

  /// 닉네임 중복 여부만 확인 (간단한 버전)
  Future<bool?> isNicknameDuplicate({
    required String nickname,
  }) async {
    try {
      final response = await checkNicknameDuplicate(nickname: nickname);
      return response?.isDuplicate;
    } catch (e) {
      debugPrint('Error checking nickname duplicate: $e');
      return null;
    }
  }

  /// 여러 닉네임 후보 생성 (중복 체크 없음)
  Future<NicknameCandidatesResponse?> generateNicknameCandidates({
    int count = 5,
  }) async {
    try {
      // 최대 개수 제한
      if (count > 20) count = 20;
      if (count < 1) count = 1;

      final response = await _apiClient.generateNicknameCandidates(
        count: count,
      );

      if (response.statusCode == 200 && response.data != null) {
        return NicknameCandidatesResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error generating nickname candidates: $e');
      return null;
    }
  }

  /// 여러 고유 닉네임 후보 생성 (중복 체크 포함)
  Future<NicknameCandidatesResponse?> generateUniqueNicknameCandidates({
    int count = 5,
  }) async {
    try {
      // 최대 개수 제한
      if (count > 20) count = 20;
      if (count < 1) count = 1;

      final response = await _apiClient.generateUniqueNicknameCandidates(
        count: count,
      );

      if (response.statusCode == 200 && response.data != null) {
        return NicknameCandidatesResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error generating unique nickname candidates: $e');
      return null;
    }
  }

  /// 고유한 shareId 생성 (중복 체크 포함)
  Future<NicknameResponse?> generateUniqueShareId({
    String? baseShareId,
  }) async {
    try {
      final response = await _apiClient.generateUniqueShareId(
        baseShareId: baseShareId,
      );

      if (response.statusCode == 200 && response.data != null) {
        return NicknameResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error generating unique shareId: $e');
      return null;
    }
  }

  /// 여러 고유 shareId 후보 생성 (중복 체크 포함)
  Future<NicknameCandidatesResponse?> generateUniqueShareIdCandidates({
    int count = 5,
  }) async {
    try {
      // 최대 개수 제한
      if (count > 20) count = 20;
      if (count < 1) count = 1;

      final response = await _apiClient.generateUniqueShareIdCandidates(
        count: count,
      );

      if (response.statusCode == 200 && response.data != null) {
        return NicknameCandidatesResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error generating unique shareId candidates: $e');
      return null;
    }
  }
}

