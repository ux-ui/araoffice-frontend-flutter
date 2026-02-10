import 'environment.dart';

enum TenantType {
  ara('ara'), // 아라
  standard('standard'), // standard
  gov(''), // 공공
  mois('mois'), // 행안부
  msit('msit'), // 과학기술정보통신부
  mfds('mfds'), // 식품의약품안전처
  devMois('dev-mois'), // 행안부 (개발)
  devMsit('dev-msit'), // 과학기술정보통신부 (개발)
  dferi('dferi'), // 대구미래교육연구원
  mpb('mpb'), // 기획예산처
  none(''),
  naverWorks('NAVER-WORKS'); // 네이버 웍스

  final String id;
  const TenantType(this.id);
  factory TenantType.fromString(String tag) {
    return TenantType.values.firstWhere(
      (type) => type.id == tag.toLowerCase(),
      orElse: () => TenantType.none,
    );
  }
}

enum DomainType {
  // - 아라 ------------------------------------------------------------
  araDev(
    'https://dev.araepub.com',
    '',
    '/api/v1/',
    TenantType.ara,
    BuildType.dev,
  ),
  araStage(
    'https://stg.araepub.com',
    '',
    '/api/v1/',
    TenantType.ara,
    BuildType.stg,
  ),
  ara(
    'https://araepub.com',
    '',
    '/api/v1/',
    TenantType.ara,
    BuildType.prod,
  ),
  araDemo(
    'https://demo.araepub.com',
    '',
    '/api/v1/',
    TenantType.ara,
    BuildType.prod,
  ),
  araDemoStage(
    'https://stg-demo.araepub.com',
    '',
    '/api/v1/',
    TenantType.ara,
    BuildType.stg,
  ),
  araDemoDev(
    'https://dev-demo.araepub.com',
    '',
    '/api/v1/',
    TenantType.ara,
    BuildType.dev,
  ),
  // - standard -------------------------------------------------------------
  standardLocal(
    'https://standard.araoffice.local',
    '',
    '/api/v1/',
    TenantType.standard,
    BuildType.local,
  ),
  standardAraepubDev(
    'https://dev-standard.araepub.com',
    '',
    '/api/v1/',
    TenantType.standard,
    BuildType.scpk8s,
  ),
  standardAraepubStage(
    'https://stg-standard.araepub.com',
    '',
    '/api/v1/',
    TenantType.standard,
    BuildType.scpk8s,
  ),
  standardAraepub(
    'https://standard.araepub.com',
    '',
    '/api/v1/',
    TenantType.standard,
    BuildType.scpk8s,
  ),
  // govLocalHttp(
  //   'http://araoffice.local',
  //   '',
  //   '/api/v1/',
  //   TenantType.ara,
  //   BuildType.scpk8s,
  // ),
  // // Kubernetes 개발 환경 (HTTPS)
  // govLocalHttps(
  //   'https://araoffice.local',
  //   '',
  //   '/api/v1/',
  //   TenantType.ara,
  //   BuildType.scpk8s,
  // ),
  // - 공공 ------------------------------------------------------------
  // Kubernetes 개발 환경 (HTTP)
  // govLocalHttp(
  //   'http://araoffice.local',
  //   '',
  //   '/api/v1/',
  //   TenantType.gov,
  //   BuildType.scpk8s,
  // ),
  // // Kubernetes 개발 환경 (HTTPS)
  // govLocalHttps(
  //   'https://araoffice.local',
  //   '',
  //   '/api/v1/',
  //   TenantType.gov,
  //   BuildType.scpk8s,
  // ),
  govDev(
    'https://araoffice-gov.dev',
    '',
    '/api/v1/',
    TenantType.gov,
    BuildType.scpk8s,
  ),
  gov(
    'https://araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.gov,
    BuildType.scpk8s,
  ),
  // - 행안부 ------------------------------------------------------------
  // Docker localhost 환경
  moisLocal(
    'https://mois.araoffice.local',
    '',
    '/api/v1/',
    TenantType.mois,
    BuildType.local,
  ),
  moisDev(
    'http://123.41.35.97',
    '',
    '/api/v1/',
    TenantType.mois,
    BuildType.scpdev,
  ),
  moisDevNginx(
    'https://123.41.32.175',
    '',
    '/api/v1/',
    TenantType.mois,
    BuildType.scpdevnginx,
  ),
  moisDevK8s(
    'https://mois.araoffice-gov.dev',
    '',
    '/api/v1/',
    TenantType.mois,
    BuildType.scpk8s,
  ),
  moisStage(
    'https://stg-mois.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.mois,
    BuildType.scpk8s,
  ),
  mois(
    'https://mois.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.mois,
    BuildType.scpk8s,
  ),
  moisDevAraoffice(
    'https://dev-mois.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.devMois,
    BuildType.scpk8s,
  ),
  moisAraepubDev(
    'https://dev-mois.araepub.com',
    '',
    '/api/v1/',
    TenantType.mois,
    BuildType.scpk8s,
  ),
  moisAraepubStage(
    'https://stg-mois.araepub.com',
    '',
    '/api/v1/',
    TenantType.mois,
    BuildType.scpk8s,
  ),
  moisAraepub(
    'https://mois.araepub.com',
    '',
    '/api/v1/',
    TenantType.mois,
    BuildType.scpk8s,
  ),
  // - 과학기술정보통신부 ----------------------------------------------------------
  msitLocal(
    'https://msit.araoffice.local',
    '',
    '/api/v1/',
    TenantType.msit,
    BuildType.local,
  ),
  msitDev(
    'https://msit.araoffice-gov.dev',
    '',
    '/api/v1/',
    TenantType.msit,
    BuildType.scpk8s,
  ),
  msitStage(
    'https://stg-msit.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.msit,
    BuildType.scpk8s,
  ),
  msit(
    'https://msit.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.msit,
    BuildType.scpk8s,
  ),
  msitAraofficeDev(
    'https://dev-msit.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.devMsit,
    BuildType.scpk8s,
  ),
  // - 식품의약품안전처 ------------------------------------------------------------
  mfdsLocal(
    'https://mfds.araoffice.local',
    '',
    '/api/v1/',
    TenantType.mfds,
    BuildType.local,
  ),
  mfdsDev(
    'https://mfds.araoffice-gov.dev',
    '',
    '/api/v1/',
    TenantType.mfds,
    BuildType.scpk8s,
  ),
  mfdsStage(
    'https://stg-mfds.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.mfds,
    BuildType.scpk8s,
  ),
  mfds(
    'https://mfds.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.mfds,
    BuildType.scpk8s,
  ),
  mfdsAraofficeDev(
    'https://dev-mfds.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.mfds,
    BuildType.scpk8s,
  ),
  // - 대구미래교육연구원 ----------------------------------------------------------
  dferiLocal(
    'https://dferi.araoffice.local',
    '',
    '/api/v1/',
    TenantType.dferi,
    BuildType.local,
  ),
  dferiAraepub(
    'https://dferi.araepub.com',
    '',
    '/api/v1/',
    TenantType.dferi,
    BuildType.scpk8s,
  ),
  // dferi(
  //   'https://www.edunavi.kr/booknavi/araoffice',
  //   '',
  //   '/api/v1/',
  //   TenantType.dferi,
  //   BuildType.scpk8s,
  // ),

