import 'dart:js_interop';

@JS()
@anonymous
extension type JSPosition(JSObject _) implements JSObject {
  external factory JSPosition.create({
    required double x,
    required double y,
  });

  external double get x;
  external double get y;
}
