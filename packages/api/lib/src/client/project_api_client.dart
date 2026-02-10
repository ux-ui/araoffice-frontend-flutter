// import 'dart:async';

// import 'package:author_editor/data/vulcan_epub_data.dart';
// import 'package:dio/dio.dart';

// import '../api_dio.dart';
// import '../model/model.dart';

// class ProjectApiClient {
//   final ApiDio _dio;
//   ProjectApiClient(this._dio);

//   Future<ApiResponse?> exportEpub(VulcanEpubData exportEpub) async =>
//       await _dio.post('/projects/export', data: exportEpub.toJson());

//   Future<ApiResponse?> downloadEpub(String fileName) async =>
//       await _dio.download(path: '/projects/download', fileName: fileName);

//   Future<ApiResponse?> fetchProject(String projectId) async =>
//       await _dio.get('/projects/$projectId');

//   Future<ApiResponse?> updateProject({
//     required String name,
//     required String projectId,
//   }) async =>
//       await _dio.patch('/projects', data: {'name': name});

//   Future<ApiResponse?> fetchProjectRecent() => _dio.get('/projects/recent');

//   Future<ApiResponse?> createProject({
//     required String projectName,
//     String? description,
//     String? thumbnail,
//     String? folderId,
//   }) async =>
//       await _dio.post('/projects/create-project', data: {
//         'projectName': projectName,
//         'description': description,
//         'folderId': folderId
//       });

//   // mock test deleteProject
//   Future<ApiResponse?> deleteProject({required String projectId}) async =>
//       await _dio.delete('/projects/$projectId');

//   Future<bool> deleteProjectResources({
//     required String projectId,
//     required String resourceId,
//   }) {
//     return _dio
//         .delete('/projects/$projectId/resources/$resourceId')
//         .then((result) {
//       return !result.isError;
//     });
//   }

//   // move project
//   Future<ApiResponse?> moveProject(
//           {required String projectId, required String targetFolderId}) async =>
//       await _dio.post('/projects/move', data: {
//         'projectId': projectId,
//         'targetFolderId': targetFolderId,
//       });

//   Future<ApiResponse?> updateFolder({
//     required String folderId,
//     required String name,
//   }) async {
//     return await _dio.patch('/folders', data: {
//       'folderId': folderId,
//       'name': name,
//     });
//   }

//   Future<ApiResponse?> createFolder({
//     required String targetFolderId,
//     required String name,
//   }) async =>
//       await _dio.post('/create-folder', data: {
//         'targetFolderId': targetFolderId,
//         'name': name,
//       });

//   Future<ApiResponse?> fetchFolder(String folderId) async =>
//       await _dio.get('/folders/$folderId');

//   /// mock test deletefolder.
//   Future<ApiResponse?> deleteFolder({required String folderId}) async =>
//       await _dio.delete('/folders/$folderId');

//   Future<ApiResponse?> moveFolder(
//           {required String folderId, required String targetFolderId}) async =>
//       await _dio.post('/folders/move', data: {
//         'folderId': folderId,
//         'targetFolderId': targetFolderId,
//       });

//   Future<ApiResponse?> createPage(String projectId) async {
//     return await _dio
//         .post('/pages/create-page', data: {'projectId': projectId});
//   }

//   Future<ApiResponse?> deletePage(
//       {required String projectId, required String pageId}) async {
//     return await _dio
//         .delete('/pages', data: {'projectId': projectId, 'pageId': pageId});
//   }

//   Future<ApiResponse?> copyPage(
//       {required String projectId,
//       required String pageId,
//       required String fileName}) async {
//     return await _dio.post('/pages/copy', data: {
//       'projectId': projectId,
//       'pageId': pageId,
//       'fileName': fileName,
//     });
//   }

//   Future<ApiResponse?> updatePageContent(
//       {required String projectId,
//       required String pageId,
//       required String fileName,
//       required String content}) async {
//     return await _dio.put('/pages/content', data: {
//       'projectId': projectId,
//       'pageId': pageId,
//       'fileName': fileName,
//       'content': content
//     });
//   }

//   Future<ApiResponse?> uploadFile(FormData formData) async {
//     return await _dio.post('/upload', data: formData);
//   }

//   Future<ApiResponse?> fetchReousrces(String projectId, String fileType) async {
//     return await _dio
//         .get('/resources/$projectId', queryParameters: {'fileType': fileType});
//   }
// }

import 'dart:async';

import 'package:author_editor/data/vulcan_epub_data.dart';
import 'package:author_editor/data/vulcan_txt_data.dart';
import 'package:author_editor/data/vulcan_xhtml_data.dart';
import 'package:author_editor/enum/share_type.dart';
import 'package:dio/dio.dart';

import '../api_dio.dart';
import '../model/model.dart';

