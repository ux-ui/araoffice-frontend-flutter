import 'dart:convert';
import 'dart:typed_data';

import 'package:common_util/common_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web; // web용 다운로드 처리를 위해 추가

import 'model/model.dart';

// class _ApiDev {
//   static const kHostAppServer = 'http://15.165.209.235:8080/api/v1/';
// }

// class _ApiProd {
//   static const kHostAppServer = 'http://localhost:3000/api/v1/';
// }

// class _ApiLocal {
//   static const kHostAppServer = 'http://localhost:8082/api/v1/';
// }

typedef AuthenticationListener = void Function();
typedef AuthenticationMessageListener = void Function(int message);
typedef AuthenticationDataListener = void Function(Map<String, dynamic> data);

class CloudApiDio {
  CloudApiDio(String apiUrl) {
    apiHostAppServer = apiUrl;
  }

  static AuthenticationListener? _onUnauthorized;
  static AuthenticationListener? _serverError;
  static AuthenticationDataListener? _onErrorWithData;
  static AuthenticationDataListener? _onLoginStatus;

  static bool _isHandlingUnauthorized = false;

  // 리스너 설정
  static void setUnauthorizedListener(AuthenticationListener listener) {
    _onUnauthorized = listener;
  }

  static void setLoginStatusListener(AuthenticationDataListener listener) {
    _onLoginStatus = listener;
  }

  static void setServerErrorListener(AuthenticationListener listener) {
    _serverError = listener;
  }

  static void setErrorListener(AuthenticationMessageListener listener) {}

  static void setErrorListenerWithData(AuthenticationDataListener listener) {
    _onErrorWithData = listener;
  }

  // 리스너 제거
  static void removeUnauthorizedListener() {
    _onUnauthorized = null;
  }

  static void removeLoginStatusListener() {
    _onLoginStatus = null;
  }

  static void removeServerErrorListener() {
    _serverError = null;
  }

  static void removeErrorListener() {}

  static void removeErrorListenerWithData() {
    _onErrorWithData = null;
  }

  // 401 처리 메서드
  static void _handleUnauthorized() {
    if (_isHandlingUnauthorized) return;

    try {
      _isHandlingUnauthorized = true;

      // 등록된 리스너가 있다면 호출
      if (_onUnauthorized != null) {
        Future.microtask(() {
          try {
            _onUnauthorized!();
          } catch (e) {
            debugPrint('Error in unauthorized listener: $e');
          } finally {
            _isHandlingUnauthorized = false;
          }
        });
      } else {
        debugPrint('No unauthorized listener registered');
        _isHandlingUnauthorized = false;
      }
    } catch (e) {
      _isHandlingUnauthorized = false;
      debugPrint('Error in _handleUnauthorized: $e');
    }
  }

  static void _handleErrorWithData(Map<String, dynamic> data) {
    if (_onErrorWithData != null) {
      Future.microtask(() {
        try {
          _onErrorWithData!(data);
        } catch (e) {
          debugPrint('Error in error listener: $e');
        }
      });
    } else {
      debugPrint('No error listener registered');
    }
  }

  static void _handleLoginStatus(Map<String, dynamic> data) {
    if (_onLoginStatus != null) {
      Future.microtask(() {
        try {
          _onLoginStatus!(data);
        } catch (e) {
          debugPrint('Error in login status listener: $e');
        }
      });
    }
  }

  // 일반 오류 처리 메서드
  // static void _handleError(int message) {
  //   if (_onError != null) {
  //     Future.microtask(() {
  //       try {
  //         _onError!(message);
  //       } catch (e) {
  //         debugPrint('Error in error listener: $e');
  //       }
  //     });
  //   } else {
  //     debugPrint('No error listener registered');
  //   }
  // }

  static void _handelServerError() {
    if (_serverError != null) {
      _serverError!();
    }
  }

