import 'dart:js_interop';

import 'package:author_editor/engine/extension_js_type/js_paragraph_style.dart';

@JS()
@anonymous
extension type JSTextStyle(JSObject _) implements JSObject {
  external factory JSTextStyle.create({
    required String paragraphTag,
    required String fontFamily,
    required String fontSize,
    required String textColor,
    required String backColor,
    required bool bold,
    required bool italic,
    required bool underline,
    required bool overline,
    required bool strike,
    required bool subScript,
    required bool superScript,
    // required bool subscriptAlpha,
    // required bool superscriptAlpha,
    bool? needToApplyTypingStyle,
    required String letterSpacing,
    required JSParagraphStyle paragraphStyle,
  });

  external String get paragraphTag;
  external String get fontFamily;
  external String get fontSize;
  external String get textColor;
  external String get backColor;
  external bool get bold;
  external bool get italic;
  external bool get underline;
  external bool get overline;
  external bool get strike;
  external bool get subScript;
  external bool get superScript;
  // external bool get subscriptAlpha;
  // external bool get superscriptAlpha;
  external bool? get needToApplyTypingStyle;
  external String get letterSpacing;
  external JSParagraphStyle get paragraphStyle;

  JSTextStyle withCopy({
    String? paragraphTag,
    String? fontFamily,
    String? fontSize,
    String? textColor,
    String? backColor,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? overline,
    bool? strike,
    bool? subScript,
    bool? superScript,
    // bool? subscriptAlpha,
    // bool? superscriptAlpha,
    bool? needToApplyTypingStyle,
    String? letterSpacing,
    JSParagraphStyle? paragraphStyle,
  }) {
    return JSTextStyle.create(
      paragraphTag: paragraphTag ?? this.paragraphTag,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      backColor: backColor ?? this.backColor,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      overline: overline ?? this.overline,
      strike: strike ?? this.strike,
      subScript: subScript ?? this.subScript,
      superScript: superScript ?? this.superScript,
      // subscriptAlpha: subscriptAlpha ?? this.subscriptAlpha,
      // superscriptAlpha: superscriptAlpha ?? this.superscriptAlpha,
      needToApplyTypingStyle:
          needToApplyTypingStyle ?? this.needToApplyTypingStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      paragraphStyle: paragraphStyle ?? this.paragraphStyle,
    );
  }
}
