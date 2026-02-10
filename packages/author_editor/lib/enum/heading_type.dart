enum HeadingType {
  h1('h1'),
  h2('h2'),
  h3('h3'),
  h4('h4'),
  h5('h5'),
  h6('h6');

  final String name;
  const HeadingType(this.name);
}

extension HeadingTypeExtension on HeadingType {
  static HeadingType? fromString(String tag) {
    try {
      return HeadingType.values.firstWhere(
        (type) => type.name == tag,
      );
    } catch (_) {
      return null;
    }
  }
}
