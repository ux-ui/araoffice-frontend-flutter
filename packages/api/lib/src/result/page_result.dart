import 'package:api/api.dart';
import 'package:api/src/result/base_result.dart';

class PageResult extends BaseResult {
  final ProjectModel? project;
  final PageModel? page;

  PageResult({
    required super.statusCode,
    super.message,
    this.project,
    this.page,
  });

  factory PageResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return PageResult(
      message: json['message'] as String,
      statusCode: json['statusCode'] as int?, // statusCode로 변경
      project: data['project'] != null
          ? ProjectModel.fromJson(data['project'] as Map<String, dynamic>)
          : null,
      page: data['page'] != null
          ? PageModel.fromJson(data['page'] as Map<String, dynamic>)
          : null,
    );
  }

  factory PageResult.fromApiResponseJson(ApiResponse response) {
    final data = response.data['data'] as Map<String, dynamic>; // data 객체 추가
    return PageResult(
      message: response.message,
      statusCode: response.statusCode,
      project: data['project'] != null
          ? ProjectModel.fromJson(data['project'] as Map<String, dynamic>)
          : null,
      page: data['page'] != null
          ? PageModel.fromJson(data['page'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode, // statusCode로 변경
      'data': {
        'project': project?.toJson(),
        'page': page?.toJson(),
      },
    };
  }
}
