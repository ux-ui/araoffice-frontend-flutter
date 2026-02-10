import 'package:get/get.dart';

import 'languages/en_us.dart';
import 'languages/id_id.dart';
import 'languages/ja_jp.dart';
import 'languages/ko_kr.dart';
import 'languages/vi_vn.dart';
import 'languages/zh_cn.dart';
import 'languages/zh_tw.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUs,
        'ko_KR': koKr,
        'ja_JP': jaJp,
        'zh_CN': zhCn,
        'zh_TW': zhTw,
        'id_ID': idId,
        'vi_VN': viVn,
      };
}
