class VulcanResourceData {
  final String id;
  final String fileName;
  final String fileType;
  final String thumbnailFileName;
  final int size; // Dart에서는 long 대신 int 사용
  final String description;

  VulcanResourceData({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.thumbnailFileName,
    required this.size,
    required this.description,
  });

  // JSON으로부터 모델 생성
  factory VulcanResourceData.fromJson(Map<String, dynamic> json) {
    return VulcanResourceData(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      thumbnailFileName: json['thumbnailFileName'] as String,
      fileType: json['fileType'] as String,
      size: json['size'] as int,
      description: json['description'] as String,
    );
  }

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'thumbnailFileName': thumbnailFileName,
      'fileType': fileType,
      'size': size,
      'description': description,
    };
  }

  // 복사본 생성을 위한 메서드
  VulcanResourceData copyWith({
    String? id,
    String? fileName,
    String? thumbnailFileName,
    String? fileType,
    int? size,
    String? description,
  }) {
    return VulcanResourceData(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      thumbnailFileName: thumbnailFileName ?? this.thumbnailFileName,
      fileType: fileType ?? this.fileType,
      size: size ?? this.size,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'VulcanResourceModel(id: $id, fileName: $fileName, thumbnailFileName: $thumbnailFileName,  fileType: $fileType, size: $size, description: $description)';
  }
}
