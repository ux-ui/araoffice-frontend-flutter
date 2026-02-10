// import 'package:app/app/project/view/file_path_selector.dart';
import 'package:api/api.dart';
import 'package:app_ui/app_ui.dart';
import 'package:author_editor/data/vulcan_project_setting_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class EditorProjectSettingDialog extends StatelessWidget {
  final textEditingController = TextEditingController();

  final ValueChanged<VulcanProjectSettingData> onTap;
  final Widget? contentWidget;
  final String? contentMessage;
  final String? initialProjectName;
  final String? initialFolderId;

  EditorProjectSettingDialog({
    super.key,
    required this.onTap,
    this.contentWidget,
    this.contentMessage,
    this.initialProjectName,
    this.initialFolderId,
  }) {
    if (initialProjectName != null) {
      textEditingController.text = initialProjectName!;
    }
  }
  final selectPathFolderId = Rx<String>('root');
  final useCover = RxBool(true);
  final useToc = RxBool(true);
  final isNameEmpty = RxBool(false);

  Future<void> validateAndSubmit() async {
    if (textEditingController.text.trim().isEmpty) {
      isNameEmpty.value = true;
      return;
    }

    if (textEditingController.text.length > 20) {
      // 20자가 넘어가면 20자까지 잘라서 저장
      textEditingController.text = textEditingController.text.substring(0, 20);
    }

    // 사전에 중복 검사: 전체 프로젝트 목록에서 중복 검사
    final projectName = textEditingController.text.toLowerCase();
    final apiService = Get.find<ProjectApiService>();
    final projectListResult = await apiService.fetchProjectList();
    final projects = projectListResult?.projects ?? [];
    if (projects.any((e) => e.name.toLowerCase() == projectName)) {
      EasyLoading.showError('duplicate_project_name'.tr);
      return;
    }

    onTap(VulcanProjectSettingData(
        projectName: textEditingController.text,
        targetFolderId: selectPathFolderId.value,
        useCover: useCover.value,
        useToc: useToc.value));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            // 저장할 폴더를 선택 후 프로젝트 이름을 변경해 주세요
            Text(contentMessage ?? 'project_setting_message'.tr),
            SelectProjectPath(
              initialFolderId: initialFolderId,
              onPathSelected: (folderId) {
                selectPathFolderId.value = folderId;
              },
            ),
            // contentWidget ?? const SizedBox(),
          ],
        ),
        // const SizedBox(height: 19),
        // 프로젝트 이름을 입력하세요.
        Obx(() => VulcanXTextField(
              onSubmitted: (value) async {
                await validateAndSubmit();
              },
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  isNameEmpty.value = false;
                }
              },
              controller: textEditingController,
              hintText: isNameEmpty.value
                  ? 'project_name_required'.tr
                  : 'input_project_name_hint'.tr,
              suffixIcon: isNameEmpty.value
                  ? const Icon(Icons.error_outline, color: Colors.red)
                  : null,
              maxLength: 20,
              height: 60,
              autofocus: true,
            )),
        // TODO: 표지, 목차 활성화 옵션 비활성화(office 기반에서는 새프로젝트 만들기에서 불필요함. 추후 epub 기반에서 필요할 수 있음.)
        // const SizedBox(height: 14),
        // Obx(() => LabelRectangleCheckbox(
        //     label: 'cover_enable'.tr,
        //     isChecked: useCover.value,
        //     onChanged: (value) => useCover.value = value)),
        // const SizedBox(height: 14),
        // Obx(() => LabelRectangleCheckbox(
        //     label: 'toc_enable'.tr,
        //     isChecked: useToc.value,
        //     onChanged: (value) => useToc.value = value)),
        const SizedBox(height: 14),
        VulcanXElevatedButton.primary(
            onPressed: () async {
              await validateAndSubmit();
            },
            child: Text('apply'.tr,
                style: context.bodyMedium?.copyWith(color: context.onPrimary)))
      ],
    );
  }
}

