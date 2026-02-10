import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LinkItem extends StatelessWidget with EditorEventbus {
  LinkItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // VulcanXDropdown<String>(
            //   value: 'URL 링크',
            //   stringItems: const ['URL 링크', 'URL 링크2'],
            //   onChanged: (String? newValue) {},
            //   hintText: 'URL 링크',
            // ),
            // const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: VulcanXTextField(
                      focusNode: controller.focusHyperLinkNode,
                      controller: controller.linkController,
                      hintText: 'https://www.example.com',
                      onChanged: (link) {
                        if (link.isEmpty) {
                          controller.removeLink();
                        }
                      },
                      onSubmitted: (link) {
                        if (link.isNotEmpty) {
                          controller.applyLink(link);
                        }
                      }),
                ),
                const SizedBox(width: 8),
                IconButton(
                    tooltip: 'link_off'.tr,
                    onPressed: () => controller.removeLink(),
                    icon: const Icon(Icons.link_off)),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ));
  }
}
