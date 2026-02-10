// ara, ara_ebook, kakao, naver, naverworks, naver_works, brity_works, google
enum UserLoginType {
  ara('ara'), // 아라 아이디, 비밀번호
  araEbook('ara_ebook'), // 아라이북 연동
  kakao('kakao'),
  naver('naver'),
  naverWorks('naverworks'), // 네이버 웍스 연동
  naver_works(
      'naver_works'), // 네이버 웍스 연동. 아라 네이버 연동 시 'naver_works'로 넘어옴. 임시 추가.
  brityWorks('brity_works'), // 브리티 웍스 연동
  google('google'),
  sso('sso');

  final String name;
  const UserLoginType(this.name);
  factory UserLoginType.fromString(String tag) {
    return UserLoginType.values.firstWhere(
      (type) => type.name == tag.toLowerCase(),
      orElse: () => UserLoginType.ara, // 기본값 지정 필요
    );
  }
}

// TODO: 로그인 화면 하단 연동 버턴 추가
// 1. 아라 이북 - araepub.com에서만 사용
// 2. 민간 네이버 웍스 - araepub.com에서만 사용
// 3. 공공(GOV) - 네이버 웍스: 테스트 기간 동안 항상 노출, 추후 domain url보고 노출 여부 결정.
// 4. 행안부 - 네이버 웍스: 테스트 기간 동안 항상 노출, 추후 domain url보고 노출 여부 결정.
// 5. 과학기술정보통신부 - 네이버 웍스: - 테스트 기간 동안 항상 노출, 추후 domain url보고 노출 여부 결정.
// 6. 식품의약품안전처 - 네이버 웍스: - 테스트 기간 동안 항상 노출, 추후 domain url보고 노출 여부 결정.

// TODO
// 1. 행안부 - 브리티 웍스
