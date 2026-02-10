import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/datas.dart';
import '../enum/enums.dart';

class EditorShareDialog extends StatelessWidget with EditorEventbus {
  final String projectId;
  final TreeListModel? page;
  final bool? isUserDeleted;
  final List<VulcanUserData> userList;
  final ValueChanged<String> onGetUserList;
  final ValueChanged<VulcanUserData>? onEditPermission;

  // 상태 관리 변수
  final _userIdController = TextEditingController();
  final _isCopied = false.obs;
  final _isLoading = false.obs;
  final _message = RxMap<String, dynamic>({'text': '', 'isSuccess': true});
  final _shareType = ShareType.userId.obs;

  EditorShareDialog({
    super.key,
    required this.projectId,
    this.page,
    this.isUserDeleted,
    required this.userList,
    required this.onGetUserList,
    this.onEditPermission,
  });

  void setLoading(bool isLoading) {
    _isLoading.value = isLoading;
  }

  void showErrorMessage(String message) {
    _showMessage(message, false);
  }

  // 새로고침 버튼용 메서드
  void _refreshUserList() {
    _isLoading.value = true;

    controller.triggerGetUserList(projectId);

    // 타임아웃 처리
    Future.delayed(const Duration(seconds: 1), () {
      if (_isLoading.value) {
        _isLoading.value = false;
      }
    });
  }

  Future<void> _copyLink() async {
    controller.triggerShortUrl();
  }

