import 'package:flutter/material.dart';

/// 도형 설정 데이터 모델
class VulcanShapeItemData {
  final String type; // figureDraw
  final String shape; // rect, circle 등
  final String lineWidth; // 선 두께
  final String strokeColor; // 테두리 색상
  final String? fillColor; // 채우기 색상

  VulcanShapeItemData({
    required this.type,
    required this.shape,
    required this.lineWidth,
    required this.strokeColor,
    this.fillColor,
  });

  /// 문자열에서 VulcanShapeItemData 객체 생성
  factory VulcanShapeItemData.fromString(String shapeSettings) {
    final settings = shapeSettings.split('|');
    return VulcanShapeItemData(
      type: settings[0],
      shape: settings[1],
      lineWidth: settings[2],
      strokeColor: settings[3],
      fillColor: settings.length > 4 ? settings[4] : null,
    );
  }

  /// 테두리 색상을 Color 객체로 변환
  Color? get strokeColorValue => _convertRGBToColor(strokeColor);

  /// 채우기 색상을 Color 객체로 변환
  Color? get fillColorValue =>
      fillColor != null ? _convertRGBToColor(fillColor!) : null;

  /// RGB 문자열을 Color 객체로 변환하는 내부 메서드
  Color? _convertRGBToColor(String colorString) {
    final rgbaMatch =
        RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)')
            .firstMatch(colorString);
    if (rgbaMatch != null) {
      final r = int.parse(rgbaMatch.group(1)!);
      final g = int.parse(rgbaMatch.group(2)!);
      final b = int.parse(rgbaMatch.group(3)!);
      final a =
          rgbaMatch.group(4) != null ? double.parse(rgbaMatch.group(4)!) : 1.0;

      return Color.fromRGBO(r, g, b, a);
    }
    return null;
  }

  /// 데이터를 문자열로 변환
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(type);
    buffer.write('|');
    buffer.write(shape);
    buffer.write('|');
    buffer.write(lineWidth);
    buffer.write('|');
    buffer.write(strokeColor);
    if (fillColor != null) {
      buffer.write('|');
      buffer.write(fillColor);
    }
    return buffer.toString();
  }

  /// 선 두께를 double로 변환
  double get lineWidthValue => double.tryParse(lineWidth) ?? 1.0;
}

/// 도형 타입 열거형
enum ShapeType {
  rect,
  circle,
  line,
  arrow,
  process,
  decisions,
  page,
  data,
  delay,
  inputoroutput,
  documents,
  offpageconnector,
  alternateprocess,
  manualinput,
  manualoperation,
  storeddata,
  database,
  magnetictape,
  internalstorage,
  offlinestorage,
  display,
  preparation,
  predefinedprocess,
  punchedcard,
  punchedtape,
  keying,
  sort,
  mergestorage,
  extract,
  collate,
  summing,
  logicalor;

  /// 문자열을 ShapeType으로 변환
  static ShapeType? fromString(String value) {
    try {
      return ShapeType.values.firstWhere(
        (type) => type.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
