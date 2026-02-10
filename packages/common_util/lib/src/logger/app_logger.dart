import 'package:flutter/foundation.dart';

import '../config/environment.dart';

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error;

  String get prefix {
    switch (this) {
      case LogLevel.verbose:
        return '🔍 VERBOSE';
      case LogLevel.debug:
        return '🐛 DEBUG';
      case LogLevel.info:
        return '💡 INFO';
      case LogLevel.warning:
        return '⚠️ WARNING';
      case LogLevel.error:
        return '❌ ERROR';
    }
  }
}

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  static AppLogger get instance => _instance;

  // 로깅 활성화를 위한 내부 설정값
  static const String _k7x9vQ2m = 'vulcan_debug_2024';
  bool _forceLogging = false;

  factory AppLogger() => _instance;

  AppLogger._internal();

  /* 
  * Release 모드에서 로깅을 활성화하는 방법:
  * 
  * ```dart
  * // 로깅 활성화
  * logger.enableLogging('vulcan_debug_2024');
  * 
  * // 로깅 비활성화
  * logger.disableLogging();
  * ```
  * 
  * 주의: 프로덕션 환경에서는 필요한 경우에만 일시적으로 사용하세요.
  */
  void enableLogging(String code) {
    if (code == _k7x9vQ2m) {
      _forceLogging = true;
      i('Logging enabled by secret code');
    }
  }

  void disableLogging() {
    _forceLogging = false;
    i('Logging disabled');
  }

  bool _shouldLog(LogLevel level) {
    // 시크릿 코드로 활성화된 경우
    if (_forceLogging) return true;

    // Release 모드에서는 모든 로그 비활성화
    if (kReleaseMode) return false;

    // Debug, Profile 모드나 개발 환경에서는 모든 로그 활성화
    if (kDebugMode || kProfileMode || Environment.isDevMode) {
      return true;
    }

    return false;
  }

  void _log(LogLevel level, String message,
      [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog(level)) return;

    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '$timestamp ${level.prefix} $message';

    debugPrint(logMessage);

    if (error != null) {
      debugPrint('Error: $error');
    }

    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  void v(String message) {
    _log(LogLevel.verbose, message);
  }

  void d(String message) {
    _log(LogLevel.debug, message);
  }

  void i(String message) {
    _log(LogLevel.info, message);
  }

  void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }
}

// 편의성을 위한 전역 getter
AppLogger get logger => AppLogger.instance;