  Future<void> _addUser() async {
    final inputValue = _userIdController.text.trim();

    if (inputValue.isEmpty) {
      _showMessage('shared_project_input_message'.tr, false);
      return;
    }

    _isLoading.value = true;
    try {
      final shareType = _shareType.value;
      String? shareId;
      String userId;
      bool isEmail = false;

      // shareType에 따라 처리
      if (shareType == ShareType.shareId) {
        shareId = inputValue;
        userId = inputValue; // shareId 사용 시에도 userId는 입력값 사용 (API 요구사항)
      } else if (shareType == ShareType.email) {
        userId = inputValue;
        isEmail = true;
      } else {
        userId = inputValue;
        isEmail = false;
      }

      // triggerAddUser에 shareId도 전달할 수 있도록 수정 필요
      // 일단 기존 방식으로 호출하고, shareId는 별도로 처리
      controller.triggerAddUser(userId, isEmail, shareId: shareId);
      _userIdController.clear();

      // 새로운 사용자를 로컬 리스트에 추가 (shareId가 아닌 경우만)
      if (shareType != ShareType.shareId) {
        final newUser = VulcanUserData(
            userId: userId,
            displayName: userId, // 초기값으로 userId를 사용
            isOwner: false);
        userList.add(newUser);
      }

      _showMessage('shared_project_input_success'.tr, true);
    } catch (e) {
      _showMessage('shared_project_input_error'.tr, false);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _deleteUser(String userId) async {
    _isLoading.value = true;
    try {
      controller.triggerDeleteUser(userId);
      await Future.delayed(const Duration(milliseconds: 300));
      _showMessage('shared_project_delete_success'.tr, true);
      // 빌드 이후 다시 요청하여 빌드 중 상태 변경을 피함
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshUserList());
    } catch (e) {
      _showMessage('shared_project_delete_error'.tr, false);
    } finally {
      _isLoading.value = false;
    }
  }

  void _showMessage(String text, bool isSuccess) {
    _message.value = {'text': text, 'isSuccess': isSuccess};
    Future.delayed(const Duration(seconds: 2), () => _message['text'] = '');
  }

  // UI 빌드 메서드
  @override
  Widget build(BuildContext context) {
    // 빌드 중 상태 변경 방지: 프레임 이후 1회 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLoading.value) {
        _refreshUserList();
      }
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (page == null) _buildPermissionSection(context),
        Obx(() => controller.documentState.rxProjectSharePermission.value ==
                ProjectAuthType.onlyMe
            ? const SizedBox.shrink()
            : _buildSettingEditCountSection(context)),
        // Obx(() => controller.documentState.rxProjectSharePermission.value ==
        //         ProjectAuthType.onlyMe
        //     ? const SizedBox.shrink()
        //     : Column(
        //         children: [
        //           if (page == null) _buildLinkSection(context),
        //           if (page == null) _buildAddUserSection(context),
        //           _buildUserListSection(context),
        //         ],
        //       )),
        Column(
          children: [
            if (page == null) _buildLinkSection(context),

            if (page == null) _buildAddUserSection(context),
            _buildUserListSection(context),
            // if (page == null) _buildCoOpCountSection(context),
          ],
        ),
        _buildMessageSection(),
      ],
    );
  }

  Widget _buildShareIdentifierSection(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('shared_project_user_add_type'.tr, style: context.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<ShareType>(
              segments: [
                ButtonSegment(
                  value: ShareType.userId,
                  label: Text('shared_project_user_add_type_user_id'.tr),
                  icon: const Icon(Icons.person, size: 16),
                ),
                ButtonSegment(
                  value: ShareType.email,
                  label: Text('shared_project_user_add_type_email'.tr),
                  icon: const Icon(Icons.email, size: 16),
                ),
                ButtonSegment(
                  value: ShareType.shareId,
                  label: Text('shared_project_user_add_type_share_id'.tr),
                  icon: const Icon(Icons.link, size: 16),
                ),
              ],
              selected: {_shareType.value},
              onSelectionChanged: (Set<ShareType> newSelection) {
                _shareType.value = newSelection.first;
                _userIdController.clear();
              },
            ),
          ],
        ));
  }

  Widget _buildSettingEditCountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('shared_project_edit_count_change'.tr),
        const SizedBox(
          height: 8,
        ),
        Obx(() => SizedBox(
              height: 40,
              child: VulcanXDropdown<int>(
                value: controller.rxSettingEditCount.value,
                items: [
                  VulcanXIconDropdownMenuItem(
                    value: 180,
                    child: Text('co_op_count'.trArgs(['3'])),
                  ),
                  VulcanXIconDropdownMenuItem(
                    value: 240,
                    child: Text('co_op_count'.trArgs(['4'])),
                  ),
                  VulcanXIconDropdownMenuItem(
                    value: 300,
                    child: Text('co_op_count'.trArgs(['5'])),
                  ),
                  VulcanXIconDropdownMenuItem(
                    value: 600,
                    child: Text('co_op_count'.trArgs(['10'])),
                  ),
                ],
                onChanged: (newValue) {
                  if (newValue != null) {
                    controller.rxSettingEditCount.value = newValue;
                  }
                },
                hintText: 'shared_project_edit_count_hint'.tr,
                hintIcon: Icons.timer,
              ),
            )),
      ],
    );
  }

  Widget _buildPermissionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('shared_project_access_permission'.tr, style: context.titleMedium),
        const SizedBox(height: 8),
        Obx(() => VulcanXDropdown<ProjectAuthType>(
              value: controller.documentState.rxProjectSharePermission.value,
              enumItems: ProjectAuthType.values,
              onChanged: (newValue) async {
                final permission = await controller.isPermission();
                controller.triggerUpdateProjectAuth(newValue!);
                if (newValue == ProjectAuthType.publicLink) {
                  if (controller.rxEditingUserId.value ==
                      controller.documentState.rxUserId.value) {
                    controller.setEditorUserPermission(false);
                  }
                  controller.rxIsCoopMode.value = true;
                  controller.showEditorUser(projectId);
                  controller.ensureSocketForPermission(
                      isPermission: permission);
                  controller.wsManager.sendPageEditorResponse(projectId,
                      controller.documentState.rxPageCurrent.value?.id ?? '');
                } else if (newValue == ProjectAuthType.userLink) {
                  if (controller.rxEditingUserId.value ==
                      controller.documentState.rxUserId.value) {
                    controller.setEditorUserPermission(false);
                  }
                  controller.rxIsCoopMode.value = true;
                  controller.showEditorUser(projectId);
                  controller.ensureSocketForPermission(
                      isPermission: permission);
                  controller.wsManager.sendPageEditorResponse(projectId,
                      controller.documentState.rxPageCurrent.value?.id ?? '');
                } else {
                  controller.ensureSocketForPermission(
                      isPermission: permission);
                  controller.rxIsDrawingMode.value = false;
                  controller.connectedUserList.clear();
                  controller.rxIsCoopMode.value = false;
                  controller.showEditorUser(projectId);
                }
                _showMessage(
                    'shared_project_access_permission_message'.tr, true);
              },
              hintText: 'shared_project_access_permission_hint'.tr,
              hintIcon: Icons.lock,
              displayStringForOption: (type) => type.name,
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCoOpCountSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('co_op_count_text'.tr, style: context.titleMedium),
        const SizedBox(height: 8),
        Obx(() => SizedBox(
              height: 40,
              child: VulcanXDropdown(
                value: controller.rxCoOpCount.value,
                items: [
                  VulcanXIconDropdownMenuItem(
                    value: 180,
                    child: Text('co_op_count'.trArgs(['3'])),
                  ),
                  VulcanXIconDropdownMenuItem(
                    value: 300,
                    child: Text('co_op_count'.trArgs(['5'])),
                  ),
                  VulcanXIconDropdownMenuItem(
                    value: 600,
                    child: Text('co_op_count'.trArgs(['10'])),
                  ),
                ],
                onChanged: (newValue) {
                  controller.setCoOpCount(newValue!);
                },
                hintText: 'shared_project_coop_count_hint'.tr,
                hintIcon: Icons.timer,
                displayStringForOption: (count) => count.toString(),
              ),
            )),
      ],
    );
  }

  Widget _buildLinkSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('shared_project_link'.tr, style: context.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: 8),
            Obx(() => VulcanXTwoSvgIconOutlinedButton(
                isColorFilter: true,
                text: _isCopied.value
                    ? 'shared_project_link_copy_hint'.tr
                    : 'shared_project_link_copy'.tr,
                prefixIcon: _isCopied.value
                    ? CommonAssets.icon.check
                    : CommonAssets.icon.link,
                borderSideColor: Colors.transparent,
                foregroundColor: Colors.white,
                backgroundColor:
                    _isCopied.value ? Colors.green : context.primary,
                onPressed: _copyLink)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAddUserSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('shared_project_user_add'.tr, style: context.titleMedium),
        const SizedBox(height: 8),
        _buildShareIdentifierSection(context),
        const SizedBox(height: 12),
        Obx(() => Row(
              children: [
                Expanded(
                  child: VulcanXTextField(
                    controller: _userIdController,
                    hintText: _getHintText(),
                    onSubmitted: (_) => _addUser(),
                  ),
                ),
                const SizedBox(width: 8),
                VulcanXTwoSvgIconOutlinedButton(
                  isColorFilter: true,
                  text: 'shared_project_user_add_button'.tr,
                  prefixIcon: CommonAssets.icon.add,
                  borderSideColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  backgroundColor: context.primary,
                  onPressed: _addUser,
                ),
              ],
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getHintText() {
    switch (_shareType.value) {
      case ShareType.userId:
        return 'shared_project_user_add_type_user_id_hint'.tr;
      case ShareType.email:
        return 'shared_project_user_add_type_email_hint'.tr;
      case ShareType.shareId:
        return 'shared_project_user_add_type_share_id_hint'.tr;
    }
  }

  Widget _buildMessageSection() {
    return Obx(() {
      final text = _message['text'] as String;
      if (text.isEmpty) return const SizedBox.shrink();

      final isSuccess = _message['isSuccess'] as bool;
      return Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSuccess ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
          ),
        ),
      );
    });
  }

  Widget _buildUserListSection(BuildContext context) {
    // rxUserList를 받아와서 listview로 보여준다.
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('shared_users'.tr, style: context.titleMedium),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16),
                  onPressed: _refreshUserList,
                  tooltip: 'shared_project_user_refresh'.tr,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoading.value
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Column(
                    children: userList
                        .map((user) => _buildUserItem(context, user))
                        .toList(),
                  ),
          ],
        ));
  }

  Widget _buildUserItem(BuildContext context, dynamic user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () => onEditPermission?.call(user),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: context.primary,
              child: Text(
                _getInitials(user.displayName ?? ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                (user.displayName ?? '').isNotEmpty
                    ? user.displayName ?? ''
                    : user.userId ?? '',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isUserDeleted != false &&
                user != userList.first &&
                user.isOwner != true)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteUser(user.userId ?? ''),
                tooltip: 'shared_project_user_add_remove'.tr,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String displayName) {
    if (displayName.isEmpty) return '';

    final nameParts = displayName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }

    return displayName.substring(0, 1).toUpperCase();
  }
}