class ProjectApiClient {
  final ApiDio _dio;
  ProjectApiClient(this._dio);

  Future<ApiResponse?> downloadEpub(VulcanEpubData exportEpub) async =>
      await _dio.post(
        '/publish/download/epub',
        data: exportEpub.toJson(),
        useAuthDio: true,
      );

  Future<ApiResponse?> downloadXhtml(VulcanXhtmlData xhtmlData) async =>
      await _dio.post(
        '/publish/download/xhtml',
        data: xhtmlData.toJson(),
        useAuthDio: true,
      );

  Future<ApiResponse?> downloadTxt(VulcanTxtData txtData) async =>
      await _dio.post(
        '/publish/download/txt',
        data: txtData.toJson(),
        useAuthDio: true,
      );

  Future<ApiResponse?> uploadEpub(
    VulcanEpubData exportEpub, {
    String? folderId,
  }) async =>
      await _dio.post(
        '/publish/upload/epub',
        data: exportEpub.toJson(),
        queryParameters: folderId != null ? {'folderId': folderId} : null,
        useAuthDio: true,
      );

  Future<ApiResponse?> uploadXhtml(
    VulcanXhtmlData xhtmlData, {
    String? folderId,
  }) async =>
      await _dio.post(
        '/publish/upload/xhtml',
        data: xhtmlData.toJson(),
        queryParameters: folderId != null ? {'folderId': folderId} : null,
        useAuthDio: true,
      );

  Future<ApiResponse?> uploadTxt(
    VulcanTxtData txtData, {
    String? folderId,
  }) async =>
      await _dio.post(
        '/publish/upload/txt',
        data: txtData.toJson(),
        queryParameters: folderId != null ? {'folderId': folderId} : null,
        useAuthDio: true,
      );

  Future<ApiResponse?> activePage(
          String projectId, String type, bool isActive) async =>
      await _dio.post(
        '/pages/active-page',
        data: {
          'projectId': projectId,
          'type': type,
          'active': isActive,
        },
        useAuthDio: true,
      );

  Future<ApiResponse?> downloadFile(String fileName, String fileType) async =>
      await _dio.download(
        path: '/projects/download',
        fileName: fileName,
        fileType: fileType,
        useAuthDio: true,
      );

  Future<ApiResponse?> downloadXhtmlFile(String fileName) async =>
      await _dio.download(
        path: '/publish/download/xhtml/$fileName',
        fileName: fileName,
        fileType: 'zip',
        useAuthDio: true,
      );

  Future<ApiResponse?> fetchProjectList() async =>
      await _dio.get('/projects', useAuthDio: true);

  Future<ApiResponse?> fetchProject(String projectId) async =>
      await _dio.get('/projects/$projectId', useAuthDio: true);

  Future<ApiResponse?> updateProject({
    required String name,
    required String projectId,
  }) async =>
      await _dio.patch(
        '/projects',
        data: {'name': name, 'id': projectId},
        useAuthDio: true,
      );

  Future<ApiResponse?> fetchProjectRecent() =>
      _dio.get('/projects/recent', useAuthDio: true);

  Future<ApiResponse?> createProject({
    required String projectName,
    String? description,
    String? thumbnail,
    String? folderId,
    String? templateId,
    bool? useCover,
    bool? useToc,
    String? language,
  }) async =>
      await _dio.post(
        '/projects/create-project',
        data: {
          'projectName': projectName,
          'description': description,
          'folderId': folderId,
          'templateId': templateId,
          'useCover': useCover,
          'useToc': useToc,
          'language': language,
        },
        useAuthDio: true,
      );

  Future<ApiResponse?> deleteProject({required String projectId}) async =>
      await _dio.delete('/projects/$projectId', useAuthDio: true);

  Future<bool> deleteProjectResources({
    required String projectId,
    required String resourceId,
  }) {
    return _dio
        .delete(
      '/projects/$projectId/resources/$resourceId',
      useAuthDio: true,
    )
        .then((result) {
      return !result.isError;
    });
  }

  Future<ApiResponse?> moveProject(
          {required String projectId,
          required String currentFolderId,
          required String targetFolderId}) async =>
      await _dio.post(
        '/projects/move',
        data: {
          'projectId': projectId,
          'currentFolderId': currentFolderId,
          'targetFolderId': targetFolderId,
        },
        useAuthDio: true,
      );

