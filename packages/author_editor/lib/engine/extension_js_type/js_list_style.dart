import 'dart:js_interop';

@JS()
@anonymous
extension type JsListStyle(JSObject _) implements JSObject {
  external factory JsListStyle.create({
    required String tagType,
    required String style,
  });

  external String get tagType;
  external String get style;
}
