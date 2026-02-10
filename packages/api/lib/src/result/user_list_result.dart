import 'package:api/api.dart';
import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';

class UserListResult extends BaseResult {
  final List<UserModel>? users;

  UserListResult({
    required super.statusCode,
    super.message,
    this.users,
  });

  factory UserListResult.fromJson(Map<String, dynamic> json) {
    final data = json.requireObject('data', (json) => json);

    return UserListResult(
      message: json.requireString('message'),
      statusCode: json.optionalInt('statusCode'),
      users: data.requireList(
        'data',
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
        'users': users?.map((user) => user.toJson()).toList(),
      },
    };
  }
}
