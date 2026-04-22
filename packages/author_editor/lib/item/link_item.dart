import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_controller.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 하이퍼링크: URL 직접 입력 + 프로젝트 페이지 목록에서 선택(내부 `href`만 적용, 오동작 방지).
class LinkItem extends StatefulWidget {
  const LinkItem({super.key});

  @override
  State<LinkItem> createState() => _LinkItemState();
}

class _LinkItemState extends State<LinkItem> with EditorEventbus {
  static List<TreeListModel> _linkablePages(VulcanEditorController c) {
    return c.documentState.rxPages
        .where(
          (p) => p.href.trim().isNotEmpty && !p.type.startsWith('temp_'),
        )
        .toList();
  }

  static String _pageLabel(TreeListModel p) {
    final title = processTranslation(p.title).trim();
    if (title.isEmpty) return p.href;
    return title;
  }

  static TreeListModel? _pageMatchingHref(
    List<TreeListModel> pages,
    String linkText,
  ) {
    final t = linkText.trim();
    if (t.isEmpty) return null;
    for (final p in pages) {
      if (p.href == t) return p;
    }
    return null;
  }

  void _applyCurrentLink() {
    final link = controller.linkController.text;
    if (link.trim().isNotEmpty) {
      controller.applyLink(link);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'hyperlink_internal_page'.tr,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Obx(() {
            final pages = _linkablePages(controller);
            if (pages.isEmpty) {
              return Text(
                'hyperlink_no_linkable_pages'.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              );
            }
            final selected = _pageMatchingHref(
              pages,
              controller.linkController.text,
            );
            return VulcanXDropdown<TreeListModel>(
              value: selected != null && pages.contains(selected)
                  ? selected
                  : null,
              enumItems: pages,
              displayStringForOption: _pageLabel,
              hintText: 'hyperlink_select_page_hint'.tr,
              height: 40,
              onChanged: (TreeListModel? page) {
                if (page == null) return;
                controller.applyInternalPageLink(page.href);
                setState(() {});
              },
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: VulcanXTextField(
                  focusNode: controller.focusHyperLinkNode,
                  controller: controller.linkController,
                  hintText: 'https://www.example.com',
                  textInputAction: TextInputAction.done,
                  onChanged: (link) {
                    if (link.isEmpty) {
                      controller.removeLink();
                    }
                    setState(() {});
                  },
                  onSubmitted: (link) {
                    _applyCurrentLink();
                  },
                  onEditingComplete: _applyCurrentLink,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                tooltip: 'apply'.tr,
                onPressed: _applyCurrentLink,
                icon: const Icon(Icons.check),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'link_off'.tr,
                onPressed: () {
                  controller.removeLink();
                  setState(() {});
                },
                icon: const Icon(Icons.link_off),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
