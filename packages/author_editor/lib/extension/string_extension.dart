import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension RgbColorConverter on String {
  String toHexColor() {
    try {
      // rgb(r, g, b) 또는 rgba(r, g, b, a) 형식에서 숫자만 추출
      final rgbaPattern =
          RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)');
      final numbers = rgbaPattern.firstMatch(this);

      if (numbers == null) {
        throw const FormatException('Invalid RGB/RGBA format');
      }

      // r, g, b 값 추출
      final r = int.parse(numbers.group(1)!);
      final g = int.parse(numbers.group(2)!);
      final b = int.parse(numbers.group(3)!);

      // alpha 값 추출 및 변환 (0~1 -> 0~255)
      // rgba일 경우 네 번째 그룹이 있고, rgb일 경우 없음
      final a = numbers.group(4) != null
          ? (double.parse(numbers.group(4)!) * 255).round()
          : 255;

      // 16진수로 변환하고 2자리로 맞춤
      final rHex = r.toRadixString(16).padLeft(2, '0');
      final gHex = g.toRadixString(16).padLeft(2, '0');
      final bHex = b.toRadixString(16).padLeft(2, '0');
      final aHex = a.toRadixString(16).padLeft(2, '0');

      // alpha가 255(ff)가 아닐 때만 alpha 값 포함
      return '#$rHex$gHex$bHex${a != 255 ? aHex : ''}';
    } catch (e) {
      return this; // 변환 실패시 원래 문자열 반환
    }
  }

  // RGB/RGBA 문자열을 Color 객체로 변환
  Color? toColor() {
    try {
      final rgbaPattern =
          RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)');
      final numbers = rgbaPattern.firstMatch(this);

      if (numbers == null) {
        throw const FormatException('Invalid RGB/RGBA format');
      }

      final r = int.parse(numbers.group(1)!);
      final g = int.parse(numbers.group(2)!);
      final b = int.parse(numbers.group(3)!);
      final a = numbers.group(4) != null
          ? (double.parse(numbers.group(4)!) * 255).round()
          : 255;

      return Color.fromARGB(a, r, g, b);
    } catch (e) {
      return null;
    }
  }

  bool toBool() => isEmpty ? false : toLowerCase() == 'true';

  String transparencyToOpacity() {
    // String을 double로 변환
    double transparencyValue = double.tryParse(this) ?? 0.0;
    // 입력값이 0~100 범위를 벗어나면 가장 가까운 유효값으로 조정
    double clampedValue = transparencyValue.clamp(0.0, 100.0);

    // 투명도(%) -> opacity 변환 후 소수점 2자리까지 문자열로 변환
    return ((100 - clampedValue) / 100).toStringAsFixed(2);
  }

  String opacityToTransparency() {
    // String을 double로 변환
    double opacityValue = double.tryParse(this) ?? 0.0;
    // 입력값이 0~1 범위를 벗어나면 가장 가까운 유효값으로 조정
    double clampedValue = opacityValue.clamp(0.0, 1.0);

    // opacity -> 투명도(%) 변환 후 소수점 없이 문자열로 변환
    return ((1 - clampedValue) * 100).toStringAsFixed(0);
  }

  String replacePX() {
    return replaceAll('px', '');
  }

  /// px 단위를 pt 단위로 변환하는 메서드
  /// 예: "111px" -> "83.25pt"
  String pxToPt() {
    try {
      // px를 제거하고 숫자만 추출
      final numberString = replaceAll('px', '').trim();
      final pxValue = double.tryParse(numberString);

      if (pxValue == null) {
        return this; // 숫자 변환 실패시 원래 문자열 반환
      }

      // px를 pt로 변환 (1px = 0.75pt)
      final ptValue = pxValue * 0.75;

      return '${ptValue.toStringAsFixed(2)}pt';
    } catch (e) {
      return this; // 변환 실패시 원래 문자열 반환
    }
  }

  /// px 단위를 pt 숫자 값으로 변환하는 메서드
  /// 예: "111px" -> "83.25"
  String pxToPtNumber() {
    try {
      // px를 제거하고 숫자만 추출
      final numberString = replaceAll('px', '').trim();
      final pxValue = double.tryParse(numberString);

      if (pxValue == null) {
        return numberString; // 숫자 변환 실패시 숫자 부분만 반환
      }

      // px를 pt로 변환 (1px = 0.75pt)
      final ptValue = pxValue * 0.75;

      return ptValue.toStringAsFixed(2);
    } catch (e) {
      return replaceAll('px', '').trim(); // 변환 실패시 숫자 부분만 반환
    }
  }
}

extension StringExtension on String {
  String truncate(int maxLength) {
    return length > maxLength ? '${substring(0, maxLength)}...' : this;
  }

  // SVG 문자열에서 width와 height 값을 추출하고 scaleFactor 배로 확대하는 메서드
  String scaleSvgDimensions(double scaleFactor) {
    // width 값 추출 및 수정
    final widthRegex = RegExp(r'width="([^"]+)"');
    final widthMatch = widthRegex.firstMatch(this);

    // height 값 추출 및 수정
    final heightRegex = RegExp(r'height="([^"]+)"');
    final heightMatch = heightRegex.firstMatch(this);

    // 두 값 모두 찾았을 경우에만 처리
    if (widthMatch != null && heightMatch != null) {
      final originalWidth = widthMatch.group(1)!;
      final originalHeight = heightMatch.group(1)!;

      // 숫자 부분과 단위 부분 분리
      final dimensionRegex = RegExp(r'^([\d.]+)(.*)$');

      final widthNumMatch = dimensionRegex.firstMatch(originalWidth);
      final heightNumMatch = dimensionRegex.firstMatch(originalHeight);

      if (widthNumMatch != null && heightNumMatch != null) {
        final widthNum = double.parse(widthNumMatch.group(1)!);
        final widthUnit = widthNumMatch.group(2)!;
        final heightNum = double.parse(heightNumMatch.group(1)!);
        final heightUnit = heightNumMatch.group(2)!;

        // scaleFactor 배로 곱하기
        final scaledWidth =
            (widthNum * scaleFactor).toStringAsFixed(3) + widthUnit;
        final scaledHeight =
            (heightNum * scaleFactor).toStringAsFixed(3) + heightUnit;

        // 새 값으로 교체
        var modifiedSvg = replaceFirst(widthRegex, 'width="$scaledWidth"');
        modifiedSvg =
            modifiedSvg.replaceFirst(heightRegex, 'height="$scaledHeight"');

        return modifiedSvg;
      }
    }

    // 매치되지 않으면 원본 반환
    return this;
  }

  /// 문자열에서 %로 둘러싸인 부분을 찾아 다국어 처리하는 확장 메서드
  String processTranslation() {
    // 정규 표현식을 사용하여 %로 둘러싸인 모든 부분 찾기
    final regex = RegExp(r'%([^%]+)%');
    final matches = regex.allMatches(this);

    // 매치된 부분이 없으면 원래 문자열 반환
    if (matches.isEmpty) {
      return this;
    }

    // 매치된 부분들을 번역하여 치환
    String result = this;
    for (var match in matches) {
      final key = match.group(1);
      if (key != null) {
        final translated = key.tr;
        result = result.replaceFirst('%$key%', translated);
      }
    }

    return result;
  }
}
