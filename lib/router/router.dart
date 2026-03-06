import 'package:api/api.dart';
import 'package:app/app/account/accounts_page.dart';
import 'package:app/app/guide/guide_view_type.dart';
import 'package:app/app/logout/logout_complete_page.dart';
import 'package:app/app/office/office_page.dart';
import 'package:app/app/plan/plan_page.dart';
import 'package:app/app/resource/resource_page.dart';
import 'package:app/app/subscription/subscription_page.dart';
import 'package:app/app/template/template_page.dart';
import 'package:app/app/window/window_api_demo_page.dart';
import 'package:author_editor/mixins/dragdocs_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../app/editor/cotroller/splash_controller.dart';
import '../app/editor/editor_page.dart';
import '../app/editor/splash_page.dart';
import '../app/guide/controller/guide_controller.dart';
import '../app/guide/guide_page.dart';
import '../app/home/view/home_page.dart';
import '../app/login/view/change_password_page.dart';
import '../app/login/view/find_account_page.dart';
import '../app/login/view/login_controller.dart';
import '../app/login/view/login_page.dart';
import '../app/office/controller/office_controller.dart';
import '../app/question/question_page.dart';
import '../app/setting/settings_page.dart';
import '../app/sign_up/sign_up_page.dart';

class AppRouter {
  ///
  /// 1. 화면 단위는 아래와 같은 순서로 구성된다.
  /// page -> view -> content
  /// ex) GuidePage -> GuideContentView -> GuideStartContent
  ///
  /// 2. 동일한 페이지에서 viewType을 변경하여 페이지 전환을 할 경우엔
  /// 경로 세그먼트 앞에 ':' 문자로 접두사를 붙이거나 파라미터를 사용한다.
  /// ex) '${GuidePage.route}/:guideId',
  ///
  /// 3. controller는 main.dart _initContorller에서 Get.lazyPut합니다.
  ///
  /// *******************************************************************
  /// 중첩된 라우트에 동일한 page를 사용하여 obx로 viewType을 update하면
  /// obx가 2번 실행되는 현상이 발생하므로 중첩된 라우트에서는 동일한 page를 사용하지 말자.
  /// *******************************************************************
  // Public Routes (인증 불필요)
  static final publicRoutes = [
    GoRoute(path: LoginPage.route, builder: (context, state) => LoginPage()),
    GoRoute(
        path: '/change-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final userId = extra?['userId'];
          final email = extra?['email'];
          return ChangePasswordPage(userId: userId, email: email);
        }),
    GoRoute(
        path: FindAccountPage.route,
        builder: (context, state) {
          final initialPage = state.extra as bool?;
          return FindAccountPage(initialPage: initialPage);
        }),
    GoRoute(
        path: SignUpPage.route,
        builder: (context, state) {
          final extra = state.extra;
          LoginType? loginType;
          UserData? userInfo;

          if (extra is Map<String, dynamic>) {
            loginType = extra['loginType'];
            userInfo = extra['userInfo'];
          } else if (extra is LoginType) {
            loginType = extra;
          }

          return SignUpPage(loginType: loginType, userInfo: userInfo);
        }),
    GoRoute(
        path: LogoutCompletePage.route,
        builder: (context, state) => const LogoutCompletePage()),
    GoRoute(
      path: EditorPage.route,
      builder: (context, state) {
        // 문서 생성하기 화면으로 이동: /editor?displayType=create
        // 특정 템플릿으로 문서 생성하기 화면으로 이동: /editor?displayType=create&templateId=t12345678
        // 특정 문서 오픈하기: /editor?p=pd9e1d35b

        final param = state.uri.queryParameters;
        final extra = state.extra as Map<String, dynamic>?;
        final displayType = param['displayType'] ?? extra?['displayType'];
        final templateId = param['templateId'] ?? extra?['templateId'];
        final folderId = extra?['folderId'];
        final projectId = param['p'];
        final pageId = param['g'];

        // final redirect = RouteGuard.checkAuth(context, state);
        // displayType이 create인 경우 리다이렉트
        // if (displayType == 'create') {
        //   // final redirect = RouteGuard.checkAuth(context, state);
        //   final result = RouteGuard.checkLoginStatus();
        //   if (result == false) {
        //     // 팝업 띄우고 로그인 페이지로 리다이렉트
        //     // return LoginPage();
        //     return CommonPopupContent(
        //         title: 'error_title'.tr,
        //         message: 'error_server_error_message'.tr,
        //         onConfirm: () {
        //           context.go(LoginPage.route);
        //         });
        //   }
        // } else {
        //   return EditorPage(
        //       key: ValueKey('editor_${DateTime.now().millisecondsSinceEpoch}'),
        //       folderId: folderId,
        //       projectId: projectId,
        //       pageId: pageId,
        //       templateId: templateId,
        //       displayType: displayType);
        // }
        return EditorPage(
            key: ValueKey('editor_${DateTime.now().millisecondsSinceEpoch}'),
            folderId: folderId,
            projectId: projectId,
            pageId: pageId,
            templateId: templateId,
            displayType: displayType);
      },
      redirect: (context, state) {
        // EPUB 파일로 프로젝트 생성: /editor?fileUrl=https://www.test.com/test.epub

        final param = state.uri.queryParameters;
        final fileUrl = param['fileUrl'];
        if (fileUrl != null) {
          SplashController.bindingFromUrl(
            fileUrl,
            'splash_project_loading'.tr,
          );
          return SplashPage.route;
        }
        // 리다이렉트 전 로그인 검증
        return null;
      },
    ),
  ];

  // Private Routes (인증 필요)
  static final privateRoutes = [
    GoRoute(
        path: HomePage.route, builder: (context, state) => const HomePage()),
    GoRoute(
        path: TemplatePage.route,
        builder: (context, state) => const TemplatePage()),
    GoRoute(
        path: SettingsPage.route,
        builder: (context, state) => const SettingsPage()),
    GoRoute(
        path: AccountsPage.route,
        builder: (context, state) => const AccountsPage()),
    GoRoute(
        path: PlanPage.route, builder: (context, state) => const PlanPage()),
    GoRoute(
        path: SubscriptionPage.route,
        builder: (context, state) => const SubscriptionPage()),
    GoRoute(
        path: ResourcePage.route,
        builder: (context, state) => const ResourcePage()),
    GoRoute(
        path: QuestionPage.route,
        builder: (context, state) => const QuestionPage(),
        routes: [
          // 질문 목록 페이지
          GoRoute(
            path: '${GuidePage.route}/:guideId',
            builder: (context, state) {
              if (Get.isRegistered<GuideController>()) {
                Get.find<GuideController>()
                    .updateViewType(state.uri.path.toGuideViewType());
              }
              return const GuidePage();
            },
          ),
        ]),
    GoRoute(
      path: EditorPage.route,
      builder: (context, state) {
        // 문서 생성하기 화면으로 이동: /editor?displayType=create
        // 특정 템플릿으로 문서 생성하기 화면으로 이동: /editor?displayType=create&templateId=t12345678
        // 특정 문서 오픈하기: /editor?p=pd9e1d35b

        final param = state.uri.queryParameters;
        final extra = state.extra as Map<String, dynamic>?;
        final displayType = param['displayType'] ?? extra?['displayType'];
        final templateId = param['templateId'] ?? extra?['templateId'];
        final folderId = extra?['folderId'];
        final projectId = param['p'];
        final pageId = param['g'];

        return EditorPage(
            key: ValueKey('editor_${DateTime.now().millisecondsSinceEpoch}'),
            folderId: folderId,
            projectId: projectId,
            pageId: pageId,
            templateId: templateId,
            displayType: displayType);
      },
      redirect: (context, state) {
        // EPUB 파일로 프로젝트 생성: /editor?fileUrl=https://www.test.com/test.epub

        final param = state.uri.queryParameters;
        final fileUrl = param['fileUrl'];
        if (fileUrl != null) {
          SplashController.bindingFromUrl(
            fileUrl,
            'splash_project_loading'.tr,
          );
          return SplashPage.route;
        }
        return null;
      },
    ),
    GoRoute(
      path: OfficePage.route,
      builder: (context, state) {
        final param = state.uri.queryParameters;
        final extra = state.extra as Map<String, dynamic>?;

        // CloudFileModel이 있는 경우: 드라이브 목록에서 파일 클릭 시
        // 그 외: URL 파라미터에서 파일 정보 추가해서 호출한 경우
        CloudFileModel? file = extra?['file'] as CloudFileModel?;
        final fileId = file?.fileId ?? param['fileId'] ?? '';
        final fileName =
            file?.fileName ?? param['fileName'] ?? param['filename'] ?? '';
        final fileUrl = param['fileUrl'];

        // drive 파라미터로 출처 구분
        // drive 없음 or 'naverWorks' → 네이버웍스 (기존 호환성)
        // drive='iop' → IOP
        final drive = param['drive'] ?? 'naverWorks';

        // IOP: downloadUrl을 직접 받을 수도 있음
        final downloadUrl = param['downloadUrl'];
        // accessKey 또는 secretKey (호환성)
        final accessKey = param['accessKey'] ?? param['secretKey'];

        CloudStorageType storageType;
        if (drive.toLowerCase() == 'iop') {
          storageType = CloudStorageType.iop;
        } else {
          storageType = CloudStorageType.naverWorks;
        }

        // CloudFileModel 생성 조건:
        // - fileId가 있거나
        // - downloadUrl이 있거나
        // - fileName만 있어도 생성 (로컬 파일 등의 경우)
        if (file == null &&
            (fileId.isNotEmpty || downloadUrl != null || fileName.isNotEmpty)) {
          file = CloudFileModel(
            fileId: fileId,
            fileName: fileName,
            downloadUrl: downloadUrl, // IOP의 경우 직접 전달될 수 있음
            secretKey: accessKey, // accessKey를 secretKey 필드에 저장 (호환성)
            storageType: storageType,
            // 필수 파라미터
            resourceLocation: 0,
            fileSize: 0,
            filePath: '',
            fileType: '',
            createdTime: DateTime.now(),
            modifiedTime: DateTime.now(),
            accessedTime: DateTime.now(),
            hasPermission: true,
            shared: false,
          );
        }

        if (Get.isRegistered<OfficeController>()) {
          Get.delete<OfficeController>();
        }
        Get.put(OfficeController(
          fileId: fileId,
          fileName: fileName,
          cloudFile: file,
          fileUrl: fileUrl,
        ));

        return OfficePage(
          key: ValueKey('office_${DateTime.now().millisecondsSinceEpoch}'),
        );
      },
      redirect: (context, state) {
        final param = state.uri.queryParameters;
        final extra = state.extra as Map<String, dynamic>?;

        // CloudFileModel이 있는 경우: 드라이브 목록에서 파일 클릭 시
        // 그 외: URL 파라미터에서 파일 정보 추가해서 호출한 경우
        CloudFileModel? file = extra?['file'] as CloudFileModel?;
        final fileId = file?.fileId ?? param['fileId'] ?? '';
        final fileName =
            file?.fileName ?? param['fileName'] ?? param['filename'] ?? '';
        final fileUrl = param['fileUrl'];
        final downloadUrl = param['downloadUrl'];
        final projectId = param['projectId'] ?? '';

        // redirect 조건:
        // - fileName이 없으면 무조건 redirect
        // - fileName은 있지만 fileId와 downloadUrl 둘 다 없으면 redirect. fileUrl for testing.
        if (fileName.isEmpty ||
            (fileId.isEmpty && downloadUrl == null && fileUrl == null)) {
          if (projectId.isNotEmpty) {
            return '${EditorPage.route}?p=$projectId';
          } else {
            return HomePage.route;
          }
        }

        final fileExtension = fileName.split('.').last.toLowerCase();
        final isProjectFile = fileExtension == 'ara';
        final isEpubFile =
            DragDocsMixin.allowedEpubExtensions.contains(fileExtension);
        final isOfficeFile =
            DragDocsMixin.allowedOfficeExtensions.contains(fileExtension);
        final isViewerFile =
            DragDocsMixin.allowedViewerExtensions.contains(fileExtension);

        if (isProjectFile) {
          SplashController.binding(
            fileId,
            fileName,
            'splash_project_loading'.tr,
          );
          return SplashPage.route;
        } else if (isOfficeFile || isViewerFile || isEpubFile) {
          return null;
        }
        // 파일 타입 오류
        EasyLoading.showError('지원하지 않는 파일 타입입니다: $fileName');
        return HomePage.route;
      },
    ),
    // (테스트용) EPUB 파일로 프로젝트 생성하는 경우
    // ex) http://localhost:12342/web/#/project?fileId=MTAwMDAxN&fileName=example.epub
    GoRoute(
      path: '/project',
      redirect: (context, state) {
        final param = state.uri.queryParameters;
        final extra = state.extra as Map<String, dynamic>?;

        // CloudFileModel이 있는 경우: 드라이브 목록에서 파일 클릭 시
        // 그 외: URL 파라미터에서 파일 정보 추가해서 호출한 경우
        CloudFileModel? file = extra?['file'] as CloudFileModel?;
        final fileId = file?.fileId ?? param['fileId'] ?? '';
        final fileName =
            file?.fileName ?? param['fileName'] ?? param['filename'] ?? '';
        final projectId = param['projectId'] ?? '';

        if (fileId.isEmpty || fileName.isEmpty) {
          if (projectId.isNotEmpty) {
            return '${EditorPage.route}?p=$projectId';
          } else {
            return HomePage.route;
          }
        }

        final fileExtension = fileName.split('.').last.toLowerCase();
        final isProjectFile = fileExtension == 'ara';
        final isEpubFile =
            DragDocsMixin.allowedEpubExtensions.contains(fileExtension);

        if (isProjectFile || isEpubFile) {
          SplashController.binding(
            fileId,
            fileName,
            'splash_project_loading'.tr,
          );
          return SplashPage.route;
        } else {
          // 파일 타입 오류
          EasyLoading.showError('지원하지 않는 파일 타입: $fileName');
          return HomePage.route;
        }
      },
    ),
    GoRoute(
      path: SplashPage.route,
      builder: (context, state) => SplashPage(
        timeoutDuration: const Duration(seconds: 30),
        onTimeout: () {
          // 응답 없음: 서버 오류
          EasyLoading.showError('error_server_error'.tr);
          context.go(HomePage.route);
        },
      ),
      redirect: (context, state) {
        // SplashController가 등록되어 있지 않으면 홈페이지로 리다이렉트
        if (!Get.isRegistered<SplashController>()) {
          return HomePage.route;
        }
        return null;
      },
    ),
    GoRoute(
      path: WindowDemoPage.route,
      builder: (context, state) => const WindowDemoPage(),
    ),
  ];

  // 전체 routes (기존 방식 유지)
  static final routes = [
    ...publicRoutes,
    ...privateRoutes,
  ];
}
