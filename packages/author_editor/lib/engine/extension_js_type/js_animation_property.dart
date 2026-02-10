import 'dart:js_interop';

@JS()
@anonymous
extension type JSAnimationProperty(JSObject _) implements JSObject {
  external factory JSAnimationProperty.create({
    required String name,
    required String trigger,
    required num delay,
    required num duration,
    required num repeat,
  });

  external String get className;
  external String get trigger;
  external num get delay;
  external num get duration;
  external num get repeat;
}
