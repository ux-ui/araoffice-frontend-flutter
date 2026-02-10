import 'package:api/api.dart';
import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';

class ProjectListResult extends BaseResult {
  final List<ProjectModel>? projects;

  ProjectListResult({
    required super.statusCode,
    super.message,
    this.projects,
  });

  factory ProjectListResult.fromJson(Map<String, dynamic> json) {
    final data =
        json.optionalObject<Map<String, dynamic>>('data', (json) => json);
    final statusCode =
        data?.optionalInt('statusCode') ?? json.optionalInt('statusCode');
    final message =
        data?.optionalString('message') ?? json.optionalString('message');
    final projects = data != null ? data['projects'] : null;

    return ProjectListResult(
      statusCode: statusCode,
      message: message,
      projects: (projects != null && projects is List<dynamic>)
          ? projects
              .map((projectJson) =>
                  ProjectModel.fromJson(projectJson as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode, // statusCode로 변경
      'data': {
        'projects': projects?.map((project) => project.toJson()).toList(),
      },
    };
  }
}
