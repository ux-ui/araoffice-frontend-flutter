import 'package:api/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CloudApiClient {
  late final ApiDio _apiDio;

  late final Dio _dio;
  static final String _baseUrl = ApiDio.apiHostAppServer;
  // static const String _prefix = 'worksapi';

  CloudApiClient(this._apiDio) {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      // baseUrl을 비워두어 모든 도메인에 요청 가능하도록 설정
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 로그 인터셉터 추가 (디버깅용)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('NaverWorks API: $obj'),
      ),
    );

    // 인터셉터 추가 - 자동으로 액세스 토큰 헤더 추가
    // _dio.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (options, handler) async {
    //       try {
    //         // 네이버웍스 관련 도메인인지 확인 (스토리지 서버 포함)
    //         final isNaverWorksRequest =
    //             options.uri.host.contains('worksapis.com') ||
    //                 options.uri.host.contains('worksmobile.com') ||
    //                 options.uri.host.contains('apis-storage.worksmobile.com');

    //         if (!isNaverWorksRequest) {
    //           // debugPrint('비-네이버웍스 요청 - 토큰 생략: ${options.uri}');
    //           handler.next(options);
    //           return;
    //         }

    //         // 로그인 토큰 가져오기
    //         try {
    //           final loginClient = LoginApiClient(_apiDio);
    //           final tokenResponse = await loginClient.getLoginToken();

    //           if (tokenResponse != null && !tokenResponse.isError) {
    //             final tokenData = tokenResponse.data;
    //             if (tokenData != null && tokenData['accessToken'] != null) {
    //               // Authorization 헤더에 Bearer 토큰 추가
    //               options.headers['Authorization'] =
    //                   'Bearer ${tokenData['accessToken']}';
    //               options.headers['Access-Control-Allow-Origin'] = '*';
    //               options.headers['Access-Control-Allow-Credentials'] = 'true';
    //               debugPrint('클라우드 API 토큰 설정 완료: ${options.uri}');
    //             } else {
    //               debugPrint('토큰 데이터가 없습니다: $tokenData');
    //             }
    //           } else {
    //             debugPrint('토큰 조회 실패: ${tokenResponse?.message}');
    //           }
    //         } catch (tokenError) {
    //           debugPrint('토큰 조회 중 오류 발생: $tokenError');
    //           // 토큰 없어도 요청은 계속 진행 (서버에서 처리)
    //         }
    //       } catch (e) {
    //         debugPrint('네이버웍스 토큰 설정 실패: $e');
    //         // 에러가 발생해도 요청은 계속 진행
    //       }

    //       handler.next(options);
    //     },
    //     onError: (error, handler) {
    //       debugPrint('네이버웍스 API 에러: ${error.message}');
    //       debugPrint('에러 응답: ${error.response}');
    //       debugPrint('요청 URL: ${error.requestOptions.uri}');
    //       if (error.response?.statusCode == 401) {
    //         debugPrint('네이버웍스 토큰 만료 - 재로그인 필요');
    //       } else if (error.response?.statusCode == 404) {
    //         debugPrint('네이버웍스 API 엔드포인트가 존재하지 않습니다');
    //       }
    //       handler.next(error);
    //     },
    //   ),
    // );
  }

  /////////////////////////////////////////////////////////
  // _apiDio 사용하는 api
  /////////////////////////////////////////////////////////

  /// 네이버웍스 액세스 토큰 조회
  Future<ApiResponse?> getNaverWorksToken() async {
    try {
      final response = await _apiDio.get('/token/naverworks');
      debugPrint(
          '###@@@ Call Cloud Api Client: getNaverWorksToken: response: $response');
      return response;
    } catch (e) {
      debugPrint('Error getting NaverWorks token: $e');
      return null;
    }
  }

  /// 네이버웍스 파일 목록 조회
  Future<ApiResponse?> fetchCloudFiles({
    required CloudType cloudType,
    String? folderId,
    String? cursor,
    int limit = 50,
    String? orderBy,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'count': limit,
      };

      if (folderId != null) {
        queryParameters['parentFileId'] = folderId;
      }

      if (cursor != null && cursor.isNotEmpty) {
        queryParameters['cursor'] = cursor;
      }

      if (orderBy != null) {
        queryParameters['orderBy'] = orderBy;
      }

      final response = await _apiDio.get(
        '/worksapi/users/me/drive/files',
        queryParameters: queryParameters,
      );
      debugPrint(
          '###@@@ Call Cloud Api Client: fetchCloudFiles: response: $response');
      return response;
    } catch (e) {
      debugPrint('###@@@ fetchCloudFiles client error: $e');
      debugPrint('Error fetching cloud files: $e');
      return null;
    }
  }

  /// 네이버웍스 파일 검색
  /// TODO: 검색 API 추가해야 함. 20251119.
  Future<ApiResponse?> searchCloudFiles({
    required CloudType cloudType,
    required String query,
    String? cursor,
    int limit = 50,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'query': query,
        'count': limit,
      };

      if (cursor != null && cursor.isNotEmpty) {
        queryParameters['cursor'] = cursor;
      }

      final response = await _apiDio.get(
        '/worksapi/users/me/drive/files/search', // TODO: 검색 API 추가해야 함
        queryParameters: queryParameters,
      );
      debugPrint(
          '###@@@ Call Cloud Api Client: searchCloudFiles: response: $response');
      return response;
    } catch (e) {
      debugPrint('Error searching cloud files: $e');
      return null;
    }
  }

  /// 네이버웍스 다운로드 URL을 백엔드를 통해 조회합니다 (기존 방식).
  /// Flutter -> Backend -> NaverWorks API -> Backend -> Flutter 흐름
  /// [requestData] 네이버웍스 다운로드 URL 요청 데이터
  // Future<ApiResponse?> getNaverWorksDownloadUrl(
  //         Map<String, String> requestData) async =>
  //     await _apiDio.post(
  //       '/naver-works/download-url',
  //       data: requestData,
  //       useAuthDio: true,
  //     );

  Future<ApiResponse?> getNaverWorksDownloadUrl(
      Map<String, String> requestData) async {
    try {
      final response = await _apiDio.post(
        '/naver-works/download-url',
        data: requestData,
        useAuthDio: true,
      );
      debugPrint(
          '###@@@ Call Cloud Api Client: getNaverWorksDownloadUrl: response: $response');
      return response;
    } catch (e) {
      debugPrint(
          '###@@@ Call Cloud Api Client: getNaverWorksDownloadUrl: error: $e');
      return null;
    }
  }

  Future<ApiResponse?> get302ErrorResponse() async {
    try {
      final response = await _apiDio.get('/naverworks/mock/302302');
      return response;
    } catch (e) {
      debugPrint('Error getting 302: 302 error response: $e');
      return null;
    }
  }

  Future<ApiResponse?> get200ErrorResponse() async {
    try {
      final response = await _apiDio.get('/naverworks/mock/200302');
      return response;
    } catch (e) {
      debugPrint('Error getting 200: 302 error response: $e');
      return null;
    }
  }

  /// IOP 다운로드 URL 조회
  Future<ApiResponse?> getIopDownloadUrl(
      Map<String, dynamic> requestData) async {
    try {
      final response = await _apiDio.post(
        '/iop/download-url',
        data: requestData,
        useAuthDio: true,
      );
      debugPrint(
          '###@@@ Call Cloud Api Client: getIopDownloadUrl: response: $response');
      return response;
    } catch (e) {
      debugPrint(
          '###@@@ Call Cloud Api Client: getIopDownloadUrl: error: $e');
      return null;
    }
  }

  // Future<ApiResponse?> downloadFile(String downloadUrl, String fileName) async {
  //   try {
  //     final response = await _apiDio.download(
  //       path: downloadUrl,
  //       fileName: fileName,
  //       fileType: '',
  //     );
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error getting file download URL: $e');
  //     return null;
  //   }
  // }

  /// 파일 다운로드 URL 조회
  // Future<ApiResponse?> downloadFileFromUrl({
  //   required CloudType cloudType,
  //   required String fileId,
  // }) async {
  //   try {
  //     final response = await _apiDio.get(
  //       'files/$fileId/download-url',
  //     );
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error getting file download URL: $e');
  //     return null;
  //   }
  // }

  /////////////////////////////////////////////////////////
  // _dio 사용하는 api
  /////////////////////////////////////////////////////////

  /// 네이버웍스 액세스 토큰 조회 (302 응답 처리 없이 직접 호출)
  Future<ApiResponse?> getNaverWorksTokenNoRedirect() async {
    try {
      final response = await _dio.get('/token/naverworks');
      final apiResponse = ApiResponse.fromResponse(response);
      debugPrint(
          '###@@@ Call Cloud Api Client: getNaverWorksToken: response: $apiResponse');
      return apiResponse;
    } catch (e) {
      debugPrint('Error getting NaverWorks token: $e');
      return null;
    }
  }

  /// 클라우드 연결 상태 확인
  // Future<Response?> checkCloudConnection(CloudType cloudType) async {
  //   try {
  //     final response = await _dio.get('/cloud/${cloudType.value}/connection');
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error checking cloud connection: $e');
  //     return null;
  //   }
  // }

  /// 클라우드 파일 목록 조회
  // Future<Response?> fetchCloudFiles({
  //   required CloudType cloudType,
  //   String? folderId,
  //   String? cursor,
  //   int limit = 50,
  //   String? orderBy,
  // }) async {
  //   try {
  //     final Map<String, dynamic> queryParameters = {
  //       'limit': limit,
  //     };

  //     if (folderId != null) {
  //       queryParameters['folderId'] = folderId;
  //     }

  //     if (cursor != null && cursor.isNotEmpty) {
  //       queryParameters['cursor'] = cursor;
  //     }

  //     if (orderBy != null) {
  //       queryParameters['orderBy'] = orderBy;
  //     }

  //     final response = await _dio.get(
  //       //'/cloud/${cloudType.value}/files',
  //       '/users/me/drive/files',
  //       //queryParameters: queryParameters,
  //     );
  //     return response;
  //   } catch (e) {
  //     debugPrint('###@@@ fetchCloudFiles client error: $e');
  //     debugPrint('Error fetching cloud files: $e');
  //     return null;
  //   }
  // }

  /// 특정 폴더의 하위 파일 조회
  // Future<Response?> fetchFolderFiles({
  //   required CloudType cloudType,
  //   required String folderId,
  //   String? cursor,
  //   int limit = 50,
  //   String? orderBy,
  // }) async {
  //   try {
  //     final Map<String, dynamic> queryParameters = {
  //       'cursor': cursor,
  //       'limit': limit,
  //     };

  //     if (orderBy != null) {
  //       queryParameters['orderBy'] = orderBy;
  //     }

  //     final response = await _dio.get(
  //       '/cloud/${cloudType.value}/folders/$folderId/files',
  //       queryParameters: queryParameters,
  //     );
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error fetching folder files: $e');
  //     return null;
  //   }
  // }

  /// 클라우드 파일 검색
  // Future<Response?> searchCloudFiles({
  //   required CloudType cloudType,
  //   required String query,
  //   String? cursor,
  //   int limit = 50,
  // }) async {
  //   try {
  //     final Map<String, dynamic> queryParameters = {
  //       'query': query,
  //       'limit': limit,
  //     };

  //     if (cursor != null && cursor.isNotEmpty) {
  //       queryParameters['cursor'] = cursor;
  //     }

  //     final response = await _dio.get(
  //       '/cloud/${cloudType.value}/search',
  //       queryParameters: queryParameters,
  //     );
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error searching cloud files: $e');
  //     return null;
  //   }
  // }

  /// 파일 이름 변경
  // Future<Response?> renameFile({
  //   required CloudType cloudType,
  //   required String fileId,
  //   required String newName,
  // }) async {
  //   try {
  //     final Map<String, dynamic> data = {
  //       'fileName': newName,
  //     };

  //     final response = await _dio.put(
  //       '/cloud/${cloudType.value}/files/$fileId/rename',
  //       data: data,
  //     );
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error renaming file: $e');
  //     return null;
  //   }
  // }

  /// 파일 삭제
  // Future<Response?> deleteFile({
  //   required CloudType cloudType,
  //   required String fileId,
  // }) async {
  //   try {
  //     final response = await _dio.delete(
  //       '/cloud/${cloudType.value}/files/$fileId',
  //     );
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error deleting file: $e');
  //     return null;
  //   }
  // }

  /// 폴더 생성
  // Future<Response?> createFolder({
  //   required CloudType cloudType,
  //   required String folderName,
  //   String? parentFolderId,
  // }) async {
  //   try {
  //     final Map<String, dynamic> data = {
  //       'folderName': folderName,
  //     };

  //     if (parentFolderId != null) {
  //       data['parentFolderId'] = parentFolderId;
  //     }

  //     final response = await _dio.post(
  //       '/cloud/${cloudType.value}/folders',
  //       data: data,
  //     );
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error creating folder: $e');
  //     return null;
  //   }
  // }

  /// 파일 업로드
  // Future<Response?> uploadFile({
  //   required CloudType cloudType,
  //   required String fileName,
  //   required List<int> fileBytes,
  //   String? parentFolderId,
  //   String? fileType,
  // }) async {
  //   try {
  //     final formData = FormData.fromMap({
  //       'file': MultipartFile.fromBytes(
  //         fileBytes,
  //         filename: fileName,
  //         contentType: fileType != null ? MediaType.parse(fileType) : null,
  //       ),
  //       if (parentFolderId != null) 'parentFolderId': parentFolderId,
  //     });

  //     final response = await _dio.post(
  //       '/cloud/${cloudType.value}/upload',
  //       data: formData,
  //     );
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error uploading file: $e');
  //     return null;
  //   }
  // }

  /// 네이버웍스 OAuth 인증 URL 조회
  // Future<Response?> getNaverWorksAuthUrl() async {
  //   try {
  //     final response = await _dio.get('/cloud/works/auth-url');
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error getting NaverWorks auth URL: $e');
  //     return null;
  //   }
  // }

  /// 네이버웍스 OAuth 콜백 처리
  // Future<Response?> handleNaverWorksCallback({
  //   required String code,
  //   required String state,
  // }) async {
  //   try {
  //     final Map<String, dynamic> data = {
  //       'code': code,
  //       'state': state,
  //     };

  //     final response =
  //         await _dio.post('/cloud/works/callback', data: data);
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error handling NaverWorks callback: $e');
  //     return null;
  //   }
  // }

  /// 네이버웍스 연결 해제
  // Future<Response?> disconnectNaverWorks() async {
  //   try {
  //     final response = await _dio.delete('/cloud/works/connection');
  //     return response;
  //   } catch (e) {
  //     debugPrint('Error disconnecting NaverWorks: $e');
  //     return null;
  //   }
  // }

  /// 네이버웍스 API를 직접 호출하는 메서드 (Drive API, File Download API 등)
  /// ApiDio에서 생성된 클라우드 전용 Dio를 사용하여 자동으로 토큰 인증 처리
  // Future<Response?> callNaverWorksApi(
  //   String url, {
  //   String method = 'GET',
  //   dynamic data,
  //   Map<String, dynamic>? queryParameters,
  //   Map<String, String>? headers,
  // }) async {
  //   try {
  //     final options = Options(
  //       method: method,
  //       headers: headers,
  //     );

  //     final response = await _dio.request(
  //       url,
  //       data: data,
  //       queryParameters: queryParameters,
  //       options: options,
  //     );

  //     return response;
  //   } catch (e) {
  //     //debugPrint('Error calling NaverWorks API: $e');
  //     return null;
  //   }
  // }

  /// 네이버웍스 드라이브 파일 목록 조회 (직접 API 호출)
  // Future<Response?> getNaverWorksFiles({
  //   String? folderId,
  //   int? limit,
  //   String? orderBy,
  //   String? cursor,
  // }) async {
  //   final queryParams = <String, dynamic>{};

  //   if (folderId != null) queryParams['parent'] = folderId;
  //   if (limit != null) queryParams['limit'] = limit;
  //   if (orderBy != null) queryParams['orderBy'] = orderBy;
  //   if (cursor != null) queryParams['cursor'] = cursor;

  //   return await callNaverWorksApi(
  //     'https://www.worksapis.com/v1.0/drive/files',
  //     queryParameters: queryParams,
  //   );
  // }

  /// 네이버웍스 파일 다운로드 (직접 API 호출)
  // Future<Response?> downloadNaverWorksFile({
  //   required String fileId,
  //   String? fileName,
  // }) async {
  //   final data = <String, dynamic>{
  //     'fileId': fileId,
  //   };

  //   if (fileName != null) data['fileName'] = fileName;

  //   return await callNaverWorksApi(
  //     'https://apis-storage.worksmobile.com/v1.0/files/download',
  //     method: 'POST',
  //     data: data,
  //   );
  // }

  /// 네이버웍스 파일 업로드 (직접 API 호출)
  // Future<Response?> uploadNaverWorksFile({
  //   required String fileName,
  //   required List<int> fileBytes,
  //   String? parentFolderId,
  //   String? contentType,
  // }) async {
  //   final formData = FormData.fromMap({
  //     'file': MultipartFile.fromBytes(
  //       fileBytes,
  //       filename: fileName,
  //       contentType: contentType != null ? MediaType.parse(contentType) : null,
  //     ),
  //     if (parentFolderId != null) 'parent': parentFolderId,
  //   });

  //   return await callNaverWorksApi(
  //     'https://apis-storage.worksmobile.com/v1.0/files/upload',
  //     method: 'POST',
  //     data: formData,
  //   );
  // }
}