  // 수정 전
  dferi(
    'https://www.edunavi.kr',
    '/booknavi/araoffice',
    '/api/v1/',
    TenantType.dferi,
    BuildType.scpk8s,
  ),
  // - 기획예산처 ----------------------------------------------------------
  mpb(
    'https://mpb.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.mpb,
    BuildType.scpk8s,
  ),
  mpbDev(
    'https://dev-mpb.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.mpb,
    BuildType.scpk8s,
  ),
  mpbStage(
    'https://stg-mpb.araoffice.go.kr',
    '',
    '/api/v1/',
    TenantType.mpb,
    BuildType.scpk8s,
  ),

  // - localhost ------------------------------------------------------------
  // 로컬 개발 환경으로 간주 - nginx 프록시를 통해 백엔드로 요청
  localhostDev(
    'http://localhost:12342',
    ':8080',
    '/api/v1/',
    TenantType.none,
    BuildType.local,
  ),
  // Docker localhost 환경
  localhost(
    'http://localhost',
    ':8080',
    '/api/v1/',
    TenantType.none,
    BuildType.local,
  ),

  // ------ 로컬 환경 도메인
  // moisLocal(
  //   'https://mois.araoffice.local',
  //   '',
  //   '/api/v1/',
  //   TenantType.mois,
  //   BuildType.local,
  // ),
  // msitLocal(
  //   'https://msit.araoffice.local',
  //   '',
  //   '/api/v1/',
  //   TenantType.msit,
  //   BuildType.local,
  // ),
  // mfdsLocal(
  //   'https://mfds.araoffice.local',
  //   '',
  //   '/api/v1/',
  //   TenantType.mfds,
  //   BuildType.local,
  // ),
  govLocalHttp(
    'http://araoffice.local',
    '',
    '/api/v1/',
    TenantType.ara,
    BuildType.local,
  ),
  // Kubernetes 개발 환경 (HTTPS)
  govLocalHttps(
    'https://araoffice.local',
    '',
    '/api/v1/',
    TenantType.ara,
    BuildType.local,
  ),

  // - 알 수 없는 도메인 ----------------------------------------------------------
  unknown(
    'unknown',
    '',
    '',
    TenantType.none,
    BuildType.none,
  );

  final String domain; // 도메인 검사 시 사용. 포트 포함.
  final String port; // 포트 변경 시 사용.
  final String api; // 기본 API 경로.
  final TenantType tenantType; // 'mois', 'msit', 'mfds', ...
  final BuildType buildType;

  const DomainType(
    this.domain,
    this.port,
    this.api,
    this.tenantType,
    this.buildType,
  );
  factory DomainType.fromString(String url) {
    return DomainType.values.firstWhere(
      (type) => url.startsWith(type.domain),
      orElse: () => DomainType.unknown,
    );
  }

