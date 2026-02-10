import 'package:get/get.dart';

enum ListStyleClassType {
  styleNone('ve_list_style_none'),
  styleList1('ve_list_style1'),
  styleList2('ve_list_style2'),
  styleList3('ve_list_style3');

  final String translationKey;
  const ListStyleClassType(this.translationKey);

  // 번역된 이름을 가져오는 getter
  String get name => translationKey.tr;

  // vlist 값을 가져오는 getter
  String get vlistValue {
    switch (this) {
      case ListStyleClassType.styleList1:
        return "vlist1";
      case ListStyleClassType.styleList2:
        return "vlist2";
      case ListStyleClassType.styleList3:
        return "vlist3";
      default:
        return "";
    }
  }

  // factory constructor 방식
  factory ListStyleClassType.fromString(String tag) {
    return ListStyleClassType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => ListStyleClassType.styleList1, // 기본값 지정 필요
    );
  }

  //vlistValue 값으로 목록 스타일 타입 반환
  factory ListStyleClassType.fromVlistValue(String vlistValue) {
    return ListStyleClassType.values.firstWhere(
      (type) => type.vlistValue == vlistValue,
      orElse: () => ListStyleClassType.styleNone, // 기본값 지정 필요
    );
  }
}
