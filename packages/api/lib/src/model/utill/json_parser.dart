// json_parser.dart
import 'package:common_util/common_util.dart';

class JsonParser {
  final Map<String, dynamic> json;

  JsonParser(this.json);

  /// 필수 필드를 파싱하는 메소드
  T parseRequired<T>(String key, T Function(dynamic) parser) {
    final value = json[key];
    if (value == null) {
      throw FormatException('Required field "$key" is missing or null');
    }
    try {
      return parser(value);
    } catch (e) {
      throw FormatException(
          'Failed to parse required field "$key": $value\nError: $e');
    }
  }

  /// 선택적 필드를 파싱하는 메소드
  T? parseOptional<T>(String key, T Function(dynamic) parser) {
    final value = json[key];
    if (value == null) return null;
    try {
      return parser(value);
    } catch (e) {
      logger.w(
          'Warning: Failed to parse optional field "$key": $value\nError: $e');
      return null;
    }
  }

  /// String 파싱 - 필수
  String parseRequiredString(String key) {
    return parseRequired(key, (v) => v as String);
  }

  /// String 파싱 - 선택
  String? parseOptionalString(String key) {
    return parseOptional(key, (v) => v as String);
  }

  /// int 파싱 - 필수
  int parseRequiredInt(String key) {
    return parseRequired(key, (v) => v as int);
  }

  /// int 파싱 - 선택
  int? parseOptionalInt(String key) {
    return parseOptional(key, (v) => v as int);
  }

  /// double 파싱 - 필수
  double parseRequiredDouble(String key) {
    return parseRequired(key, (v) => v as double);
  }

  /// double 파싱 - 선택
  double? parseOptionalDouble(String key) {
    return parseOptional(key, (v) => v as double);
  }

  /// bool 파싱 - 필수
  bool parseRequiredBool(String key) {
    return parseRequired(key, (v) => v as bool);
  }

  /// bool 파싱 - 선택
  bool? parseOptionalBool(String key) {
    return parseOptional(key, (v) => v as bool);
  }

  /// DateTime 파싱 - 필수
  DateTime parseRequiredDateTime(String key) {
    return parseRequired(key, (v) => DateTime.parse(v as String));
  }

  /// DateTime 파싱 - 선택
  DateTime? parseOptionalDateTime(String key) {
    return parseOptional(key, (v) => DateTime.parse(v as String));
  }

  /// Map 파싱 - 필수
  Map<String, dynamic> parseRequiredMap(String key) {
    return parseRequired(key, (v) {
      if (v is! Map<String, dynamic>) {
        throw FormatException(
            'Expected Map<String, dynamic> for key "$key" but got ${v.runtimeType}');
      }
      return v;
    });
  }

  /// Map 파싱 - 선택
  Map<String, dynamic>? parseOptionalMap(String key) {
    return parseOptional(key, (v) {
      if (v is! Map<String, dynamic>) {
        throw FormatException(
            'Expected Map<String, dynamic> for key "$key" but got ${v.runtimeType}');
      }
      return v;
    });
  }

  /// List 파싱 - 필수
  List<T> parseRequiredList<T>(
    String key,
    T Function(dynamic) itemParser,
  ) {
    return parseRequired(
      key,
      (dynamic value) {
        if (value is! List) {
          throw FormatException(
              'Expected list for key "$key" but got ${value.runtimeType}');
        }
        try {
          return value.map((item) => itemParser(item)).toList();
        } catch (e) {
          throw FormatException(
              'Failed to parse list items for key "$key"\nError: $e');
        }
      },
    );
  }

  /// List 파싱 - 선택
  List<T>? parseOptionalList<T>(
    String key,
    T Function(dynamic) itemParser,
  ) {
    return parseOptional(
      key,
      (dynamic value) {
        if (value is! List) {
          throw FormatException(
              'Expected list for key "$key" but got ${value.runtimeType}');
        }
        try {
          return value.map((item) => itemParser(item)).toList();
        } catch (e) {
          throw FormatException(
              'Failed to parse list items for key "$key"\nError: $e');
        }
      },
    );
  }

  /// List 파싱 - 기본값 지원
  List<T> parseListWithDefault<T>(String key, T Function(dynamic) itemParser,
      {List<T> defaultValue = const []}) {
    return parseOptional(
          key,
          (dynamic value) {
            if (value == null) return defaultValue;
            if (value is! List) {
              throw FormatException(
                  'Expected list for key "$key" but got ${value.runtimeType}');
            }
            try {
              return value.map((item) => itemParser(item)).toList();
            } catch (e) {
              throw FormatException(
                  'Failed to parse list items for key "$key"\nError: $e');
            }
          },
        ) ??
        defaultValue;
  }

  /// 중첩 객체 파싱 - 필수
  T parseRequiredObject<T>(
    String key,
    T Function(Map<String, dynamic>) builder,
  ) {
    return parseRequired(
      key,
      (dynamic value) {
        if (value is! Map<String, dynamic>) {
          throw FormatException(
              'Expected object for key "$key" but got ${value.runtimeType}');
        }
        try {
          return builder(value);
        } catch (e) {
          throw FormatException(
              'Failed to parse nested object for key "$key"\nError: $e');
        }
      },
    );
  }

  /// 중첩 객체 파싱 - 선택
  T? parseOptionalObject<T>(
    String key,
    T Function(Map<String, dynamic>) builder,
  ) {
    return parseOptional(
      key,
      (dynamic value) {
        if (value is! Map<String, dynamic>) {
          throw FormatException(
              'Expected object for key "$key" but got ${value.runtimeType}');
        }
        try {
          return builder(value);
        } catch (e) {
          throw FormatException(
              'Failed to parse nested object for key "$key"\nError: $e');
        }
      },
    );
  }
}
