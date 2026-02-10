import 'dart:js_interop';

@JS()
@anonymous
extension type JSCellFormatOption(JSObject _) implements JSObject {
  external factory JSCellFormatOption.create({
    required String type, // 'sum' | 'average'
    String? align, // 'left' | 'center' | 'right' | 'justify'; default: 'right'
    String? prefix, // default: ''
    String? suffix, // default: ''
    bool? useThousandSeparator, // default: true
    int? decimalPlaces, // default: 2
  });

  external String get type;
  external String? get align;
  external String? get prefix;
  external String? get suffix;
  external bool? get useThousandSeparator;
  external int? get decimalPlaces;
}
