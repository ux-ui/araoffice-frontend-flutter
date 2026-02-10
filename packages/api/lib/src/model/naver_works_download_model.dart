/// 네이버웍스 다운로드 URL 요청 모델
class NaverWorksDownloadUrlRequest {
  final String fileId;
  final String accessToken;

  const NaverWorksDownloadUrlRequest({
    required this.fileId,
    required this.accessToken,
  });

  factory NaverWorksDownloadUrlRequest.fromJson(Map<String, dynamic> json) {
    return NaverWorksDownloadUrlRequest(
      fileId: json['fileId'] as String,
      accessToken: json['accessToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'accessToken': accessToken,
    };
  }

  @override
  String toString() {
    return 'NaverWorksDownloadUrlRequest{fileId: $fileId}'; // accessToken은 보안상 출력하지 않음
  }
}

/// 네이버웍스 다운로드 URL 응답 모델
class NaverWorksDownloadUrlResponse {
  final String fileId;
  final String? downloadUrl;
  final String? message;

  const NaverWorksDownloadUrlResponse({
    required this.fileId,
    this.downloadUrl,
    this.message,
  });

  factory NaverWorksDownloadUrlResponse.fromJson(
      Map<String, dynamic> json, String? message) {
    return NaverWorksDownloadUrlResponse(
      fileId: json['fileId'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String?,
      message: message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'downloadUrl': downloadUrl,
    };
  }

  @override
  String toString() {
    return 'NaverWorksDownloadUrlResponse{fileId: $fileId, downloadUrl: $downloadUrl}';
  }
}
