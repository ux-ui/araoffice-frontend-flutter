import 'package:get/get.dart';

import '../guide_view_type.dart';

class GuideController extends GetxController {
  final viewType = GuideViewType.guideStart.obs;

  void updateViewType(GuideViewType type) {
    viewType.value = type;
  }
}
