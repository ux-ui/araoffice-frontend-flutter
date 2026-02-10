import 'package:api/src/model/base_model.dart';

/// IOP 다운로드 URL 응답
class IopDownloadUrlResponse extends BaseModel {
  final String? fileId;
  final String? downloadUrl;
  final String? message;

  IopDownloadUrlResponse({
    this.fileId,
    this.downloadUrl,
    this.message,
  });

  factory IopDownloadUrlResponse.fromJson(
    Map<String, dynamic>? json,
    String? message,
  ) {
    if (json == null) {
      return IopDownloadUrlResponse(
        message: message ?? 'No data',
      );
    }

    return IopDownloadUrlResponse(
      fileId: json['fileId'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      message: message,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'downloadUrl': downloadUrl,
      'message': message,
    };
  }
}
