import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectMoveDialog extends StatelessWidget {
  final Function() onTap;
  const ProjectMoveDialog({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 폴더명을 입력해주세요.
        VulcanXDropdown<String>(
          value: 'folder_selected'.tr,
          stringItems: ['folder_selected'.tr],
          onChanged: (String? newValue) {},
          hintText: 'folder_selected'.tr,
        ),
        const SizedBox(height: 14),
        VulcanXElevatedButton(
            onPressed: () => onTap.call(), child: Text('apply'.tr))
      ],
    );
  }
}
