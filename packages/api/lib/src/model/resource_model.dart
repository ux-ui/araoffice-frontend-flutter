import 'utill/json_parser.dart';

class ResourceModel {
  final String id;
  final String fileName;
  final String? thumbnailFileName;
  final String fileType;
  final int size; // Dart에서는 long 대신 int 사용
  final String description;
  final String?
      type; // 클립아트, 이미지와 widget 이미지를 분리하기 위해 추가 [clipart, image, widget]

  ResourceModel({
    required this.id,
    required this.fileName,
    this.thumbnailFileName,
    required this.fileType,
    required this.size,
    required this.description,
    this.type,
  });

  // JSON으로부터 모델 생성
  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    final parser = JsonParser(json);

    return ResourceModel(
      id: parser.parseRequiredString('id'),
      fileName: parser.parseRequiredString('fileName'),
      thumbnailFileName: parser.parseOptionalString('thumbnailFileName'),
      fileType: parser.parseRequiredString('fileType'),
      size: parser.parseRequiredInt('size'),
      description: parser.parseRequiredString('description'),
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
  ResourceModel copyWith({
    String? id,
    String? fileName,
    String? thumbnailFileName,
    String? fileType,
    int? size,
    String? description,
  }) {
    return ResourceModel(
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
    return 'FileModel(id: $id, fileName: $fileName, thumbnailFileName: $thumbnailFileName, fileType: $fileType, size: $size, description: $description)';
  }
}
