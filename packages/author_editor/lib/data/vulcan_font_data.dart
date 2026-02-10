import 'dart:js_interop';

import 'package:common_util/common_util.dart';

class VulcanFontListData {
  final List<VulcanFontData> fonts = [];

  VulcanFontListData();

  factory VulcanFontListData.fromJsArray(
    JSArray<JSArray<JSString>> jsArray, {
    required String defaultFontFamily,
    String? defaultFontName,
  }) {
    return VulcanFontListData()
      ..initFonts(
        jsArray,
        defaultFontFamily: defaultFontFamily,
        defaultFontName: defaultFontName,
      );
  }

  void initFonts(
    JSArray<JSArray<JSString>> jsArray, {
    required String defaultFontFamily,
    String? defaultFontName,
  }) {
    try {
      fonts.clear();

      // 기본 글꼴 추가
      fonts.add(VulcanFontData(
        family: defaultFontFamily,
        name: defaultFontName ?? defaultFontFamily,
        installed: false,
        isSystemDefault: true,
      ));

      // 설치된 글꼴 추가
      fonts.addAll(
        jsArray.toDart.map((font) => VulcanFontData.fromJsArray(font)),
      );

      logger.d('[VulcanFontListData] initFonts success: $this');
    } catch (e) {
      logger.e('[VulcanFontListData] initFonts error: $e');
    }
  }

  /// 폰트 패밀리 이름이 일치하는 폰트를 찾아서 반환. 없으면 null 반환
  VulcanFontData? getFontByFamily(String fontFamily) {
    try {
      return fonts.firstWhere((font) => font.family == fontFamily);
    } catch (_) {
      return null;
    }
  }

  /// 폰트 이름이 일치하는 폰트를 찾아서 반환. 없으면 null 반환
  VulcanFontData? getFontByName(String fontName) {
    try {
      return fonts.firstWhere((font) => font.name == fontName);
    } catch (_) {
      return null;
    }
  }

  VulcanFontData insertFont({required String fontFamily, String? fontName}) {
    var fontData = getFontByFamily(fontFamily);
    if (fontData != null) {
      return fontData;
    }
    fontData = VulcanFontData(
      family: fontFamily,
      name: fontName ?? fontFamily,
      installed: false,
      isSystemDefault: false,
    );
    logger.d('[VulcanFontListData] insert font: ${fontData.toJsonString()}');
    fonts.add(fontData);
    return fontData;
  }

  Map<String, dynamic> toJson() {
    return {
      'fonts': fonts.map((font) => font.toJson()).toList(),
    };
  }

  @override
  String toString() {
    final fontStrings = fonts.map((font) => font.toJsonString()).join(',\n');
    return '{fonts: [\n$fontStrings\n]}';
  }
}

class VulcanFontData {
  final String family;
  final String name;

  /// [installed]
  /// - true: 설치된 폰트
  /// - false: 설치되지 않은 폰트로 문서 내부에 미리 설정되어 있는 폰트.
  ///          해당 텍스트를 선택하면 동적으로 추가됨.
  final bool installed;

  /// [isSystemDefault]
  /// - true: 시스템 기본 폰트. 폰트 설정이 명시적으로 없는 경우.
  /// - false: 폰트가 명시적으로 설정된 경우.
  final bool isSystemDefault;

  VulcanFontData({
    required this.family,
    required this.name,
    this.installed = false,
    this.isSystemDefault = false,
  });

  factory VulcanFontData.fromJsArray(JSArray<JSString> jsArray) {
    final font = jsArray.toDart;
    return VulcanFontData(
      family: font.first.toString(),
      name: font.last.toString(),
      installed: true,
      isSystemDefault: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'family': family,
      'name': name,
      'installed': installed,
      'isSystemDefault': isSystemDefault,
    };
  }

  String toJsonString() => toJson().toString();

  // VulcanXDropdown에서 toString()으로 노출됨
  @override
  String toString() => name;
}
