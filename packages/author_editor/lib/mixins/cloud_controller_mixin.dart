import 'package:api/api.dart';
import 'package:get/get.dart';

mixin CloudControllerMixin on GetxController {
  final title = 'Cloud View'.obs;
  final tokenStatus = false.obs;
  final CloudApiService cloudApiService = Get.find<CloudApiService>();

  void initSettings() {
    checkTokenStatus();
  }

  @override
  void onInit() {
    super.onInit();
    initSettings();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void checkTokenStatus() async {
    final token = await cloudApiService.getNaverWorksTokenNoRedirect();
    if (token != null && token.isNotEmpty) {
      tokenStatus.value = true;
    } else {
      tokenStatus.value = false;
    }
  }
}