  Future<ApiResponse?> updateFolder({
    required String folderId,
    required String name,
  }) async {
    return await _dio.patch(
      '/folders',
      data: {
        'folderId': folderId,
        'name': name,
      },
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> createFolder({
    required String targetFolderId,
    required String name,
  }) async =>
      await _dio.post(
        '/create-folder',
        data: {
          'targetFolderId': targetFolderId,
          'name': name,
        },
        useAuthDio: true,
      );

  Future<ApiResponse?> fetchFolder(String folderId) async =>
      await _dio.get('/folders/$folderId', useAuthDio: true);

  Future<ApiResponse?> deleteFolder({required String folderId}) async =>
      await _dio.delete('/folders/$folderId', useAuthDio: true);

  Future<ApiResponse?> moveFolder({
    required String folderId,
    required String currentFolderId,
    required String targetFolderId,
  }) async =>
      await _dio.post(
        '/folders/move',
        data: {
          'folderId': folderId,
          'currentFolderId': currentFolderId,
          'targetFolderId': targetFolderId,
        },
        useAuthDio: true,
      );

  Future<ApiResponse?> getAllFolders() async =>
      await _dio.get('/folders/all', useAuthDio: true);

  Future<ApiResponse?> createPage(String projectId, String? parentId) async {
    return await _dio.post(
      '/pages/create-page',
      data: {
        'projectId': projectId,
        'parentId': parentId,
      },
      useAuthDio: true,
    );
  }

  /// 내용과 함께 새로운 페이지를 생성하는 API 클라이언트 메서드
  Future<ApiResponse?> createPageWithContent({
    required String projectId,
    required String title,
    required String content,
    required String fileName,
    String? parentId,
  }) async {
    return await _dio.post(
      '/pages/create-page-with-content',
      data: {
        'projectId': projectId,
        'title': title,
        'content': content,
        'fileName': fileName,
        if (parentId != null) 'parentId': parentId,
      },
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> deletePage(
      {required String projectId, required String pageId}) async {
    return await _dio.delete(
      '/pages',
      data: {'projectId': projectId, 'pageId': pageId},
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> copyPage({
    required String projectId,
    required String pageId,
    required String href,
    required String title,
  }) async {
    return await _dio.post(
      '/pages/copy',
      data: {
        'projectId': projectId,
        'pageId': pageId,
        'href': href,
        'title': title,
      },
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> movePage(
      {required String projectId,
      required String movedPageId,
      required String targetPageId,
      required String position}) async {
    return await _dio.post(
      '/pages/move',
      data: {
        'projectId': projectId,
        'movedPageId': movedPageId,
        'targetPageId': targetPageId,
        'position': position,
      },
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> renamePage(
          {required String projectId,
          required String pageId,
          required String href,
          required String idref,
          required String title,
          required bool linear}) async =>
      await _dio.patch(
        '/pages',
        data: {
          'projectId': projectId,
          'pageId': pageId,
          'href': href,
          'idref': idref,
          'title': title,
          'linear': linear,
        },
        useAuthDio: true,
      );
  Future<ApiResponse?> setEditorUserPermission({
    required String pageId,
    required bool isEditorEdit,
  }) async {
    return await _dio.patch(
      '/pages/$pageId/editor',
      data: {'enabled': isEditorEdit},
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> placementPropertyPage(
          {required String projectId,
          required String pageId,
          required Map<String, String> properties}) async =>
      await _dio.patch(
        '/pages',
        data: {
          'projectId': projectId,
          'pageId': pageId,
          'properties': properties
        },
        useAuthDio: true,
      );

  Future<ApiResponse?> fetchSpecificPage(
          String projectId, String pageId) async =>
      await _dio.get('/pages/$pageId',
          queryParameters: {'projectId': projectId}, useAuthDio: true);

  Future<ApiResponse?> updateTreeWidgetToc(
      {required String projectId, required String tocContent}) async {
    return await _dio.post(
      '/pages/toc',
      data: {
        'projectId': projectId,
        'tocContent': tocContent,
      },
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> shortUrl(String url) async {
    return await _dio.post(
      '/shorturl',
      data: {
        'originalUrl': url,
      },
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> updateProjectAuth({
    required String projectId,
    required String projectAuth,
  }) async {
    return await _dio.patch(
      '/share/project/$projectId',
      data: {'projectAuth': projectAuth},
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> getUserList(String projectId) async {
    return await _dio.get('/share/project/$projectId/users', useAuthDio: true);
  }

  Future<ApiResponse?> addShareUser({
    required String projectId,
    required String userId,
    required ShareType shareType,
    String? shareId,
  }) async {
    final Map<String, dynamic> data;
    switch (shareType) {
      case ShareType.userId:
        data = {'userId': userId};
        break;
      case ShareType.email:
        data = {'email': userId};
        break;
      case ShareType.shareId:
        data = {'shareId': shareId};
        break;
    }
    //     ? {'email': userId} : {'userId': userId};

    // if (shareId != null && shareId.isNotEmpty) {
    //   data['shareId'] = shareId;
    // }

    return await _dio.post(
      '/share/project/$projectId/user',
      data: data,
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> deleteUser({
    required String projectId,
    required String userId,
  }) async {
    return await _dio.delete(
      '/share/project/$projectId/user/$userId',
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> findUser(String userId) async {
    return await _dio.get(
      '/share/user',
      queryParameters: {'userId': userId},
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> thumbnail({
    required String projectId,
    required String pageId,
    required String thumbnailImage,
  }) async {
    return await _dio.put(
      '/pages/thumbnail',
      data: {
        'projectId': projectId,
        'pageId': pageId,
        'thumbnailImage': thumbnailImage,
      },
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> updatePageContent(
      {required String projectId,
      required String pageId,
      required String fileName,
      required String content}) async {
    return await _dio.put(
      '/pages/content',
      data: {
        'projectId': projectId,
        'pageId': pageId,
        'fileName': fileName,
        'content': content
      },
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> uploadFile(FormData formData) async {
    return await _dio.post(
      '/upload',
      data: formData,
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> fetchReousrces(String projectId, String fileType) async {
    return await _dio.get(
      '/resources/$projectId',
      queryParameters: {'fileType': fileType},
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> fetchClipArt(
      {required String projectId, required String path, String? type}) async {
    return await _dio.post(
      '/clipart',
      data: {
        'projectId': projectId,
        'path': path,
        'type': type ?? 'clipart', // 기본값 'clipart'
      },
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> addWidget(
      String projectId, String widgetPath, String type) async {
    return await _dio.post(
      '/widgets/add',
      data: {
        'projectId': projectId,
        'widgetPath': widgetPath,
        'type': type,
      },
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> editPagePermission(
    List<String> pageIds,
    String userId,
  ) async {
    return await _dio.post(
      '/pages/user',
      data: {
        'pageIds': pageIds,
        'userId': userId,
      },
      useAuthDio: true,
    );
  }

  Future<ApiResponse?> checkEditStatus({required String pageId}) async =>
      await _dio.get(
        '/pages/$pageId/edit',
        useAuthDio: true,
      );

  Future<ApiResponse?> checkUserPermission({required String projectId}) async =>
      await _dio.get(
        '/share/project/$projectId/user',
        useAuthDio: true,
      );

  /// 프로젝트의 시작 페이지를 설정합니다.
  /// [projectId] 프로젝트 ID
  /// [pageId] 시작 페이지로 설정할 페이지 ID
  Future<ApiResponse?> setStartPage(
          {required String projectId, required String pageId}) async =>
      await _dio.patch(
        '/projects/$projectId/start-page',
        data: {'pageId': pageId},
        useAuthDio: true,
      );

  /// TOC를 생성합니다.
  /// [type] 추출 타입 ("htag" 또는 "vlistDepth", 기본값: "htag")
  Future<ApiResponse?> updateToc(String projectId, String pageId,
      {String? type}) async {
    return await _dio.post(
      '/toc/generate',
      data: {
        'projectId': projectId,
        'pageId': pageId,
        if (type != null) 'type': type,
      },
      useAuthDio: true,
    );
  }

  /// TOC 페이지를 일반 페이지로 변경하고 해당 TOC의 toc_sub 페이지들을 삭제합니다.
  Future<ApiResponse?> convertTocToNormal(
      String projectId, String pageId) async {
    return await _dio.put(
      '/toc/convert-to-normal',
      data: {
        'projectId': projectId,
        'pageId': pageId,
      },
      useAuthDio: true,
    );
  }

  /// 커버 페이지를 설정합니다.
  /// [projectId] 프로젝트 ID
  /// [pageId] 커버로 설정할 페이지 ID
  Future<ApiResponse?> setCoverPage({
    required String projectId,
    required String pageId,
  }) async =>
      await _dio.patch(
        '/pages/cover',
        data: {
          'projectId': projectId,
          'pageId': pageId,
          'isCover': true,
        },
        useAuthDio: true,
      );

  /// 커버 페이지를 해제합니다.
  /// [projectId] 프로젝트 ID
  /// [pageId] 커버를 해제할 페이지 ID
  Future<ApiResponse?> unsetCoverPage({
    required String projectId,
    required String pageId,
  }) async =>
      await _dio.patch(
        '/pages/cover',
        data: {
          'projectId': projectId,
          'pageId': pageId,
          'isCover': false,
        },
        useAuthDio: true,
      );

  /// 가상 목록 번호를 업데이트합니다.
  /// [projectId] 프로젝트 ID
  /// [listStyleOption] 적용할 목록 스타일 옵션 (예: 've-vlist1')
  Future<ApiResponse?> updateListNumbering({
    required String projectId,
    required String listStyleOption,
  }) async =>
      await _dio.put(
        'list-numbering/update',
        data: {
          'projectId': projectId,
          'listStyleOption': listStyleOption,
        },
        useAuthDio: true,
      );
}
