import 'package:api/api.dart';
import 'package:common_util/common_util.dart';
import 'package:get/get.dart';

import '../../common/common_view_type.dart';
import '../../setting/language_enum.dart';

class TemplateController extends GetxController {
  final TemplateApiService apiService = Get.find<TemplateApiService>();
  final baseUrl = ApiDio.apiHostAppServer;
  final viewType = ViewType.template.obs;
  final title = 'Template View'.obs;
  final selectedIndex = 0.obs;
  final List tabs = ['전체', '비디오', '오디오', '사진', '이미지', '위젯'];
  final sortTitle = ['인기순', '최신순', '가나다순'];
  final sortSelected = '최신순'.obs;
  final language = ''.obs;
  final currentLanguage = ''.obs;
  final templateInfo = Rxn<TemplateModel>();
  final RxList<TemplateModel> templateList = <TemplateModel>[].obs;
  final RxList<TemplateModel> myTemplates = <TemplateModel>[].obs;
  final RxList<TemplateModel> sharedTemplateList = <TemplateModel>[].obs;
  final RxList<TemplateModel> filterTemplateList = <TemplateModel>[].obs;

  String get templateUrl => '${baseUrl}templates/';

  // 템플릿 마켓 메인 리스트
  Future<List<TemplateModel>?> fetchTemplateList() async {
    final result = await apiService.fetchTemplate();
    if (result != null) {
      templateList.value = result.templateList!;
      updateFilterTemplateList();
      return templateList.value = result.templateList!;
    }
    logger.d(templateList.toString());
    return null;
  }

  Future<List<TemplateModel>?> updateFilterTemplateList() async {
    final List<TemplateModel> list = [];
    if (templateList.isNotEmpty) {
      for (var element in templateList) {
        if (element.language == language.value) {
          list.add(element);
        }
      }
      filterTemplateList.value = list;
      return list;
    }

    logger.d(filterTemplateList.toString());
    return null;
  }

  // api 수정에 따른 변경 필요
  void createTemplate() async {
    final result = await apiService.createTemplate(
      templateName: 'templateName',
      templateId: 'templateId',
    );
    if (result != null) {
      logger.d('템플릿 생성 성공');
    }
  }

  Future fetchTemplateInfo() async {
    final result = await apiService.fetchTemplateInfo(templateId: 'templateId');
    if (result != null) {
      templateInfo.value = result.template;
      logger.d('템플릿 정보 가져오기 성공');
    } else {
      logger.d('템플릿 정보 가져오기 실패');
    }
  }

  Future<bool> deleteTemplate(String templateId) async {
    final result = await apiService.deleteTemplate(templateId: templateId);
    if (result) {
      logger.d('템플릿 삭제 성공');
      return true;
    } else {
      logger.d('템플릿 삭제 실패');
      return false;
    }
  }

  Future<void> fetchMyTemplate() async {
    final result = await apiService.fetchMyTemplate();
    if (result != null) {
      myTemplates.value = result.templateList!;
      logger.d('내 템플릿 가져오기 성공');
    } else {
      logger.d('내 템플릿 가져오기 실패');
    }
  }

  Future<bool> addFavoriteTemplate(String templateId) async {
    final result =
        await apiService.addFavoritesTemplate(templateId: templateId);

    return result;
  }

  Future<bool> deleteFavoriteTemplate(String templateId) async {
    final result =
        await apiService.deleteFavoritesTemplate(templateId: templateId);

    if (result == true) {
      logger.d('즐겨찾기 삭제 성공');
      return true;
    } else {
      logger.d('즐겨찾기 삭제 실패');
      return false;
    }
  }

  Future<void> fetchSharedTemplates() async {
    final result = await apiService.fetchSharedTemplates();
    if (result != null) {
      sharedTemplateList.value = result.templateList!;
    }
  }

  String getImageUrl(TemplateModel template) {
    return '$templateUrl${template.id}/${template.thumbnail}';
  }

  String getPageImageUrl(TemplateModel template, TemplatePageModel page) {
    return '$templateUrl${template.id}/${page.thumbnail}';
  }

  String getCurrentLanguage() {
    if (Get.locale == LanguageType.korean.locale) {
      language.value = 'ko-KR';
      currentLanguage.value = 'Korean';
      return 'Korean';
    } else if (Get.locale == LanguageType.indonesia.locale) {
      language.value = 'id-ID';
      currentLanguage.value = 'Indonesia';
      return 'Indonesia';
    } else if (Get.locale == LanguageType.english.locale) {
      language.value = 'en-US';
      currentLanguage.value = 'English';
      return 'English';
    } else {
      language.value = 'ko-KR';
      currentLanguage.value = 'Korean';
      return 'Korean';
    }
  }
}
