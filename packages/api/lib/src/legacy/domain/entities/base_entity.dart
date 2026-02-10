abstract class BaseEntity {
  Map<String, dynamic> toJson();

  static T fromJson<T extends BaseEntity>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in the subclass');
  }
}
