import 'dart:async';
import 'dart:convert';
/**
 * flutter 3.35.0
 * dart:js_util is deprecated.
 * Use package:web and dart:js_interop instead.
 */
// import 'dart:js_util' as js_util;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:app_ui/app_ui.dart';
import 'package:author_editor/editor_event_timer_manager.dart';
import 'package:author_editor/panel/page_attribute_panel.dart';
import 'package:author_editor/panel/quiz/quiz_widget_attribute_panel.dart';
import 'package:common_assets/common_assets.dart';
import 'package:common_util/common_util.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
// import 'package:js/js.dart';
import 'package:web/web.dart' as web;

import 'data/datas.dart';
import 'data/vulcan_font_data.dart';
import 'engine/editor_html_node_rect.dart';
import 'engine/engines.dart';
import 'enum/enums.dart';
import 'extension/extensions.dart';
import 'mixins/mixins.dart';
import 'panel/panels.dart';
import 'states/states.dart';
import 'utill/position_storage.dart';
import 'view/memo_popup.dart';

class VulcanEditorController extends GetxController
    with
        BodyControlMixin,
        TextEditingMixin,
        MediaControlMixin,
        TableControlMixin,
        AnimationControlMixin,
        StyleControlMixin,
        PageControlMixin,
        ShapeControlMixin,
        DragDocsMixin,
        EpubViewerMixin,
        WidgetSliderMixin,
        WidgetPageNumberMixin,
        WidgetTocMixin,
        TriggerControlMixin,
        FocusNodeMixin,
        QuizWidgetMixin,
        WebSocketControlMixin,
        BookmarkControlMixin,
        FormatCopyPasteMixin,
        FindReplaceMixin,
        // CloudControllerMixin,
        VirtualListControlMixin {
  @override
  String get baseUrl => documentState.baseUrl;

  // States
  late final EditorUIState uiState;
  @override
  late final DocumentState documentState;
  late final ResourceState resourceState;

  final languageCode = Get.locale?.languageCode ?? 'ko';

  Editor? _editor;

  @override
  Editor? get editor => _editor;

  @override
  EditorHtmlNode? get currentNode => rxEditorHtmlNode.value;

  @override
  WidgetSliderMixin get sliderMixin => this;

  @override
  bool get isOwner => rxIsOwner.value;

  @override
  PageControlMixin get pageController => this;

  VulcanEditorController() {
    uiState = EditorUIState();
    documentState = DocumentState();
    resourceState = ResourceState();
  }

  final rxTemplates = <VulcanTemplateData>[].obs;

  final rxDisplayType = VulcanEditorDisplayType.unauthorized.obs;
  final rxIsOwner = false.obs;
  // final rxUserLoginType = UserLoginType.ara.obs;
  final rxTenantType = TenantType.ara.obs;

  final EditorEventTimerManager timerManager =
      Get.put(EditorEventTimerManager());

  final rxPanel = Rx<Widget?>(null);
  final rxAttribute = Rx<Widget?>(null);
  final rxOldAttribute = Rx<Widget?>(null);

  final rxViewColumn = true.obs;

  final rxInnerHTML = ''.obs;

  final rxShowRuler = true.obs;
  final rxShowGrid = true.obs;
  final rxShowOutline = true.obs;
  final rxGridSnap = true.obs;
  final rxZoomValue = 1.0.obs;
  final rxPopupInteracting = false.obs;
  // final isEditorBlocked = false.obs;

  final rxIsDrawingMode = false.obs;
  final rxIsEraseMode = false.obs;

  final TextEditingController linkController = TextEditingController();
  final rxCanUndo = false.obs;
  final rxCanRedo = false.obs;

  late VulcanEditorData vulcanEditorData;

  final colorPickerKey = GlobalKey<PopupMenuButtonState>();

  // 폰트 리스트
  final installedFonts = VulcanFontListData();

  // _____ page info ______
  final rxPageUrl = ''.obs;
  // _____ clipart templates ______
  final rxClipArtsPrimary = <Template>[].obs; // 최상위 템플릿 리스트
  final rxClipArtsSelectedPrimary = Rx<Template?>(null); // 선택된 최상위 템플릿
  final rxClipArtsSecondary = <Template>[].obs; // 하위 템플릿 리스트
  final rxClipArtsSelectedSecondary = Rx<Template?>(null); // 선택괸 하위 템플릿
  final rxClipArtsResource = <TemplateData?>[].obs;
  final rxClipArtsPath = ''.obs;

  // _____ government logo templates ______
  final rxGlogoTemplates = <Template>[].obs; // 정부로고 최상위 템플릿 리스트
  final rxGlogoSelectedPrimary = Rx<Template?>(null); // 선택된 정부로고 최상위 템플릿
  final rxGlogoSecondary = <Template>[].obs; // 정부로고 하위 템플릿 리스트
  final rxGlogoSelectedSecondary = Rx<Template?>(null); // 선택된 정부로고 하위 템플릿
  final rxGlogoResource = <TemplateData?>[].obs;
  final rxGlogoPath = ''.obs;

  final rxIsAvailableAddPage = true.obs;

  /// 프로젝트 접근 거부(403) 시 호출. VulcanEditor 등에서 EasyLoading + 홈 이동 처리 등록.
  void Function()? onProjectAccessDenied;

  // _____ whiteboard ______
  final rxWhiteboardXPosition = 50.0.obs;
  final rxWhiteboardYPosition = 50.0.obs;

  // co-op
  final rxIsCoopMode = false.obs;
  final myCoOpState = false.obs;
  final myCoOpUserId = ''.obs;
  final rxCoOpXPosition = 70.0.obs;
  final rxCoOpYPosition = 650.0.obs;
  final rxCoOpCount = 300.obs;
  final rxSettingEditCount = 300.obs;
  final rxStartCoOpCount = false.obs;
  final rxRemainingTime = 0.obs;
  final rxShowEditorUser = false.obs;
  Timer? coOpCountTimer;
  // final rxIsEditingPermission = false.obs; // 협업 편집 권한

  final tenantSetting = <String, dynamic>{}.obs; // 테넌트 설정
  final cloudProjectSaveStatus = false.obs; // 클라우드 프로젝트 저장
  final govElementLogoStatus = false.obs; // 정부 요소 로고
  final mathMenuStatus = false.obs; // 수학 메뉴
  final tooggleWidgetStatus = false.obs; // 토글 위젯
  final tabWidgetStatus = false.obs; // 탭 위젯
  final accordionWidgetStatus = false.obs; // 아코디언 위젯
  final quizWidgetStatus = false.obs; // 퀴즈 위젯
  final shareStatus = false.obs; // 공유 유무
  // 프로젝트 자동저장 카운트
  final rxAutoSaveCount = 300.obs;
  final rxStartAutoSaveCount = false.obs;
  Timer? autoSaveTimer;
  bool isDocumentChanged = false;

  VoidCallback? onUpdate;
  VoidCallback? onTempSaveCheckCallback;

  // 페이지 로드 대기. 현재는 메모 보기에서만 사용중.
  Completer<String?>? pageLoadCompleter;

  @override
  void update([List<Object>? ids, bool condition = true]) {
    super.update(ids, condition);
    onUpdate?.call();
  }

  @override
  void onClose() {
    logger.d('[VulcanEditorController] onClose');
    // 불필요한 리소스 해제
    disposeFocusNodes();
    super.onClose();
  }

  void initTenantSetting(Map<String, dynamic> tenant) {
    tenantSetting.value = tenant;
    cloudProjectSaveStatus.value = tenant['cloudProjectSaveStatus'] ?? false;
    govElementLogoStatus.value = tenant['govElementLogoStatus'] ?? false;
    mathMenuStatus.value = tenant['mathMenuStatus'] ?? false;
    tooggleWidgetStatus.value = tenant['tooggleWidgetStatus'] ?? false;
    tabWidgetStatus.value = tenant['tabWidgetStatus'] ?? false;
    accordionWidgetStatus.value = tenant['accordionWidgetStatus'] ?? false;
    quizWidgetStatus.value = tenant['quizWidgetStatus'] ?? false;
    shareStatus.value = tenant['shareStatus'] ?? false;
    debugPrint('######initTenantSetting');
  }

  /// 데이터가 변경되었을 때마다 호출되는 함수
  Future<void> display(
      {required VulcanEditorData vulcanEditorData,
      required String baseUrl}) async {
    rxDisplayType.value =
        vulcanEditorData.displayType ?? VulcanEditorDisplayType.unauthorized;
    debugPrint(
        '####@@@editor controller display displayType: $rxDisplayType.value');
    final projectId = vulcanEditorData.projectId ?? '';

    documentState.initializeUrls(baseUrl);
    rxTemplates.value = vulcanEditorData.templates ?? [];

    await Future.delayed(Duration.zero, () async {
      if (rxDisplayType.value == VulcanEditorDisplayType.unauthorized) {
        documentState.rxProjectId.value = '';
        documentState.rxPageCurrent.value = null;
        update();
      } else if (rxDisplayType.value == VulcanEditorDisplayType.create) {
        documentState.rxProjectId.value = '';
        documentState.rxPageCurrent.value = null;
        update();
      } else if (rxDisplayType.value == VulcanEditorDisplayType.editor) {
        rxShareUserList.value = vulcanEditorData.sharedUserList ?? [];

        // 문서 상태 업데이트
        documentState.rxProjectId.value = projectId;
        documentState.rxStartPageId.value = vulcanEditorData.startPageId ?? '';
        documentState.rxProjectName.value = vulcanEditorData.projectName ?? '';
        documentState.rxPages.value = vulcanEditorData.pages ?? [];
        // documentState.rxUserId.value = vulcanEditorData.userDisplayName ?? '';
        documentState.rxUserId.value = vulcanEditorData.userId ?? '';
        documentState.rxProjectSharePermission.value =
            ProjectAuthType.fromString(vulcanEditorData.projectAuth);

        documentState.rxProjectOwner.value =
            vulcanEditorData.projectOwner ?? '';

        documentState.rxHasCover.value = vulcanEditorData.hasCover ?? false;
        documentState.rxHasToc.value = vulcanEditorData.hasToc ?? false;

        resourceState.rxImageResources.value =
            vulcanEditorData.imageResources ?? [];
        resourceState.rxVideoResources.value =
            vulcanEditorData.videoResources ?? [];
        resourceState.rxAudioResources.value =
            vulcanEditorData.audioResources ?? [];
        resourceState.rxOfficeResources.value =
            vulcanEditorData.officeResources ?? [];

        //resourceState.rxTemplates.value = vulcanEditorData.templates ?? [];

        final path = vulcanEditorData.clipArtPath ?? '';
        if (path.isNotEmpty) {
          if (vulcanEditorData.resourceType == 'clipart' ||
              vulcanEditorData.resourceType == 'glogo') {
            editor?.insertImage(path);
            debugPrint('######insertImage: $path');
            Future.delayed(const Duration(milliseconds: 150), () {
              updatePageContent();
            });
          } else if (vulcanEditorData.resourceType == 'widget') {
            changeSliderIcon('./$path');
            Future.delayed(const Duration(milliseconds: 150), () {
              updatePageContent();
            });
          } else if (vulcanEditorData.resourceType == 'body_background_image') {
            setBodyBackImageUrl('./$path');
            Future.delayed(const Duration(milliseconds: 150), () {
              updatePageContent();
            });
          } else if (vulcanEditorData.resourceType == 'change_image') {
            editor?.changeImageSource(path);
            Future.delayed(const Duration(milliseconds: 150), () {
              updatePageContent();
            });
          }
        }
        checkUserLoginType();
        _loadTemplates();

        if (vulcanEditorData.widgetData != null) {
          final widgetPath = vulcanEditorData.widgetData!.widgetPath;
          final markup = vulcanEditorData.widgetData!.markup;
          final jsFiles = vulcanEditorData.widgetData!.jsFiles.first;
          final cssFiles = vulcanEditorData.widgetData!.cssFiles.first;

          final cssPath = './$cssFiles?type=widget&id=$widgetPath';
          final jsPath = './$jsFiles?type=widget&id=$widgetPath';

          //widget 값 초기화
          if (vulcanEditorData.widgetData!.widgetType == 'page_number') {
            final position = await PositionStorage.loadPosition('page_number');
            final left = position?['x']?.toString();
            final top = position?['y']?.toString();
            editor?.insertWidget(
                markup.processTranslation(), cssPath, jsPath, left, top);

            // 페이지 번호 위젯 삽입 후 즉시 번호 업데이트
            Future.delayed(const Duration(milliseconds: 100), () {
              if (documentState.rxPageCurrent.value?.calculatedPage != null) {
                updatePageNumber(
                    (documentState.rxPageCurrent.value?.calculatedPage)
                        .toString());
              } else {
                updatePageNumber('#');
              }
            });
          } else {
            editor?.insertWidget(
                markup.processTranslation(), cssPath, jsPath, null, null);
          }
        }

        if (vulcanEditorData.changedPage != null) {
          await changedPage(vulcanEditorData.changedPage!);
        }
      }
    });

    if (rxEditingUserId.value == 'null') {
      logger.d('######display: rxEditingUserId.value is null');
      editor?.enable(true);
    }
    showEditorUser(projectId);
  }

  void toggleLeftDrawer() => uiState.isLeftDrawerOpen.toggle();

  void toggleRightDrawer() {
    uiState.isRightDrawerOpen.toggle();
    if (uiState.isRightDrawerOpen.isFalse) {
      uiState.resetAttributes();
    }
  }

  /// 첫 번째 클립아트 데이터 초기 로딩
  Future<void> _loadInitialClipArtData(Template template) async {
    try {
      if (!template.isTemplateDataLoaded) {
        await TemplateParser.instance.loadTemplateData(
          templateName: template.name,
          type: TemplateType.clipart,
        );
      }

      rxClipArtsResource.value = template.templateInfo?.templateDatas ?? [];
    } catch (e) {
      debugPrint('Error loading initial clipart data: $e');
      rxClipArtsResource.value = [];
    }
  }

  /// 첫 번째 정부로고 데이터 초기 로딩
  Future<void> _loadInitialGlogoData(Template template) async {
    try {
      if (!template.isTemplateDataLoaded) {
        await TemplateParser.instance.loadTemplateData(
          templateName: template.name,
          type: TemplateType.glogo,
        );
      }

      rxGlogoResource.value = template.templateInfo?.templateDatas ?? [];
    } catch (e) {
      debugPrint('Error loading initial glogo data: $e');
      rxGlogoResource.value = [];
    }
  }

  // 프로젝트 공유 유저 리스트와 로그인 유저를 검증하는 단계
  Future<bool> isPermission() async {
    try {
      final result =
          await apiService.getUserList(documentState.rxProjectId.value);
      final userList = result?.users
              ?.map((user) => VulcanUserData.fromJson(user.toJson()))
              .toList() ??
          [];

      // displayName만 추출하여 리스트로 변환
      // final displayNames = userList.map((user) => user.displayName).toList();
      // final hasName = displayNames.contains(documentState.rxUserId.value);
      // if (hasName) {
      //   isEditingPermission.value = true;
      // } else {
      //   isEditingPermission.value = false;
      // }
      // return hasName;

      final userIds = userList.map((user) => user.userId).toList();
      final hasUserId = userIds.contains(documentState.rxUserId.value);
      if (hasUserId) {
        if (documentState.rxProjectSharePermission.value ==
                ProjectAuthType.publicLink ||
            documentState.rxProjectSharePermission.value ==
                ProjectAuthType.userLink) {
          rxIsCoopMode.value = true;
          isEditingPermission.value = true;
          myCoOpState.value = true;
        }
      } else {
        rxIsCoopMode.value = false;
        isEditingPermission.value = false;
        myCoOpState.value = false;
      }
      return hasUserId;
    } catch (e) {
      debugPrint('#### isPermission 오류 발생: $e');
      return false;
    }
  }

  // void getSharedUserList() async {
  //   try {
  //     final result =
  //         await apiService.getUserList(documentState.rxProjectId.value);
  //     final userList = result?.users
  //             ?.map((user) => VulcanUserData.fromJson(user.toJson()))
  //             .toList() ??
  //         [];

  //     // displayName만 추출하여 리스트로 변환
  //     final displayNames = userList.map((user) => user.displayName).toList();
  //     final hasName = displayNames.contains(documentState.rxUserId.value);
  //     // bool hasDisplayName(String name) {
  //     //   return displayNames.contains(name);
  //     // }

  //     // if (hasDisplayName(documentState.rxUserId.value)) {
  //     if (hasName) {
  //       debugPrint('######getSharedUserList : $displayNames');
  //       debugPrint('#### ${documentState.rxUserId.value} 공유 사용자 목록에 있습니다.');
  //       // editor가 초기화되었는지 확인 후 연결
  //       if (_editor != null) {
  //         connectEditor();
  //         debugPrint('######connectEditor');
  //       } else {
  //         debugPrint('#### Editor가 아직 초기화되지 않았습니다.');
  //       }
  //     } else {
  //       debugPrint('#### ${documentState.rxUserId.value} 공유 사용자 목록에 없습니다.');
  //     }
  //   } catch (e) {
  //     debugPrint('#### getSharedUserList 오류 발생: $e');
  //   }
  // }

  void preview() {}

  void loadAttributePanel(
      EditorCallBackType callBackType, EditorHtmlNode? node) {
    unfocusAllNodes();

    if (node != null) {
      _resetPanelState(node);
      rxEditorHtmlNode.value = node;

      _getAnimation(node);
    }

    final newAttribute = _getAttributePanelForNode(callBackType, node);
    _updateAttributePanel(newAttribute);
  }

  /// 멀티 콜백 호출됨.
  /// onCaretSelected 호출 후 이어서 바로 onCellSelected 호출됨.
  void loadCellSelectedAttributePanel(
      EditorHtmlNode table, List<EditorHtmlNode> nodes) {
    final newAttribute =
        _getAttributePanelForNode(EditorCallBackType.cellSelected, table);
    _updateAttributePanel(newAttribute);
  }

  void loadMultiSelectedAttributePanel(List<EditorHtmlNode> nodes) {
    rxMultiSelectedNodes.value = nodes;
    _updateAttributePanel(MultiSelectedAttributePanel());
  }

  void loadWidgetSelectedAttributePanel(
      EditorHtmlNode node, String id, Map<String, dynamic> properties) {
    final widgetId = WidgetId.fromString(id);

    Widget? newAttribute;
    if (widgetId == WidgetId.pageNumber) {
      newAttribute = WidgetPageNumberAttributePanel();
      initPageNumber();
    } else if (widgetId == WidgetId.toc) {
      newAttribute = WidgetTocAttributePanel();
      initToc();
    } else if (widgetId == WidgetId.slider) {
      final type = WidgetSliderType.fromString(id);
      newAttribute = WidgetSliderAttributePanel(type: type);
      initSlider();
    } else if (widgetId == WidgetId.simpleSlider) {
      final type = WidgetSliderType.fromString(id);
      newAttribute = WidgetSliderAttributePanel(type: type);
      initSlider();
    } else if (widgetId == WidgetId.toggle) {
      // newAttribute = QuizWidgetAttributePanel();
      // initToggle();
    } else if (widgetId == WidgetId.tab) {
      // newAttribute = QuizWidgetAttributePanel();
      // initQuiz();
    } else if (widgetId == WidgetId.arccodion) {
      // final type = WidgetSliderType.fromString(id);
      // newAttribute = WidgetSliderAttributePanel(type: type);
      // initSlider();
    } else if (widgetId == WidgetId.truefalse) {
      newAttribute = QuizWidgetAttributePanel();
      // initQuiz();
      syncPropertiesFromWidget();
    } else if (widgetId == WidgetId.singlechoice) {
      newAttribute = QuizWidgetAttributePanel();
      // initQuiz();
      syncPropertiesFromWidget();
    } else if (widgetId == WidgetId.multichoice) {
      newAttribute = QuizWidgetAttributePanel();
      // initQuiz();
      syncPropertiesFromWidget();
    } else if (widgetId == WidgetId.resultbutton) {
      newAttribute = QuizWidgetAttributePanel();
      // initQuiz();
    }
    _updateAttributePanel(newAttribute);
  }

  /// 객체들의 위치,크기의 변화가 실시간으로 전달됨.
  void onNodeRectChanged(List<EditorHtmlNodeRect> nodes) {
    final adb = nodes[0];

    rxWidth.value = adb.width;
    rxHeight.value = adb.height;
    rxLocationX.value = adb.left ?? 0;
    rxLocationY.value = adb.top ?? 0;
  }

  void onUndoStackChanged(bool canUndo, bool canRedo) {
    rxCanUndo.value = canUndo;
    rxCanRedo.value = canRedo;
  }

  void onMouseMove(double editorX, double editorY, double windowX,
      double windowY, bool isInEditor) {
    // 에디터가 초기화되지 않았으면 조기 반환
    if (editor == null) return;

    // 커서 위치 보정 계산
    final scrollPosition = editor?.scrollPosition();

    // 화이트보드 마우스 다운 상태 안전하게 확인
    bool isMouseDown = false;
    try {
      isMouseDown = editor?.whiteBoardIsMouseDown() ?? false;
    } catch (e) {
      // JavaScript에서 null 참조 오류 발생 시 무시
      isMouseDown = false;
    }

    final scrollX = scrollPosition?.x ?? 0;
    final scrollY = scrollPosition?.y ?? 0;
    if (documentState.rxProjectSharePermission.value ==
            ProjectAuthType.publicLink ||
        documentState.rxProjectSharePermission.value ==
            ProjectAuthType.userLink) {
      if (isMouseDown) {
        // 화이트 보드 좌표
        onWhiteBoardMouseMove(scrollX, scrollY);

        // 에디터 좌표
        // updateCursorPosition(
        //     x: editorX, y: editorY, scrollX: scrollX, scrollY: scrollY);
      } else {
        updateCursorPosition(
            x: editorX, y: editorY, scrollX: scrollX, scrollY: scrollY);
      }
    }
  }
  // if (rxIsDrawingMode.value == true) {
  //   editor?.isDrawingEditorXY(editorX.toInt(), editorY.toInt());
  //   // debugPrint('######onMouseMove: ${editorX.toInt()}, ${editorY.toInt()}');
  // }

  void _getAnimation(EditorHtmlNode node) {
    final animation = node.attributes['data-ve-animation'];
    if (animation != null) {
      // "click|ve-animation-swing|1|1|1";
      List<String> parts = animation.split('|');
      rxAnimationTrigger.value = AnimationTriggerType.fromString(parts[0]);
      rxAnimationNames.value = AnimationType.fromString(parts[1]);
      rxAnimationDelay.value = double.tryParse(parts[2]) ?? 1.0;
      rxAnimationDuration.value = double.tryParse(parts[3]) ?? 1.0;
      rxAnimationRepeat.value = int.tryParse(parts[4]) ?? 1;
    }
  }

  void _resetPanelState(EditorHtmlNode node) {
    rxOldAttribute.value = null;
    rxInnerHTML.value = '';

    //____ reset animation ______//
    rxAnimationDelay.value = 1;
    rxAnimationDuration.value = 1;
    rxAnimationRepeat.value = 1;
    rxAnimationNames.value = AnimationType.no;
    rxAnimationTrigger.value = AnimationTriggerType.click;

    // 가상 리스트 깊이 초기화
    rxVirtualListDepth.value = 0;
    rxVirtualListDepthType.value = 'none';

    // 도형인 경우 도형 상태 리셋
    if (node.nodeName == 'canvas') {
      resetShapeState();
    }

    if (node.nodeName == 'math') {
      rxInnerHTML.value = node.innerHTML;
    }
  }

  Widget? _getAttributePanelForNode(
      EditorCallBackType callBackType, EditorHtmlNode? node) {
    if (callBackType == EditorCallBackType.noneSelected && node == null) {
      // rxVirtualListStartNumber.value = editor
      //         ?.getVirtualListCounts()
      //         .toDart
      //         .map((e) => e.toDartInt)
      //         .toList() ??
      //     [];
      return const PageSettingsPanel();
    }

    final nodeName = node!.nodeName;

    //선택한 요소에 가상리스트가 포함되어있는지 확인
    rxHasVirtualList.value = editor?.hasVirtualListInSelection() ?? false;

    if (rxHasVirtualList.value) {
      final virtualListStyle = editor?.getCurrentVirtualListStyle() ?? '';
      if (virtualListStyle.isNotEmpty) {
        rxVirtualListDepthType.value = virtualListStyle;
        rxVirtualListDepth.value = editor?.getSelectedVirtualListDepth() ?? 0;
      }
    }

    final isInsideOrderedList = editor?.isInsideOrderedList() ?? false;

    final link = editor?.getAppliedLink();
    if (link != null) {
      linkController.text = editor?.getAppliedLink() ?? '';
    }

    _loadTextStyleAttributes(node);
    if (callBackType == EditorCallBackType.caretSelected) {
      unfocusAllNodes();
      // 테이블의 cell이 선택되었다면 CellAttributePanel보여준다.
      final selectedCells = editor?.selectedCells().toDart;
      rxDisabledTextbox.value = false;
      if (selectedCells?.isEmpty == true) {
        final virtualList = node.attributes['data-ve-vlist-depth'];
        rxIsVirtualList.value = (virtualList != null);
        checkIntentOutdentList();
        getListStyle();
        // rxVirtualList.value = true;
        // rxVirtualListDepth.value =
        //     int.tryParse(node.attributes['data-ve-vlist-depth'] ?? '0') ?? 0;
        return TextBoxTextAttributePanel(isUlList: isInsideOrderedList);
      } else {
        rxTableRowCount.value = 1;
        rxTableColumnCount.value = 1;
        return CellAttributePanel();
      }
    }

    if (callBackType == EditorCallBackType.cellSelected) {
      rxDisabledTextbox.value = false;
      rxTableRowCount.value = 1;
      rxTableColumnCount.value = 1;
      return CellAttributePanel();
    }

    if (node.nodeName == 'svg') {
      final mathMarkup = node.attributes['data-ve-math-markup'];
      if (mathMarkup != null) {
        return MathAttributePanel(mathMarkup: mathMarkup);
      }
    }

    switch (nodeName) {
      case 'div':
        rxDisabledTextbox.value = true;
        return TextBoxAttributePanel();
      case '#text':
        checkIntentOutdentList();
        getListStyle();
        rxVirtualListDepth.value =
            int.tryParse(node.attributes['data-ve-vlist-depth'] ?? '0') ?? 0;
        return TextBoxTextAttributePanel(isUlList: isInsideOrderedList);
      case 'img':
        return ImageAttributePanel();
      case 'veaudio':
        _loadMediaAttributes();
        return AudioAttributePanel();
      case 'vevideo':
        _loadMediaAttributes();
        return VideoAttributePanel();
      case 'table':
        rxDisabledTextbox.value = true;
        return TableAttributePanel();
      case 'canvas':
        resetShapeState(); // 도형 패널을 보여주기 전에 상태 리셋
        setShapeAttributes(node); // 도형 속성 설정
        return ShapeAttributePanel();
      default:
        return null;
    }
  }

  void _loadTextStyleAttributes(EditorHtmlNode node) {
    JSTextStyle? style = editor?.getSelectedTextStyle().withCopy(
        paragraphTag: editor?.getSelectedParagraphTag(),
        paragraphStyle: editor?.getSelectedParagraphStyle());

    final fontFamily = style?.fontFamily ?? '';
    updateFontStatus(fontFamily);

    rxFontSize.value = style?.fontSize.pxToPtNumber() ?? '16';
    rxTextColor.value = style?.textColor.toColor() ?? Colors.black;
    rxFontBackColor.value = style?.backColor.toColor() ?? Colors.transparent;

    // 도형인 경우 배경색 불러오기
    if (node.nodeName == 'canvas') {
      final shapeSettings = node.attributes['data-ve-shape-setting'];
      if (shapeSettings != null) {
        final settings = shapeSettings.split('|');
        if (settings.length >= 4) {
          rxObjectBackColor.value = settings[3].toColor() ?? Colors.transparent;
        }
      }
    }
    // _______________________________________
    //      table & cell 변수 초기화
    // _______________________________________
    // 테이블 노드 찾기
    final tableNode = rxEditorHtmlNode.value?.findParentTableNode();
    final EditorHtmlNode? editorTableNode = tableNode?.$2;
    final tableStyle = editorTableNode?.style;

    rxTableBackColor.value = (tableNode != null)
        ? tableStyle?.backgroundColor.toColor() ?? Colors.transparent
        : Colors.transparent;
    rxTableBackImage.value = tableStyle?.backgroundImage ?? '';
    rxTableBackRepeat.value = BackgroundRepeatType.fromString(
        tableStyle?.backgroundRepeat ?? BackgroundRepeatType.noRepeat.name);

    final selectedCells = editor?.selectedCells().toDart;
    if (selectedCells?.isEmpty == true) {
      rxObjectBackColor.value =
          node.style.backgroundColor.toColor() ?? Colors.transparent;
      rxObjectBackImage.value = node.style.backgroundImage ?? '';
      rxObjectBackRepeat.value = BackgroundRepeatType.fromString(
          node.style.backgroundRepeat ?? BackgroundRepeatType.noRepeat.name);

      // border
      rxBorderWidth.value =
          int.tryParse(node.style.borderWidth?.replacePX() ?? '0') ?? 0;
      rxBorderColor.value =
          node.style.borderColor.toColor() ?? Colors.transparent;
      rxBorderStyle.value = BorderStyleType.fromString(
          node.style.borderStyle ?? BorderStyleType.none.optionName);

      // size
      rxWidth.value =
          double.tryParse(node.style.width?.replacePX() ?? '100.0') ?? 100.0;
      rxHeight.value =
          double.tryParse(node.style.height?.replacePX() ?? '100.0') ?? 100.0;

      rxBackgroundWidth.value =
          node.style.backgroundImageWidth?.replacePX() ?? '';

      rxBackgroundHeight.value =
          node.style.backgroundImageHeight?.replacePX() ?? '';
    } else {
      final nodeCell = EditorHtmlNode.fromNode(selectedCells![0] as web.Node);
      rxObjectBackColor.value =
          nodeCell.style.backgroundColor.toColor() ?? Colors.transparent;
      rxObjectBackImage.value = nodeCell.style.backgroundImage ?? '';
      rxObjectBackRepeat.value = BackgroundRepeatType.fromString(
          nodeCell.style.backgroundRepeat ?? BackgroundRepeatType.repeat.name);

      // border
      rxBorderWidth.value =
          int.tryParse(nodeCell.style.borderWidth?.replacePX() ?? '0') ?? 0;
      rxBorderColor.value =
          nodeCell.style.borderColor.toColor() ?? Colors.transparent;
      rxBorderStyle.value = BorderStyleType.fromString(
          nodeCell.style.borderStyle ?? BorderStyleType.none.optionName);

      // // size
      // rxWidth.value =
      //     double.tryParse(nodeCell.style.width?.replacePX() ?? '100.0') ??
      //         100.0;
      // rxHeight.value =
      //     double.tryParse(nodeCell.style.height?.replacePX() ?? '100.0') ??
      //         100.0;
    }

    // table border
    rxTableBorderWidth.value =
        int.tryParse(tableStyle?.borderWidth?.replacePX() ?? '1') ?? 1;
    rxTableBorderColor.value =
        tableStyle?.borderColor.toColor() ?? Colors.black;
    rxTableBorderStyle.value = BorderStyleType.fromString(
        tableStyle?.borderStyle ?? BorderStyleType.none.optionName);

    // table
    rxTableRowCount.value = 1;
    rxTableColumnCount.value = 1;

    rxLetterSpacing.value = (style?.letterSpacing == 'normal')
        ? '0'
        : style?.letterSpacing.replacePX() ?? '0';

    rxLineSpacing.value =
        (style != null && style.paragraphStyle.lineHeight.isEmpty ||
                style?.paragraphStyle.lineHeight == 'normal')
            ? '0'
            : style?.paragraphStyle.lineHeight.replacePX() ?? '0';

    final paddingTop = style?.paragraphStyle.paddingTop.replacePX();
    if (paddingTop?.isEmpty == true) {
      // 초기화값 10
      rxLinePaddingTop.value = '10';
    } else {
      rxLinePaddingTop.value = paddingTop ?? '10';
    }

    rxTextAlign.value = TextAlignTypeExtension.fromString(
        style?.paragraphStyle.textAlign ?? TextAlignType.left.name);
    rxTextAlign.value;

    rxHeading.value = HeadingTypeExtension.fromString(
        style?.paragraphTag ?? HeadingType.h1.name);

    rxPadding.value = (node.style.padding ?? '0').replacePX();
    rxPaddingLeft.value = (node.style.paddingLeft ?? '0').replacePX();
    rxPaddingRight.value = (node.style.paddingRight ?? '0').replacePX();
    rxPaddingTop.value = (node.style.paddingTop ?? '0').replacePX();
    rxPaddingBottom.value = (node.style.paddingBottom ?? '0').replacePX();

    // 마진 값 로드
    rxMargin.value = (node.style.margin ?? '0').replacePX();
    rxMarginLeft.value = (node.style.marginLeft ?? '0').replacePX();
    rxMarginRight.value = (node.style.marginRight ?? '0').replacePX();
    rxMarginTop.value = (node.style.marginTop ?? '0').replacePX();
    rxMarginBottom.value = (node.style.marginBottom ?? '0').replacePX();

    rxOpacity.value =
        (node.style.opacity ?? '1').replaceAll('%', '').opacityToTransparency();

    final textDecorations = [
      style?.bold,
      style?.italic,
      style?.underline,
      style?.overline,
      style?.strike
    ];

    rxTextDecorations.value = textDecorations
        .asMap()
        .entries
        .where((entry) => entry.value == true)
        .map((entry) => TextDecorationType.values[entry.key])
        .toList();

    final textPositions = [
      style?.subScript,
      style?.superScript,
      //
      // style.subscriptAlpha,
      // style.superscriptAlpha,
    ];

    final index = textPositions.indexOf(true);
    rxTextPosition.value = index != -1 ? TextPositionType.values[index] : null;

    // multi column
    rxMultiColumnCount.value = int.tryParse(node.style.columnCount ?? '1') ?? 1;
    rxMultiColumnFillOption.value = MultiColumnFillType.fromString(
        node.style.columnFill ?? MultiColumnFillType.auto.optionName);
    rxMultiColumnGap.value = int.tryParse(node.style.columnGap ?? '10') ?? 10;
    rxMultiColumnRuleStyleOption.value = BorderStyleType.fromString(
        node.style.columnRuleStyle ?? BorderStyleType.none.optionName);
    rxMultiColumnRuleWidth.value =
        int.tryParse(node.style.columnRuleWidth?.replacePX() ?? '1') ?? 1;
    rxMultiColumnRuleColor.value =
        node.style.columnRuleColor.toColor() ?? Colors.black;

    // location
    rxLocationX.value =
        double.tryParse(node.style.left?.replacePX() ?? '0.0') ?? 0.0;
    rxLocationY.value =
        double.tryParse(node.style.top?.replacePX() ?? '0.0') ?? 0.0;
  }

  void _loadMediaAttributes() {
    rxMediaControls.value = getAttribute('controls').toBool();
    rxMediaAutoPlay.value = getAttribute('autoplay').toBool();
    rxMediaLoop.value = getAttribute('loop').toBool();
    rxMediaMuted.value = getAttribute('muted').toBool();
  }

  void _updateAttributePanel(Widget? newAttribute) {
    // 새로운 속성이 null이 아니고, 이전 속성과 다른 경우에만 업데이트
    if (newAttribute != null &&
        (rxOldAttribute.value == null ||
            rxOldAttribute.value.runtimeType != newAttribute.runtimeType)) {
      rxOldAttribute.value = newAttribute;
      rxAttribute.value = newAttribute;
      uiState.isRightDrawerOpen.value = true;
    }
  }

  void checkUserLoginType() async {
    // 테넌트 타입으로 수정해야 함
    // 현재는 유저의 로그인 타입을 알 수 없으므로 웍스만 고정으로 처리

    final result = await loginService.userInfo();
    if (result != null) {
      // final provider = UserLoginType.fromString(result.provider ?? '');
      // rxUserLoginType.value = provider;
      rxTenantType.value = TenantType.fromString(result.provider ?? '');
    }
  }

  void editorRefresh() {
    editor?.unload();
    editor?.load(rxPageUrl.value);
  }

  //_____editor engine______
  void setEditorLoad(Editor editor) async {
    _editor = editor;

    loadEditor(isUnload: false);

    // final permission = await isPermission();

    final loginStatus = await loginService.userInfo();
    final isLoggedIn = loginStatus?.displayName != null;
    bool permission = false;

    if (isLoggedIn) {
      permission = await isPermission();
    } else {
      permission = false;
    }
    if (documentState.rxProjectSharePermission.value ==
            ProjectAuthType.publicLink ||
        documentState.rxProjectSharePermission.value ==
            ProjectAuthType.userLink) {
      // WebSocket 연결 보장 (이미 연결된 경우 재연결하지 않음)
      ensureSocketForPermission(isPermission: permission);
      // rxIsCoopMode.value = true;
      // checkEnabledEditor();
      // getSharedUserList();
      if (rxEditingUserId.value == 'null') {
        editor.enable(true);
      }
    } else {
      rxIsCoopMode.value = false;
      rxIsEditorStatus.value = true;
      isEditingStatus.value = true;
      isEditingPermission.value = true;
      // 비공개에서는 소켓 연결 해제 보장
      ensureSocketForPermission(isPermission: false);
    }
  }

  void setEditorUserPermission(bool isEditorEdit) async {
    final result = await apiService.setEditorUserPermission(
        pageId: documentState.rxPageCurrent.value?.id ?? '',
        isEditorEdit: isEditorEdit);
    if (result == true) {
      final data =
          await apiService.fetchProject(documentState.rxProjectId.value);
      final pages = data?.project?.toPageJson();
      final treeListModel = TreeListModel.listFromJson(pages!);
      documentUserId.value = data?.project?.displayName ?? '';
      documentState.rxPages.value = treeListModel;
    }
    wsManager.sendTreeList(documentState.rxProjectId.value);
    debugPrint('#### setEditorUserPermission: $isEditorEdit');
  }

  void loadEditor({bool? isUnload = true}) async {
    try {
      if (_editor == null) {
        debugPrint('#### Editor가 초기화되지 않았습니다.');
        return;
      }

      if (isUnload == true) {
        _editor?.unload();
      }

      editor?.load(rxPageUrl.value);
    } catch (e) {
      debugPrint('#### loadEditor 오류 발생: $e');
    }
  }

  // 전달 받은 baseUrl에서 lang 파일 경로 반환
  String getLangUrl(String baseUrl) {
    var language = Get.locale?.languageCode ?? 'ko';
    // 현재는 'ko', 'en'만 지원되므로 다른 언어는 'en'으로 처리
    if (language != 'ko') {
      language = 'en';
    }

    final langUrl =
        '${documentState.rxBaseURL.value.replaceAll('/api/v1', '')}lang/$language.json';

    // final langUrl =
    //     '${AutoConfig.instance.domainType.originWithPath}/lang/$language.json';

    return langUrl;
  }

  // 페이지 로드 후 호출되는 메서드
  void onPageLoad(Editor editor) {
    logger.d('onPageLoad: ${documentState.rxPageCurrent.value?.idref}');
    final document = editor.getDocumentState();
    documentState.rxDocumentSizeWidth.value = document.width;
    documentState.rxDocumentSizeHeight.value = document.height;

    // 설정 가능한 폰트 리스트 조회
    initializeFonts();

    // body panel 초기화
    initBodyPanel();

    // 페이지가 변경될 때 마다 속성을 초기화한다.
    documentState.setPageProperties();
    // 페이지 번호 위젯의 페이지 번호 값 변경
    if (documentState.rxPageCurrent.value?.calculatedPage != null) {
      updatePageNumber(
          (documentState.rxPageCurrent.value?.calculatedPage).toString());
    } else {
      updatePageNumber('#');
    }

    // 페이지 속성 패널 초기화 시 배경색 불러오기
    rxBodyBackColor.value =
        editor.getBodyBackColor().toColor() ?? Colors.transparent;
    rxAttribute.value = const PageSettingsPanel();

    checkEnabledEditor();

    if (pageLoadCompleter != null) {
      logger.d(
          '[MEMO] completer: complete ${documentState.rxPageCurrent.value?.idref}');
      pageLoadCompleter?.complete(documentState.rxPageCurrent.value?.idref);
      pageLoadCompleter = null;
    }
  }

  // 페이지 편집 권한이 있는 사용자인지 체크
  void checkEnabledEditor() async {
    final loginStatus = await loginService.userInfo();
    final isLoggedIn = loginStatus?.displayName != null;

    if (!isLoggedIn) {
      rxIsCoopMode.value = false;
      rxIsEditorStatus.value = false;
      editor?.enable(false);
      return;
    }

    // 페이지 편집 권한 체크
    // 페이지 소유자, 페이지 편집자 여부 체크
    final pageId = documentState.rxPageCurrent.value?.id ?? '';
    if (pageId.isEmpty) {
      return;
    }
    final userInfo = await apiService.checkEditStatus(pageId: pageId);
    rxIsOwner.value = userInfo?.user?.isOwner ?? false;
    myCoOpState.value = userInfo?.user?.isEditable ?? false;
    // rxIsEditorStatus.value = userInfo?.user?.isEditable ?? false;
    // editor?.enable(userInfo?.user?.isEditable ?? false);
    documentState.rxPageEditable.value = userInfo?.user?.isEditable ?? false;

    logger
        .i('######display: checkEnabledEditor: ${userInfo?.user?.isEditable}');
    if (rxEditingUserId.value == 'null') {
      logger.i('######display: rxEditingUserId.value is null');
      editor?.enable(true);
    }
  }

  void updateEditorPosition() {
    editor?.updateEditorPosition();
  }

  Future<void> changePageTreeList(TreeListModel pageData) async {
    final projectId = documentState.rxProjectId.value;
    if (projectId.isEmpty) {
      if (documentState.rxPageCurrent.value.hashCode != pageData.hashCode) {
        await changedPage(pageData);
      }
      return;
    }
    final result = await apiService.fetchProject(projectId);
    if (result != null && result.statusCode == 403) {
      onProjectAccessDenied?.call();
      return;
    }
    if (documentState.rxPageCurrent.value.hashCode != pageData.hashCode) {
      await changedPage(pageData);
    }
  }

  Future<void> changedPage(TreeListModel pageData) async {
    logger.d('[VulcanEditorController] changedPage');

    // 페이지 변경 작업이 이루어지기 전에 타이머를 종료 시키고 저장 동작을 한 후에 변경 동작 시작
    if (documentState.rxPageCurrent.value?.idref != null) {
      if (documentState.rxPageCurrent.value?.idref != pageData.idref) {
        EasyLoading.show();
        if (timerManager.isTimerRunning) {
          timerManager.cancelTimer();
        }
        if (isDocumentChanged) {
          isDocumentChanged = false;
          String? html = editor?.getHtmlString() ?? '';
          logger.d('[VulcanEditorController] triggerUpdatePageContent start');
          await triggerUpdatePageContent(html, '');
          logger.d('[VulcanEditorController] triggerUpdatePageContent end');
        }
        EasyLoading.dismiss();
      }
    }

    // 변경 전 페이지 확인
    if (documentState.rxPageCurrent.value?.idref != pageData.idref) {
      if (rxEditingUserId.value == documentState.rxUserId.value) {
        // 로그인 되어 있는 편집 권한 가진 유저들만 체크하도록
        if (rxIsEditorStatus.value) {
          setEditorUserPermission(false);
        }
      }
    }

    // 페이지 변경 시 화이트보드 초기화

    // 페이지 클릭 시 호출 함수
    final fileName = pageData.href;
    // final pageUrl = rxPageUrl.value.replaceAll(RegExp(r'[^/]+\.xhtml$'), fileName);
    final pageUrl = documentState.getBuildTypeUrl(
        documentState.rxProjectId.value, fileName);

    documentState.rxPageCurrent.value = pageData;
    rxPageUrl.value = pageUrl;

    final loginStatus = await loginService.userInfo();
    final isLoggedIn = loginStatus?.displayName != null;
    bool permission = false;

    if (isLoggedIn) {
      permission = await isPermission();
    } else {
      permission = false;
    }

    editor?.unload();
    editor?.load(rxPageUrl.value);
    // editor?.unloadWhiteBoard();
    // editor?.loadWhiteBoard();
    // web-socket 페이지 변경 로직 추가
    if (documentState.rxProjectSharePermission.value ==
            ProjectAuthType.publicLink ||
        documentState.rxProjectSharePermission.value ==
            ProjectAuthType.userLink) {
      onChangedPage(documentState.rxPageCurrent.value?.idref ?? '',
          isPermission: permission);
      wsManager.sendCursorPosition(
          documentState.rxProjectId.value,
          documentState.rxPageCurrent.value?.idref ?? 'cover.xhtml',
          0,
          0,
          documentState.rxDocumentSizeWidth.value.toDouble(),
          documentState.rxDocumentSizeHeight.value.toDouble(),
          'clear',
          'false');
      // getSharedUserList();
    }

    // 페이지 속성 패널 초기화 시 배경색 불러오기
    rxBodyBackColor.value =
        editor?.getBodyBackColor().toColor() ?? Colors.transparent;
    rxAttribute.value = const PageSettingsPanel();

    onTempSaveCheck();
  }

  void refreshPage(TreeListModel pageData) {
    final fileName = pageData.href;
    rxPageUrl.value =
        rxPageUrl.value.replaceAll(RegExp(r'[^/]+\.xhtml$'), fileName);

    rxPageUrl.value = documentState.getBuildTypeUrl(
        documentState.rxProjectId.value, fileName);

    wsManager.sendRefresh(
        documentState.rxProjectId.value,
        documentState.rxPageCurrent.value?.idref ?? 'cover.xhtml',
        rxPageUrl.value);
  }

  void onNodeRemoved(EditorHtmlNode node) {
    if (node.webNode.nodeName == 'div' &&
        node.attributes['data-widget-id'] == 'toc') {
      updatePageContent();
      Future.delayed(const Duration(milliseconds: 500), () {
        convertTocToNormalTrigger.value = true;
      });
    }
  }

  void refreshTree(List<TreeListModel> treeListModel) {
    // wsManager.sendTreeList(documentState.rxProjectId.value, treeListModel);
    wsManager.sendTreeList(documentState.rxProjectId.value);
  }

  void showEditorUser(String projectId) async {
    final projectOwner;
    if (documentState.rxProjectOwner.isEmpty) {
      final result = await apiService.fetchProject(projectId);
      // await apiService.fetchProject(documentState.rxProjectId.value);
      // await apiService.fetchProject('pb1d34435');

      projectOwner = result?.project?.userId;
    } else {
      projectOwner = documentState.rxProjectOwner.value;
    }
    if (projectOwner == documentState.rxUserId.value) {
      if (documentState.rxProjectSharePermission.value ==
              ProjectAuthType.publicLink ||
          documentState.rxProjectSharePermission.value ==
              ProjectAuthType.userLink) {
        rxShowEditorUser.value = true;
        wsManager.sendTreeList(documentState.rxProjectId.value);
      } else {
        rxShowEditorUser.value = false;
        wsManager.sendTreeList(documentState.rxProjectId.value);
      }
    } else {
      rxShowEditorUser.value = true;
      wsManager.sendTreeList(documentState.rxProjectId.value);
    }
  }

  void openDocument(BuildContext context) async {
    final file = await pickDocumentFile(context);
    if (file != null && context.mounted) {
      final extension = file.extension?.toLowerCase() ?? '';
      if (DragDocsMixin.allowedOfficeExtensions.contains(extension)) {
        showDragDocsWebViewDialog(
          context,
          fileBytes: file.bytes,
          fileName: file.name,
        );
      } else if (DragDocsMixin.allowedEpubExtensions.contains(extension)) {
        showEpubViewerWebViewDialog(
          context,
          fileBytes: file.bytes,
          fileName: file.name,
        );
      }
    }
  }

  Future<void> openMemoPopup(BuildContext context, TreeListModel page) async {
    logger.d('[MEMO] openMemoPopup');
    if (!context.mounted) {
      return;
    }

    EasyLoading.show();
    // 이미 페이지 로드 중이면 대기
    if (pageLoadCompleter != null) {
      logger.d('[MEMO] completer: wait1 start');
      await pageLoadCompleter?.future;
      logger.d('[MEMO] completer: wait1 end');
      pageLoadCompleter = null;
    }

    // await changePageTreeList(page);
    if (documentState.rxPageCurrent.value.hashCode != page.hashCode) {
      logger.d('[MEMO] completer: new');
      pageLoadCompleter = Completer<String>();

      await changedPage(page);

      // 페이지 로드 대기
      logger.d('[MEMO] completer: wait2 start');
      await pageLoadCompleter?.future;
      logger.d('[MEMO] completer: wait2 end');
      pageLoadCompleter = null;
    }
    EasyLoading.dismiss();

    final memoList = getMemo();
    if (memoList == null) {
      EasyLoading.showError('memo_open_error'.tr);
      return;
    }
    if (context.mounted) {
      MemoPopup.show(
        context: context,
        memoList: memoList,
        documentState: documentState,
        isEditingPermission: isEditingPermission.value,
        onMemoAdded: (memo) => addMemo(memo),
        onMemoUpdated: (memo) => updateMemo(memo),
        onMemoDeleted: (memo) => deleteMemo(memo.id),
      );
    }
  }

  void viewColumn() {
    rxViewColumn.value = !rxViewColumn.value;
    uiState.isLeftDrawerOpen.value = !uiState.isLeftDrawerOpen.value;
    uiState.isRightDrawerOpen.value = rxViewColumn.value;
  }

  Future<void> fileUpload(PlatformFile file) async {
    // FormData 생성
    dio.FormData formData = dio.FormData.fromMap({
      'projectId': documentState.rxProjectId.value,
      'file': dio.MultipartFile.fromBytes(
        file.bytes!, // Web에서는 bytes를 사용
        filename: file.name,
      ),
      'description': 'File description'
    });

    // TriggerControlMixin에서 정의된 uploadFileTrigger 사용
    uploadFileTrigger.value = formData;
  }

  void scale(double factor) {
    editor?.scale(factor);
    rxZoomValue.value = factor;
  }

  //_______popup menu__________
  Future<void> gotoHome(BuildContext context) async {
    logger.d('[VulcanEditorController] gotoHome');
    stopCoOpCount();

    EasyLoading.show();
    if (timerManager.isTimerRunning) {
      timerManager.cancelTimer();
    }
    if (isDocumentChanged) {
      isDocumentChanged = false;
      String? html = editor?.getHtmlString() ?? '';
      logger.d('[VulcanEditorController] triggerUpdatePageContent start');
      await triggerUpdatePageContent(html, '');
      logger.d('[VulcanEditorController] triggerUpdatePageContent end');
    }
    EasyLoading.dismiss();

    if (rxEditingUserId.value == documentState.rxUserId.value) {
      setEditorUserPermission(false);
    }

    // if (documentState.rxPageCurrent.value?.idref != null) {
    //   if (timerManager.isTimerRunning) {
    //     timerManager.cancelTimer();
    //   }
    //   // 페이지 변경 작업이 이루어지기 전에 타이머를 종료 시키고 저장 동작을 한 후에 변경 동작 시작
    //   String? html = '';
    //   if (editor != null) {
    //     html = editor?.getHtmlString() ?? '';
    //   }
    //   if (html.isNotEmpty) {
    //     triggerUpdatePageContent(html, '');
    //     timerManager.dispose();
    //   }
    // }

    // timerManager.cancelTimer();
    // getHtmlString() 호출 시 에디터가 이미 dispose되거나 DOM 요소가 제거된 경우를 대비
    // String? html = '';
    // try {
    //   if (editor != null) {
    //     html = editor?.getHtmlString() ?? '';
    //   }
    // } catch (e) {
    //   logger.w('Error getting HTML string in gotoHome (continuing anyway): $e');
    //   html = '';
    // }

    // triggerUpdatePageContent(html, '');

    // // 에디터 정리 작업 수행
    // try {
    //   editor?.unload();
    // } catch (e) {
    //   logger.e('Error unloading editor in gotoHome: $e');
    // }

    disposeWebSocket();
    rxIsCoopMode.value = false;
    uiState.isLeftDrawerOpen.value = false;
    uiState.isRightDrawerOpen.value = false;
    // Get.delete<VulcanEditorController>();

    // 에디터 정리 완료 후 페이지 이동
    Future.microtask(() {
      if (context.mounted) {
        context.go('/home');
      }
    });
  }

  void updateCreateNewEditor(BuildContext context) {
    documentState.rxProjectId.value = '';
    update();
  }

  // 미리보기 전 데이터 저장
  Future<void> savePreviewData() async {
    // 미리보기 전 데이터 저장
    EasyLoading.show();
    if (timerManager.isTimerRunning) {
      timerManager.cancelTimer();
    }
    if (isDocumentChanged) {
      isDocumentChanged = false;
      String? html = editor?.getHtmlString() ?? '';
      logger.d('[VulcanEditorController] triggerUpdatePageContent start');
      await triggerUpdatePageContent(html, '');
      logger.d('[VulcanEditorController] triggerUpdatePageContent end');
    }
    EasyLoading.dismiss();
  }

  void showGrid(bool value) {
    rxShowGrid.value = value;
    wsManager.sendCursorPosition(
        documentState.rxProjectId.value,
        documentState.rxPageCurrent.value?.idref ?? 'cover.xhtml',
        4.0,
        10.0,
        documentState.rxDocumentSizeWidth.value.toDouble(),
        documentState.rxDocumentSizeHeight.value.toDouble(),
        cursorAction.value,
        'false');
    editor?.showGrid(value);
  }

  void showRuler(bool value) {
    rxShowRuler.value = value;
    editor?.showRuler(value);
  }

  void enableSnapToGrid(bool value) {
    rxGridSnap.value = value;
    editor?.enableSnapToGrid(value);
  }

  void setContentSize({required int width, required int height}) {
    documentState.rxDocumentSizeWidth.value = width;
    documentState.rxDocumentSizeHeight.value = height;
    editor?.setContentSize(width, height);
    updatePageContent();
  }

  // _______ 수식 입력기 _______
  void insertMath(String contents) {
    Map<String, dynamic> mathData = {};

    try {
      // JSON 문자열을 Map으로 변환
      mathData = jsonDecode(contents);

      final mathOuterHTML = mathData['mathml'] as String;
      //final imagedata = mathData['imagedata'] as String;
      final svg = mathData['svg'] as String;

      editor?.insertMath(mathOuterHTML, svg.scaleSvgDimensions(8), null);
    } catch (e) {
      logger.e('수식 입력 중 오류 발생: $e');
    }
  }

  void updateMath(String contents) {
    Map<String, dynamic> mathData = {};

    try {
      // JSON 문자열을 Map으로 변환
      mathData = jsonDecode(contents);

      final mathOuterHTML = mathData['mathml'] as String;
      final svg = mathData['svg'] as String;
      final svgScaled = svg.scaleSvgDimensions(8);

      editor?.updateMath(
          rxEditorHtmlNode.value!.webNode, mathOuterHTML, svgScaled, null);
      rxInnerHTML.value = mathOuterHTML;
    } catch (e) {
      logger.e('수식 업데이트 중 오류 발생: $e');
    }
  }

  void multiSelectedAnimationRun() {
    for (var htmlNode in rxMultiSelectedNodes) {
      editor?.runAnimation(htmlNode!.webNode);
    }
  }

  // ________ 링크 ________________
  void applyLink(String link) {
    linkController.text = link;
    editor?.applyLink(link);
  }

  void removeLink() {
    linkController.text = '';
    editor?.removeLink();
  }

  void undo() => editor?.undo();
  void redo() => editor?.redo();

  void onFrameClick() {
    unfocusAllNodes();
  }

  void onNodeInserted(EditorHtmlNode node) {
    if (node.webNode.nodeName == 'div' &&
        node.attributes['data-widget-id'] == 'toc') {
      updatePageContent();
    }

    //   // 페이지 번호 위젯이 삽입되었을 때 즉시 번호 업데이트
    if (node.webNode.nodeName == 'div' &&
        node.attributes['data-widget-id'] == 'page-number') {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (documentState.rxPageCurrent.value?.calculatedPage != null) {
          updatePageNumber(
              (documentState.rxPageCurrent.value?.calculatedPage).toString());
        } else {
          updatePageNumber('#');
        }
      });
    }
  }

  void refreshPageNumbers() {
    if (documentState.rxPageCurrent.value?.calculatedPage != null) {
      updatePageNumber(
          (documentState.rxPageCurrent.value?.calculatedPage).toString());
    } else {
      updatePageNumber('#');
    }
  }

  Future<void> onDocumentChanged(EditorHtmlNode node) async {
    logger.d('[VulcanEditorController] onDocumentChanged');
    isDocumentChanged = true;
    timerManager.startTimer(
      onComplete: () {
        isDocumentChanged = false;
        String? html = editor?.getHtmlString() ?? '';
        triggerUpdatePageContent(html, '');
      },
    );
  }

  void updateUndoRedoState() {
    rxCanUndo.value = editor?.canUndo() ?? false;
    rxCanRedo.value = editor?.canRedo() ?? false;
  }

  void multiSelectedAnimationStop() {
    for (var htmlNode in rxMultiSelectedNodes) {
      editor?.stopAnimation(htmlNode!.webNode);
    }
  }

  Future<void> _loadTemplates() async {
    try {
      // 클립아트 템플릿 로딩 (shallow 모드)
      final clipartTemplates = await TemplateParser.instance.parseTemplatesXml(
        type: TemplateType.clipart,
        parseMode: TemplateParseMode.shallow,
      );

      // 정부로고 템플릿 로딩 (shallow 모드)
      final glogoTemplates = await TemplateParser.instance.parseTemplatesXml(
        type: TemplateType.glogo,
        parseMode: TemplateParseMode.shallow,
      );

      // 클립아트 초기화 - 안전하게 처리
      if (rxClipArtsSelectedPrimary.value == null ||
          rxClipArtsPrimary.isEmpty) {
        _initializeClipArts(clipartTemplates);
      }

      // 정부로고 초기화 - 안전하게 처리
      if (rxGlogoSelectedPrimary.value == null || rxGlogoTemplates.isEmpty) {
        _initializeGlogos(glogoTemplates);
      }
    } catch (e) {
      debugPrint('Error parsing templates XML: $e');
      // 에러 발생 시 기본값으로 초기화
      if (rxClipArtsPrimary.isEmpty) {
        rxClipArtsPrimary.value = [];
        rxClipArtsSelectedPrimary.value = null;
        rxClipArtsSecondary.value = [];
        rxClipArtsSelectedSecondary.value = null;
        rxClipArtsResource.value = [];
        rxClipArtsPath.value = '';
      }
      if (rxGlogoTemplates.isEmpty) {
        rxGlogoTemplates.value = [];
        rxGlogoSelectedPrimary.value = null;
        rxGlogoSecondary.value = [];
        rxGlogoSelectedSecondary.value = null;
        rxGlogoResource.value = [];
        rxGlogoPath.value = '';
      }
    }
  }

  void _initializeClipArts(Templates templates) {
    try {
      if (templates.children.isNotEmpty) {
        rxClipArtsPrimary.value = templates.children;
        rxClipArtsSelectedPrimary.value = rxClipArtsPrimary.first;
        rxClipArtsSecondary.value = rxClipArtsPrimary.first.children;

        if (rxClipArtsSecondary.isNotEmpty) {
          rxClipArtsSelectedSecondary.value = rxClipArtsSecondary.first;
          rxClipArtsPath.value = rxClipArtsSecondary.first.path;
          // 초기 로드 시 첫 번째 템플릿 데이터 로드
          _loadInitialClipArtData(rxClipArtsSecondary.first);
        } else if (rxClipArtsPrimary.first.children.isEmpty) {
          // 하위 카테고리가 없는 경우 직접 템플릿 데이터 로드
          rxClipArtsPath.value = rxClipArtsPrimary.first.path;
          _loadInitialClipArtData(rxClipArtsPrimary.first);
        }
      } else {
        // 빈 템플릿의 경우 기본값 설정
        rxClipArtsPrimary.value = [];
        rxClipArtsSelectedPrimary.value = null;
        rxClipArtsSecondary.value = [];
        rxClipArtsSelectedSecondary.value = null;
        rxClipArtsResource.value = [];
        rxClipArtsPath.value = '';
      }
    } catch (e) {
      debugPrint('Error initializing cliparts: $e');
      // 에러 발생 시 기본값으로 초기화
      rxClipArtsPrimary.value = [];
      rxClipArtsSelectedPrimary.value = null;
      rxClipArtsSecondary.value = [];
      rxClipArtsSelectedSecondary.value = null;
      rxClipArtsResource.value = [];
      rxClipArtsPath.value = '';
    }
  }

  /// 정부로고 초기화 (새로운 메서드)
  void _initializeGlogos(Templates templates) {
    try {
      if (templates.children.isNotEmpty) {
        rxGlogoTemplates.value = templates.children;
        rxGlogoSelectedPrimary.value = rxGlogoTemplates.first;
        rxGlogoSecondary.value = rxGlogoTemplates.first.children;

        if (rxGlogoSecondary.isNotEmpty) {
          rxGlogoSelectedSecondary.value = rxGlogoSecondary.first;
          rxGlogoPath.value = rxGlogoSecondary.first.path;
          // 초기 로드 시 첫 번째 템플릿 데이터 로드
          _loadInitialGlogoData(rxGlogoSecondary.first);
        } else if (rxGlogoTemplates.first.children.isEmpty) {
          // 하위 카테고리가 없는 경우 직접 템플릿 데이터 로드
          rxGlogoPath.value = rxGlogoTemplates.first.path;
          _loadInitialGlogoData(rxGlogoTemplates.first);
        }
      } else {
        // 빈 템플릿의 경우 기본값 설정
        rxGlogoTemplates.value = [];
        rxGlogoSelectedPrimary.value = null;
        rxGlogoSecondary.value = [];
        rxGlogoSelectedSecondary.value = null;
        rxGlogoResource.value = [];
        rxGlogoPath.value = '';
      }
    } catch (e) {
      debugPrint('Error initializing glogos: $e');
      // 에러 발생 시 기본값으로 초기화
      rxGlogoTemplates.value = [];
      rxGlogoSelectedPrimary.value = null;
      rxGlogoSecondary.value = [];
      rxGlogoSelectedSecondary.value = null;
      rxGlogoResource.value = [];
      rxGlogoPath.value = '';
    }
  }

  void addContentsIcon(String position) {
    debugPrint('addContentsIcon');

    if (position == 'top_left') {
      editor?.insertTocLinkImage(30, 23);
    } else if (position == 'top_right') {
      editor?.insertTocLinkImage(522, 23);
    } else if (position == 'bottom_left') {
      editor?.insertTocLinkImage(30, 720);
    } else if (position == 'bottom_right') {
      editor?.insertTocLinkImage(522, 720);
    }
  }

  void equalizeTableRowHeight() {
    editor?.equalizeTableRowHeight();
  }

  void equalizeTableColumnWidth() {
    editor?.equalizeTableColumnWidth();
  }

  void onWidgetSelectionChanged(
      EditorHtmlNode node, String id, Map<String, dynamic> properties) {
    //logger.i('onWidgetSelectionChanged: $id');
    //logger.i('properties: $properties');
  }

  void insertContainer(String type) {
    editor?.insertContainer(type);
  }

  void setOnTempSaveCheck(VoidCallback callback) {
    onTempSaveCheckCallback = callback;
  }

  void onTempSaveCheck() {
    // final pageId = documentState.rxPageCurrent.value?.id ?? '';
    // final pageUrl = rxPageUrl.value;
    onTempSaveCheckCallback?.call();
  }

  Future<Map<String, dynamic>?> getWhiteBoardCurrentPoint() async {
    try {
      if (editor == null) return null;

      /* 
       * old cdoe
       * 
      final result =
          js_util.callMethod(editor!, 'getWhiteBoardCurrentPoint', []);
      if (result == null) return null;

      // 숫자 타입 변환 확인
      final x = js_util.getProperty(result, 'x');
      final y = js_util.getProperty(result, 'y');

      return {
        'x': x is num ? x.toDouble() : 0.0,
        'y': y is num ? y.toDouble() : 0.0,
      };
      */
      final result =
          editor!.callMethod('getWhiteBoardCurrentPoint'.toJS, [null].toJS);
      if (result == null || result is! JSObject) return null;
      // 숫자 타입 변환 확인
      final x = result.getProperty<JSNumber?>('x'.toJS);
      final y = result.getProperty<JSNumber?>('y'.toJS);
      return {
        'x': x?.toDartDouble ?? 0.0,
        'y': y?.toDartDouble ?? 0.0,
      };
    } catch (e) {
      debugPrint('Error getting whiteboard point: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getWhiteBoardDrawingState() async {
    try {
      if (editor == null) return {'isDrawing': false, 'point': null};

      /* 
       * old cdoe
       * 
      final result =
          js_util.callMethod(editor!, 'getWhiteBoardDrawingState', []);
      if (result == null) return {'isDrawing': false, 'point': null};

      final point = js_util.getProperty(result, 'point');
      final isDrawing = js_util.getProperty(result, 'isDrawing') ?? false;

      if (point == null) {
        return {'isDrawing': isDrawing, 'point': null};
      }

      // 숫자 타입 변환 확인
      final x = js_util.getProperty(point, 'x');
      final y = js_util.getProperty(point, 'y');

      return {
        'isDrawing': isDrawing,
        'point': {
          'x': x is num ? x.toDouble() : 0.0,
          'y': y is num ? y.toDouble() : 0.0,
        },
      };
       */
      final result =
          editor!.callMethod('getWhiteBoardDrawingState'.toJS, [null].toJS);
      if (result == null || result is! JSObject) {
        return {'isDrawing': false, 'point': null};
      }

      final point = result.getProperty<JSObject?>('point'.toJS);
      final isDrawing =
          result.getProperty<JSBoolean?>('isDrawing'.toJS)?.toDart ?? false;

      if (point == null) {
        return {'isDrawing': isDrawing, 'point': null};
      }

      // 숫자 타입 변환 확인
      final x = point.getProperty<JSNumber?>('x'.toJS);
      final y = point.getProperty<JSNumber?>('y'.toJS);

      return {
        'isDrawing': isDrawing,
        'point': {
          'x': x?.toDartDouble ?? 0.0,
          'y': y?.toDartDouble ?? 0.0,
        },
      };
    } catch (e) {
      debugPrint('Error getting whiteboard state: $e');
      return {'isDrawing': false, 'point': null};
    }
  }

  void onWhiteBoardMouseMove(double scrollX, double scrollY) async {
    try {
      final currentPoint = await getWhiteBoardCurrentPoint();
      if (currentPoint != null) {
        final x = (currentPoint['x'] as num).toDouble();
        final y = (currentPoint['y'] as num).toDouble();
        // 커서 위치만 업데이트
        updateCursorPosition(
          x: x,
          y: y,
          scrollX: scrollX,
          scrollY: scrollY,
        );
      }
    } catch (e) {
      debugPrint('Error in onWhiteBoardMouseMove: $e');
    }
  }

  double _lastX = 0;
  double _lastY = 0;

  // 실제 그리기를 수행하는 별도의 메서드
  void drawPoint(double x, double y,
      {bool isStart = false, bool isEnd = false}) {
    try {
      if (rxIsDrawingMode.value) {
        if (isStart) {
          _lastX = x;
          _lastY = y;
          editor?.startDrawing(x.toInt(), y.toInt());
        } else if (isEnd) {
          editor?.publicDrawPoint(_lastX.toInt(), _lastY.toInt());
          editor?.endDrawing();
        } else {
          _lastX = x;
          _lastY = y;
          editor?.publicDrawPoint(x.toInt(), y.toInt());
        }
      } else if (cursorAction.value == 'erase') {
        editor?.publicErasePoint(x.toInt(), y.toInt());
      }
    } catch (e) {
      debugPrint('Error in drawPoint: $e');
    }
  }

  void onMouseDown(double x, double y) {
    drawPoint(x, y, isStart: true);
  }

  void onMouseUp() {
    drawPoint(_lastX, _lastY, isEnd: true);
  }

  void setPopupInteractionState(bool state) {
    rxPopupInteracting.value = state;
  }

  // 파일이 주기적으로 저장되는 프로젝트 자동저장 카운트
  void startAutoSaveCount({int? seconds}) {
    // 진행 중인 타이머가 있으면 취소
    if (autoSaveTimer != null) {
      autoSaveTimer?.cancel();
      autoSaveTimer = null;
    }

    // 에디터 안쪽에서만 동작 하도록
    if (!rxIsEditorStatus.value) {
      rxStartAutoSaveCount.value = false;
      return;
    }

    if (seconds != null) {
      rxAutoSaveCount.value = seconds;
    } else if (rxAutoSaveCount.value <= 0) {
      rxAutoSaveCount.value = rxSettingEditCount.value;
    }
    rxStartAutoSaveCount.value = true;
    autoSaveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 협업 카운트가 동작 중일 때만 자동 저장 카운트를 진행
      if (!rxStartCoOpCount.value) {
        timer.cancel();
        autoSaveTimer = null;
        rxStartAutoSaveCount.value = false;
        return;
      }
      // 에디터 안쪽에서만 동작 하도록
      if (!rxIsEditorStatus.value) {
        timer.cancel();
        autoSaveTimer = null;
        rxStartAutoSaveCount.value = false;
        return;
      }

      // 현재 도메인에 editor가 있는지 체크
      if (editor == null) {
        timer.cancel();
        autoSaveTimer = null;
        rxStartAutoSaveCount.value = false;
        return;
      }

      rxAutoSaveCount.value--;
      debugPrint('####@@@autoSaveCount: $rxAutoSaveCount.value');
      if (rxAutoSaveCount.value <= 0) {
        // 0초가 되면 저장 후 다시 초기 카운트로 계속 반복
        EasyLoading.showInfo('project_auto_save_message'.tr);
        // usertype이 naverworks인 경우에만 저장
        // if (rxUserLoginType.value == UserLoginType.naverWorks ||
        //     rxUserLoginType.value == UserLoginType.naver_works) {
        if (rxTenantType.value == TenantType.naverWorks ||
            rxTenantType.value == TenantType.mois ||
            rxTenantType.value == TenantType.msit ||
            rxTenantType.value == TenantType.mfds ||
            rxTenantType.value == TenantType.dferi ||
            rxTenantType.value == TenantType.gov ||
            rxTenantType.value == TenantType.standard) {
          saveAraProject();
          // } else if (rxUserLoginType.value == UserLoginType.ara) {
        } else if (rxTenantType.value == TenantType.ara) {
          // 웍스가 아닌 프로젝트의 경우 저장
          // 전체 편집중인 페이지를 멈추고 현재 상태의 페이지를 저장
          // saveAraProject();
        } else {
          // 나머지 타입의 경우 후에 정의
        }
        rxAutoSaveCount.value = rxSettingEditCount.value;
      }
    });
  }

  void stopAutoSaveCount() {
    if (autoSaveTimer != null) {
      autoSaveTimer?.cancel();
      autoSaveTimer = null;
    }
    rxStartAutoSaveCount.value = false;
  }

  void setAutoSaveCount(int count) {
    rxAutoSaveCount.value = count;
    rxStartAutoSaveCount.value = true;
    debugPrint('####setAutoSaveCount: $count');
  }

  void resetAutoSaveCount() {
    rxAutoSaveCount.value = rxSettingEditCount.value;
  }

  void startCoOpCount({int? seconds}) {
    // 진행 중인 타이머가 있으면 취소
    if (coOpCountTimer != null) {
      coOpCountTimer?.cancel();
      coOpCountTimer = null;
    }

    // 시작 값이 주어지면 설정 (기본 300초)
    if (seconds != null) {
      rxCoOpCount.value = seconds;
    } else if (rxCoOpCount.value <= 0) {
      rxCoOpCount.value = rxSettingEditCount.value;
    }

    rxStartCoOpCount.value = true;

    // 협업 카운트 동안만 자동 저장이 동작하도록 시작
    if (!rxStartAutoSaveCount.value) {
      // 편집 권한이 있는 경우만 실행
      if (rxIsEditorStatus.value) {
        startAutoSaveCount();
      } else {
        rxStartAutoSaveCount.value = false;
      }
    }

    if (rxCoOpCount.value <= 0) return;

    coOpCountTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      rxCoOpCount.value--;

      if (rxCoOpCount.value <= 0) {
        timer.cancel();
        coOpCountTimer = null;
        rxStartCoOpCount.value = false;
        // 협업 종료 시 자동 저장도 중단
        stopAutoSaveCount();
        setEditorUserPermission(false);
        EasyLoading.showInfo('coop_mode_countdown_message'.tr);
      }
    });
  }

  void stopCoOpCount() {
    if (coOpCountTimer != null) {
      coOpCountTimer?.cancel();
      coOpCountTimer = null;
    }
    rxStartCoOpCount.value = false;
    // 협업 중단 시 자동 저장도 중단
    stopAutoSaveCount();
  }

  void setCoOpCount(int count) {
    rxCoOpCount.value = count;
    rxStartCoOpCount.value = true;
    debugPrint('####setCoOpCount: $count');
  }

  void resetCoOpCount() {
    rxCoOpCount.value = rxSettingEditCount.value;
  }

  bool get isPopupInteracting => rxPopupInteracting.value;

  // ________ 폰트 리스트 ________________
  void initializeFonts() {
    if (editor == null) {
      return;
    }

    if (installedFonts.fonts.isNotEmpty) {
      // Already initialized
    } else {
      final installedFontsJs = editor!.getInstalledFonts();
      installedFonts.initFonts(
        installedFontsJs,
        defaultFontFamily: 'default_font'.tr,
      );
    }

    rxFontData.value = installedFonts.fonts.first;
  }

  void updateFontStatus(String fontFamily) {
    VulcanFontData updateFontData;
    fontFamily = fontFamily.trim().replaceAll('"', '').replaceAll("'", '');
    logger.d('[VulcanFontListData] updateFontStatus: \'$fontFamily\'');

    if (fontFamily.isEmpty) {
      updateFontData = installedFonts.fonts.first;
    } else {
      final fontData = installedFonts.getFontByFamily(fontFamily);
      if (fontData != null) {
        updateFontData = fontData;
      } else {
        final newFontData = installedFonts.insertFont(fontFamily: fontFamily);
        updateFontData = newFontData;
      }
    }

    logger.d('[VulcanFontListData] -> \'${updateFontData.family}\'');
    rxFontData.value = updateFontData;
  }

  // ________ 메모 ________________
  List<VulcanMemoData>? getMemo() {
    logger.d('[MEMO] getMemo');
    if (editor == null) {
      return null;
    }

    try {
      final memoString = editor!.getMemo();
      if (memoString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(memoString);
      return jsonList
          .map((json) => VulcanMemoData.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting memo: $e');
      return null;
    }
  }

  void setMemo(List<VulcanMemoData> memoList) {
    logger.d('[MEMO] setMemo');
    if (editor == null) {
      debugPrint('Editor is null, cannot set memo');
      return;
    }

    try {
      final jsonList = memoList.map((e) => e.toJson()).toList();
      final memoString = jsonEncode(jsonList);
      editor!.setMemo(memoString);
    } catch (e) {
      debugPrint('Error setting memo: $e');
    }
  }

  void addMemo(VulcanMemoData memo) {
    logger.d('[MEMO] addMemo');
    final currentMemoList = getMemo() ?? [];
    currentMemoList.add(memo);
    setMemo(currentMemoList);
  }

  void updateMemo(VulcanMemoData memo) {
    logger.d('[MEMO] updateMemo');
    final currentMemoList = getMemo() ?? [];
    final index = currentMemoList.indexWhere((m) => m.id == memo.id);
    if (index != -1) {
      currentMemoList[index] = memo;
      setMemo(currentMemoList);
    }
  }

  void deleteMemo(String? memoId) {
    logger.d('[MEMO] deleteMemo');
    if (memoId == null) {
      return;
    }
    final currentMemoList = getMemo() ?? [];
    currentMemoList.removeWhere((m) => m.id == memoId);
    setMemo(currentMemoList);
  }
}

abstract class EditorService {
  void refreshPage(dynamic page);
  void changedPage(dynamic page);
}

class EditorServiceImpl implements EditorService {
  @override
  void refreshPage(dynamic page) {
    final controller = Get.find<VulcanEditorController>();
    controller.refreshPage(page);
  }

  @override
  void changedPage(dynamic page) {
    final controller = Get.find<VulcanEditorController>();
    controller.changedPage(page);
  }
}
