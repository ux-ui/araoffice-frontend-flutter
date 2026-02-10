import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef ProjectMenuBuilder = List<PopupMenuItem> Function({
  required BuildContext context,
  required FolderContentModel item,
  required bool isProject,
});

typedef HistoryMenuBuilder = List<PopupMenuItem> Function({
  required BuildContext context,
  required Rxn<List<HistoryModel>?> history,
  required String projectId,
});

typedef ProjectTapCallback = void Function(FolderContentModel item);
typedef ProjectDragCallback = void Function(
    FolderContentModel source, FolderContentModel target);
typedef ProjectHistoryCallback = void Function(String projectId);
typedef NavigateToFolderCallback = void Function(FolderContentModel folder);
