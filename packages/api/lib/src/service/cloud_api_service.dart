import 'package:api/api.dart';
import 'package:flutter/foundation.dart';

class CloudApiService {
  final CloudApiClient _apiClient;

  CloudApiService(this._apiClient);

  /// 네이버웍스 액세스 토큰 조회
  Future<String?> getNaverWorksToken() async {
    try {
      final response = await _apiClient.getNaverWorksToken();
      if (response != null && response.isSuccessful) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          var accessToken = responseData['accessToken'];
          if (accessToken == null) {
            final result = responseData['data'];
            if (result is Map<String, dynamic>) {
              accessToken = result['accessToken'];
              return accessToken;
            }
          }
          return accessToken;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting NaverWorks token: $e');
      return null;
    }
  }

  /// 네이버웍스 액세스 토큰 조회 (302 응답 처리 없이 직접 호출)
  Future<String?> getNaverWorksTokenNoRedirect() async {
    try {
      final response = await _apiClient.getNaverWorksTokenNoRedirect();
      if (response != null && response.isSuccessful) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          var accessToken = responseData['accessToken'];
          // final provider = responseData['provider']; // "naverworks"
          // final providerId = responseData['providerId']; // ""
          // final userId = responseData['userId']; // "user5"
          if (accessToken == null) {
            final result = responseData['data'];
            if (result is Map<String, dynamic>) {
              accessToken = result['accessToken'];
              return accessToken;
            }
          }
          return accessToken;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting NaverWorks token: $e');
      return null;
    }
  }

