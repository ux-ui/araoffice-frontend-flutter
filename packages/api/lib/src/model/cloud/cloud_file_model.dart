import 'package:api/src/model/base_model.dart';

class CloudFileModel extends BaseModel {
  final String fileId;
  final String? parentFileId;
  final int resourceLocation;
  final int fileSize;
  final String fileName;
  final String filePath;
  final String fileType;
  final DateTime createdTime;
  final DateTime modifiedTime;
  final DateTime accessedTime;
  final bool hasPermission;
  final bool shared;
  // <-- 여기까지 내부 네이버웍스 파일 모델 -->
  // <-- 아래는 사설 네이버웍스 파일 모델에서만? -->
  final List<String>? statuses;
  final String? permissionRootFileId;
  final String? shareRootFileId;
  final String? downloadUrl;
  final String? secretKey;  // IOP secretKey
  final CloudStorageType storageType;  // 저장소 타입

  CloudFileModel({
    required this.fileId,
    this.parentFileId,
    required this.resourceLocation,
    required this.fileSize,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.createdTime,
    required this.modifiedTime,
    required this.accessedTime,
    required this.hasPermission,
    required this.shared,
    // ------------------------------
    this.statuses,
    this.permissionRootFileId,
    this.shareRootFileId,
    this.downloadUrl,
    this.secretKey,
    this.storageType = CloudStorageType.naverWorks,
  });

  // 폴더 여부 확인
  bool get isFolder => fileType.toUpperCase() == 'FOLDER';

  // 파일 크기를 읽기 쉬운 형태로 반환
  String get formattedFileSize {
    if (fileSize == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int suffixIndex = 0;
    double size = fileSize.toDouble();

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(size < 10 && suffixIndex > 0 ? 1 : 0)} ${suffixes[suffixIndex]}';
  }

  // 파일 확장자 추출
  String get fileExtension {
    final lastDot = fileName.lastIndexOf('.');
    return lastDot == -1 ? '' : fileName.substring(lastDot + 1).toUpperCase();
  }

  // 파일인지 확인
  bool get isFile => !isFolder;

  // 파일 크기를 읽기 쉬운 형태로 변환
  String get readableFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  factory CloudFileModel.fromJson(Map<String, dynamic> json) {
    return CloudFileModel(
      fileId: json['fileId'] ?? '',
      parentFileId: json['parentFileId'],
      resourceLocation: json['resourceLocation'] ?? 0,
      fileSize: json['fileSize'] ?? 0,
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      fileType: json['fileType'] ?? '',
      createdTime:
          DateTime.tryParse(json['createdTime'] ?? '') ?? DateTime.now(),
      modifiedTime:
          DateTime.tryParse(json['modifiedTime'] ?? '') ?? DateTime.now(),
      accessedTime:
          DateTime.tryParse(json['accessedTime'] ?? '') ?? DateTime.now(),
      hasPermission: json['hasPermission'] ?? false,
      shared: json['shared'] ?? false,
      // ------------------------------
      statuses: (json['statuses'] != null && json['statuses'] is List<dynamic>)
          ? (json['statuses'] as List<dynamic>)
              .map((status) => status as String)
              .toList()
          : [],
      permissionRootFileId: json['permissionRootFileId'] ?? '',
      shareRootFileId: json['shareRootFileId'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'parentFileId': parentFileId,
      'resourceLocation': resourceLocation,
      'fileSize': fileSize,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'createdTime': createdTime.toIso8601String(),
      'modifiedTime': modifiedTime.toIso8601String(),
      'accessedTime': accessedTime.toIso8601String(),
      'hasPermission': hasPermission,
      'shared': shared,
      // ------------------------------
      'statuses': statuses,
      'permissionRootFileId': permissionRootFileId,
      'shareRootFileId': shareRootFileId,
    };
  }

  CloudFileModel copyWith({
    String? fileId,
    String? parentFileId,
    int? resourceLocation,
    int? fileSize,
    String? fileName,
    String? filePath,
    String? fileType,
    DateTime? createdTime,
    DateTime? modifiedTime,
    DateTime? accessedTime,
    bool? hasPermission,
    bool? shared,
    // ------------------------------
    List<String>? statuses,
    String? permissionRootFileId,
    String? shareRootFileId,
    String? downloadUrl,
    String? secretKey,
    CloudStorageType? storageType,
  }) {
    return CloudFileModel(
      fileId: fileId ?? this.fileId,
      parentFileId: parentFileId ?? this.parentFileId,
      resourceLocation: resourceLocation ?? this.resourceLocation,
      fileSize: fileSize ?? this.fileSize,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      createdTime: createdTime ?? this.createdTime,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      accessedTime: accessedTime ?? this.accessedTime,
      hasPermission: hasPermission ?? this.hasPermission,
      shared: shared ?? this.shared,
      // ------------------------------
      statuses: statuses != null
          ? List<String>.from(statuses)
          : this.statuses != null
              ? List<String>.from(this.statuses!)
              : null,
      permissionRootFileId: permissionRootFileId ?? this.permissionRootFileId,
      shareRootFileId: shareRootFileId ?? this.shareRootFileId,
      downloadUrl: downloadUrl,
      secretKey: secretKey ?? this.secretKey,
      storageType: storageType ?? this.storageType,
    );
  }
}

class CloudFileResponse extends BaseModel {
  final List<CloudFileModel> files;
  final ResponseMetaData responseMetaData;

