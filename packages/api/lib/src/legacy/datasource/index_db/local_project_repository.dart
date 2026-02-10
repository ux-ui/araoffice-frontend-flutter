import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../domain/entities/project_folder.dart';
import '../../domain/entities/project_info.dart';
import '../../domain/entities/storage_file.dart';
import '../../domain/repository/project_repository.dart';
import 'local_storage_service.dart';

class LocalProjectRepository implements ProjectRepository {
  final LocalStorageService _storage;

  LocalProjectRepository(this._storage);

  @override
  Future<ProjectInfo> createProject({
    required String name,
    String? description,
    String? thumbnail,
    int? folderId,
  }) async {
    final newProject = ProjectInfo(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: 1, // Assuming a default user ID for local testing
      name: name,
      createdAt: DateTime.now(),
      description: description,
      thumbnail: thumbnail,
      folderId: folderId,
    );

    await _storage.saveProject(newProject.toJson());

    final page = await createPage(projectId: newProject.id);

    return newProject.copyWith(pages: [page]);
  }

  @override
  Future<bool> deleteProject(int projectId) async {
    try {
      // 프로젝트 삭제
      await _storage.deleteProject(projectId);

      // 프로젝트와 관련된 모든 파일 삭제
      final files = await _storage.getFilesForProject(projectId);
      for (var file in files) {
        await _storage.deleteFile(projectId, file['id']);
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting project: $e');
      return false;
    }
  }

  @override
  Future<bool> updateProject(int projectId,
      {required String name, String? folderId}) async {
    final project = await _storage.getProject(projectId);
    if (project != null) {
      project['name'] = name;
      project['folderId'] = folderId;
      await _storage.saveProject(project);
      return true;
    }
    return false;
  }

  @override
  Future<ProjectInfo> fetchProjectDetail(int projectId) async {
    final projectData = await _storage.getProject(projectId);
    if (projectData != null) {
      final projectInfo = ProjectInfo.fromJson(projectData);
      final files = await _storage.getFilesForProject(projectId);
      projectInfo.pages.addAll(files
          .where((f) => f['fileType'] == StorageFileType.content.index)
          .map((f) => StorageFile.fromJson(f)));
      projectInfo.resources.addAll(files
          .where((f) => f['fileType'] != StorageFileType.content.index)
          .map((f) => StorageFile.fromJson(f)));
      return projectInfo;
    }
    throw Exception('Project not found');
  }

  @override
  Future<List<ProjectInfo>> fetchAllProject() async {
    final projects = await _storage.getAllProjects();
    return projects.map((p) => ProjectInfo.fromJson(p)).toList();
  }

  @override
  Future<List<ProjectInfo>> filterProject(
      {String? search, int? folderId}) async {
    final allProjects = await fetchAllProject();
    return allProjects
        .where((p) =>
            (search == null ||
                p.name.toLowerCase().contains(search.toLowerCase())) &&
            (folderId == null || p.folderId == folderId))
        .toList();
  }

  @override
  Future<List<ProjectFolder>> fetchAllFolders() async {
    final folders = await _storage.getAllFolders();
    return folders.map((f) => ProjectFolder.fromJson(f)).toList();
  }

  @override
  Future<ProjectFolder> createFolder(String name, {int? parentId}) async {
    final newFolder = ProjectFolder(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      createdAt: DateTime.now(),
      parentId: parentId,
    );

    await _storage.saveFolder(newFolder.toJson());
    return newFolder;
  }

  @override
  Future<bool> deleteFolder(int folderId) async {
    try {
      await _storage.deleteFolder(folderId);

      final projects = await fetchAllProject();
      for (var project in projects) {
        if (project.folderId == folderId) {
          await updateProject(project.id,
              name: project.name, folderId: null);
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting folder: $e');
      return false;
    }
  }

  @override
  Future<bool> updateFolder(int folderId,
      {required String name, int? parentId}) async {
    final folder = await _storage.getFolder(folderId);
    if (folder != null) {
      folder['name'] = name;
      folder['parentId'] = parentId;
      await _storage.saveFolder(folder);
      return true;
    }
    return false;
  }

  @override
  Future<StorageFile> createPage({
    required int projectId,
    int? pageNumber,
  }) async {
    final readData =
        await rootBundle.load('packages/api/assets/template/empty_page.xhtml');
    final base64Data = base64Encode(readData.buffer.asUint8List());

    final newPage = StorageFile(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: 1,
      path: '', // Empty content for new page
      createdAt: DateTime.now(),
      fileType: StorageFileType.content,
    );

    final uploadData = newPage.toJson();
    uploadData['base64Data'] = base64Data;

    await _storage.saveFile(projectId, uploadData);
    return newPage;
  }

  @override
  Future<bool> deletePage(
      {required int projectId, required int pageId}) async {
    try {
      await _storage.deleteFile(projectId, pageId);
      return true;
    } catch (e) {
      debugPrint('Error deleting page: $e');
      return false;
    }
  }

  @override
  Future<bool> updatePage(
      {required int projectId,
      required Map<String, StorageFile> pages}) async {
    for (var page in pages.values) {
      await _storage.saveFile(projectId, page.toJson());
    }
    return true;
  }

  @override
  Future<StorageFile> uploadResource(
      {required int projectId, required XFile file}) async {
    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);

    StorageFile newResource = StorageFile(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: 1,
      path: '', // This will be set when retrieved
      createdAt: DateTime.now(),
      fileType: StorageFile.determineFileType(file.name),
    );

    final resourceData = newResource.toJson();
    resourceData['base64Data'] = base64;

    await _storage.saveFile(projectId, resourceData);

    // Set the path to a Blob URL for immediate use
    newResource = newResource.copyWith(path: newResource.path);
    return newResource;
  }

  @override
  Future<bool> deleteResource({required int resourceId}) async {
    try {
      final projects = await fetchAllProject();
      for (var project in projects) {
        final projectInfo = await fetchProjectDetail(project.id);
        if (projectInfo.resources
            .any((resource) => resource.id == resourceId)) {
          await _storage.deleteFile(project.id, resourceId);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