class SelectProjectPath extends StatefulWidget {
  final String? initialFolderId;
  final void Function(String folderName) onPathSelected;

  const SelectProjectPath({
    super.key,
    this.initialFolderId,
    required this.onPathSelected,
  });
  @override
  State<SelectProjectPath> createState() => _SelectProjectPathState();
}

class _SelectProjectPathState extends State<SelectProjectPath> {
  late ProjectApiService apiService;
  final folders = <FolderModel>[].obs;
  var currentPath = <FolderModel>[];
  int activeFolderIndex = 0;

  @override
  void initState() {
    super.initState();
    apiService = Get.find<ProjectApiService>();
    fetchFolderData();
  }

  void fetchFolderData() async {
    final result = await apiService.getAllFolders();
    if (result != null) {
      folders.value = result.folders ?? [];
      if (widget.initialFolderId != null) {
        var folder =
            folders.firstWhereOrNull((e) => e.id == widget.initialFolderId);
        if (folder != null) {
          while (folder != null) {
            currentPath.insert(0, folder);
            folder = folders.firstWhereOrNull((e) => e.id == folder?.parentId);
          }
          activeFolderIndex = currentPath.length - 1;
          widget.onPathSelected(widget.initialFolderId!);
        } else {
          currentPath = [folders.first];
        }
      } else {
        currentPath = [folders.first];
      }
    }
  }

  void updatePathFolder(FolderModel selectedFolder, int index) {
    if (index == currentPath.length - 1) {
      // 현재 폴더를 다시 선택한 경우
      return;
    }

    setState(() {
      if (index < currentPath.length - 1) {
        // 이전 경로로 돌아가는 경우
        currentPath = currentPath.sublist(0, index + 1);
      } else {
        // 새 폴더를 선택한 경우
        currentPath.add(selectedFolder);
      }
      activeFolderIndex = currentPath.length - 1;
      widget.onPathSelected(currentPath.last.id);
    });
  }

  List<FolderModel> getSubfolder(String id) {
    final list =
        folders.value!.where((folder) => folder.parentId == id).toList();
    return list;
  }

  bool hasSubfolder(FolderModel folder) {
    return getSubfolder(folder.id).isNotEmpty;
  }

  void returnSelectedFolder() {
    Navigator.of(context).pop(currentPath.last);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => folders.value == null ? const SizedBox() : textRow()),
      ),
    );
  }

  Widget textRow() {
    return Row(
        children: currentPath.asMap().entries.map((entry) {
      final index = entry.key;
      final folder = entry.value;
      final isActive = index == activeFolderIndex;
      final isRoot = index == 0;

      final folderName =
          (folder.folderName == 'root') ? 'root'.tr : folder.folderName;
      return Row(
        children: [
          if (isRoot) ...[
            const Icon(Icons.home_outlined, size: 20),
            const SizedBox(width: 4),
          ],
          GestureDetector(
            onTap: () => updatePathFolder(folder, index),
            child: Text(
              folderName,
              style: TextStyle(
                color: isActive ? Colors.blue : null,
              ),
            ),
          ),
          if (hasSubfolder(folder))
            isActive
                ? PopupMenuButton<FolderModel>(
                    position: PopupMenuPosition.under,
                    color: Colors.white,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                    ),
                    itemBuilder: (BuildContext context) {
                      return getSubfolder(folder.id).map((subfolder) {
                        return PopupMenuItem<FolderModel>(
                          value: subfolder,
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder,
                                size: 20,
                                color: context.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(subfolder.folderName),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    onSelected: (value) {
                      updatePathFolder(value, currentPath.length);
                    },
                    constraints: const BoxConstraints(
                      minWidth: 100,
                      maxWidth: 250,
                    ),
                  )
                : Icon(Icons.chevron_right,
                    size: 20, color: context.surfaceDim),
        ],
      );
    }).toList());
  }
}
