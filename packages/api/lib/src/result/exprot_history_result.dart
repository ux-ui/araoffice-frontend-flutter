import 'package:api/api.dart';
import 'package:api/src/result/base_result.dart';

class ExportHistoryResult extends BaseResult {
  final List<ExportHistoryModel>? history;

  ExportHistoryResult({
    required super.statusCode,
    super.message,
    this.history,
  });

  factory ExportHistoryResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return ExportHistoryResult(
      message: json['message'] as String,
      statusCode: json['statusCode'] as int?,
      history: (data['history'] as List<dynamic>?) // data.history에서 리스트 가져오기
          ?.map((historyJson) =>
              ExportHistoryModel.fromJson(historyJson as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': {
        'history': history?.map((history) => history.toJson()).toList(),
      },
    };
  }
}
