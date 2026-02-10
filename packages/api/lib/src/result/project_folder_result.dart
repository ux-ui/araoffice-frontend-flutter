import 'package:api/api.dart';
import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';

import '../model/utill/json_parser.dart';

class ProjectFolderResult extends BaseResult {
  final ProjectModel? project;
  final FolderModel? folder;

  ProjectFolderResult({
    required super.statusCode,
    super.message,
    this.project,
    this.folder,
  });

  factory ProjectFolderResult.fromJson(Map<String, dynamic> json) {
    final data =
        json.optionalObject<Map<String, dynamic>>('data', (json) => json);
    final statusCode =
        data?.optionalInt('statusCode') ?? json.optionalInt('statusCode');
    final message =
        data?.optionalString('message') ?? json.optionalString('message');
    final project = data != null ? data['project'] : null;
    final folder = data != null ? data['folder'] : null;

    return ProjectFolderResult(
      statusCode: statusCode,
      message: message,
      project: (project != null && project is Map<String, dynamic>)
          ? ProjectModel.fromJson(project)
          : null,
      folder: (folder != null && folder is Map<String, dynamic>)
          ? FolderModel.fromJson(folder)
          : null,
    );
  }

  factory ProjectFolderResult.fromApiResponseJson(ApiResponse response) {
    try {
      final parser = JsonParser(response.data);

      return ProjectFolderResult(
        message: response.message,
        statusCode: response.statusCode,
        project: parser.parseOptionalObject(
          'project',
          (json) => ProjectModel.fromJson(json),
        ),
        folder: parser.parseOptionalObject(
          'folder',
          (json) => FolderModel.fromJson(json),
        ),
      );
    } catch (e) {
      throw FormatException(
          'Failed to parse ProjectFolderResult: ${e.toString()}');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode, // statusCode로 변경
      'data': {
        'project': project?.toJson(),
        'folder': folder?.toJson(),
      },
    };
  }
}
