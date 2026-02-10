import 'package:app_ui/app_ui.dart';
import 'package:author_editor/extension/assets_image_extension.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../vulcan_editor_eventbus.dart';

/// 재사용 가능한 카테고리 드롭다운 위젯
/// 클립아트, 정부로고 등 다양한 템플릿 타입에 사용 가능
class CategoryDropdownItem extends StatelessWidget with EditorEventbus {
  final TemplateType templateType;
  final String title;
  final String? type; // 'clipart', 'widget', 'body_background_image' 등
  final String? type2; // 추가 타입 정보
  final VoidCallback? onTemplateChanged; // 템플릿 변경 시 콜백

  CategoryDropdownItem({
    super.key,
    required this.templateType,
    required this.title,
    this.type,
    this.type2,
    this.onTemplateChanged,
  });

  /// 템플릿 타입에 따른 상태 변수들 반환
  _TemplateStateVars? get _stateVars {
    try {
      switch (templateType) {
        case TemplateType.clipart:
          return _TemplateStateVars(
            primaryCategories: controller.rxClipArtsPrimary,
            selectedPrimary: controller.rxClipArtsSelectedPrimary,
            secondaryCategories: controller.rxClipArtsSecondary,
            selectedSecondary: controller.rxClipArtsSelectedSecondary,
            templateResources: controller.rxClipArtsResource,
            templatePath: controller.rxClipArtsPath,
          );
        case TemplateType.glogo:
          return _TemplateStateVars(
            primaryCategories: controller.rxGlogoTemplates,
            selectedPrimary: controller.rxGlogoSelectedPrimary,
            secondaryCategories: controller.rxGlogoSecondary,
            selectedSecondary: controller.rxGlogoSelectedSecondary,
            templateResources: controller.rxGlogoResource,
            templatePath: controller.rxGlogoPath,
          );
        default:
          debugPrint('지원하지 않는 템플릿 타입: $templateType');
          return null;
      }
    } catch (e) {
      debugPrint('Error getting state vars: $e');
      return null;
    }
  }

  /// 1차 카테고리 변경 처리
  Future<void> _onPrimaryCategoryChanged(Template? newValue) async {
    if (newValue == null) return;

    final stateVars = _stateVars;
    if (stateVars == null) return;

    try {
      stateVars.selectedPrimary.value = newValue;
      stateVars.secondaryCategories.value = newValue.children;

      if (newValue.children.isNotEmpty) {
        stateVars.selectedSecondary.value = newValue.children.first;
        await _loadTemplateResources(newValue.children.first);
      } else {
        // 하위 카테고리가 없는 경우 직접 템플릿 데이터 로드
        await _loadTemplateDataForTemplate(newValue);
      }
    } catch (e) {
      debugPrint('Error in _onPrimaryCategoryChanged: $e');
    }
  }

  /// 2차 카테고리 변경 처리
  Future<void> _onSecondaryCategoryChanged(Template? newValue) async {
    if (newValue == null) return;

    final stateVars = _stateVars;
    if (stateVars == null) return;

    try {
      stateVars.selectedSecondary.value = newValue;
      await _loadTemplateResources(newValue);
    } catch (e) {
      debugPrint('Error in _onSecondaryCategoryChanged: $e');
    }
  }

  /// 템플릿 리소스 로딩 (지연 로딩)
  Future<void> _loadTemplateResources(Template template) async {
    try {
      final stateVars = _stateVars;
      if (stateVars == null) return;

      // 템플릿 데이터가 아직 로드되지 않았다면 지연 로딩
      if (!template.isTemplateDataLoaded) {
        await TemplateParser.instance.loadTemplateData(
          templateName: template.name,
          type: templateType,
        );
      }

      stateVars.templatePath.value = template.path;
      stateVars.templateResources.value =
          template.templateInfo?.templateDatas ?? [];

      onTemplateChanged?.call();
    } catch (e) {
      debugPrint('Error loading template resources: $e');
    }
  }

  /// 단일 템플릿의 데이터 로딩 (하위 카테고리가 없는 경우)
  Future<void> _loadTemplateDataForTemplate(Template template) async {
    try {
      final stateVars = _stateVars;
      if (stateVars == null) return;

      if (!template.isTemplateDataLoaded) {
        await TemplateParser.instance.loadTemplateData(
          templateName: template.name,
          type: templateType,
        );
      }

      stateVars.templatePath.value = template.path;
      stateVars.templateResources.value =
          template.templateInfo?.templateDatas ?? [];
      stateVars.selectedSecondary.value = null; // 하위 카테고리가 없으므로 null

      onTemplateChanged?.call();
    } catch (e) {
      debugPrint('Error loading template data: $e');
    }
  }

