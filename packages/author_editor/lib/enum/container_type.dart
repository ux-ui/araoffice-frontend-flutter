enum ContainerType {
  none(''),
  free('free'), // 임의 위치(자식 아이템의 position 값이 absolute), 다른 타입과 호환(변환)되지 않음
  left(
      'left'), // flex-direction: row, justify-content: flex-start, align-items: center(공통), flex-wrap: wrap(공통, css 기본값은 nowrap)
  horizontalCenter(
      'horizontalCenter'), // flex-direction: row, justify-content: center
  right('right'), // flex-direction: row, justify-content: flex-end
  horizontalBetween(
      'horizontalBetween'), // flex-direction: row, justify-content: space-between
  top('top'), // flex-direction: column, justify-content: flex-start
  verticalCenter(
      'verticalCenter'), // flex-direction: column, justify-content: center
  bottom('bottom'), // flex-direction: column, justify-content: flex-end
  verticalBetween(
      'verticalBetween'); // flex-direction: column, justify-content: space-between

  final String name;
  const ContainerType(this.name);

  // factory constructor 방식
  factory ContainerType.fromString(String tag) {
    return ContainerType.values.firstWhere(
      (type) => type.name == tag,
      orElse: () => ContainerType.free,
    );
  }
}
