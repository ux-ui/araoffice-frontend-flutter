import 'package:cross_file/cross_file.dart';

import '../../datasource/index_db/local_project_repository.dart';
import '../entities/entity.dart';

class ProjectUsecase {
  // final ProjectRepository _projectRepository;

  /// 디버깅 편의를 위하여 로컬 레포지토리 타입을 명시적으로 선언
  final LocalProjectRepository _projectRepository;

  ProjectUsecase(this._projectRepository);

  /// 새로운 프로젝트를 생성합니다.
  /// [name]은 프로젝트의 이름입니다.
  /// [description]은 프로젝트의 설명입니다.
  /// [thumbnail]은 프로젝트의 썸네일 이미지 URL입니다.
  /// [folderId]는 프로젝트의 폴더 ID입니다.
  ///
  /// 새로 생성된 프로젝트의 ID를 반환합니다.
  Future<ProjectInfo> createProject({
    required String name,
    String? description,
    String? thumbnail,
    int? folderId,
  }) {
    return _projectRepository.createProject(
      name: name,
      description: description,
      thumbnail: thumbnail,
      folderId: folderId,
    );
  }

  /// 프로젝트를 삭제합니다.
  /// [projectId]는 프로젝트의 ID입니다.
  ///
  /// 삭제가 성공하면 true를 반환합니다.
  Future<bool> deleteProject(int projectId) {
    return _projectRepository.deleteProject(projectId);
  }

  /// 프로젝트 정보를 업데이트합니다.
  Future<bool> updateProject(
    int projectId, {
    required String name,
    String? folderId,
  }) {
    return _projectRepository.updateProject(
      projectId,
      name: name,
      folderId: folderId,
    );
  }

  /// 프로젝트 페이지, 리소스 정보까지 모두 포함한 상세 정보를 가져옵니다.
  /// [projectId]는 프로젝트의 ID입니다.
  Future<ProjectInfo> fetchProjectDetail(int projectId) {
    return _projectRepository.fetchProjectDetail(projectId);
  }

  /// 모든 프로젝트 정보를 가져옵니다.
  Future<List<ProjectInfo>> fetchAllProject() {
    return _projectRepository.fetchAllProject();
  }

  /// 프로젝트를 검색합니다.
  /// [search]는 검색어, null이면 모든 프로젝트를 반환합니다.
  /// [folderId]는 폴더 ID, null이면 모든 프로젝트를 반환합니다.
  Future<List<ProjectInfo>> filterProject({
    String? search,
    int? folderId,
  }) {
    return _projectRepository.filterProject(
      search: search,
      folderId: folderId,
    );
  }

  /// 하위 모든 폴더 정보를 가져옵니다.
  Future<List<ProjectFolder>> fetchAllFolders() {
    return _projectRepository.fetchAllFolders();
  }

  /// 새로운 폴더를 생성합니다.
  Future<ProjectFolder> createFolder(
    String name, {
    int? parentId,
  }) {
    return _projectRepository.createFolder(
      name,
      parentId: parentId,
    );
  }

  /// 폴더를 삭제합니다.
  /// [folderId]는 폴더의 ID입니다.
  Future<bool> deleteFolder(int folderId) {
    return _projectRepository.deleteFolder(folderId);
  }

  /// 폴더 정보를 업데이트합니다.
  Future<bool> updateFolder(
    int folderId, {
    required String name,
    int? parentId,
  }) {
    return _projectRepository.updateFolder(
      folderId,
      name: name,
      parentId: parentId,
    );
  }

  /// 페이지를 생성합니다.
  /// [projectId]는 프로젝트의 ID입니다.
  /// [pageNumber]는 생성할 페이지 번호입니다.
  /// 만약 [pageNumber]가 null이면 마지막 페이지 다음에 생성합니다.
  /// [pageNumber]가 중간에 있으면 다른 페이지를 뒤로 밀고 새로 생성합니다.
  Future<StorageFile> createPage({
    required int projectId,
    int? pageNumber,
  }) {
    return _projectRepository.createPage(
      projectId: projectId,
      pageNumber: pageNumber,
    );
  }

  /// 페이지를 삭제합니다.
  /// [projectId]는 프로젝트의 ID입니다.
  /// [pageId]는 삭제할 페이지의 ID입니다.
  Future<bool> deletePage({
    required int projectId,
    required int pageId,
  }) {
    return _projectRepository.deletePage(
      projectId: projectId,
      pageId: pageId,
    );
  }

  /// 페이지 정보를 업데이트합니다.
  /// [projectId]는 프로젝트의 ID입니다.
  /// [pages]는 페이지 정보 목록입니다.
  Future<bool> updatePage({
    required int projectId,
    required Map<String, StorageFile> pages,
  }) {
    return _projectRepository.updatePage(
      projectId: projectId,
      pages: pages,
    );
  }

  /// 리소스를 업로드합니다.
  Future<StorageFile> uploadResource({
    required int projectId,
    required XFile file,
  }) {
    return _projectRepository.uploadResource(
      projectId: projectId,
      file: file,
    );
  }

  /// 리소스를 삭제합니다.
  /// [resourceId]는 프로젝트의 ID입니다.
  Future<bool> deleteResource({
    required int resourceId,
  }) {
    return _projectRepository.deleteResource(
      resourceId: resourceId,
    );
  }
}
