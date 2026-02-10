import 'package:app/app/dialog/template_preview_dialog.dart';
import 'package:app/app/setting/language_enum.dart';
import 'package:app/app/template/controller/template_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TemplateView extends GetView<TemplateController> {
  const TemplateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            //템플릿 마켓
            'template_market'.tr,
            style: context.displaySmall,
          ),
          const SizedBox(height: 10),
          Text(
            //다양한 분야의 템플릿을 저작권 걱정없이 활용해 보세요
            'templeate_market_message'.tr,
            style: TextStyle(color: context.outlineVariant),
          ),
          const SizedBox(height: 20),
          // _buildTapGroup(context),
          // const SizedBox(height: 20),
          //_buildSortRow(context),
          //const SizedBox(height: 20),
          _buildTemplateBody(context),
          const SizedBox(height: 20),
          Align(
              alignment: Alignment.topLeft,
              child: TemplateListView(controller: controller))
        ],
      ),
    );
  }

  // selected text color = context.primary Fill = 30%
  // Widget _buildTapGroup(BuildContext context) {
  //   return Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: List.generate(
  //           controller.tabs.length,
  //           (index) => Obx(
  //                 () => Padding(
  //                   padding: const EdgeInsets.only(right: 5),
  //                   child: LabelButton(
  //                     borderRadius: 20,
  //                     label: controller.tabs[index],
  //                     onPressed: () {
  //                       controller.selectedIndex.value = index;
  //                     },
  //                     textColor: controller.selectedIndex.value == index
  //                         ? context.primary
  //                         : const Color(0xff212529),
  //                     backgroundColor: controller.selectedIndex.value == index
  //                         ? context.primary.withOpacity(0.2)
  //                         : context.surface,
  //                     borderColor: controller.selectedIndex.value == index
  //                         ? context.primary
  //                         : context.outline,
  //                   ),
  //                 ),
  //               )));
  // }

  // Widget _buildSortRow(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       VulcanXDropdown<String>(
  //         width: 94,
  //         value: controller.sortSelected.value,
  //         stringItems: controller.sortTitle,
  //         onChanged: (String? newValue) {
  //           controller.sortSelected.value = newValue!;
  //         },
  //         hintText: '권한이 있는 사용자',
  //         hintIcon: Icons.lock,
  //       ),
  //       VulcanXTextField(
  //           width: 336,
  //           //파일 또는 프로젝트 검색
  //           hintText: 'hint_text_file_project_search'.tr,
  //           isSearchIcon: true),
  //     ],
  //   );
  // }

  Widget _buildTemplateBody(BuildContext context) {
    controller.getCurrentLanguage();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 기본 템플릿
            Text(
              'template_default'.tr,
              style: context.titleLarge,
            ),
            SizedBox(
              width: 150,
              height: 40,
              child: Obx(
                () => VulcanXDropdown<String>(
                  value: controller.currentLanguage.value,
                  enumItems: LanguageType.values.map((e) => e.name).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      final language = LanguageType.values
                          .firstWhere((element) => element.name == value);
                      controller.language.value =
                          language.locale.toLanguageTag();
                      controller.currentLanguage.value = value;
                      controller.updateFilterTemplateList();
                    }
                  },
                  hintText: 'account_management_language_hint'.tr,
                  hintIcon: Icons.language,
                ),
              ),
            ),
            // Obx(
            //   () => Text(
            //     '${controller.sortSelected.value} 템플릿',
            //     style: context.titleLarge,
            //   ),
            // ),
            // VulcanXText(
            //   text: '더 많은 템플릿 보기',
            //   suffixIcon:
            //       CommonAssets.icon.arrowForward.svg(width: 16, height: 16),
            //   onTap: () {},
            // ),
          ],
        )
      ],
    );
  }
}

class TemplateListView extends StatefulWidget {
  final TemplateController controller;
  const TemplateListView({required this.controller, super.key});

  @override
  State<TemplateListView> createState() => _TemplateListViewState();
}

class _TemplateListViewState extends State<TemplateListView> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchTemplateList();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.fetchTemplateList();
    return Obx(
      () => widget.controller.filterTemplateList.isNotEmpty
          ? Wrap(
              spacing: 24, // 가로 간격
              runSpacing: 24, // 세로 간격
              alignment: WrapAlignment.start, // 시작점부터 정렬
              children:
                  widget.controller.filterTemplateList.asMap().entries.map(
                (e) {
                  return HoverableAnimatedTap(
                    onTap: () async {
                      await VulcanCloseDialogWidget(
                        width: 800,
                        //템플릿 미리보기
                        title: 'template_preview'.tr,
                        content: Flexible(
                          child: TemplatePreviewDialog(
                            templateUrl: widget.controller.templateUrl,
                            templateModel: e.value,
                          ),
                        ),
                      ).show(context);
                    },
                    child: SizedBox(
                      width: 242,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VulcanXImageChip(
                            imageUrl: widget.controller.getImageUrl(e.value),
                            width: 242,
                            height: 180,
                            chipLabel: null,
                            //Text('fixed_layout'.tr),
                            isBookmark: false,
                            isCrownBadge: e.value.free,
                            onSelectedBookmark: (value) {
                              // widget.controller.addFavoriteTemplate(e.value.id);
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            e.value.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: context.primaryContainer,
                                child: Text(
                                    e.value.authorNo.characters.firstOrNull
                                            ?.toUpperCase() ??
                                        '?',
                                    style: context.labelSmall
                                        ?.apply(color: context.primary)),
                              ),
                              const SizedBox(width: 8),
                              Text(e.value.authorNo, style: context.bodyMedium),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            )
          : Center(
              //템플릿이 없습니다.
              child: Text('template_no_data'.tr)),
    );
  }
}
