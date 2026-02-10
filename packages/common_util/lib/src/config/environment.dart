import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum BuildType {
  none('none'),
  dev('dev'),
  stg('stg'),
  prod('prod'),
  scpdev('scpdev'),
  scpdevnginx('scpdevnginx'),
  scpk8s('scpk8s'),
  local('local');

  final String name;
  const BuildType(this.name);
}

class Environment {
  static const appSuffix = String.fromEnvironment('DEFINE_APP_SUFFIX');

  static BuildType get buildType {
    if (appSuffix == 'dev') {
      return BuildType.dev;
    } else if (appSuffix == 'stg') {
      return BuildType.stg;
    } else if (appSuffix == 'local') {
      return BuildType.local;
    } else if (appSuffix == 'scpdev') {
      return BuildType.scpdev;
    } else if (appSuffix == 'scpdevnginx') {
      return BuildType.scpdevnginx;
    } else if (appSuffix == 'scpk8s') {
      return BuildType.scpk8s;
    } else {
      return BuildType.prod;
    }
  }

  static final Environment _instance = Environment._internal();
  static Environment get instance => _instance;
  factory Environment() => _instance;

  Environment._internal();

  static bool isDevMode = buildType == BuildType.dev;
  static bool isStgMode = buildType == BuildType.stg;
  static bool isProdMode = buildType == BuildType.prod;
  static bool isLocalMode = buildType == BuildType.local;
  static bool isScpdevMode = buildType == BuildType.scpdev;
  static bool isScpdevnginxMode = buildType == BuildType.scpdevnginx;
  static bool isScpk8sMode = buildType == BuildType.scpk8s;

  static const isDebugMode = kDebugMode;
  static const isProfileMode = kProfileMode;
  static const isReleaseMode = kReleaseMode;

  static String get version => _version;
  static String get buildNumber => _buildNumber;

  static String _version = '1.0.0';
  static String _buildNumber = '';

  static String get appVersion =>
      kReleaseMode && isProdMode ? 'v$_version' : 'v$_version+$_buildNumber';

  static Future<void> loadVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
  }
}
