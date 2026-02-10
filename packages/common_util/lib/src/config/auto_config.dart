import 'package:web/web.dart';

import '../../common_util.dart';

class AutoConfig {
  static AutoConfig? _instance;
  late final DomainType domainType;
  late final String apiUrl;
  late final BuildType environment;

  // 싱글톤 인스턴스 getter
  static AutoConfig get instance {
    _instance ??= AutoConfig._();
    return _instance!;
  }

  AutoConfig._() {
    _initializeConfig();
  }

  void _initializeConfig() {
    // 현재 웹 페이지의 URL을 가져옴
    final currentUrl = window.location.href;
    final uri = Uri.tryParse(currentUrl);
    final origin = uri?.origin ?? '';
    domainType = DomainType.fromString(origin);
    apiUrl = domainType.apiUrl;
    environment = domainType.buildType;
    logger.d('[${domainType.name}] apiUrl: $apiUrl, environment: $environment');

    if (domainType == DomainType.unknown) {
      apiUrl = '${window.location.origin}/api/v1/';
      logger.e('wildcard api: ${window.location.origin}/api/v1/');
      environment = BuildType.none;
    }
  }
}
