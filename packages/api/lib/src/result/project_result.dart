import 'package:api/api.dart';
import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';
import 'package:common_util/common_util.dart';

class ProjectResult extends BaseResult {
  final ProjectModel? project;

  ProjectResult({
    required super.statusCode,
    super.message,
    this.project,
  });

  factory ProjectResult.fromJson(Map<String, dynamic> json) {
    try {
      final statusCode = json.optionalInt('statusCode');
      if (statusCode == 200) {
        final data = json.requireObject('data', (json) => json);

        return ProjectResult(
          message: json.requireString('message'),
          statusCode: json.optionalInt('statusCode'), // statusCode로 변경
          project: data.optionalObject(
            'project', // data 안에서 project를 찾도록 변경
            (json) => ProjectModel.fromJson(json),
          ),
        );
      } else {
        return ProjectResult(
          message: json.requireString('message'),
          statusCode: json.optionalInt('statusCode'),
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error parsing ProjectResult: $json', e, stackTrace);
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode, // statusCode로 변경
      'data': {
        'project': project?.toJson(),
      },
    };
  }
}
