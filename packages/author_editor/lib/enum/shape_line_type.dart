enum ShapeLineType {
  none('none'),
  wings('wings'),
  diamond('diamond'),
  circle('circle');

  final String name;
  const ShapeLineType(this.name);
}

extension ShapeLineTypeExtension on ShapeLineType {
  static ShapeLineType? fromString(String tag) {
    try {
      return ShapeLineType.values.firstWhere(
        (type) => type.name == tag,
      );
    } catch (_) {
      return null;
    }
  }
}
