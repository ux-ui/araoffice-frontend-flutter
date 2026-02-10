import 'package:api/api.dart';
import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';

class UserInfoResult extends BaseResult {
  final UserModel? user;

  UserInfoResult({
    required super.statusCode,
    super.message,
    this.user,
  });

  factory UserInfoResult.fromJson(Map<String, dynamic> json) {
    final data = json.requireObject('data', (json) => json);

    return UserInfoResult(
      message: json.requireString('message'),
      statusCode: json.optionalInt('statusCode'),
      user: data.requireObject(
        'user', // data 안에서 project를 찾도록 변경
        (json) => UserModel.fromJson(json),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': {
        'user': user?.toJson(),
      },
    };
  }
}
