import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

class UploadStatus {
  static const success = 'success';
  static const error = 'error';
}

class UploadResult {
  final String status;
  final int? statusCode;
  final String? response;
  final String? error;

  UploadResult({
    required this.status,
    this.statusCode,
    this.response,
    this.error,
  });
}

class FileUploadOptions {
  final String url;
  final Map<String, String>? headers;
  final Map<String, String>? extraData;
  final String? fileFieldName;

  FileUploadOptions({
    required this.url,
    this.headers,
    this.extraData,
    this.fileFieldName = 'file',
  });
}

class HtmlFileUploader {
  final FileUploadOptions options;
  final Function(UploadResult)? onComplete;
  final Function(int)? onProgress;

  HtmlFileUploader({
    required this.options,
    this.onComplete,
    this.onProgress,
  });

  Future<void> uploadFile(String fileName, Uint8List fileBytes) async {
    final formData = FormData();

    // 파일 추가
    final blob = Blob([fileBytes.toJS] as JSArray<BlobPart>);
    formData.append(options.fileFieldName ?? 'file', blob, fileName);

    // 추가 데이터가 있다면 추가
    options.extraData?.forEach((key, value) {
      formData.append(key, value.toJS);
    });

    try {
      final request = XMLHttpRequest();
      request.open('POST', options.url);

      // 헤더 설정
      options.headers?.forEach((key, value) {
        request.setRequestHeader(key, value);
      });

      // 업로드 진행률 모니터링
      request.upload.addEventListener(
        'progress',
        ((Event event) {
          if (event is ProgressEvent && event.lengthComputable) {
            final percentComplete =
                ((event.loaded / event.total) * 100).round();
            onProgress?.call(percentComplete);
          }
        }).toJS,
      );

      // 완료 리스너
      request.addEventListener(
        'loadend',
        ((Event event) {
          final result = UploadResult(
            status: request.status == 200
                ? UploadStatus.success
                : UploadStatus.error,
            statusCode: request.status,
            response: request.responseText,
            error: request.status != 200 ? request.statusText : null,
          );
          onComplete?.call(result);
        }).toJS,
      );

      // 에러 리스너
      request.addEventListener(
        'error',
        ((Event event) {
          final result = UploadResult(
            status: UploadStatus.error,
            error: 'Network error occurred',
          );
          onComplete?.call(result);
        }).toJS,
      );

      request.send(formData);
    } catch (e) {
      final result = UploadResult(
        status: UploadStatus.error,
        error: e.toString(),
      );
      onComplete?.call(result);
    }
  }
}
