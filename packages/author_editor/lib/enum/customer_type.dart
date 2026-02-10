enum CustomerType {
  ara('ara'), // 아라
  mois('mois'), // 행안부
  gov('gov'),
  msit('msit'), // 과학기술정보통신부
  mdfs('mdfs'); // 식품의약품안전처

  final String name;
  const CustomerType(this.name);
  factory CustomerType.fromString(String tag) {
    return CustomerType.values.firstWhere(
      (type) => type.name == tag.toLowerCase(),
      orElse: () => CustomerType.ara, // 기본값 지정 필요
    );
  }
}
