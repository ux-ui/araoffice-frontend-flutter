enum BorderPositionType {
  left('left'),
  right('right'),
  top('top'),
  bottom('bottom');

  final String name;
  const BorderPositionType(this.name);
}

extension CellBorderTypeExtension on BorderPositionType {
  static BorderPositionType? fromString(String tag) {
    try {
      return BorderPositionType.values.firstWhere(
        (type) => type.name == tag,
      );
    } catch (_) {
      return null;
    }
  }
}
