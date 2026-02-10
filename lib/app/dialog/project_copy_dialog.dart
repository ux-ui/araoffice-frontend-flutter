import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectCopyDialog extends StatelessWidget {
  final Function() onTap;
  const ProjectCopyDialog({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        //저장할 폴더를 선택 후 프로젝트 이름을 변경해 주세요.
        Text('project_copy_message'.tr),
        const SizedBox(height: 8),
        // 폴더 선택
        VulcanXDropdown<String>(
          value: 'folder_selected'.tr,
          stringItems: ['folder_selected'.tr],
          onChanged: (String? newValue) {},
          hintText: 'folder_selected'.tr,
        ),
        const SizedBox(height: 8),
        // 프로젝트 이름
        VulcanXTextField(hintText: 'project_name'.tr),
        const SizedBox(height: 14),
        VulcanXElevatedButton(
            onPressed: () => onTap.call(), child: Text('apply'.tr))
      ],
    );
  }
}
