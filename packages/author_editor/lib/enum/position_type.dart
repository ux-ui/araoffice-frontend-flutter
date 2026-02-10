enum PositionType {
  topLeft('TopLeft'),
  topCenter('TopCenter'),
  topRight('TopRight'),
  centerLeft('CenterLeft'),
  center('Center'),
  centerRight('CenterRight'),
  bottomLeft('BottomLeft'),
  bottomCenter('BottomCenter'),
  bottomRight('BottomRight');

  final String name;
  const PositionType(this.name);

  // toString 오버라이드하여 드롭다운 등에서 name이 표시되도록
  @override
  String toString() => name;

  // CSS 위치 값으로부터 PositionType을 찾는 메서드
  static PositionType? fromPositionValue(String positionValue) {
    try {
      return PositionType.values.firstWhere(
        (type) => type.getPositionValue() == positionValue,
      );
    } catch (_) {
      return null;
    }
  }

  // PositionType에 따른 CSS 위치 값을 리턴하는 메서드
  String getPositionValue() {
    switch (this) {
      case PositionType.topLeft:
        return "0% 0%";
      case PositionType.topCenter:
        return "50% 0%";
      case PositionType.topRight:
        return "100% 0%";
      case PositionType.centerLeft:
        return "0% 50%";
      case PositionType.center:
        return "50% 50%";
      case PositionType.centerRight:
        return "100% 50%";
      case PositionType.bottomLeft:
        return "0% 100%";
      case PositionType.bottomCenter:
        return "50% 100%";
      case PositionType.bottomRight:
        return "100% 100%";
    }
  }
}
