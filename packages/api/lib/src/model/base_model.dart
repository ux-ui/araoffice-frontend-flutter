abstract class BaseModel {
  Map<String, dynamic> toJson();

  static T fromJson<T extends BaseModel>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in the subclass');
  }
}
