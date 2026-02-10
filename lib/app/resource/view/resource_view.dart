import 'package:api/api.dart';
import 'package:app/app/common/common_home_header.dart';
import 'package:app/app/dialog/template_preview_dialog.dart';
import 'package:app/app/template/controller/template_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResourceView extends StatefulWidget {
  const ResourceView({super.key});

  @override
  State<ResourceView> createState() => _ResourceViewState();
}

/// 리소스 관리
class _ResourceViewState extends State<ResourceView> {
  final TemplateController controller = Get.find<TemplateController>();
  final String userId = 'Ara Kim';

  @override
  void initState() {
    super.initState();
    controller.fetchTemplateList();
    controller.fetchMyTemplate();
    controller.fetchSharedTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        children: [
          SizedBox(
            height: 800,
            child: BtoTabBarView(
                indicatorSize: TabBarIndicatorSize.tab,
                tabWidth: 250,
                tabsAlignment: Alignment.centerLeft,
                physics: const NeverScrollableScrollPhysics(),
                tabs: [
                  'template'.tr,
                  'library'.tr,
                ],
                children: [
                  templateTab(context),
                  Text('library'.tr),
                ]),
          )
        ],
      ),
    );
  }

  Widget templateTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildSortRow(context),
        const SizedBox(height: 20),
        _buildTemplateBody(context, title: 'my_template'.tr),
        const SizedBox(height: 20),
        Obx(() => _buildTemplateListByData(context,
            templateList: controller.myTemplates)),
        const SizedBox(height: 20),
        _buildTemplateBody(context, title: 'shared_template'.tr),
        const SizedBox(height: 20),
        Obx(
          () => _buildTemplateListByData(context,
              templateList: controller.sharedTemplateList),
        ),
      ],
    );
  }

  Widget _buildSortRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        VulcanXDropdown<String>(
          width: 94,
          value: controller.sortSelected.value,
          stringItems: controller.sortTitle,
          onChanged: (String? newValue) {
            controller.sortSelected.value = newValue!;
          },
          hintText: 'sort_by_user'.tr,
          hintIcon: Icons.lock,
        ),
        VulcanXTextField(
            width: 336,
            //파일 또는 프로젝트 검색
            hintText: 'hint_text_file_project_search'.tr,
            isSearchIcon: true),
      ],
    );
  }

  Widget _buildTemplateBody(
    BuildContext context, {
    required title,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: context.titleLarge,
            ),
            VulcanXText(
              text: 'more_template_view'.tr,
              suffixIcon:
                  CommonAssets.icon.arrowForward.svg(width: 16, height: 16),
              onTap: () {},
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTemplateListByData(
    BuildContext context, {
    required List<TemplateModel> templateList,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 24, // 가로 간격
        runSpacing: 24, // 세로 간격
        alignment: WrapAlignment.start, // 시작점부터 정렬
        children: templateList.asMap().entries.map(
          (e) {
            return HoverableAnimatedTap(
              onTap: () {},
              child: SizedBox(
                width: 242,
                child: Column(
                  children: [
                    VulcanXImageChip(
                      width: 242,
                      height: 180,
                      chipLabel: e.value.fixed
                          ? Text('fixed_layout'.tr)
                          : Text('free_layout'.tr),
                      imageUrl: controller.getImageUrl(e.value),
                      isBookmark: false,
                      isCrownBadge: false,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(e.value.name,
                              overflow: TextOverflow.ellipsis),
                        ),
                        PopupMenuButton<String>(
                            color: context.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            icon: const Icon(
                              Icons.more_vert,
                              size: 16,
                            ),
                            itemBuilder: (BuildContext context) => [
                                  CustomPopupItem(
                                    icon: Icons.add_box_outlined,
                                    text: 'template_create_project',
                                    onTap: () async {
                                      await VulcanCloseDialogWidget(
                                        width: 800,
                                        //템플릿 미리보기
                                        title: 'template_preview'.tr,
                                        content: Flexible(
                                          child: TemplatePreviewDialog(
                                            templateUrl: controller.templateUrl,
                                            templateModel: e.value,
                                          ),
                                        ),
                                      ).show(context);
                                    },
                                  ),
                                  CustomPopupItem(
                                    icon: Icons.share_outlined,
                                    text: 'template_share',
                                    onTap: () async {},
                                  ),
                                  CustomPopupItem(
                                    icon: Icons.delete_outline,
                                    text: 'template_delete',
                                    onTap: () async {
                                      controller
                                          .deleteFavoriteTemplate(e.value.id);
                                    },
                                  ),
                                ])
                      ],
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: context.primaryContainer,
                          radius: 10,
                          child: Text(
                              e.value.authorNo.toUpperCase().characters.first,
                              style: context.labelSmall
                                  ?.apply(color: context.primary)),
                        ),
                        const SizedBox(width: 8),
                        Text(e.value.authorNo, style: context.bodyMedium),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
