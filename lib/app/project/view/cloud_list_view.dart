import 'package:api/api.dart';
import 'package:app/app/project/controller/cloud_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'grid/cloud_grid_view.dart';

class CloudFileTreePage extends StatefulWidget {
  final String baseUrl;
  final CloudController controller;
  final Function(CloudFileModel)? onCloseDialog;

  const CloudFileTreePage({
    super.key,
    required this.baseUrl,
    required this.controller,
    this.onCloseDialog,
  });

  @override
  State<CloudFileTreePage> createState() => _CloudFileTreePageState();
}

class _CloudFileTreePageState extends State<CloudFileTreePage> {
  final _maxHeight = 560.0;

  @override
  void initState() {
    super.initState();
    // CloudFileTreePage가 열릴 때 연결 상태 확인 후 파일 로드
    // widget.controller.loadFilesOnInit();
  }

  // Future<void> loadFilesOnInit() async {
  //   // 연결 상태가 확인되지 않았으면 먼저 확인
  //   if (!widget.controller.rxIsNaverWorksConnected.value) {
  //     final isConnected = await widget.controller.checkCloudConnection();
  //     if (isConnected) {
  //       widget.controller.loadCloudFiles(refresh: true);
  //     }
  //   } else {
  //     // 이미 연결 상태가 확인되었으면 바로 로드
  //     widget.controller.loadCloudFiles(refresh: true);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //_buildConnectionStatus(),
        _buildCurrentPath(),
        const SizedBox(height: 8),
        _buildToolbar(),
        const SizedBox(height: 16),
        // 파일 목록
        Obx(
          () => widget.controller.rxIsLoading.value
              ? _buildProgress()
              : widget.controller.rxCloudFiles.isEmpty
                  ? _buildNoProject()
                  : ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: _maxHeight),
                      child: CloudGridView(
                        items: widget.controller.rxCloudFiles.toList(),
                        currentFolderId:
                            widget.controller.rxCurrentFolder.value?.fileId ??
                                'root',
                        controller: widget.controller,
                        onCloseDialog: widget.onCloseDialog,
                      ),
                    ),
        ),
        // Obx(
        //   () => widget.controller.rxHasMoreData.value &&
        //           !widget.controller.rxIsLoading.value
        //       ? Center(
        //           child: Padding(
        //             padding: const EdgeInsets.all(16),
        //             child: VulcanXOutlinedButton(
        //               onPressed: () => widget.controller.loadMoreFiles(),
        //               child: const Text('더 불러오기'),
        //             ),
        //           ),
        //         )
        //       : const SizedBox.shrink(),
        // ),
      ],
    );
  }

  // 연결 상태 표시 위젯
  // Widget _buildConnectionStatus() {
  //   return Obx(
  //     () {
  //       if (widget.controller.rxCurrentCloudType.value == CloudType.works) {
  //         return Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //           decoration: BoxDecoration(
  //             color: Colors.blue[50],
  //             border: Border.all(color: Colors.blue[200]!),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Row(
  //             children: [
  //               Icon(
  //                 Icons.cloud,
  //                 color: Colors.blue[600],
  //                 size: 20,
  //               ),
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: Text(
  //                   'naver_works_drive_connected'.tr,
  //                   style: TextStyle(
  //                     color: Colors.blue[700],
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ),
  //               if (widget.controller.rxErrorMessage.value.contains('로그인'))
  //                 VulcanXOutlinedButton(
  //                   onPressed: () {
  //                     // 네이버웍스 로그인 페이지로 이동
  //                     Get.find<LoginController>().naverWorksLogin();
  //                   },
  //                   child: Text('login_again'.tr),
  //                 ),
  //             ],
  //           ),
  //         );
  //       }
  //       return const SizedBox.shrink();
  //     },
  //   );
  // }

  Widget _buildToolbar() {
    return Row(
      children: [
        // 새로고침 버튼
        IconButton(
          onPressed: () => widget.controller.loadCloudFiles(refresh: true),
          icon: const Icon(Icons.refresh),
          tooltip: 'cloud_refresh'.tr,
        ),
        const SizedBox(width: 4),
        // 상위 폴더로 이동 버튼
        IconButton(
          onPressed: () => widget.controller.navigateToParentFolder(),
          icon: const Icon(Icons.arrow_upward),
          tooltip: '상위 폴더',
        ),
        // const SizedBox(width: 4),
        // 새 폴더 생성 버튼
        // IconButton(
        //   onPressed: () => _showCreateFolderDialog(context),
        //   icon: const Icon(Icons.create_new_folder),
        //   tooltip: '새 폴더',
        // ),
        // const SizedBox(width: 4),
        // 파일 업로드 버튼
        // IconButton(
        //   onPressed: () => _showFileUploadDialog(context),
        //   icon: const Icon(Icons.upload_file),
        //   tooltip: '파일 업로드',
        // ),
        // const SizedBox(width: 16),
        // 검색 필드
        // Expanded(
        //   child: VulcanXTextField(
        //     controller: widget.controller.searchController,
        //     hintText: 'cloud_search_hint'.tr,
        //     onSubmitted: (query) => widget.controller.searchFiles(query),
        //     suffixIcon: IconButton(
        //       icon: const Icon(Icons.search),
        //       onPressed: () => widget.controller.searchFiles(
        //         widget.controller.searchController.text,
        //       ),
        //     ),
        //   ),
        // ),
        const SizedBox(width: 16),
        // 정렬 드롭다운
        Obx(
          () => DropdownButton<String>(
            value: widget.controller.rxSortBy.value,
            onChanged: (value) {
              if (value != null) {
                widget.controller.sortFiles(value);
              }
            },
            items: [
              DropdownMenuItem(
                  value: 'name', child: Text('cloud_sort_by_name'.tr)),
              DropdownMenuItem(
                  value: 'size', child: Text('cloud_sort_by_size'.tr)),
              DropdownMenuItem(
                  value: 'modifiedTime',
                  child: Text('cloud_sort_by_modified_time'.tr)),
              DropdownMenuItem(
                  value: 'createdTime',
                  child: Text('cloud_sort_by_created_time'.tr)),
              DropdownMenuItem(
                  value: 'type', child: Text('cloud_sort_by_type'.tr)),
            ],
          ),
        ),
        // const SizedBox(width: 4),
        // // 정렬 방향 토글
        // Obx(
        //   () => IconButton(
        //     onPressed: () => widget.controller.sortAscending.toggle(),
        //     icon: Icon(
        //       widget.controller.sortAscending.value
        //           ? Icons.arrow_upward
        //           : Icons.arrow_downward,
        //     ),
        //     tooltip: '정렬 방향',
        //   ),
        // ),
        // const SizedBox(width: 4),
        // // 뷰 전환 버튼
        // IconButton(
        //   onPressed: () {
        //     setState(() {
        //       isGridView = !isGridView;
        //     });
        //   },
        //   icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
        //   tooltip: '뷰 전환',
        // ),
      ],
    );
  }

  Widget _buildCurrentPath() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.folder, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.controller.navigateToFolder(null);
                    },
                    child: Text('cloud_my_drive_title'.tr),
                  ),
                  ...widget.controller.rxCurrentPathParts.map((part) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommonAssets.icon.keyboardArrowRight.svg(),
                        GestureDetector(
                          onTap: () {
                            widget.controller.navigateToFolder(part);
                          },
                          child: Text(part.fileName),
                        ),
                      ],
                    );
                  })
                ],
              ),
            ),
            // Expanded(
            //   child: Text(
            //     '${'cloud_title'.tr}: ${widget.controller.rxCurrentPath.value}',
            //     style: const TextStyle(fontWeight: FontWeight.w500),
            //   ),
            // ),
          ],
        ),
      );
    });
  }

  Widget _buildProgress() {
    return SizedBox(
      height: _maxHeight,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildNoProject() {
    return SizedBox(
      height: _maxHeight,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              CommonAssets.image.noProjectImage.image(),
              const SizedBox(height: 32),
              Text('no_project_message'.tr, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              VulcanXElevatedButton(
                onPressed: () =>
                    widget.controller.loadCloudFiles(refresh: true),
                child: Text('cloud_refresh'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _showCreateFolderDialog(BuildContext context) {
  //   final folderNameController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('cloud_create_folder_title'.tr),
  //       content: VulcanXTextField(
  //         controller: folderNameController,
  //         hintText: 'cloud_create_folder_hint'.tr,
  //       ),
  //       actions: [
  //         VulcanXOutlinedButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: Text('cloud_cancel'.tr),
  //         ),
  //         VulcanXElevatedButton(
  //           onPressed: () {
  //             final folderName = folderNameController.text.trim();
  //             if (folderName.isNotEmpty) {
  //               widget.controller.createFolder(folderName);
  //               Navigator.of(context).pop();
  //             }
  //           },
  //           child: Text('cloud_create'.tr),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _showFileUploadDialog(BuildContext context) {
  //   // 파일 업로드 다이얼로그 구현
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('파일 업로드'),
  //       content: const Text('파일 업로드 기능은 실제 구현에서 추가됩니다.'),
  //       actions: [
  //         VulcanXOutlinedButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('확인'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // List<PopupMenuItem> _buildProjectMenuItems(
  //     {required BuildContext context,
  //     required CloudFileModel item,
  //     required bool isProject}) {
  //   final String deleteTitle =
  //       item.isFolder ? 'folder_delete_title'.tr : 'file_delete_title'.tr;

  //   return [
  //     // 파일/폴더 이름 변경
  //     if (item.hasPermission)
  //       PopupMenuItem(
  //         value: 'rename',
  //         child: Text('이름 변경'),
  //         onTap: () async {
  //           final result = await VulcanCloseDialogWidget(
  //             isShowConfirm: true,
  //             isShowCancel: true,
  //             width: 320,
  //             height: 190,
  //             title: '이름 변경',
  //             content: Column(
  //               children: [
  //                 VulcanXTextField(
  //                   controller: widget.controller.nameEditingController,
  //                   hintText: '새 이름을 입력하세요',
  //                 ),
  //               ],
  //             ),
  //           ).show(context);

  //           if (result == VulcanCloseDialogType.ok) {
  //             if (widget.controller.nameEditingController.text.isNotEmpty) {
  //               await widget.controller.renameFile(
  //                 item.fileId,
  //                 widget.controller.nameEditingController.text,
  //               );
  //               widget.controller.nameEditingController.clear();
  //             }
  //           } else {
  //             widget.controller.nameEditingController.clear();
  //           }
  //         },
  //       ),

  //     // 파일/폴더 삭제
  //     if (item.hasPermission)
  //       PopupMenuItem(
  //         value: 'delete',
  //         child: Text(deleteTitle),
  //         onTap: () async {
  //           final result = await VulcanCloseDialogWidget(
  //             isShowConfirm: true,
  //             isShowCancel: true,
  //             width: 320,
  //             height: 150,
  //             title: deleteTitle,
  //             content: Text('정말로 ${item.fileName}을(를) 삭제하시겠습니까?'),
  //           ).show(context);

  //           if (result == VulcanCloseDialogType.ok) {
  //             // 실제 구현에서는 삭제 API 호출
  //             widget.controller.cloudFiles.removeWhere(
  //               (file) => file.fileId == item.fileId,
  //             );
  //           }
  //         },
  //       ),

  //     // 폴더인 경우 폴더로 이동
  //     if (item.isFolder)
  //       PopupMenuItem(
  //         value: 'open',
  //         child: const Text('폴더 열기'),
  //         onTap: () {},
  //       ),

  //     // 파일인 경우 다운로드
  //     if (!item.isFolder)
  //       PopupMenuItem(
  //         value: 'download',
  //         child: const Text('다운로드'),
  //         onTap: () {
  //           // 실제 구현에서는 다운로드 API 호출
  //           debugPrint('파일 다운로드: ${item.fileName}');
  //         },
  //       ),

  //     // 공유 상태가 아닌 경우 공유
  //     if (!item.shared)
  //       PopupMenuItem(
  //         value: 'share',
  //         child: const Text('공유'),
  //         onTap: () {
  //           // 실제 구현에서는 공유 API 호출
  //           debugPrint('파일 공유: ${item.fileName}');
  //         },
  //       ),
  //   ];
  // }
}
