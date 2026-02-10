import 'package:app_ui/app_ui.dart';

import '../enum/editor_type.dart';
import 'datas.dart';
import 'vulcan_widget_data.dart';

class VulcanEditorData {
  final String? loginName;
  final String? userId;
  final String? projectName;
  final String? projectId;
  final String? userDisplayName;
  final String? projectOwner;
  final VulcanEditorDisplayType? displayType;
  final VulcanEditorPageData? cover;
  final VulcanEditorPageData? nav;
  final List<TreeListModel>? pages;
  final List<VulcanResourceData>? imageResources;
  final List<VulcanResourceData>? videoResources;
  final List<VulcanResourceData>? audioResources;
  final List<VulcanResourceData>? officeResources;
  final String? clipArtPath;
  final String? projectAuth;

  // 클립아트, 이미지와 widget 이미지를 분리하기 위해 추가 [clipart, image, widget]
  final String? resourceType;
  final TreeListModel? changedPage;
  final List<VulcanTemplateData>? templates;
  final VulcanWidgetData? widgetData;
  final List<VulcanUserData>? sharedUserList;

  // editor의 권한 체크 여부
  final bool? isEdit;

  final String? startPageId;
  final bool? hasCover;
  final bool? hasToc;

  VulcanEditorData({
    this.loginName,
    this.userId,
    this.userDisplayName,
    this.projectId,
    this.projectName,
    this.projectOwner,
    this.displayType,
    this.cover,
    this.nav,
    this.pages,
    this.imageResources,
    this.videoResources,
    this.audioResources,
    this.officeResources,
    this.templates,
    this.clipArtPath,
    this.resourceType,
    this.changedPage,
    this.widgetData,
    this.sharedUserList,
    this.isEdit,
    this.projectAuth,
    this.startPageId,
    this.hasCover,
    this.hasToc,
  });

  VulcanEditorData copyWith({
    String? loginId,
    String? userId,
    String? projectId,
    String? userDisplayName,
    String? projectName,
    String? projectOwner,
    VulcanEditorDisplayType? displayType,
    VulcanEditorPageData? cover,
    VulcanEditorPageData? nav,
    List<TreeListModel>? pages,
    List<VulcanResourceData>? imageResources,
    List<VulcanResourceData>? videoResources,
    List<VulcanResourceData>? audioResources,
    List<VulcanResourceData>? officeResources,
    List<VulcanTemplateData>? templates,
    String? clipArtPath,
    String? resourceType,
    TreeListModel? changedPage,
    VulcanWidgetData? widgetData,
    List<VulcanUserData>? sharedUserList,
    bool? isEdit,
    String? projectAuth,
    String? startPageId,
    bool? hasCover,
    bool? hasToc,
  }) {
    return VulcanEditorData(
      loginName: loginId ?? loginName,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      projectName: projectName ?? this.projectName,
      projectId: projectId ?? this.projectId,
      projectOwner: projectOwner ?? this.projectOwner,
      displayType: displayType ?? this.displayType,
      cover: cover ?? this.cover,
      nav: nav ?? this.nav,
      pages: pages ?? this.pages,
      imageResources: imageResources ?? this.imageResources,
      videoResources: videoResources ?? this.videoResources,
      audioResources: audioResources ?? this.audioResources,
      officeResources: officeResources ?? this.officeResources,
      templates: templates ?? this.templates,
      clipArtPath: clipArtPath ?? this.clipArtPath,
      resourceType: resourceType ?? this.resourceType,
      changedPage: changedPage,
      widgetData: widgetData,
      sharedUserList: sharedUserList ?? this.sharedUserList,
      projectAuth: projectAuth ?? this.projectAuth,
      startPageId: startPageId ?? this.startPageId,
      isEdit: isEdit ?? this.isEdit,
      hasCover: hasCover ?? this.hasCover,
      hasToc: hasToc ?? this.hasToc,
    );
  }
}
