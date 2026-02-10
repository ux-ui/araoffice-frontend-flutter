import 'package:api/api.dart';
import 'package:app/app/login/view/tenant_setting_controller.dart';
import 'package:app/app/project/controller/project_controller.dart';
import 'package:app/app/project/view/grid/project_grid_view.dart';
import 'package:app/app/project/view/list/project_list_view_widget.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FileTreePage extends StatefulWidget {
  final String baseUrl;
  final ProjectController controller;
  const FileTreePage({
    super.key,
    required this.baseUrl,
    required this.controller,
  });

  @override
  State<FileTreePage> createState() => _FileTreePageState();
}

class _FileTreePageState extends State<FileTreePage> {
  final TenantSettingController tenantSettingController =
      Get.find<TenantSettingController>();
  bool isGridView = true;

  @override
  void initState() {
    super.initState();
    widget.controller.initSettings();
  }

  // @override
  // void dispose() {
  //   widget.controller.nameEditingController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPathNavigator(),
            _buildViewToggle(),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () {
            // docCoOperationStatus를 명시적으로 읽어서 GetX가 관찰하도록 함
            final isDocCoOperationVisible =
                tenantSettingController.docCoOperationStatus.value;
            final hasContents =
                widget.controller.rxFolderInfo.value?.contents.isNotEmpty ??
                    false;

            return hasContents
                ? isGridView
                    ? ProjectGridView(
                        items: widget.controller.rxFolderInfo.value!.contents,
                        buildMenuItems: _buildProjectMenuItems,
                        buildHistoryMenuItems: _buildHistoryMenuItems,
                        visibleHistory: isDocCoOperationVisible,
                        navigateToFolder: _navigateToFolder,
                        onDragAccepted: (source, target) {
                          if (target.id ==
                              widget.controller.rxFolderInfo.value?.id) {
                            return;
                          }

                          if (source.isProject) {
                            widget.controller.moveProject(
                              isRefresh: true,
                              projectId: source.id,
                              currentFolderId:
                                  widget.controller.rxFolderInfo.value?.id ??
                                      'root',
                              targetFolderId: target.id,
                            );
                          } else if (source.isFolder) {
                            widget.controller.moveFolder(
                              isRefresh: true,
                              folderId: source.id,
                              currentFolderId:
                                  widget.controller.rxFolderInfo.value?.id ??
                                      'root',
                              targetFolderId: target.id,
                              context: context,
                            );
                          }
                        },
                        onHistoryTap: (projectId) {
                          widget.controller.getProjectHistory(projectId);
                        },
                        baseUrl: widget.baseUrl,
                        projectHistory: widget.controller.rxProjectHistory,
                        projectHistoryExport:
                            widget.controller.rxProjectHistoryExport,
                        currentFolderId:
                            widget.controller.rxFolderInfo.value?.id ?? 'root',
                      )
                    : ProjectListViewWidget(
                        items: widget.controller.rxFolderInfo.value!.contents,
                        buildMenuItems: _buildProjectMenuItems,
                        buildHistoryMenuItems: _buildHistoryMenuItems,
                        navigateToFolder: _navigateToFolder,
                        projectList: widget.controller.rxProjectInfoList,
                        onDragAccepted: (source, target) {
                          if (target.id ==
                              widget.controller.rxFolderInfo.value?.id) {
                            return;
                          }

                          if (source.isProject) {
                            widget.controller.moveProject(
                              isRefresh: true,
                              projectId: source.id,
                              currentFolderId:
                                  widget.controller.rxFolderInfo.value?.id ??
                                      'root',
                              targetFolderId: target.id,
                            );
                          } else if (source.isFolder) {
                            widget.controller.moveFolder(
                              isRefresh: true,
                              folderId: source.id,
                              currentFolderId:
                                  widget.controller.rxFolderInfo.value?.id ??
                                      'root',
                              targetFolderId: target.id,
                              context: context,
                            );
                          }
                        },
                        onHistoryTap: (projectId) {
                          widget.controller.getProjectHistory(projectId);
                        },
                        projectHistory: widget.controller.rxProjectHistory,
                        currentFolderId:
                            widget.controller.rxFolderInfo.value?.id ?? 'root',
                      )
                : Center(
                    child: _buildNoProject(),
                  );
          },
        ),
      ],
    );
  }

  Widget _buildNoProject() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          CommonAssets.image.noProjectImage.image(),
          const SizedBox(height: 32),
          Text('no_project_message'.tr, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isGridView ? Colors.grey[200] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.black),
            onPressed: () => setState(() => isGridView = true),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: !isGridView ? Colors.grey[200] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.list, color: Colors.black),
            onPressed: () => setState(() => isGridView = false),
          ),
        ),
      ],
    );
  }

  List<PopupMenuItem> _buildProjectMenuItems(
      {required BuildContext context,
      required FolderContentModel item,
      required bool isProject}) {
    final String deleteTitle =
        isProject ? 'project_delete_title'.tr : 'folder_delete_title'.tr;
    return [
      // updateProject
      if (item.isOwner)
        PopupMenuItem(
          value: isProject ? 'edit_project'.tr : 'edit_folder'.tr,
          child: Text(
            isProject ? 'edit_project'.tr : 'edit_folder'.tr,
          ),
          onTap: () async {
            widget.controller.updateEditingController(item.name);

            final result = await VulcanCloseDialogWidget(
              isShowConfirm: false,
              isShowCancel: false,
              width: 320,
              height: 220,
              title: isProject ? 'edit_project'.tr : 'edit_folder'.tr,
              content: _EditNameDialog(
                controller: widget.controller,
                isProject: isProject,
                onConfirm: () {
                  Navigator.of(context).pop(VulcanCloseDialogType.ok);
                },
              ),
            ).show(context);

            if (result == VulcanCloseDialogType.ok) {
              final text = widget.controller.nameEditingController.text;
              // 최소 2글자, 최대 20글자 검증
              if (text.length >= 2 && text.length <= 20) {
                isProject
                    ? widget.controller.validateAndSubmitProjectName(item.id)
                    : widget.controller.validateAndSubmitFolderName(item.id);
                widget.controller.nameEditingController.clear();
              }
            } else {
              widget.controller.nameEditingController.clear();
            }
          },
        ),
      if (item.isOwner)
        PopupMenuItem(
          value: 'delete'.tr,
          child: Text(deleteTitle),
          onTap: () async {
            final result = await VulcanCloseDialogWidget(
              isShowConfirm: true,
              isShowCancel: true,
              width: 320,
              height: 150,
              title: isProject
                  ? 'project_delete_title'.tr
                  : 'folder_delete_title'.tr,
              content: Text('delete_message'.tr),
            ).show(context);

            if (result == VulcanCloseDialogType.ok) {
              isProject
                  ? widget.controller.deleteProject(projectId: item.id)
                  : widget.controller.deleteFolder(folderId: item.id);
            }
          },
        ),
      if (!item.isOwner)
        PopupMenuItem(
          value: 'shared_project'.tr,
          child: Text('shared_project'.tr),
          onTap: () async {},
        ),
      if (item.isOwner && tenantSettingController.exportHistoryStatus.value)
        PopupMenuItem(
          value: 'export_history'.tr,
          child: Text('export_history'.tr),
          onTap: () async {
            widget.controller.getProjectHistoryExport(item.id);
            final RenderBox button = context.findRenderObject() as RenderBox;
            final Offset offset = button.localToGlobal(Offset.zero);
            showMenu(
              color: Colors.white,
              context: context,
              constraints: const BoxConstraints(
                minWidth: 200,
                maxWidth: 500,
                minHeight: 50,
                maxHeight: 200,
              ),
              position: RelativeRect.fromLTRB(
                offset.dx,
                offset.dy + button.size.height,
                offset.dx + button.size.width,
                offset.dy + button.size.height,
              ),
              items: _buildExportHistoryMenuItems(
                context: context,
                history: widget.controller.rxProjectHistoryExport,
                projectId: item.id,
              ),
            );
          },
        ),
    ];
  }

  List<PopupMenuItem> _buildExportHistoryMenuItems(
      {required BuildContext context,
      // required Rxn<List<ExportHistoryModel>?> history,
      required Rxn<List<HistoryModel>?> history,
      required String projectId}) {
    return [
      PopupMenuItem(
        enabled: false,
        child: SizedBox(
          width: 600,
          child: Obx(
            () => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: (history.value == null || history.value!.isEmpty)
                    ? [
                        Text('export_history_empty'.tr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            )),
                      ]
                    : history.value!.map((e) {
                        final dateTime = DateTime.parse(e.createdAt.toString());
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  e.message,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  e.user.displayName ?? e.user.userId ?? '',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  DateFormat('yyyy-MM-dd HH:mm:ss')
                                      .format(dateTime),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        );
                      }).toList(),
              ),
            ),
          ),
        ),
        onTap: () async {},
      ),
    ];
  }

  List<PopupMenuItem> _buildHistoryMenuItems(
      {required BuildContext context,
      required Rxn<List<HistoryModel>?> history,
      required String projectId}) {
    return [
      PopupMenuItem(
        enabled: false,
        child: SizedBox(
          width: 600,
          child: Obx(
            () => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: history.value?.map((e) {
                      final dateTime = DateTime.parse(e.createdAt.toString());
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.message,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                e.user.displayName ?? e.user.userId ?? '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(dateTime),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      );
                    }).toList() ??
                    [],
              ),
            ),
          ),
        ),
        onTap: () async {},
      ),
    ];
  }

  void _navigateToFolder(FolderContentModel folder) {
    if (!folder.isFolder) return;
    if (folder.id == widget.controller.rxFolderInfo.value?.id) return;
    EasyLoading.show();
    setState(() {
      widget.controller.addPathInfo(folder.name, folder.id);
      widget.controller.selectFolder(folder.id).then((_) {
        EasyLoading.dismiss();
      });
    });
  }

  Widget _buildPathNavigator() {
    List<Widget> pathWidgets = [];

    pathWidgets.add(DragTarget<FolderContentModel>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        if (widget.controller.rxFolderInfo.value?.id == 'root') return;
        if (details.data.isProject) {
          widget.controller.moveProject(
            isRefresh: false,
            projectId: details.data.id,
            currentFolderId: widget.controller.rxFolderInfo.value?.id ?? 'root',
            targetFolderId: 'root',
          );
        } else if (details.data.isFolder) {
          widget.controller.moveFolder(
            isRefresh: true,
            folderId: details.data.id,
            currentFolderId: widget.controller.rxFolderInfo.value?.id ?? 'root',
            targetFolderId: 'root',
            context: context,
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty ? Colors.green.withAlpha(26) : null,
            borderRadius: BorderRadius.circular(4),
            border: candidateData.isNotEmpty
                ? Border.all(color: Colors.green, width: 1)
                : null,
          ),
          child: TextButton(
            onPressed: () {
              setState(() {
                widget.controller.clearPathInfo();
                widget.controller.initSettings();
              });
            },
            child: Text('root'.tr, style: const TextStyle(color: Colors.black)),
          ),
        );
      },
    ));

    if (widget.controller.pathHistory.isNotEmpty) {
      for (int i = 0; i < widget.controller.pathHistory.length; i++) {
        if (i > 0) {
          pathWidgets.add(
            Text(' > ', style: TextStyle(color: Colors.black.withAlpha(128))),
          );
        }

        final pathInfo = widget.controller.pathHistory[i];
        pathWidgets.add(DragTarget<FolderContentModel>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) {
            if (pathInfo.id == widget.controller.rxFolderInfo.value?.id) {
              return;
            }

            if (details.data.isProject) {
              widget.controller.moveProject(
                isRefresh: false,
                projectId: details.data.id,
                currentFolderId:
                    widget.controller.rxFolderInfo.value?.id ?? 'root',
                targetFolderId: pathInfo.id,
              );
            } else if (details.data.isFolder) {
              widget.controller.moveFolder(
                isRefresh: false,
                folderId: details.data.id,
                currentFolderId:
                    widget.controller.rxFolderInfo.value?.id ?? 'root',
                targetFolderId: pathInfo.id,
                context: context,
              );
            }
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              decoration: BoxDecoration(
                color: candidateData.isNotEmpty
                    ? Colors.green.withAlpha(26)
                    : null,
                borderRadius: BorderRadius.circular(4),
                border: candidateData.isNotEmpty
                    ? Border.all(color: Colors.green, width: 1)
                    : null,
              ),
              child: TextButton(
                onPressed: () async {
                  if (pathInfo.id == widget.controller.rxFolderInfo.value?.id) {
                    return;
                  }
                  EasyLoading.show();
                  await widget.controller.selectFolder(pathInfo.id);
                  setState(() {
                    widget.controller.removePathInfo(i + 1);
                    EasyLoading.dismiss();
                  });
                },
                child: Text(
                  pathInfo.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: pathWidgets),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final ProjectController controller;
  final bool isProject;
  final VoidCallback onConfirm;

  const _EditNameDialog({
    required this.controller,
    required this.isProject,
    required this.onConfirm,
  });

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  bool _isValidLength(String text) {
    return text.length >= 2 && text.length <= 20;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        VulcanXTextField(
          height: 60,
          maxLength: 20,
          controller: widget.controller.nameEditingController,
          hintText:
              widget.isProject ? 'edit_project_name'.tr : 'edit_folder_name'.tr,
          autofocus: true,
          onChanged: (value) {
            setState(() {}); // 버튼 활성화 상태 업데이트
            if (value.trim().isNotEmpty) {
              widget.controller.isNameEmpty.value = false;
            }
          },
        ),
        const SizedBox(height: 10),
        widget.isProject
            ? Text('edit_project_input_message'.tr,
                style: context.bodySmall?.copyWith(color: Colors.grey))
            : Text('edit_folder_input_message'.tr,
                style: context.bodySmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop(VulcanCloseDialogType.cancel);
              },
            ),
            Spacer(),
            SizedBox(
              width: 80,
              child: VulcanXElevatedButton.primary(
                onPressed:
                    _isValidLength(widget.controller.nameEditingController.text)
                        ? () {
                            final text =
                                widget.controller.nameEditingController.text;
                            // 최소 2글자, 최대 20글자 검증
                            if (_isValidLength(text)) {
                              widget.onConfirm();
                            }
                          }
                        : null,
                child: Text('confirm'.tr),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