  Future<ApiResponse> request({
    required String path,
    RequestType method = RequestType.get,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    bool useAuthDio = false,
    bool? loginErrorHandling = false,
  }) async {
    if (apiHostAppServer.isEmpty) {
      throw Exception('You must call setUrlByEnvironment before any request');
    }
    try {
      final dioInstance = useAuthDio ? authDio : commonDio;

      final response = await dioInstance.request(
        path,
        options: Options(
          method: method.value,
          headers: headers,
        ),
        queryParameters: queryParameters,
        data: data,
      );

      if (response.statusCode == 200) {
        _handleLoginStatus(response.data);
        return ApiResponse.fromResponse(response);
      }

      if (response.data["statusCode"] == 401) {
        if (loginErrorHandling != true) {
          _handleErrorWithData(response.data!);
          debugPrint(
              'Unauthorized: ${response.statusCode} ${response.statusMessage}');
        }
        return ApiResponse(
          statusCode: response.statusCode ?? 401,
          message: 'unauthorized',
          data: null,
        );
      }

      if (response.data["statusCode"] == 403 ||
          response.data["statusCode"] == 404 ||
          response.data["statusCode"] == 500) {
        return ApiResponse(
          statusCode: response.statusCode ?? 401,
          message: response.data["message"],
          data: response.data["data"],
        );
      }

      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      _handelServerError();
      // _handleUnauthorized();
      return _handleDioError(e);
    } catch (e) {
      _handelServerError();
      return ApiResponse(
        statusCode: 500,
        message: 'request_error',
        data: null,
      );
    }
  }

  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool useAuthDio = false,
  }) {
    if (apiHostAppServer.isEmpty) {
      throw Exception('You must call setUrlByEnvironment before any request');
    }
    return request(
      path: path,
      method: RequestType.get,
      queryParameters: queryParameters,
      headers: headers,
      useAuthDio: useAuthDio,
    );
  }

  Future<ApiResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool useAuthDio = false,
    bool? loginErrorHandling = false,
  }) {
    if (apiHostAppServer.isEmpty) {
      throw Exception('You must call setUrlByEnvironment before any request');
    }
    return request(
      path: path,
      method: RequestType.post,
      queryParameters: queryParameters,
      data: data,
      headers: headers,
      useAuthDio: useAuthDio,
      loginErrorHandling: loginErrorHandling,
    );
  }

  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    bool useAuthDio = false,
  }) {
    if (apiHostAppServer.isEmpty) {
      throw Exception('You must call setUrlByEnvironment before any request');
    }
    return request(
      path: path,
      method: RequestType.put,
      data: data,
      headers: headers,
      useAuthDio: useAuthDio,
    );
  }

  Future<ApiResponse> delete(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    bool useAuthDio = false,
  }) {
    if (apiHostAppServer.isEmpty) {
      throw Exception('You must call setUrlByEnvironment before any request');
    }
    return request(
      path: path,
      method: RequestType.delete,
      data: data,
      headers: headers,
      useAuthDio: useAuthDio,
    );
  }

  Future<ApiResponse> patch(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    bool useAuthDio = false,
  }) {
    if (apiHostAppServer.isEmpty) {
      throw Exception('You must call setUrlByEnvironment before any request');
    }
    return request(
      path: path,
      method: RequestType.patch,
      data: data,
      headers: headers,
      useAuthDio: useAuthDio,
    );
  }

  Future<ApiResponse> download({
    required String path,
    required String fileName,
    required String fileType,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    bool useAuthDio = false,
    Function(int received, int total)? onReceiveProgress,
  }) async {
    if (apiHostAppServer.isEmpty) {
      throw Exception('You must call setUrlByEnvironment before any request');
    }

    try {
      final dioInstance = useAuthDio ? authDio : commonDio;

      final response = await dioInstance.post(
        path,
        data: {
          'fileName': fileName,
          'fileType': fileType,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
          method: 'POST',
        ),
        onReceiveProgress: onReceiveProgress,
      );

      // Web 환경에서 파일 다운로드 처리
      if (response.data is List<int>) {
        try {
          final bytes = Uint8List.fromList(response.data as List<int>);

          // 데이터 URL 생성하는 방식으로 대체
          final base64 = Uri.parse(
              'data:application/octet-stream;base64,${base64Encode(bytes)}');

          final anchor =
              web.document.createElement('a') as web.HTMLAnchorElement
                ..href = base64.toString()
                ..style.display = 'none'
                ..download = fileName;

          web.document.body!.appendChild(anchor);
          anchor.click();
          web.document.body!.removeChild(anchor);
        } catch (e) {
          logger.e('Download error: $e');
        }
      }

      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse(
        statusCode: 500,
        message: 'download_error',
        data: null,
      );
    }
  }

  Future<ApiResponse> downloadWithData({
    required String path,
    required String fileName,
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
    bool useAuthDio = false,
    Function(int received, int total)? onReceiveProgress,
  }) async {
    if (apiHostAppServer.isEmpty) {
      throw Exception('You must call setUrlByEnvironment before any request');
    }

    try {
      final dioInstance = useAuthDio ? authDio : commonDio;

      final response = await dioInstance.post(
        path,
        data: data,
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
          method: 'POST',
        ),
        onReceiveProgress: onReceiveProgress,
      );

      // Web 환경에서 파일 다운로드 처리
      if (response.data is List<int>) {
        try {
          final bytes = Uint8List.fromList(response.data as List<int>);

          // 파일 형식에 따른 MIME 타입 결정
          String mimeType = 'application/octet-stream';
          if (fileName.endsWith('.txt')) {
            mimeType = 'text/plain';
          } else if (fileName.endsWith('.epub')) {
            mimeType = 'application/epub+zip';
          } else if (fileName.endsWith('.pdf')) {
            mimeType = 'application/pdf';
          }

          // 데이터 URL 생성하는 방식으로 대체
          final base64 =
              Uri.parse('data:$mimeType;base64,${base64Encode(bytes)}');

          final anchor =
              web.document.createElement('a') as web.HTMLAnchorElement
                ..href = base64.toString()
                ..style.display = 'none'
                ..download = fileName;

          web.document.body!.appendChild(anchor);
          anchor.click();
          web.document.body!.removeChild(anchor);
        } catch (e) {
          logger.e('Download with data error: $e');
        }
      }

      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse(
        statusCode: 500,
        message: 'download_with_data_error',
        data: null,
      );
    }
  }

  ApiResponse _handleDioError(DioException e) {
    logger.d('DioException: ${e.response?.statusCode}');
    if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
      _handleUnauthorized();
      return ApiResponse(
        statusCode: 401,
        message: 'unauthorized',
        data: null,
      );
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse(
          statusCode: 408,
          message: 'request_timeout',
          data: null,
        );
      case DioExceptionType.badResponse:
        return ApiResponse(
          statusCode: e.response?.statusCode ?? 400,
          message: e.response?.statusMessage ?? 'bad_response',
          data: null,
        );
      case DioExceptionType.cancel:
        return ApiResponse(
          statusCode: 499,
          message: 'request_cancel',
          data: null,
        );
      default:
        return ApiResponse(
          statusCode: 500,
          message: 'request_error',
          data: null,
        );
    }
  }

  static Dio authDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      // 중요! 쿠키를 주고받기 위한 설정
      receiveDataWhenStatusError: true,
      validateStatus: (status) => true,
      extra: {
        'withCredentials': true, // 쿠키 전송을 위해 필요
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          /// Add headers or other stuff here
          /// options.headers['Authorization'] =
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.statusCode == 401) {
            // _handleUnauthorized();
            logger.d('unauthorized 401 인증없음');
            // 기본 인증 응답 처리 이곳에 하기
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // _handleUnauthorized();
            logger.d('unauthorized');
          }
          return handler.next(error);
        },
      ),
    );

  static Dio commonDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
      // 중요! 쿠키를 주고받기 위한 설정
      receiveDataWhenStatusError: true,
      validateStatus: (status) => true,
      extra: {
        'withCredentials': true, // 쿠키 전송을 위해 필요
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          /// Add headers or other stuff here
          /// options.headers['Authorization'] =
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // commonDio에서도 401 체크
          if (response.statusCode == 401) {
            // _handleUnauthorized();
            logger.d('unauthorized');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          // commonDio 에러에서도 401 체크
          if (error.response?.statusCode == 401) {
            logger.d('unauthorized');
            // _handleUnauthorized();
          }
          return handler.next(error);
        },
      ),
    );

  static String apiHostAppServer = '';

  /// Must be called before any request
  void setUrlByEnvironment(BuildType type) {
    if (type == BuildType.dev) {
      //apiHostAppServer = _ApiDev.kHostAppServer;

      // 개발 환경에서만 로그 인터셉터 추가
      authDio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ));

      commonDio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ));
      // authDio.interceptors.add(MockApiInterceptor());
      // commonDio.interceptors.add(MockApiInterceptor());
    } else if (type == BuildType.prod) {
      // apiHostAppServer = _ApiProd.kHostAppServer;
    } else if (type == BuildType.local) {
      // apiHostAppServer = _ApiLocal.kHostAppServer;
      // 개발 환경에서만 로그 인터셉터 추가
      authDio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ));

      commonDio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ));
    }
    authDio.options.baseUrl = apiHostAppServer;
    commonDio.options.baseUrl = apiHostAppServer;
  }
}

enum RequestType {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE'),
  patch('PATCH');

  final String value;
  const RequestType(this.value);
}
