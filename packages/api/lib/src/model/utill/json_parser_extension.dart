// json_parser_extension.dart
import 'json_parser.dart';

extension JsonParserExtension on Map<String, dynamic> {
  /// 필수 String
  String requireString(String key) {
    return JsonParser(this).parseRequiredString(key);
  }

  /// 선택적 String
  String? optionalString(String key) {
    return JsonParser(this).parseOptionalString(key);
  }

  /// 필수 int
  int requireInt(String key) {
    return JsonParser(this).parseRequiredInt(key);
  }

  /// 선택적 int
  int? optionalInt(String key) {
    return JsonParser(this).parseOptionalInt(key);
  }

  /// 필수 double
  double requireDouble(String key) {
    return JsonParser(this).parseRequiredDouble(key);
  }

  /// 선택적 double
  double? optionalDouble(String key) {
    return JsonParser(this).parseOptionalDouble(key);
  }

  /// 필수 bool
  bool requireBool(String key) {
    return JsonParser(this).parseRequiredBool(key);
  }

  /// 선택적 bool
  bool? optionalBool(String key) {
    return JsonParser(this).parseOptionalBool(key);
  }

  /// 필수 DateTime
  DateTime requireDateTime(String key) {
    return JsonParser(this).parseRequiredDateTime(key);
  }

  /// 선택적 DateTime
  DateTime? optionalDateTime(String key) {
    return JsonParser(this).parseOptionalDateTime(key);
  }

  /// 필수 Map
  Map<String, dynamic> requireMap(String key) {
    return JsonParser(this).parseRequiredMap(key);
  }

  /// 선택적 Map
  Map<String, dynamic>? optionalMap(String key) {
    return JsonParser(this).parseOptionalMap(key);
  }

  /// 필수 List
  List<T> requireList<T>(
    String key,
    T Function(dynamic) itemParser,
  ) {
    return JsonParser(this).parseRequiredList(key, itemParser);
  }

  /// 선택적 List
  List<T>? optionalList<T>(
    String key,
    T Function(dynamic) itemParser,
  ) {
    return JsonParser(this).parseOptionalList(key, itemParser);
  }

  /// 기본값이 있는 List
  List<T> listWithDefault<T>(
    String key,
    T Function(dynamic) itemParser, {
    List<T> defaultValue = const [],
  }) {
    return JsonParser(this).parseListWithDefault(
      key,
      itemParser,
      defaultValue: defaultValue,
    );
  }

  /// 필수 Object
  T requireObject<T>(
    String key,
    T Function(Map<String, dynamic>) builder,
  ) {
    return JsonParser(this).parseRequiredObject(key, builder);
  }

  /// 선택적 Object
  T? optionalObject<T>(
    String key,
    T Function(Map<String, dynamic>) builder,
  ) {
    return JsonParser(this).parseOptionalObject(key, builder);
  }
}
