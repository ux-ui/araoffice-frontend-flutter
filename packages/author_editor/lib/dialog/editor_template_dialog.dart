import 'package:app_ui/app_ui.dart';
import 'package:author_editor/data/datas.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditorTemplateDialog extends StatelessWidget with EditorEventbus {
  final ValueChanged<String> onTap;
  EditorTemplateDialog({super.key, required this.onTap});

  // final _templateData = [
  //   {'label': '잡지', 'child': CommonAssets.image.testBookCover.image()},
  //   {'label': '사진', 'child': CommonAssets.image.testBookCover.image()},
  //   {'label': '패션', 'child': CommonAssets.image.testBookCover.image()},
  //   {'label': '경제 고급', 'child': CommonAssets.image.testBookCover.image()},
  //   {'label': '잡지', 'child': CommonAssets.image.testBookCover.image()},
  //   {'label': '사진', 'child': CommonAssets.image.testBookCover.image()},
  //   {'label': '패션', 'child': CommonAssets.image.testBookCover.image()},
  //   {'label': '경제 고급', 'child': CommonAssets.image.testBookCover.image()},
  // ];

  // final _previewData = [
  //   CommonAssets.image.testBookCover.image(),
  //   CommonAssets.image.testBookCover.image(),
  //   CommonAssets.image.testBookCover.image(),
  //   CommonAssets.image.testBookCover.image(),
  //   CommonAssets.image.testBookCover.image(),
  //   CommonAssets.image.testBookCover.image(),
  //   CommonAssets.image.testBookCover.image(),
  //   CommonAssets.image.testBookCover.image(),
  // ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row(
        //   children: [
        //     VulcanXDropdown<String>(
        //       width: 130,
        //       value: 'category',
        //       stringItems: const ['category', 'category2'],
        //       onChanged: (String? newValue) {},
        //       hintText: 'category',
        //     ),
        //     const SizedBox(width: 8),
        //     VulcanXDropdown<String>(
        //       width: 130,
        //       value: 'template_all',
        //       stringItems: const ['template_all', 'template_all2'],
        //       onChanged: (String? newValue) {},
        //       hintText: 'template_all',
        //     ),
        //     const Spacer(),
        //     VulcanXTextField(
        //       width: 276,
        //       isSearchIcon: true,
        //       // 검색어를 입력해주세요.
        //       hintText: 'input_hint_message'.tr,
        //     )
        //   ],
        // ),
        // const SizedBox(height: 16),

        //템플릿 전체
        Text('template_all'.tr),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 560),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  spacing: 16, // 가로 간격
                  runSpacing: 16, // 세로 간격
                  children: controller.rxTemplates
                      .map(
                        (template) => VulcanXHoverThumbnail(
                          onApply: () => onTap.call(template.id),
                          previewChild: _buildPreview(template.pages),
                          text: template.name,
                          child: Image.network(template.thumbnailUrl),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPreview(List<VulcanTemplatePage> pages) {
    ScrollController scrollController = ScrollController();

    return PopupMenuButton<void>(
      tooltip: '',
      offset: const Offset(0, 10),
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(
        minWidth: 500,
        maxWidth: 500,
        minHeight: 195,
        maxHeight: 195,
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<void>(
          enabled: true,
          padding: EdgeInsets.zero,
          child: RawScrollbar(
            controller: scrollController,
            thickness: 8,
            radius: const Radius.circular(4),
            thumbVisibility: true,
            trackVisibility: true,
            thumbColor: Colors.grey[500], // 스크롤바 색상
            trackColor: Colors.grey[300], // 트랙 색상
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: pages
                    .map(
                      (preview) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                            width: 131,
                            height: 178,
                            child: Image.network(preview.thumbnailUrl)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
      child:
          VulcanXElevatedButton.nullStyle(width: 73, child: Text('preview'.tr)),
    );
  }
}