  /// 클라우드 파일 목록 조회
  Future<CloudFileListResult?> fetchCloudFiles({
    required CloudType cloudType,
    String? folderId,
    String? cursor,
    int limit = 50,
    String? orderBy,
  }) async {
    try {
      final response = await _apiClient.fetchCloudFiles(
        cloudType: cloudType,
        folderId: folderId,
        cursor: cursor,
        limit: limit,
        orderBy: orderBy,
      );

      if (response != null && response.isSuccessful) {
        final responseData = response.data;
        debugPrint(
            '###@@@ fetchCloudFiles service response: ${response.statusCode}');
        debugPrint(
            '###@@@ fetchCloudFiles service response data: ${responseData.toString()}');

        if (responseData is Map<String, dynamic>) {
          final result = responseData['data'];
          if (result is Map<String, dynamic>) {
            final cloudFileListResult = CloudFileListResult.fromJson(result);
            return cloudFileListResult;
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('###@@@ fetchCloudFiles service error: $e');
      debugPrint('Error fetching cloud files: $e');
      return null;
    }
  }

  /// 클라우드 파일 검색
  /// TODO: 검색 API 추가해야 함. 20251119.
  Future<CloudFileListResult?> searchCloudFiles({
    required CloudType cloudType,
    required String query,
    String? cursor,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.searchCloudFiles(
        cloudType: cloudType,
        query: query,
        cursor: cursor,
        limit: limit,
      );

      if (response != null && response.isSuccessful) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final result = responseData['data'];
          if (result is Map<String, dynamic>) {
            final cloudFileListResult = CloudFileListResult.fromJson(result);
            return cloudFileListResult;
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error searching cloud files: $e');
      return null;
    }
  }

  /// 네이버웍스 다운로드 URL을 백엔드 세션을 통해 조회합니다 (세션 기반)
  /// Flutter -> Backend (세션에서 토큰 자동 조회) -> NaverWorks API -> Backend -> Flutter 흐름
  /// [fileId] 네이버웍스 파일 ID
  /// 성공 시 다운로드 URL을 포함한 NaverWorksDownloadUrlResponse를 반환합니다.
  Future<NaverWorksDownloadUrlResponse?> getNaverWorksDownloadUrl({
    required String fileId,
  }) async {
    try {
      // 세션 기반 요청 데이터 생성 (토큰 없이)
      final requestData = {
        'fileId': fileId,
      };

      // API 클라이언트를 통해 백엔드에 요청 (세션 기반 엔드포인트)
      final response = await _apiClient.getNaverWorksDownloadUrl(requestData);

      if (response != null && response.isSuccessful) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          final naverWorksResponse = NaverWorksDownloadUrlResponse.fromJson(
            responseData['data'],
            responseData['message'],
          );
          return naverWorksResponse;
        } else {
          debugPrint('네이버웍스 응답 데이터 형식 오류 (세션 기반): ${responseData.runtimeType}');
          return null;
        }
      } else {
        debugPrint('네이버웍스 다운로드 URL API 호출 실패 (세션 기반)');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting NaverWorks download URL from session: $e');
      return null;
    }
  }

  Future<ApiResponse?> get302ErrorResponse() async {
    return await _apiClient.get302ErrorResponse();
  }

  Future<ApiResponse?> get200ErrorResponse() async {
    return await _apiClient.get200ErrorResponse();
  }

  /// IOP 다운로드 URL 조회
  /// [fileId] IOP 파일 ID (선택)
  /// [downloadUrl] IOP 다운로드 URL (선택)
  /// [accessKey] IOP 액세스키 (선택)
  Future<IopDownloadUrlResponse?> getIopDownloadUrl({
    String? fileId,
    String? downloadUrl,
    String? accessKey,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      
      // Case 1: fileId로 조회
      if (fileId != null && fileId.isNotEmpty) {
        requestData['fileId'] = fileId;
      }
      // Case 2: downloadUrl 직접 전달
      else if (downloadUrl != null && downloadUrl.isNotEmpty) {
        requestData['downloadUrl'] = downloadUrl;
        if (accessKey != null) {
          requestData['accessKey'] = accessKey;
        }
      } else {
        debugPrint('fileId 또는 downloadUrl이 필요합니다');
        return null;
      }
      
      final response = await _apiClient.getIopDownloadUrl(requestData);
      
      if (response != null && response.isSuccessful) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          final iopResponse = IopDownloadUrlResponse.fromJson(
            responseData['data'],
            responseData['message'],
          );
          return iopResponse;
        } else {
          debugPrint('IOP 응답 데이터 형식 오류: ${responseData.runtimeType}');
          return null;
        }
      } else {
        debugPrint('IOP 다운로드 URL API 호출 실패');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting IOP download URL: $e');
      return null;
    }
  }

  /// 클라우드 연결 상태 확인
  // Future<CloudConnectionResult?> checkCloudConnection(
  //     CloudType cloudType) async {
  //   try {
  //     final response = await _apiClient.checkCloudConnection(cloudType);

  //     if (response != null) {
  //       final result = ApiResponse.fromJson(response.data);
  //       return CloudConnectionResult.fromJson(result.data);
  //     }

  //     return CloudConnectionResult(
  //       statusCode: response?.statusCode ?? 500,
  //       message: response?.data['message'] ?? 'Connection check failed',
  //       connected: false,
  //     );
  //   } catch (e) {
  //     debugPrint('Error checking cloud connection: $e');
  //     return CloudConnectionResult(
  //       statusCode: 500,
  //       message: 'Connection check failed: $e',
  //       connected: false,
  //     );
  //   }
  // }

  // Future<bool> downloadFile(String downloadUrl, String fileName) async {
  //   final response = await _apiClient.downloadFile(downloadUrl, fileName);
  //   if (response != null && response.isSuccessful) {
  //     return true;
  //   }
  //   return false;
  // }

  /// 파일 이름 변경
  // Future<CloudFileListResult?> renameFile({
  //   required CloudType cloudType,
  //   required String fileId,
  //   required String newName,
  // }) async {
  //   try {
  //     final response = await _apiClient.renameFile(
  //       cloudType: cloudType,
  //       fileId: fileId,
  //       newName: newName,
  //     );

  //     if (response != null) {
  //       final result = ApiResponse.fromJson(response.data);
  //       return CloudFileListResult.fromJson(result.data);
  //     }

  //     return null;
  //   } catch (e) {
  //     debugPrint('Error renaming file: $e');
  //     return null;
  //   }
  // }

  /// 파일 삭제
  // Future<bool> deleteFile({
  //   required CloudType cloudType,
  //   required String fileId,
  // }) async {
  //   try {
  //     final response = await _apiClient.deleteFile(
  //       cloudType: cloudType,
  //       fileId: fileId,
  //     );

  //     return response != null;
  //   } catch (e) {
  //     debugPrint('Error deleting file: $e');
  //     return false;
  //   }
  // }

  /// 폴더 생성
  // Future<CloudFileListResult?> createFolder({
  //   required CloudType cloudType,
  //   required String folderName,
  //   String? parentFolderId,
  // }) async {
  //   try {
  //     final response = await _apiClient.createFolder(
  //       cloudType: cloudType,
  //       folderName: folderName,
  //       parentFolderId: parentFolderId,
  //     );

  //     if (response != null) {
  //       final result = ApiResponse.fromJson(response.data);
  //       return CloudFileListResult.fromJson(result.data);
  //     }

  //     return null;
  //   } catch (e) {
  //     debugPrint('Error creating folder: $e');
  //     return null;
  //   }
  // }

  /// 파일 업로드
  // Future<CloudFileListResult?> uploadFile({
  //   required CloudType cloudType,
  //   required String fileName,
  //   required List<int> fileBytes,
  //   String? parentFolderId,
  //   String? fileType,
  // }) async {
  //   try {
  //     final response = await _apiClient.uploadFile(
  //       cloudType: cloudType,
  //       fileName: fileName,
  //       fileBytes: fileBytes,
  //       parentFolderId: parentFolderId,
  //       fileType: fileType,
  //     );

  //     if (response != null) {
  //       final result = ApiResponse.fromJson(response.data);
  //       return CloudFileListResult.fromJson(result.data);
  //     }

  //     return null;
  //   } catch (e) {
  //     debugPrint('Error uploading file: $e');
  //     return null;
  //   }
  // }

  /// 네이버웍스 OAuth 인증 URL 조회
  // Future<String?> getNaverWorksAuthUrl() async {
  //   try {
  //     final response = await _apiClient.getNaverWorksAuthUrl();

  //     if (response != null) {
  //       final result = ApiResponse.fromJson(response.data);
  //       if (result.data is Map<String, dynamic> &&
  //           result.data['authUrl'] != null) {
  //         return result.data['authUrl'] as String;
  //       }
  //     }

  //     return null;
  //   } catch (e) {
  //     debugPrint('Error getting NaverWorks auth URL: $e');
  //     return null;
  //   }
  // }

  /// 네이버웍스 OAuth 콜백 처리
  // Future<bool> handleNaverWorksCallback({
  //   required String code,
  //   required String state,
  // }) async {
  //   try {
  //     final response = await _apiClient.handleNaverWorksCallback(
  //       code: code,
  //       state: state,
  //     );

  //     return response != null;
  //   } catch (e) {
  //     debugPrint('Error handling NaverWorks callback: $e');
  //     return false;
  //   }
  // }

  /// 네이버웍스 연결 해제
  // Future<bool> disconnectNaverWorks() async {
  //   try {
  //     final response = await _apiClient.disconnectNaverWorks();

  //     return response != null;
  //   } catch (e) {
  //     debugPrint('Error disconnecting NaverWorks: $e');
  //     return false;
  //   }
  // }

  /// 네이버웍스 연결 상태만 확인 (간편 메서드)
  // Future<bool> isNaverWorksConnected() async {
  //   final result = await checkCloudConnection(CloudType.works);
  //   return result?.connected ?? false;
  // }
}
