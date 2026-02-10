import 'dart:js_interop';

import 'package:web/web.dart' as web;

@JS('Object.keys')
external JSArray keys(JSObject obj);

@JS('typeof')
external String getJSType(JSAny value);

@JS()
@anonymous
extension type JSWidgetInfo(JSObject _) implements JSObject {
  external factory JSWidgetInfo.create({
    required web.Node widget, // EditorHtmlNode
    required JSAny id, // WidgetId
    required JSAny key,
  });

  external web.Node get widget;
  external JSAny get id;
  // external JSAny get key;

// 동적 속성 접근을 위한 메서드 추가
  // external JSAny getProperty(String propertyName);
  // external void setProperty(String propertyName, JSAny value);

  // 모든 속성 이름 목록 가져오기 (안전하게)
  List<String> getAllPropertyNames() {
    try {
      // JS의 Object.keys 활용
      final keysArray = keys(this);
      return List<String>.from(keysArray.dartify() as List);
    } catch (e) {
      // 키 추출 실패시 기본 속성만 포함
      return ['widget', 'id'];
    }
  }

  // 단일 속성의 안전한 접근 및 변환
  dynamic getSafePropertyValue(String name) {
    try {
      final value = this[name];
      if (value == null) return null;

      // 기본 타입만 dartify 시도
      try {
        return value.dartify();
      } catch (e) {
        // dartify 실패시, 타입 정보만 반환
        return '[JavaScript 객체]';
      }
    } catch (e) {
      return '[접근 불가]';
    }
  }

  // 모든 속성과 값을 Map으로 가져오기 (안전하게 모든 속성 접근)
  Map<String, dynamic> getAllProperties() {
    final result = <String, dynamic>{};

    try {
      // 기타 모든 속성 안전하게 접근 시도
      try {
        // JavaScript 속성 이름 목록 가져오기
        final propertyNames = getAllPropertyNames();
        // 나머지 속성 처리
        for (final name in propertyNames) {
          // 각 속성 개별적으로 try-catch로 감싸기
          try {
            final value = this[name];

            // null 체크
            if (value == null) {
              result[name] = null;
              continue;
            }

            // 안전하게 변환 시도
            try {
              // 기본 타입은 dartify 가능
              result[name] = value.dartify();
            } catch (_) {
              // 함수 같은 복잡한 타입은 설명만 표시
              result[name] = '[복잡한 JavaScript 객체]';
            }
          } catch (_) {
            // 개별 속성 접근 실패
            result[name] = '[접근 불가 속성]';
          }
        }
      } catch (e) {
        // 속성 열거 실패 시
        result['_error'] = '추가 속성 열거 실패: $e';
      }
    } catch (e) {
      // 완전 실패 시
      return {'error': '속성 접근 실패: $e'};
    }

    return result;
  }

  // 모든 속성을 문자열로 출력 (안전한 구현)
  String printAllProperties() {
    try {
      final properties = getAllProperties();
      final buffer = StringBuffer();

      // 명시적 반복으로 안전하게 구현
      final keys = properties.keys.toList();
      for (int i = 0; i < keys.length; i++) {
        final key = keys[i];
        buffer.writeln('$key: ${properties[key]}');
      }

      return buffer.toString();
    } catch (e) {
      return '속성 출력 중 오류 발생: $e';
    }
  }

  // @JS('[]') 주석 제거
  external JSAny? operator [](String key);

  // @JS('[]=') 주석 제거
  external void operator []=(String key, JSAny? value);
}
