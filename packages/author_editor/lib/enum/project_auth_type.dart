import 'package:get/get.dart';

/// 프로젝트 권한 유형을 정의하는 enum
enum ProjectAuthType {
  /// 링크가 있는 모든 사용자가 접근 가능
  publicLink('PUBLICLINK'),

  /// 권한이 있는 사용자만 접근 가능
  userLink('USERLINK'),

  /// 소유자만 접근 가능
  onlyMe('ONLYME');

  /// 생성자
  final String translationKey;
  const ProjectAuthType(this.translationKey);

  /// 서버 API와 통신할 때 사용되는 문자열 값
  String get value => translationKey;

  // 번역된 이름을 가져오는 getter
  String get name => translationKey.tr;

  /// 문자열 값으로부터 enum 값을 찾아 반환
  static ProjectAuthType fromString(String? value) {
    return ProjectAuthType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ProjectAuthType.onlyMe,
    );
  }
}
