import 'dart:js_interop';

@JS()
@anonymous
extension type JSDocumentState(JSObject _) implements JSObject {
  external factory JSDocumentState.create({
    required int width,
    required int height,
  });

  external int get width;
  external int get height;
}
