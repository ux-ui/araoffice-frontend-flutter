import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// NAVER WORKS Drive Location Picker 응답 데이터 모델
/// PickerLocation 스펙에 맞춘 폴더/위치 정보
class NaverWorksDriveFolder {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final int resourceLocation;

  NaverWorksDriveFolder({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.resourceLocation,
  });

  factory NaverWorksDriveFolder.fromJson(Map<String, dynamic> json) {
    return NaverWorksDriveFolder(
      fileId: json['fileId'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      resourceLocation: json['resourceLocation'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'resourceLocation': resourceLocation,
    };
  }

  String get id => fileId;
  String get name => fileName;
  String? get path => fileUrl;
}

/// NAVER WORKS Drive File Picker 응답 데이터 모델
/// PickerFile 스펙에 맞춘 파일 정보 (fileSize 포함)
class NaverWorksDriveFile {
  final String fileId;
  final String fileName;
  final int fileSize;
  final String fileUrl;
  final int resourceLocation;

  NaverWorksDriveFile({
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    required this.fileUrl,
    required this.resourceLocation,
  });

  factory NaverWorksDriveFile.fromJson(Map<String, dynamic> json) {
    return NaverWorksDriveFile(
      fileId: json['fileId'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileSize: json['fileSize'] as int? ?? 0,
      fileUrl: json['fileUrl'] as String? ?? '',
      resourceLocation: json['resourceLocation'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileUrl': fileUrl,
      'resourceLocation': resourceLocation,
    };
  }

  String get id => fileId;
  String get name => fileName;
  int get size => fileSize;
  String? get path => fileUrl;
}

/// NAVER WORKS Drive Picker 유틸리티 클래스
class NaverWorksDrivePicker {
  /// 네이버웍스 드라이브 Base URL
  static const String _baseOrigin = kDebugMode
      ? 'https://alpha-drive.naverworks-gov.com'
      : 'https://drive.naverworks-gov.com';

  /// Location Picker URL (폴더/위치 선택)
  static const String _locationPickerUrl =
      '$_baseOrigin/drive/web/files/location';

  /// File Picker URL (파일 선택)
  static const String _filePickerUrl = '$_baseOrigin/drive/web/files/picker';

  static const String _popupName = 'naverWorksDrivePicker';

  /// 팝업 창 참조 (닫힘 감지용)
  static web.Window? _popupWindow;

  /// 현재 등록된 메시지 리스너
  static JSFunction? _messageListener;

  /// 팝업 닫힘 감지용 타이머
  static Timer? _popupCheckTimer;

  /// 현재 피커 타입 (file / folder)
  static String? _currentPickerType;

  /// 폴더 선택 결과 콜백
  static Function(NaverWorksDriveFolder)? _onFolderSuccess;

  /// 파일 선택 결과 콜백
  static Function(List<NaverWorksDriveFile>)? _onFilesSuccess;

  /// 에러 콜백
  static Function(String)? _onError;

  // ============================================================
  // File Picker (파일 선택)
  // ============================================================

  /// Drive File Picker 팝업 열기 (Future 반환)
  ///
  /// [maxSelectionFileCount] 최대 선택 파일 개수 (선택사항)
  /// [maxSelectionFileSize] 선택 가능한 총 파일 크기 (e.g., '10GB', '10MB') (선택사항)
  /// [extensionFilters] 표시할 확장자 필터 목록 (e.g., ['png', 'jpg']) (선택사항)
  ///
  /// 성공 시 [List<NaverWorksDriveFile>] 반환
  /// 에러 발생 시 Exception throw
  static Future<List<NaverWorksDriveFile>?> openFilePickerAsync({
    int? maxSelectionFileCount,
    String? maxSelectionFileSize,
    List<String>? extensionFilters,
  }) {
    final completer = Completer<List<NaverWorksDriveFile>>();

    openFilePicker(
      maxSelectionFileCount: maxSelectionFileCount,
      maxSelectionFileSize: maxSelectionFileSize,
      extensionFilters: extensionFilters,
      onSuccess: (files) {
        if (!completer.isCompleted) {
          completer.complete(files);
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(error));
        }
      },
    );

    return completer.future;
  }

  /// Drive File Picker 팝업 열기 (파일 선택)
  ///
  /// [maxSelectionFileCount] 최대 선택 파일 개수 (선택사항)
  /// [maxSelectionFileSize] 선택 가능한 총 파일 크기 (e.g., '10GB', '10MB') (선택사항)
  /// [extensionFilters] 표시할 확장자 필터 목록 (e.g., ['png', 'jpg']) (선택사항)
  /// [onSuccess] 파일 선택 완료 콜백
  /// [onError] 에러 발생 콜백
  static void openFilePicker({
    int? maxSelectionFileCount,
    String? maxSelectionFileSize,
    List<String>? extensionFilters,
    required Function(List<NaverWorksDriveFile>) onSuccess,
    required Function(String) onError,
    int? popupWidth = 1200,
    int? popupHeight = 650,
  }) {
    // 기존 리스너가 있으면 제거
    _removeMessageListener();

    // 피커 타입 및 콜백 저장
    _currentPickerType = 'file';
    _onFilesSuccess = onSuccess;
    _onError = onError;

    // URL 파라미터 구성
    final params = <String>['service=araoffice'];
    if (maxSelectionFileCount != null) {
      params.add('maxSelectionFileCount=$maxSelectionFileCount');
    }
    if (maxSelectionFileSize != null && maxSelectionFileSize.isNotEmpty) {
      params.add('maxSelectionFileSize=$maxSelectionFileSize');
    }
    if (extensionFilters != null && extensionFilters.isNotEmpty) {
      // OpenAPI style: form, explode: true → 반복 키 방식
      for (final ext in extensionFilters) {
        params.add('extensionFilters=$ext');
      }
    }

    final url = '$_filePickerUrl?${params.join('&')}';

    _popupWindow = web.window.open(
      url,
      _popupName,
      'width=$popupWidth,height=$popupHeight,menubar=no,toolbar=no,location=no,status=no,scrollbars=yes,resizable=yes',
    );

    // 메시지 리스너 등록
    _setupMessageListener();

    // 팝업 닫힘 감지 (폴링 방식)
    _checkPopupClosed();
  }

  // ============================================================
  // Location Picker (폴더/위치 선택)
  // ============================================================

  /// Drive Location Picker 팝업 열기 (Future 반환)
  ///
  /// [fileId] 위치 선택 시작점 ID (선택사항)
  /// [resourceLocation] 위치 선택 시작점 resourceLocation (선택사항)
  ///
  /// 성공 시 [NaverWorksDriveFolder] 반환
  /// 에러 발생 시 Exception throw
  static Future<NaverWorksDriveFolder?> openFolderPickerAsync({
    String? fileId,
    int? resourceLocation,
    int? popupWidth = 700,
    int? popupHeight = 800,
  }) {
    final completer = Completer<NaverWorksDriveFolder?>();

    openFolderPicker(
      fileId: fileId,
      resourceLocation: resourceLocation,
      popupWidth: popupWidth,
      popupHeight: popupHeight,
      onSuccess: (folder) {
        if (!completer.isCompleted) {
          completer.complete(folder);
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(error));
        }
      },
    );

    return completer.future;
  }

  /// Drive Location Picker 팝업 열기 (폴더/위치 선택)
  ///
  /// [fileId] 위치 선택 시작점 ID (선택사항)
  /// [resourceLocation] 위치 선택 시작점 resourceLocation (선택사항)
  /// [onSuccess] 폴더 선택 완료 콜백
  /// [onError] 에러 발생 콜백
  static void openFolderPicker({
    String? fileId,
    int? resourceLocation,
    int? popupWidth = 700,
    int? popupHeight = 800,
    required Function(NaverWorksDriveFolder) onSuccess,
    required Function(String) onError,
  }) {
    // 기존 리스너가 있으면 제거
    _removeMessageListener();

    // 피커 타입 및 콜백 저장
    _currentPickerType = 'folder';
    _onFolderSuccess = onSuccess;
    _onError = onError;

    // URL 파라미터 구성
    final params = <String>['service=araoffice'];
    if (fileId != null && fileId.isNotEmpty) {
      params.add('fileId=$fileId');
    }
    if (resourceLocation != null) {
      params.add('resourceLocation=$resourceLocation');
    }

    final url = '$_locationPickerUrl?${params.join('&')}';

    _popupWindow = web.window.open(
      url,
      _popupName,
      'width=$popupWidth,height=$popupHeight,menubar=no,toolbar=no,location=no,status=no,scrollbars=yes,resizable=yes',
    );

    // 메시지 리스너 등록
    _setupMessageListener();

    // 팝업 닫힘 감지 (폴링 방식)
    _checkPopupClosed();
  }

  // ============================================================
  // Private Methods
  // ============================================================

  /// postMessage 리스너 설정
  static void _setupMessageListener() {
    _messageListener = ((web.MessageEvent event) {
      // Origin 검증 (보안)
      if (event.origin != _baseOrigin) {
        debugPrint('[NaverWorksDrivePicker] Invalid origin: ${event.origin}');
        return;
      }

      try {
        final rawData = event.data.dartify();
        if (rawData == null || rawData is! Map) {
          debugPrint('[NaverWorksDrivePicker] Invalid message data');
          return;
        }
        final data = Map<String, dynamic>.from(rawData);

        final status = data['status'] as String?;
        debugPrint(
            '[NaverWorksDrivePicker] Received message: status=$status, type=$_currentPickerType');

        switch (status) {
          case 'SUCCESS':
            if (_currentPickerType == 'file') {
              _handleFilePickerSuccess(data);
            } else {
              _handleFolderPickerSuccess(data);
            }
            break;
          case 'ERROR':
            _handleError(data);
            break;
          default:
            debugPrint('[NaverWorksDrivePicker] Unknown status: $status');
        }
      } catch (e) {
        debugPrint('[NaverWorksDrivePicker] Error processing message: $e');
        _onError?.call('An error occurred while processing the message: $e');
      } finally {
        // 리스너 제거
        _removeMessageListener();
      }
    }).toJS;

    web.window.addEventListener('message', _messageListener!);
  }

  /// File Picker 성공 응답 처리
  static void _handleFilePickerSuccess(Map<String, dynamic> data) {
    try {
      // File Picker는 'files' 키로 파일 목록을 전달
      // 문서와 다르게 파일 목록이 'data' 키로 전달될 수 있음
      var rawFilesData = data['files'] ?? data['data'];

      if (rawFilesData == null || rawFilesData is! List) {
        _onError?.call('No files selected.');
        return;
      }

      final files = rawFilesData.map((item) {
        final fileData = Map<String, dynamic>.from(item as Map);
        return NaverWorksDriveFile.fromJson(fileData);
      }).toList();

      _onFilesSuccess?.call(files);
    } catch (e) {
      debugPrint('[NaverWorksDrivePicker] Error parsing files data: $e');
      _onError?.call('An error occurred while processing the files data: $e');
    }
  }

  /// Folder Picker 성공 응답 처리
  static void _handleFolderPickerSuccess(Map<String, dynamic> data) {
    try {
      // Location Picker는 'file' 키로 단일 위치 정보를 전달
      final rawFileData = data['file'];

      if (rawFileData == null || rawFileData is! Map) {
        _onError?.call('No location data selected.');
        return;
      }

      final fileData = Map<String, dynamic>.from(rawFileData);
      final folder = NaverWorksDriveFolder.fromJson(fileData);
      _onFolderSuccess?.call(folder);
    } catch (e) {
      debugPrint('[NaverWorksDrivePicker] Error parsing location data: $e');
      _onError
          ?.call('An error occurred while processing the location data: $e');
    }
  }

  /// 에러 응답 처리
  static void _handleError(Map<String, dynamic> data) {
    final errorMessage =
        data['error'] as String? ?? 'An unknown error occurred.';
    _onError?.call(errorMessage);
  }

  /// 메시지 리스너 제거
  static void _removeMessageListener() {
    if (_messageListener != null) {
      web.window.removeEventListener('message', _messageListener!);
      _messageListener = null;
    }
    _popupCheckTimer?.cancel();
    _popupCheckTimer = null;
    _currentPickerType = null;
    _onFolderSuccess = null;
    _onFilesSuccess = null;
    _onError = null;
  }

  /// 팝업 창이 닫혔는지 확인 (폴링)
  static void _checkPopupClosed() {
    // 기존 타이머가 있으면 취소
    _popupCheckTimer?.cancel();

    // 주기적으로 팝업 상태 확인
    _popupCheckTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_popupWindow != null) {
        try {
          // 팝업이 닫혔는지 확인
          if (_popupWindow!.closed == true) {
            timer.cancel();
            _popupCheckTimer = null;
            _popupWindow = null;
            // 팝업이 닫혔지만 메시지를 받지 못한 경우
            // 리스너는 이미 제거되었을 수 있지만, 안전하게 제거
            _removeMessageListener();
          }
        } catch (e) {
          // 크로스 오리진 에러는 무시 (팝업이 닫힌 것으로 간주)
          timer.cancel();
          _popupCheckTimer = null;
          _popupWindow = null;
          _removeMessageListener();
        }
      } else {
        timer.cancel();
        _popupCheckTimer = null;
      }
    });
  }
}
