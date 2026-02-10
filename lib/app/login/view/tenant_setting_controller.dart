import 'package:app/app/login/view/login_controller.dart';
import 'package:author_editor/enum/enums.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class TenantSettingController extends GetxController {
  final loginController = Get.find<LoginController>();

  final customer = CustomerType.values.first.obs; // 고객 유형
  final environment = EnvironmentType.values.first.obs; // 환경 유형
  final userLoginType = UserLoginType.values.first.obs; // 로그인 유형
  final tenantType = TenantType.values.first.obs; // 테넌트 유형

  final loginType = LoginType.values.first.obs; // 아이디, 비밀번호 방식
  final accountFindStatus = false.obs; // 아이디, 비밀번호 찾기
  final simpleAraLoginStatus = false.obs; // 간편로그인 아라
  final simpleBrityWorksLoginStatus = false.obs; // 간편로그인 브리티
  final simpleNaverWorksLoginStatus = false.obs; // 간편로그인 네이버 웍스
  // final simpleNaverLoginStatus = false.obs;
  // final simpleGoogleLoginStatus = false.obs;
  // final simpleKakaoLoginStatus = false.obs;

  final cloudLinkStatus = false.obs; // 클라우드 연동
  final templateMarketingStatus = false.obs; // 템플릿 마켓
  final authorPlanStatus = false.obs; // 오서 플랜
  final subscribeManagementStatus = false.obs; // 구독 관리
  final helpCenterStatus = false.obs; // 도움말 센터
  final termsOfServiceStatus = false.obs; // 이용약관
  final privacyPolicyStatus = false.obs; // 개인정보 처리방침
  final servicePolicyStatus = false.obs; // 서비스 정책
  final youthProtectionPolicyStatus = false.obs; // 청소년 보호 정책

  final exportHistoryStatus = false.obs; // 내보내기 기록
  final docCoOperationStatus = false.obs; // 문서 협업

  final cloudProjectSaveStatus = false.obs; // 클라우드 프로젝트 저장
  final govElementLogoStatus = false.obs; // 정부 요소 로고
  final mathMenuStatus = false.obs; // 수학 메뉴
  final tooggleWidgetStatus = false.obs; // 토글 위젯
  final tabWidgetStatus = false.obs; // 탭 위젯
  final accordionWidgetStatus = false.obs; // 아코디언 위젯
  final quizWidgetStatus = false.obs; // 퀴즈 위젯
  final shareStatus = false.obs; // 공유 유무

  final accountSettingStatus = LoginType.araService.obs; // 계정 설정

  final confirmTenantSetting = ''.obs; // 테넌트 설정 확인

  @override
  void onInit() {
    super.onInit();
    getAutoConfigSetting();
  }

  void getAutoConfigSetting() {
    if (AutoConfig.instance.domainType.isAraDomain) {
      userLoginType.value = UserLoginType.ara;
      tenantType.value = TenantType.ara;
      araServiceSetting();
      confirmTenantSetting.value = 'araService';
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    } else if (AutoConfig.instance.domainType.isGovDomain) {
      userLoginType.value = UserLoginType.sso;
      tenantType.value = TenantType.gov;
      noCloudLinkSetting();
      confirmTenantSetting.value = 'worksPrivate';
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    } else if (AutoConfig.instance.domainType.isMoisAraofficeDevDomain) {
      userLoginType.value = UserLoginType.sso;
      tenantType.value = TenantType.mois;
      moisDevSetting();
      confirmTenantSetting.value = 'moisDev setting';
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    } else if (AutoConfig.instance.domainType.isMsitAraofficeDevDomain) {
      userLoginType.value = UserLoginType.sso;
      tenantType.value = TenantType.msit;
      msitDevSetting();
      confirmTenantSetting.value = 'msitDev setting';
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    } else if (AutoConfig.instance.domainType.isMoisDomain) {
      userLoginType.value = UserLoginType.sso;
      tenantType.value = TenantType.mois;
      // worksPrivateSetting();
      // 배포 전 밑 코드 사용
      // noCloudLinkSetting();
      moisSetting();
      confirmTenantSetting.value = 'moisPublic';
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    } else if (AutoConfig.instance.domainType.isMsitDomain) {
      userLoginType.value = UserLoginType.sso;
      tenantType.value = TenantType.msit;
      // worksPrivateSetting();
      // noCloudLinkSetting();
      msitSetting();
      confirmTenantSetting.value = 'msitPrivate';
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    } else if (AutoConfig.instance.domainType.isMfdsDomain) {
      userLoginType.value = UserLoginType.sso;
      tenantType.value = TenantType.mfds;
      // noCloudLinkSetting();
      mfdsSetting();
      confirmTenantSetting.value = 'worksPrivate';
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    } else if (AutoConfig.instance.domainType.isDferiDomain) {
      userLoginType.value = UserLoginType.sso;
      tenantType.value = TenantType.dferi;
      dferiSetting();
      confirmTenantSetting.value = 'worksPrivate';
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    } else if (AutoConfig.instance.domainType.isMoisLocalDomain) {
      userLoginType.value = UserLoginType.ara;
      tenantType.value = TenantType.ara;
      moisLocalSetting();
      confirmTenantSetting.value = 'moisLocal';
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    } else if (AutoConfig.instance.domainType.isStandardDomain) {
      userLoginType.value = UserLoginType.sso;
      tenantType.value = TenantType.standard;
      araServiceSetting();
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
      // if (AutoConfig.instance.domainType.isAraepubStandardDomain) {
      //   araServiceSetting();
      //   confirmTenantSetting.value = 'araService';
      // } else {
      //   noCloudLinkSetting();
      //   confirmTenantSetting.value = 'noCloudLink';
      // }
    } else if (AutoConfig.instance.domainType.isMpbDomain) {
      userLoginType.value = UserLoginType.sso;
      tenantType.value = TenantType.mpb;
      mpbSetting();
      confirmTenantSetting.value = 'mpb setting';
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    } else if (AutoConfig.instance.domainType.isLocalDomain) {
      if (AutoConfig.instance.domainType == DomainType.localhost ||
          AutoConfig.instance.domainType == DomainType.localhostDev) {
        userLoginType.value = UserLoginType.ara;
        tenantType.value = TenantType.ara;
        defaultSetting();
        // localDevSetting();
        debugPrint(
            '####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
        return;
      } else {
        userLoginType.value = UserLoginType.sso;
        tenantType.value = TenantType.naverWorks;
        localSetting();
        debugPrint(
            '####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
        return;
      }
    } else if (AutoConfig.instance.domainType.isLocalDevDomain) {
      userLoginType.value = UserLoginType.ara;
      tenantType.value = TenantType.ara;
      // 웍스 세팅 테스트 코드
      // provider.value = UserLoginType.naverWorks;
      // worksPrivateSetting();
      // 기본 세팅
      userLoginType.value = UserLoginType.ara;
      localDevSetting();
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    } else {
      defaultSetting();
      debugPrint('####@@@confirmTenantSetting: ${confirmTenantSetting.value}');
      return;
    }
  }

  void setTenantSetting() async {
    // final user = await loginController.getUser();
    final user = loginController.loginUserInfo.value;
    if (user != null) {
      getAutoConfigSetting();
      // debugPrint('####@@@setTenantSetting: user: $user');
      // debugPrint('####@@@setTenantSetting: user.customer: ${user.customer}');
      // debugPrint(
      //     '####@@@setTenantSetting: user.environment: ${user.environment}');
      // debugPrint('####@@@setTenantSetting: user.provider: ${user.provider}');
      // debugPrint(
      //     '####@@@setTenantSetting: AutoConfig.instance.domainType: ${AutoConfig.instance.domainType}');

      customer.value = CustomerType.fromString(user.customer ?? '');
      environment.value = EnvironmentType.fromString(user.environment ?? '');
      // provider.value = UserLoginType.fromString(user.provider ?? '');

      // provider가 특정 테넌트만을 정해주지 않기 때문에 후에 테넌트와 sso 타입을 분리해야함
      userLoginType.value = UserLoginType.fromString(user.provider ?? '');
      tenantType.value = TenantType.fromString(user.provider ?? '');

      //   if (tenantType.value == TenantType.ara) {
      //     araServiceSetting();
      //     confirmTenantSetting.value = 'araService';
      //     return;
      //   } else if (tenantType.value == TenantType.standard) {
      //     noCloudLinkSetting();
      //     confirmTenantSetting.value = 'worksPrivate';
      //     return;
      //   } else if (tenantType.value == TenantType.gov) {
      //     noCloudLinkSetting();
      //     confirmTenantSetting.value = 'worksPrivate';
      //     return;
      //   } else if (tenantType.value == TenantType.mois) {
      //     noCloudLinkSetting();
      //     // worksPrivateSetting();
      //     confirmTenantSetting.value = 'worksPrivate';
      //     return;
      //   } else if (tenantType.value == TenantType.msit) {
      //     worksPrivateSetting();
      //     // noCloudLinkSetting();
      //     confirmTenantSetting.value = 'worksPrivate';
      //     return;
      //   } else if (tenantType.value == TenantType.mfds) {
      //     noCloudLinkSetting();
      //     confirmTenantSetting.value = 'worksPrivate';
      //     return;
      //   } else if (tenantType.value == TenantType.dferi) {
      //     noCloudLinkSetting();
      //     confirmTenantSetting.value = 'worksPrivate';
      //     return;
      //   } else {
      //     // noCloudLinkSetting();
      //     defaultSetting();
      //     confirmTenantSetting.value = 'default';
      //     return;
      //   }
      // } else {
      //   if (AutoConfig.instance.domainType.isAraDomain) {
      //     araServiceSetting();
      //     confirmTenantSetting.value = 'araService';
      //     return;
      //   } else if (AutoConfig.instance.domainType.isMsitDomain) {
      //     worksPrivateSetting();
      //     confirmTenantSetting.value = 'worksPrivate';
      //     return;
      //   } else {
      //     // noCloudLinkSetting();
      //     defaultSetting();
      //     confirmTenantSetting.value = 'default';
      //     return;
      //   }
    }
    getAutoConfigSetting();
    // if (userLoginType.value == UserLoginType.ara) {
    //   araServiceSetting();
    //   confirmTenantSetting.value = 'araService';
    // } else if (userLoginType.value == UserLoginType.naverWorks ||
    //     userLoginType.value == UserLoginType.naver_works) {
    //   if (environment.value == EnvironmentType.public) {
    //     worksPublicSetting();
    //     confirmTenantSetting.value = 'worksPublic';
    //   } else if (environment.value == EnvironmentType.private) {
    //     worksPrivateSetting();
    //     confirmTenantSetting.value = 'worksPrivate';
    //   } else {
    //     worksPublicSetting();
    //     confirmTenantSetting.value = 'worksPublic';
    //   }
    //   // worksPublicSetting();
    // } else if (userLoginType.value == UserLoginType.brityWorks) {
    //   if (environment.value == EnvironmentType.public) {
    //     brityWorksPublicSetting();
    //     confirmTenantSetting.value = 'brityWorksPublic';
    //   } else if (environment.value == EnvironmentType.private) {
    //     brityWorksPrivateSetting();
    //     confirmTenantSetting.value = 'brityWorksPrivate';
    //   }
    // }
  }

  void defaultSetting() {
    debugPrint('####@@@default Tenant Setting');
    // 기본 설정
    // 모든 설정 true
    customer.value = CustomerType.values.first;
    environment.value = EnvironmentType.values.first;
    userLoginType.value = UserLoginType.values.first;
    accountSettingStatus.value = LoginType.araService;
    loginType.value = LoginType.araService;
    accountFindStatus.value = true;
    simpleAraLoginStatus.value = true;
    simpleBrityWorksLoginStatus.value = false;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = false;
    // cloudLinkStatus.value = true;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = false;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = true;
    tabWidgetStatus.value = true;
    accordionWidgetStatus.value = true;
    shareStatus.value = true;
    quizWidgetStatus.value = true;
    confirmTenantSetting.value = 'default setting';
  }

  void localDevSetting() {
    // 로컬 개발 설정
    customer.value = CustomerType.values.first;
    environment.value = EnvironmentType.values.first;
    userLoginType.value = UserLoginType.values.first;
    accountSettingStatus.value = LoginType.araService;
    loginType.value = LoginType.araService;
    accountFindStatus.value = true;
    simpleAraLoginStatus.value = true;
    simpleBrityWorksLoginStatus.value = false;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = true;
    // cloudLinkStatus.value = true;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = true;
    subscribeManagementStatus.value = true;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = true;
    mathMenuStatus.value = true;
    tooggleWidgetStatus.value = true;
    tabWidgetStatus.value = true;
    accordionWidgetStatus.value = true;
    shareStatus.value = true;
    quizWidgetStatus.value = true;
    // quizWidgetStatus.value = false;
    confirmTenantSetting.value = 'localDevSetting';
  }

  void araServiceSetting() {
    // 아라 서비스 설정
    accountSettingStatus.value = LoginType.araService;
    loginType.value = LoginType.araService;
    accountFindStatus.value = true;
    simpleAraLoginStatus.value = true;
    simpleBrityWorksLoginStatus.value = false;
    simpleNaverWorksLoginStatus.value = false;
    cloudLinkStatus.value = false;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = true;
    subscribeManagementStatus.value = true;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = false;
    cloudProjectSaveStatus.value = false;
    mathMenuStatus.value = true;
    tooggleWidgetStatus.value = true;
    tabWidgetStatus.value = true;
    accordionWidgetStatus.value = true;
    shareStatus.value = true;
    quizWidgetStatus.value = true;
    confirmTenantSetting.value = 'araService setting';
  }

  void localSetting() {
    // 로컬 설정
    accountSettingStatus.value = LoginType.naverWorks;
    loginType.value = LoginType.naverWorks;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = true;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = true;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = true;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = true;
    quizWidgetStatus.value = false;
    confirmTenantSetting.value = 'localSetting';
  }

  void worksPrivateSetting() {
    // 폐쇄망 네이버 웍스 사용자 설정
    accountSettingStatus.value = LoginType.naverWorks;
    loginType.value = LoginType.naverWorks;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = true;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = true;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = true;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = false;
    quizWidgetStatus.value = true;
    confirmTenantSetting.value = 'worksPrivate setting';
  }

  void worksPublicSetting() {
    // 공개망 네이버 웍스 사용자 설정
    accountSettingStatus.value = LoginType.naverWorks;
    loginType.value = LoginType.naverWorks;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = true;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = true;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = true;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = false;
    quizWidgetStatus.value = false;
    confirmTenantSetting.value = 'worksPublic setting';
  }

  void noCloudLinkSetting() {
    // 클라우드 연동 없는 설정
    accountSettingStatus.value = LoginType.araService;
    loginType.value = LoginType.araService;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = true;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = false;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = false;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = false;
    quizWidgetStatus.value = false;
    confirmTenantSetting.value = 'noCloudLink setting';
  }

  void moisSetting() {
    // 공개망 모임 사용자 설정
    accountSettingStatus.value = LoginType.araService;
    loginType.value = LoginType.araService;
    tenantType.value = TenantType.mois;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = true;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = true;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = true;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = false;
    quizWidgetStatus.value = false;
    confirmTenantSetting.value = 'moisPublic setting';
  }

  void msitSetting() {
    // 공개망 모임 사용자 설정
    accountSettingStatus.value = LoginType.naverWorks;
    loginType.value = LoginType.naverWorks;
    tenantType.value = TenantType.msit;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = true;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = false;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = false;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = false;
    quizWidgetStatus.value = false;
    confirmTenantSetting.value = 'msitPrivate setting';
  }

  void mpbSetting() {
    accountSettingStatus.value = LoginType.naverWorks;
    loginType.value = LoginType.naverWorks;
    tenantType.value = TenantType.mpb;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = true;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = false;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = false;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = false;
    quizWidgetStatus.value = false;
    confirmTenantSetting.value = 'mpb setting';
  }

  void moisDevSetting() {
    accountSettingStatus.value = LoginType.naverWorks;
    loginType.value = LoginType.naverWorks;
    tenantType.value = TenantType.msit;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = true;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = false;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = false;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = false;
    quizWidgetStatus.value = false;
    confirmTenantSetting.value = 'moisDev setting';
  }

  void msitDevSetting() {
    accountSettingStatus.value = LoginType.araService;
    loginType.value = LoginType.araService;
    tenantType.value = TenantType.mois;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = true;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = true;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = true;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = false;
    quizWidgetStatus.value = false;
    confirmTenantSetting.value = 'msitDev setting';
  }

  void mfdsSetting() {
    // 공개망 모임 사용자 설정
    accountSettingStatus.value = LoginType.araService;
    loginType.value = LoginType.araService;
    tenantType.value = TenantType.mfds;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = true;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = true;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = true;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = false;
    quizWidgetStatus.value = false;
    confirmTenantSetting.value = 'mfdsSetting setting';
  }

  void dferiSetting() {
    // 대구 미래교육연구원 설정
    accountSettingStatus.value = LoginType.araService;
    loginType.value = LoginType.araService;
    tenantType.value = TenantType.dferi;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = false;
    simpleNaverWorksLoginStatus.value = false;
    cloudLinkStatus.value = false;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = false;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = true;
    quizWidgetStatus.value = true;
    confirmTenantSetting.value = 'dferi setting';
  }

  void moisLocalSetting() {
    // mois local alpha test 설정
    accountSettingStatus.value = LoginType.araService;
    loginType.value = LoginType.araService;
    tenantType.value = TenantType.mois;
    accountFindStatus.value = false;
    simpleAraLoginStatus.value = false;
    simpleBrityWorksLoginStatus.value = true;
    simpleNaverWorksLoginStatus.value = true;
    cloudLinkStatus.value = true;
    templateMarketingStatus.value = true;
    authorPlanStatus.value = false;
    subscribeManagementStatus.value = false;
    helpCenterStatus.value = true;
    termsOfServiceStatus.value = true;
    privacyPolicyStatus.value = true;
    servicePolicyStatus.value = true;
    youthProtectionPolicyStatus.value = true;
    exportHistoryStatus.value = true;
    docCoOperationStatus.value = true;
    govElementLogoStatus.value = true;
    cloudProjectSaveStatus.value = true;
    mathMenuStatus.value = false;
    tooggleWidgetStatus.value = false;
    tabWidgetStatus.value = false;
    accordionWidgetStatus.value = false;
    shareStatus.value = true;
    quizWidgetStatus.value = false;
    confirmTenantSetting.value = 'moisLocal setting';
  }

  void brityWorksPrivateSetting() {
    // 폐쇄망 브리티 웍스 사용자 설정
  }

  void brityWorksPublicSetting() {
    // 공개망 브리티 웍스 사용자 설정
  }

  void naverWorksSetting() {
    // 네이버 웍스 설정
    if (environment.value == EnvironmentType.public) {
      userLoginType.value = UserLoginType.naverWorks;
    } else if (environment.value == EnvironmentType.private) {
      userLoginType.value = UserLoginType.naverWorks;
    }
  }

  void brityWorksSetting() {
    if (environment.value == EnvironmentType.public) {
      userLoginType.value = UserLoginType.brityWorks;
      environment.value = EnvironmentType.public;
    } else if (environment.value == EnvironmentType.private) {
      userLoginType.value = UserLoginType.brityWorks;
      environment.value = EnvironmentType.private;
    }
  }

  Map<String, dynamic> getTenantSettingMap() {
    final Map<String, dynamic> tenantSettingMap = {
      'cloudProjectSaveStatus': cloudProjectSaveStatus.value,
      'govElementLogoStatus': govElementLogoStatus.value,
      'mathMenuStatus': mathMenuStatus.value,
      'tooggleWidgetStatus': tooggleWidgetStatus.value,
      'tabWidgetStatus': tabWidgetStatus.value,
      'accordionWidgetStatus': accordionWidgetStatus.value,
      'quizWidgetStatus': quizWidgetStatus.value,
      'shareStatus': shareStatus.value,
    };
    return tenantSettingMap;
  }
}
