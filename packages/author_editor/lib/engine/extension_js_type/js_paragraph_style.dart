import 'dart:js_interop';

@JS()
@anonymous
extension type JSParagraphStyle(JSObject _) implements JSObject {
  external factory JSParagraphStyle.create({
    required String textAlign,
    required String lineHeight,
  });

  external String get textAlign;
  external String get lineHeight;
  external String get paddingTop;
  external String get paddingBottom;
}
