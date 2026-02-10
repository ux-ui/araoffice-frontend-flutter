import 'package:api/src/model/cloud/cloud_file_model.dart';

import 'cloud_result.dart';

class CloudFileListResult {
  final List<CloudFileModel> files;
  final CloudMetaData metaData;

  CloudFileListResult({
    required this.files,
    required this.metaData,
  });

  factory CloudFileListResult.fromJson(Map<String, dynamic> json) {
    return CloudFileListResult(
      files: (json['files'] != null && json['files'] is List<dynamic>)
          ? (json['files'] as List<dynamic>)
              .map((file) => CloudFileModel.fromJson(file))
              .toList()
          : [],
      metaData: CloudMetaData.fromJson(json['responseMetaData'] ?? {}),
    );
  }
}
