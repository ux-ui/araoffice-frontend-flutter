import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 위치 정보를 브라우저 저장소에 저장하고 관리하는 클래스
class PositionStorage {
  static const String _keyPrefix = 'position_';

  /// 위치 정보를 저장하는 메서드
  /// [saveId] 저장할 위치의 고유 ID
  /// [x] X 좌표 값
  /// [y] Y 좌표 값
  /// [positionType] 위치 타입 문자열 (예: "50% 50%")
  static Future<bool> savePosition({
    required String saveId,
    required double x,
    required double y,
    required String positionType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 각각의 값을 저장
      await prefs.setDouble('$_keyPrefix${saveId}_x', x);
      await prefs.setDouble('$_keyPrefix${saveId}_y', y);
      await prefs.setString('$_keyPrefix${saveId}_type', positionType);

      return true;
    } catch (e) {
      debugPrint('위치 저장 실패: $e');
      return false;
    }
  }

  /// 저장된 위치 정보를 불러오는 메서드
  /// [saveId] 불러올 위치의 고유 ID
  /// 반환값: Map<String, dynamic> 형태로 x, y, positionType 포함
  static Future<Map<String, dynamic>?> loadPosition(String saveId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final x = prefs.getDouble('$_keyPrefix${saveId}_x');
      final y = prefs.getDouble('$_keyPrefix${saveId}_y');
      final positionType = prefs.getString('$_keyPrefix${saveId}_type');

      if (x != null && y != null && positionType != null) {
        return {
          'x': x,
          'y': y,
          'positionType': positionType,
        };
      }

      return null;
    } catch (e) {
      debugPrint('위치 로드 실패: $e');
      return null;
    }
  }

  /// 특정 위치 정보를 삭제하는 메서드
  /// [saveId] 삭제할 위치의 고유 ID
  static Future<bool> deletePosition(String saveId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('$_keyPrefix${saveId}_x');
      await prefs.remove('$_keyPrefix${saveId}_y');
      await prefs.remove('$_keyPrefix${saveId}_type');

      return true;
    } catch (e) {
      debugPrint('위치 삭제 실패: $e');
      return false;
    }
  }

  /// 저장된 모든 위치 ID 목록을 가져오는 메서드
  static Future<List<String>> getAllSavedPositionIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      final positionIds = <String>{};

      for (final key in keys) {
        if (key.startsWith(_keyPrefix) && key.endsWith('_x')) {
          final saveId =
              key.replaceFirst(_keyPrefix, '').replaceFirst('_x', '');
          positionIds.add(saveId);
        }
      }

      return positionIds.toList();
    } catch (e) {
      debugPrint('위치 ID 목록 로드 실패: $e');
      return [];
    }
  }

  /// 모든 저장된 위치 정보를 삭제하는 메서드
  static Future<bool> clearAllPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_keyPrefix)) {
          await prefs.remove(key);
        }
      }

      return true;
    } catch (e) {
      debugPrint('모든 위치 정보 삭제 실패: $e');
      return false;
    }
  }
}
