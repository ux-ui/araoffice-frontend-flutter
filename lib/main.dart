import 'dart:js_interop';

import 'package:api/api.dart';
import 'package:app/app/account/controller/accounts_controller.dart';
import 'package:app/app/login/view/tenant_setting_controller.dart';
import 'package:app/app/project/controller/cloud_controller.dart';
import 'package:app/app/subscription/controller/subscription_controller.dart';
import 'package:app/app/window/window_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'app/editor/cotroller/editor_controller.dart';
import 'app/guide/controller/guide_controller.dart';
import 'app/home/controller/home_controller.dart';
import 'app/login/view/find_account_controller.dart';
import 'app/login/view/login_controller.dart';
import 'app/plan/controller/plan_controller.dart';
import 'app/project/controller/project_controller.dart';
import 'app/question/controller/question_controller.dart';
import 'app/resource/controller/resource_controller.dart';
import 'app/setting/controller/settings_controller.dart';
import 'app/sign_up/sign_up_controller.dart';
import 'app/template/controller/template_controller.dart';

@JS('removeSplashScreen')
external void _jsRemoveSplashScreen();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialization();
  runApp(App());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _jsRemoveSplashScreen();
  });
}

Future initialization() async {
  await Environment.loadVersionInfo();
  _initSettings();
  _initEasyLoadingStyle();
  _initController();
  await _initResources();
}

void _initSettings() {
  final config = AutoConfig.instance;
  final apiDio = ApiDio(config.apiUrl);
  apiDio.setUrlByEnvironment(config.environment);

  Get.lazyPut(() => ProjectApiClient(apiDio), fenix: true);
  Get.lazyPut(() => CloudApiClient(apiDio), fenix: true);
  Get.lazyPut(() => LoginApiClient(apiDio), fenix: true);
  Get.lazyPut(() => AraApiClient(apiDio), fenix: true);
  Get.lazyPut(() => NaverWorksApiClient(apiDio), fenix: true);
  Get.lazyPut(() => TemplateApiClient(apiDio), fenix: true);
  Get.lazyPut(() => LoginApiService(LoginApiClient(apiDio)), fenix: true);
  Get.lazyPut(() => AraApiService(AraApiClient(apiDio)), fenix: true);
  Get.lazyPut(() => ProjectApiService(ProjectApiClient(apiDio)), fenix: true);
  Get.lazyPut(() => CloudApiService(CloudApiClient(apiDio)), fenix: true);
  Get.lazyPut(() => TemplateApiService(TemplateApiClient(apiDio)), fenix: true);
  Get.lazyPut(() => HistoryApiService(HistoryApiClient(apiDio)), fenix: true);
  Get.lazyPut(() => NickNameApiService(NickNameApiClient(apiDio)), fenix: true);
}

void _initController() {
  Get.put(LoginController(), permanent: true);
  Get.lazyPut(() => TenantSettingController(), fenix: true);
  Get.lazyPut(() => SignUpController(), fenix: true);
  Get.lazyPut(() => HomeController(), fenix: true);
  Get.lazyPut(() => ProjectController(), fenix: true);
  Get.lazyPut(() => TemplateController(), fenix: true);
  Get.lazyPut(() => CloudController(), fenix: true);
  Get.lazyPut(() => SettingsController(), fenix: true);
  Get.lazyPut(() => EditorController(), fenix: true);
  Get.lazyPut(() => QuestionController(), fenix: true);
  Get.lazyPut(() => GuideController(), fenix: true);
  Get.lazyPut(() => SubscriptionController(), fenix: true);
  Get.lazyPut(() => ResourceController(), fenix: true);
  Get.lazyPut(() => PlanController(), fenix: true);
  Get.lazyPut(() => AccountsController(), fenix: true);
  Get.lazyPut(() => WindowController(), fenix: true);
  Get.lazyPut(() => FindAccountController(), fenix: true);
}

void _initEasyLoadingStyle() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 1000)
    ..loadingStyle = EasyLoadingStyle.custom
    ..progressColor = lightMaterialScheme.primary
    ..progressWidth = 8
    ..backgroundColor = lightMaterialScheme.surface
    ..indicatorColor = lightMaterialScheme.primary
    ..textColor = lightMaterialScheme.onSurface
    ..maskColor = lightMaterialScheme.primary.withAlpha(128)
    ..userInteractions = false
    ..boxShadow = [
      BoxShadow(
        color: lightMaterialScheme.onSurfaceVariant.withAlpha(26),
        blurRadius: 1,
        spreadRadius: 1,
        offset: const Offset(0, 0),
      )
    ]
    ..errorWidget = Icon(
      Icons.error,
      color: lightMaterialScheme.error,
    )
    ..dismissOnTap = false;
}

Future<void> _initResources() async {
  try {
    final fontLoader = FontLoader('Pretendard');
    fontLoader.addFont(rootBundle.load(AppUiAssets.fonts.pretendardRegular));
    await fontLoader.load();
  } catch (_) {}
}
