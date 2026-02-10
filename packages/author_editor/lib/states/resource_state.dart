import 'package:get/get.dart';

import '../data/datas.dart';

/// 문서에서 사용되는 각종 리소스의 상태를 관리하는 클래스
/// 이미지, 비디오, 오디오 등의 미디어 리소스와 템플릿을 관리합니다.
class ResourceState {
  /// 프로젝트에서 사용 중인 이미지 리소스 목록
  final rxImageResources = <VulcanResourceData?>[].obs;

  /// 프로젝트에서 사용 중인 비디오 리소스 목록
  final rxVideoResources = <VulcanResourceData?>[].obs;

  /// 프로젝트에서 사용 중인 오디오 리소스 목록
  final rxAudioResources = <VulcanResourceData?>[].obs;

  /// 사용 가능한 템플릿 목록
  final rxTemplates = <VulcanTemplateData>[].obs;

  final rxOfficeResources = <VulcanResourceData?>[].obs;

  /// 모든 리소스를 초기화하는 메서드
  /// 프로젝트를 새로 시작하거나 초기화할 때 사용
  void clearAll() {
    rxImageResources.clear();
    rxVideoResources.clear();
    rxAudioResources.clear();
    rxTemplates.clear();
  }
}
