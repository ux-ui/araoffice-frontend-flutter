import 'package:api/api.dart';
import 'package:app/app/login/view/login_controller.dart';
import 'package:app/app/project/controller/project_controller.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/common_view_type.dart';
import '../../login/view/find_account_controller.dart';
import '../../template/controller/template_controller.dart';

class HomeController extends GetxController {
  LoginController loginController = Get.find<LoginController>();
  final viewType = ViewType.project.obs;

  final userId = '테스터'.obs;
  final isFreeUser = false.obs;
  final isProjectExpanded = false.obs;
  final List<String> projects = <String>[
    '프로젝트1',
    '프로젝트2',
    '프로젝트3',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _initalizeSubController();
    setUserId();
    // 사용자 상태 확인 (한 번만 실행)
   WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = Get.context;
      if (context == null || !context.mounted) {
        return;
      }
      await loginController.checkUserSignStatus(context);
    });
  }

  @override
  void onClose() {
    _disposeSubController();
    super.onClose();
  }

  void setUserId() async {
    final user = await loginController.getUser();
    userId.value = user?.userId ?? '테스터';
    debugPrint('----setUserId userId : $userId');
  }

  void updateViewType(ViewType type) {
    debugPrint('----updateViewType template switch type : $type ');
    viewType.value = type;
  }

  /// 홈 페이지의 하위에서 사용하는 컨트롤러를 초기화합니다.
  void _initalizeSubController() {
    //Get.put(ProjectController());
    Get.put(TemplateController());
    // LoginController는 main.dart에서 permanent: true로 등록되어 있으므로 재등록하지 않음
    // Get.put(LoginController());
    Get.put(FindAccountController());
  }

  /// 홈 페이지의 하위에서 사용하는 컨트롤러를 해제합니다.
  void _disposeSubController() {
    Get.delete<ProjectController>();
    Get.delete<TemplateController>();
    // LoginController는 permanent: true로 등록되어 있으므로 삭제하지 않음
    // Get.delete<LoginController>();
  }

  String getBaseUrl() {
    final baseUrl = ApiDio.apiHostAppServer.replaceAll('/api/v1', '');
    return baseUrl;
  }

  String getUrlTerms() {
    final baseUrl = getBaseUrl();
    // return '${baseUrl}info/term-of-use';
    const dferiUrl =
        'https://www.edunavi.kr/portal/cm/cntnts/cntntsView.do?mi=7750&cntntsId=5800';

    return AutoConfig.instance.domainType.isDferiDomain
        ? dferiUrl
        : '${baseUrl}info/term-of-use';
  }

  String getUrlPrivacyPolicy() {
    final baseUrl = getBaseUrl();
    // return '${baseUrl}info/privacy-policy';

    const dferiUrl =
        'https://www.edunavi.kr/portal/cm/cntnts/cntntsView.do?mi=7749&cntntsId=5797';

    return AutoConfig.instance.domainType.isDferiDomain
        ? dferiUrl
        : '${baseUrl}info/privacy-policy';
  }

  String getUrlYouthProtectionPolicy() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/term-of-youth';
  }

  String getFAQUrl() {
    final baseUrl = getBaseUrl();
    const dferiUrl = 'https://www.edunavi.kr/booknavi/customer/faq';
    return AutoConfig.instance.domainType.isDferiDomain
        ? dferiUrl
        : '${baseUrl}info/faq';
  }
}

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