  // https://araepub.com => https://araepub.com
  // http://localhost:12342 => http://localhost:8080
  // https://www.edunavi.kr/booknavi/araoffice => https://www.edunavi.kr/booknavi/araoffice

  String get originWithPath {
    final uri = Uri.tryParse(domain);
    if (uri != null) {
      return '${uri.scheme}://${uri.host}$port${uri.path}';
    } else {
      // 포트 부분만 정의된 값으로 교체
      final replacedDomain = domain.replaceFirst(RegExp(r':\d+'), port);
      return replacedDomain;
    }
  }

  String get apiUrl => '$originWithPath$api';

  /// 각 테넌트의 인증 URL 형식
  ///
  /// https://{테넌트ID}.araoffice.local/oauth2/authorization/{테넌트ID}
  String get oauth2Url =>
      '$originWithPath/oauth2/authorization/${tenantType.id}';

  /// 각 테넌트의 폰트 URL
  ///
  /// 일단 mois를 기본으로 사용하고, 아라 도메인일 경우에만 public 폰트를 사용.
  String get fontUrl {
    if (isAraDomain) {
      return '$originWithPath/fonts/public/font.json';
    }
    return '$originWithPath/fonts/mois/font.json';
  }

  /// 아라
  bool get isAraDomain =>
      this == araDev ||
      this == araStage ||
      this == ara ||
      // this == araDemo ||
      // this == araDemoStage ||
      // this == araDemoDev ||
      this == govLocalHttp ||
      this == govLocalHttps ||
      // this == standardAraepub ||
      this == govDev;

  bool get isAraDemoDomain =>
      this == araDemo || this == araDemoStage || this == araDemoDev;

  /// standard
  bool get isStandardDomain =>
      this == standardLocal ||
      this == standardAraepubDev ||
      this == standardAraepubStage ||
      this == standardAraepub;

  /// araepub - standard
  bool get isAraepubStandardDomain =>
      this == standardAraepubDev ||
      this == standardAraepubStage ||
      this == standardAraepub;

  /// 공공
  bool get isGovDomain =>
      // this == govLocalHttp ||
      // this == govLocalHttps ||
      // this == govDev ||
      this == gov;

  /// 기획예산처
  bool get isMpbDomain => this == mpb || this == mpbDev || this == mpbStage;

  /// 행안부
  bool get isMoisDomain =>
      // this == moisLocal ||
      // this == moisDev ||
      this == moisDevNginx ||
      this == moisDevK8s ||
      this == moisStage ||
      this == mois ||
      this == moisDev;
  // ||
  // this == moisAraepubDev ||
  // this == moisAraepubStage ||
  // this == moisAraepub;

  bool get isMoisAraepubDomain =>
      this == moisAraepubDev || this == moisAraepubStage || this == moisAraepub;

  /// mois local alpha test
  bool get isMoisLocalDomain => this == moisLocal;

  bool get isMoisAraofficeDevDomain => this == moisDevAraoffice;

  /// 과학기술정보통신부
  bool get isMsitDomain =>
      this == msitLocal || this == msitStage || this == msit || this == msitDev;

  bool get isMsitAraofficeDevDomain => this == msitAraofficeDev;

  /// 식품의약품안전처
  bool get isMfdsDomain =>
      this == mfdsLocal ||
      this == mfdsDev ||
      // this == mfdsStage ||
      this == mfds;

  bool get isMfdsNormalDomain => this == mfdsStage || this == mfdsAraofficeDev;

  /// 대구미래교육연구원
  bool get isDferiDomain =>
      this == dferiLocal || this == dferiAraepub || this == dferi;

  /// 로컬 개발 환경
  bool get isLocalDevDomain => this == localhostDev;
  bool get isLocalDomain => this == localhost;
  // ||
  // this == moisLocal ||
  // this == msitLocal ||
  // this == mfdsLocal ||
  // this == govLocalHttp ||
  // this == govLocalHttps;

  /// araepub.com을 사용하는 타입
  bool get isAraepubDomain =>
      this == araDev ||
      this == araStage ||
      this == ara ||
      this == araDemo || // demo.araepub.com
      this == araDemoStage ||
      this == araDemoDev ||
      // this == govLocalHttp ||
      // this == govLocalHttps ||
      this == standardAraepubDev ||
      this == standardAraepubStage ||
      this == standardAraepub ||
      this == moisAraepubDev ||
      this == moisAraepubStage ||
      this == moisAraepub ||
      this == dferiAraepub;

  // 폐쇄망 구분
  bool get isClosedNetworkDomain =>
      this == gov ||
      this == moisStage ||
      this == msitStage ||
      this == mfdsStage ||
      this == mois ||
      this == msit ||
      this == mfds;

  bool get isGovDomainWithoutTenant => this == gov;

  /// 알 수 없는 도메인
  bool get isUnknownDomain => this == unknown;
}