  CloudFileResponse({
    required this.files,
    required this.responseMetaData,
  });

  factory CloudFileResponse.fromJson(Map<String, dynamic> json) {
    return CloudFileResponse(
      files: (json['files'] as List? ?? [])
          .map((file) => CloudFileModel.fromJson(file))
          .toList(),
      responseMetaData:
          ResponseMetaData.fromJson(json['responseMetaData'] ?? {}),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'files': files.map((file) => file.toJson()).toList(),
      'responseMetaData': responseMetaData.toJson(),
    };
  }
}

class ResponseMetaData extends BaseModel {
  final String? nextCursor;
  final int totalCount;
  final bool hasMore;

  ResponseMetaData({
    this.nextCursor,
    required this.totalCount,
    required this.hasMore,
  });

  factory ResponseMetaData.fromJson(Map<String, dynamic> json) {
    return ResponseMetaData(
      nextCursor: json['nextCursor'],
      totalCount: json['totalCount'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nextCursor': nextCursor,
      'totalCount': totalCount,
      'hasMore': hasMore,
    };
  }
}

// 클라우드 타입 enum
enum CloudType {
  works('works', '네이버 웍스'),
  ara('ara', '아라'),
  brity('brity', '브리티');

  final String value;
  final String displayName;

  const CloudType(this.value, this.displayName);

  factory CloudType.fromString(String value) {
    return CloudType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CloudType.works,
    );
  }
}

// 클라우드 저장소 타입 enum
enum CloudStorageType {
  naverWorks('naverWorks', '네이버웍스'),
  iop('iop', 'IOP');

  final String value;
  final String displayName;

  const CloudStorageType(this.value, this.displayName);

  factory CloudStorageType.fromString(String value) {
    return CloudStorageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CloudStorageType.naverWorks,
    );
  }
}

// 클라우드 파일 검색 요청
class CloudFileSearchRequest extends BaseModel {
  final String query;
  final String? cursor;
  final int limit;
  final String? sortBy;
  final bool ascending;

  CloudFileSearchRequest({
    required this.query,
    this.cursor,
    this.limit = 50,
    this.sortBy,
    this.ascending = true,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'cursor': cursor,
      'limit': limit,
      'sortBy': sortBy,
      'ascending': ascending,
    };
  }
}

// 클라우드 파일 다운로드 URL 응답
class CloudFileDownloadUrlResponse extends BaseModel {
  final String downloadUrl;
  final DateTime? expiresAt;

  CloudFileDownloadUrlResponse({
    required this.downloadUrl,
    this.expiresAt,
  });

  factory CloudFileDownloadUrlResponse.fromJson(Map<String, dynamic> json) {
    return CloudFileDownloadUrlResponse(
      downloadUrl: json['downloadUrl'] ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'downloadUrl': downloadUrl,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}