  /// 템플릿 리소스 탭 처리
  void _onTemplateResourceTap(TemplateData templateData) {
    try {
      final fileName = templateData.clipartFile ?? '';
      final stateVars = _stateVars;
      if (stateVars == null) return;

      // 전체 경로 구성
      String fullPath = '${stateVars.templatePath.value}/$fileName';

      // packages/common_assets/ 제거하여 assets부터 시작하도록 만들기
      if (fullPath.startsWith('packages/common_assets/')) {
        fullPath = fullPath.replaceFirst('packages/common_assets/', '');
      }

      if (templateType == TemplateType.glogo) {
        fullPath = fullPath.replaceAll('assets/templates/glogo/', '');
      } else {
        fullPath = fullPath.replaceAll('assets/templates/clipart/', '');
      }

      final clipartType =
          templateType == TemplateType.glogo ? 'glogo' : 'clipart';
      controller.triggerClipArt(fullPath, type ?? clipartType, clipartType);

      // 타입에 따른 다른 처리
      // switch (type) {
      //   case 'background_image':
      //     controller.setObjectBackImage(path: fullPath, type: type2);
      //     break;
      //   case 'body_background_image':
      //     controller.setBodyBackImageUrl(fullPath);
      //     break;
      //   case 'widget':
      //     controller.changeSliderIcon(fullPath);
      //     break;
      //   default:
      //     // templateType에 따라 적절한 메서드 호출
      //     final clipartType =
      //         templateType == TemplateType.glogo ? 'glogo' : 'clipart';
      //     controller.triggerClipArt(fullPath, type ?? clipartType, clipartType);
      //     break;
      // }
    } catch (e) {
      debugPrint('Error in _onTemplateResourceTap: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateVars = _stateVars;

    // stateVars가 null이면 에러 방지용 빈 위젯 반환
    if (stateVars == null) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 필요한 만큼만 크기 사용
        children: [
          // 타이틀
          VulcanXText(
            text: title.tr,
            suffixIcon: const Icon(Icons.expand_more_rounded, size: 16.0),
          ),
          const SizedBox(height: 8),

          // 드롭다운 영역
          _buildDropdownSection(stateVars),

          const SizedBox(height: 8),

          // 템플릿 리소스 그리드
          Obx(() => _buildTemplateResourceGrid(stateVars)),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 드롭다운 섹션 빌드
  Widget _buildDropdownSection(_TemplateStateVars stateVars) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min, // 필요한 만큼만 크기 사용
        children: [
          // 1차 카테고리 드롭다운
          Flexible(
            flex: 1,
            child: Obx(() {
              if (stateVars.primaryCategories.isEmpty) {
                return const SizedBox.shrink();
              }

              return ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 150, maxWidth: 150),
                child: VulcanXDropdown<Template>(
                  value: stateVars.selectedPrimary.value,
                  enumItems: stateVars.primaryCategories.toList(),
                  onChanged: _onPrimaryCategoryChanged,
                  hintText: title,
                  displayStringForOption: (Template template) =>
                      Get.locale?.languageCode == 'ko'
                          ? template.description
                          : template.name,
                ),
              );
            }),
          ),

          // 2차 카테고리 드롭다운 (있는 경우에만 표시)
          Obx(() => stateVars.secondaryCategories.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 1,
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 100, maxWidth: 150),
                        child: VulcanXDropdown<Template>(
                          value: stateVars.selectedSecondary.value,
                          enumItems: stateVars.secondaryCategories.toList(),
                          onChanged: _onSecondaryCategoryChanged,
                          hintText: title,
                          displayStringForOption: (Template template) =>
                              Get.locale?.languageCode == 'ko'
                                  ? template.description
                                  : template.name,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  /// 템플릿 리소스 그리드 빌드
  Widget _buildTemplateResourceGrid(_TemplateStateVars stateVars) {
    if (stateVars.templateResources.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 사용 가능한 너비 확인
        final availableWidth = constraints.maxWidth;
        if (availableWidth <= 0) {
          return const SizedBox.shrink();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 84,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: stateVars.templateResources.length,
          itemBuilder: (context, index) {
            try {
              final templateData = stateVars.templateResources[index];
              if (templateData == null) return const SizedBox.shrink();

              final fileName = templateData.clipartFile ?? '';
              if (fileName.isEmpty) return const SizedBox.shrink();

              final path =
                  '${stateVars.templatePath.value.replaceAll('packages/common_assets/', '')}/$fileName';

              return VulcanXInkWell(
                onTap: () => _onTemplateResourceTap(templateData),
                child: VulcanXRoundedContainer(
                  width: 84,
                  height: 84,
                  borderColor: context.outline,
                  child: Assets.image.fromPath(path).image(),
                ),
              );
            } catch (e) {
              debugPrint('Error building grid item: $e');
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}

/// 템플릿 상태 변수들을 묶은 헬퍼 클래스
class _TemplateStateVars {
  final RxList<Template> primaryCategories;
  final Rx<Template?> selectedPrimary;
  final RxList<Template> secondaryCategories;
  final Rx<Template?> selectedSecondary;
  final RxList<TemplateData?> templateResources;
  final RxString templatePath;

  _TemplateStateVars({
    required this.primaryCategories,
    required this.selectedPrimary,
    required this.secondaryCategories,
    required this.selectedSecondary,
    required this.templateResources,
    required this.templatePath,
  });
}
