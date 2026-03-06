import 'package:app_ui/widgets/widgets.dart';
import 'package:get/get.dart';

import '../constants/editor_constants.dart';
import '../enum/enums.dart';

/// 문서의 기본 정보와 페이지 관련 상태를 관리하는 클래스
/// 프로젝트 정보, 문서 크기, 페이지 목록 등을 관리합니다.
class DocumentState {
  /// 현재 프로젝트의 고유 식별자
  final rxProjectId = ''.obs;

  // 현재 유저 이름
  final rxDisplayName = 'anonymous'.obs;

  /// 현재 프로젝트의 시작 페이지 ID
  final rxStartPageId = ''.obs;

  /// 현재 프로젝트의 소유자
  final rxProjectOwner = ''.obs;

  /// 현재 프로젝트의 이름
  final rxProjectName = ''.obs;

  /// 문서의 너비 (픽셀 단위)
  final rxDocumentSizeWidth = EditorConstants.defaultDocumentWidth.obs;

  /// 문서의 높이 (픽셀 단위)
  final rxDocumentSizeHeight = EditorConstants.defaultDocumentHeight.obs;

  final documentSizeWidth = EditorConstants.defaultDocumentWidth;
  final documentSizeHeight = EditorConstants.defaultDocumentHeight;

  /// 프로젝트의 모든 페이지 목록
  final rxPages = <TreeListModel>[].obs;

  // 현재 유저 이름
  final rxUserId = ''.obs;

  /// 현재 선택된 페이지
  /// null일 경우 선택된 페이지가 없음
  final rxPageCurrent = Rx<TreeListModel?>(null);

  /// 현재 페이지의 URL
  final rxPageUrl = ''.obs;

  /// 현재 페이지의 편집 가능 여부
  final rxPageEditable = false.obs;

  /// 현재 페이지의 배치 속성 상태
  final rxPageProperties = Rx<Map<String, String>>({});

  /// 현재 페이지의 배치 속성 상태
  final rxPlacementState = PlacementType.auto.obs;

  /// 현재 프로젝트의 공유 설정
  final rxProjectSharePermission = ProjectAuthType.onlyMe.obs;
  bool get hasSharedPermission =>
      rxProjectSharePermission.value == ProjectAuthType.publicLink ||
      rxProjectSharePermission.value == ProjectAuthType.userLink;

  // ===== URL 관리 필드들 =====
  /// 기본 API URL
  final rxBaseURL = ''.obs;

  /// 수식 편집기 URL
  // final rxMathURL = '{url}/math/editor_image.html'.obs;
  final rxMathURL = '{url}math/editor_image.html'.obs;

  /// Dragdocs URL
  // final rxDragdocsURL = '{url}/dragdocs/index.html'.obs;
  final rxDragdocsURL = '{url}dragdocs/index.html'.obs;

  /// Text Viewer URL
  //  final rxTextViewerURL = '{url}/dragdocs/textviewer.html'.obs;
  final rxTextViewerURL = '{url}dragdocs/textviewer.html'.obs;

  /// Epub Viewer URL
  // final rxEpubViewerURL = '{url}/epub_viewer/epub_viewer.html'.obs;
  final rxEpubViewerURL = '{url}epub_viewer/epub_viewer.html'.obs;

  final rxHasCover = false.obs;
  final rxHasToc = false.obs;

  /// 기본 URL 반환 getter
  String get baseUrl => rxBaseURL.value;

  /// 문서의 크기를 업데이트하는 메서드
  /// [width] 새로운 문서 너비
  /// [height] 새로운 문서 높이
  void updateDocumentSize(int width, int height) {
    rxDocumentSizeWidth.value = width;
    rxDocumentSizeHeight.value = height;
  }

  void updateDisplayName(String displayName) {
    rxDisplayName.value = displayName.isEmpty ? 'anonymous' : displayName;
  }

  void setPageProperties() {
    rxPageProperties.value = rxPageCurrent.value?.properties ?? {};
    rxPlacementState.value =
        PlacementType.fromString(rxPageProperties.value['rendition'] ?? '');
  }

  /// 프로젝트별 빌드 타입 URL 생성
  /// [projectId] 프로젝트 ID
  /// [fileName] 파일명
  String getBuildTypeUrl(String projectId, String fileName) {
    return '${rxBaseURL.value}user/project/$projectId/$fileName';
  }

  /// URL 설정 초기화
  /// [baseUrl] 기본 API URL
  void initializeUrls(String baseUrl) {
    // 수식 테스트 라이센스는 2027년 12월 17일까지 유효합니다.
    // 이후엔 정식 라이센스인 3.37.45.128 서버로 변경해서 사용하거나
    // imatheq에 메일 보내서 재발급 받아야합니다.
    //const mathTestUrl = 'http://3.37.45.128:8080/';
    const mathTestUrl = 'https://araepub.com/';

    // rxBaseURL.value = baseUrl;
    // rxBaseURL.value = '$baseUrl/api/v1/';
    rxBaseURL.value = baseUrl;

    rxMathURL.value = baseUrl.contains('localhost')
        ? rxMathURL.value.replaceAll('{url}', mathTestUrl)
        : rxMathURL.value
            .replaceAll('{url}', baseUrl.replaceAll('/api/v1', ''));
    // .replaceAll('{url}', baseUrl);

    rxDragdocsURL.value = rxDragdocsURL.value
        .replaceAll('{url}', baseUrl.replaceAll('/api/v1', ''));
    // .replaceAll('{url}', baseUrl);

    rxTextViewerURL.value = rxTextViewerURL.value
        .replaceAll('{url}', baseUrl.replaceAll('/api/v1', ''));
    // .replaceAll('{url}', baseUrl);

    rxEpubViewerURL.value = rxEpubViewerURL.value
        .replaceAll('{url}', baseUrl.replaceAll('/api/v1', ''));
    // .replaceAll('{url}', baseUrl);
  }
}
